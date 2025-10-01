importScripts("https://www.gstatic.com/firebasejs/7.20.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/7.20.0/firebase-messaging.js");

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

// Optional:
messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});