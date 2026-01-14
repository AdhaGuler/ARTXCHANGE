const firebaseConfig = {
  apiKey: "AIzaSyCtsUCthyR4r0YlthaI1Wlr_aQ6EImQ-a0",
  authDomain: "artxchange-a7dea.firebaseapp.com",
  projectId: "artxchange-a7dea",
  storageBucket: "artxchange-a7dea.firebasestorage.app",
  messagingSenderId: "586824104024",
  appId: "1:586824104024:web:4ba1c15206a2b246f5b22d"
};
// Initialize Firebase
firebase.initializeApp(firebaseConfig);

// Get Firebase services
const auth = firebase.auth();

// Export for use in other files
window.firebaseAuth = auth;
