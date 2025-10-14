// functions/index.js
const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { setGlobalOptions } = require('firebase-functions/v2/options');
const { onDocumentUpdated } = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

setGlobalOptions({ memory: '256MB', timeoutSeconds: 60 });

exports.sendNewMessageNotification = onDocumentCreated(
  'chat_rooms/{chatId}/messages/{messageId}',
  async (event) => {
    console.log('🔥 Triggered sendNewMessageNotification', event.params);

    const snap = event.data;
    if (!snap) {
      console.log('❌ No snapshot data');
      return null;
    }

    const messageData = snap.data();
    console.log('📩 Message data:', messageData);

    if (!messageData) return null;

    const chatId = event.params.chatId;
    const messageId = event.params.messageId;
    const senderId = messageData.senderId;
    const recipientId = messageData.receiverId || messageData.to;
    const messageStatus = messageData.messageStatus;

    if (!recipientId || recipientId === senderId) {
      console.log('⚠️ No valid recipient or recipient is same as sender');
      return null;
    }
    if (messageStatus !== "sent") {
      console.log("Notification suppressed because status is not 'sent'");
      return null;
    }

    // Get sender name (optional)
    let senderName = 'New message';
    try {
      const senderDoc = await db.collection('Users').doc(senderId).get();
      if (senderDoc.exists) {
        const s = senderDoc.data();
        senderName = s?.email || s?.name || senderName;
      }
    } catch (e) {
      console.error('⚠️ Could not fetch sender info:', e);
    }

    // Get recipient tokens
    const tokensSnap = await db
      .collection('Users')
      .doc(recipientId)
      .collection('fcmTokens')
      .get();

    if (tokensSnap.empty) {
      console.log('⚠️ No tokens for recipient:', recipientId);
      return null;
    }

    const tokens = tokensSnap.docs.map((doc) => doc.id);
    console.log('📲 Recipient tokens:', tokens);

    const payload = {
      notification: {
        title: senderName,
        body: messageData.text ? String(messageData.text).slice(0, 120) : 'Sent you a message',
      },
      data: {
        chatId,
        messageId,
        senderId,
        messageStatus,
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
    };

    const sendPromises = tokens.map((token) => {
      return admin.messaging().send({ ...payload, token });
    });

    const results = await Promise.allSettled(sendPromises);

    const invalidTokens = [];
    results.forEach((res, idx) => {
      if (res.status === 'rejected') {
        const err = res.reason;
        console.error('❌ Push send error for token', tokens[idx], err);
        if (
          err.code === 'messaging/invalid-registration-token' ||
          err.code === 'messaging/registration-token-not-registered'
        ) {
          invalidTokens.push(tokens[idx]);
        }
      }
    });

    if (invalidTokens.length > 0) {
      const batch = db.batch();
      invalidTokens.forEach((token) => {
        const ref = db
          .collection('Users')
          .doc(recipientId)
          .collection('fcmTokens')
          .doc(token);
        batch.delete(ref);
      });
      await batch.commit();
      console.log('🧹 Cleaned up invalid tokens:', invalidTokens);
    }

    return null;
  }
);





exports.notifyOnMessageStatusChange = onDocumentUpdated(
  'chat_rooms/{chatId}/messages/{messageId}',
  async (event) => {
    console.log('🔄 Triggered notifyOnMessageStatusChange', event.params);

    const beforeData = event.data?.before?.data();
    const afterData = event.data?.after?.data();

    if (!beforeData || !afterData) {
      console.log('❌ Missing before/after data');
      return null;
    }

    const prevStatus = beforeData.messageStatus;
    const newStatus = afterData.messageStatus;

    // 👇 Only continue if status actually changed
    if (prevStatus === newStatus) {
      console.log('ℹ️ messageStatus unchanged, skipping...');
      return null;
    }

    console.log(`📌 messageStatus changed: ${prevStatus} → ${newStatus}`);

    // 🚨 We're only interested in uploading → sent
    if (!(prevStatus === 'uploading' && newStatus === 'sent')) {
      console.log('ℹ️ Not the transition we care about, skipping...');
      return null;
    }

    const chatId = event.params.chatId;
    const messageId = event.params.messageId;
    const senderId = afterData.senderId;
    const recipientId = afterData.receiverId || afterData.to;
    const messageType = afterData.type;

    if (!recipientId || recipientId === senderId) {
      console.log('⚠️ No valid recipient or recipient is same as sender');
      return null;
    }

    // Fetch recipient FCM tokens
    const tokensSnap = await db
      .collection('Users')
      .doc(recipientId)
      .collection('fcmTokens')
      .get();

    if (tokensSnap.empty) {
      console.log('⚠️ No tokens for recipient:', recipientId);
      return null;
    }

    const tokens = tokensSnap.docs.map((doc) => doc.id);
    console.log('📲 Recipient tokens:', tokens);

    // Create notification payload
    const payload = {
      notification: {
        title: '[['+messageType+']]',
        body: '',
      },
      data: {
        chatId,
        messageId,
        senderId,
        type: 'MESSAGE_STATUS_UPDATE',
        newStatus,
      },
    };

    const sendPromises = tokens.map((token) =>
      admin.messaging().send({ ...payload, token })
    );

    const results = await Promise.allSettled(sendPromises);
    const invalidTokens = [];

    results.forEach((res, idx) => {
      if (res.status === 'rejected') {
        const err = res.reason;
        console.error('❌ Push send error for token', tokens[idx], err);
        if (
          err.code === 'messaging/invalid-registration-token' ||
          err.code === 'messaging/registration-token-not-registered'
        ) {
          invalidTokens.push(tokens[idx]);
        }
      }
    });

    // 🧹 Clean up invalid tokens
    if (invalidTokens.length > 0) {
      const batch = db.batch();
      invalidTokens.forEach((token) => {
        const ref = db
          .collection('Users')
          .doc(recipientId)
          .collection('fcmTokens')
          .doc(token);
        batch.delete(ref);
      });
      await batch.commit();
      console.log('🧹 Cleaned up invalid tokens:', invalidTokens);
    }

    return null;
  }
);



