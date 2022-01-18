importScripts('https://www.gstatic.com/firebasejs/8.6.1/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.6.1/firebase-messaging.js');

const firebaseConfig = {
    apiKey: "AIzaSyD7GlAAMOY7o5oXm2Hx9yYSnAaA9rC3yAE",
    authDomain: "pragti.firebaseapp.com",
    databaseURL: "https://pragti.firebaseio.com",
    projectId: "pragti",
    storageBucket: "pragti.appspot.com",
    messagingSenderId: "521852175920",
    appId: "1:521852175920:web:fe5ac268972a95fd240ff5",
    measurementId: "G-RB53G8EGJQ"
};

firebase.initializeApp(firebaseConfig);

const messaging = firebase.messaging();




