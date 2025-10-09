// // web/firebase-messaging-sw.js
// importScripts('https://www.gstatic.com/firebasejs/9.6.11/firebase-app-compat.js');
// importScripts('https://www.gstatic.com/firebasejs/9.6.11/firebase-messaging-compat.js');

// firebase.initializeApp({
//     apiKey: "AIzaSyCvL_aGl8JDYO-mdlolYuM1Mi8pUHQCFEo",
//     authDomain: "msta-pits-dev.firebaseapp.com",
//     databaseURL: "https://msta-pits-dev-default-rtdb.firebaseio.com",
//     projectId: "msta-pits-dev",
//     storageBucket: "msta-pits-dev.firebasestorage.app",
//     messagingSenderId: "302427474416",
//     appId: "1:302427474416:web:37f174d9f63bcd2b96f535",
//     measurementId: "G-5SLTPT801Y",
// });

// // Retrieve firebase messaging
// const messaging = firebase.messaging();

// // Handle background messages
// messaging.onBackgroundMessage((payload) => {
//   console.log('[firebase-messaging-sw.js] Received background message ', payload);
//   const notificationTitle = payload.notification.title;
//   const notificationOptions = {
//     body: payload.notification.body,
//     icon: '/icons/Icon-192.png', // optional
//   };

//   self.registration.showNotification(notificationTitle, notificationOptions);
// });
