// functions/index.js
const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { setGlobalOptions } = require('firebase-functions/v2/options');
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

    if (!recipientId || recipientId === senderId) {
      console.log('⚠️ No valid recipient or recipient is same as sender');
      return null;
    }

    // Get sender name (optional)
    let senderName = 'New message';
    try {
      const senderDoc = await db.collection('Users').doc(senderId).get();
      if (senderDoc.exists) {
        const s = senderDoc.data();
        senderName = s?.displayName || s?.name || senderName;
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


