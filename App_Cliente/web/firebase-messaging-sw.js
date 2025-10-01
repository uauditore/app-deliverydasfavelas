importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
    apiKey: "AIzaSyDaH01xVUiw0vCfMurVMM8q-oSGLVwYQak",
    authDomain: "deliveryfavela-app.firebaseapp.com",
    databaseURL: "https://deliveryfavela-app-default-rtdb.firebaseio.com",
    projectId: "deliveryfavela-app",
    storageBucket: "deliveryfavela-app.firebasestorage.app",
    messagingSenderId: "519142677304",
    appId: "1:519142677304:web:3303403d9f06c859853fcd",
    measurementId: "G-F97BT0QLJL"
});

const messaging = firebase.messaging();

messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            const title = payload.notification.title;
            const options = {
                body: payload.notification.score
              };
            return registration.showNotification(title, options);
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});