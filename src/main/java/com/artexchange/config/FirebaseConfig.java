package com.artexchange.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.cloud.firestore.Firestore;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.cloud.FirestoreClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.io.IOException;
import java.io.InputStream;

/**
 * Firebase configuration and initialization
 */
@WebListener
public class FirebaseConfig implements ServletContextListener {
    private static final Logger logger = LoggerFactory.getLogger(FirebaseConfig.class);
    private static FirebaseApp firebaseApp;
    private static Firestore firestore;
    
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        try {
            initializeFirebase();
            logger.info("Firebase initialized successfully");
        } catch (Exception e) {
            logger.error("Failed to initialize Firebase", e);
            throw new RuntimeException("Firebase initialization failed", e);
        }
    }
    
    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (firebaseApp != null) {
            firebaseApp.delete();
            logger.info("Firebase app deleted");
        }
    }
    
    private void initializeFirebase() throws IOException {
        if (firebaseApp == null) {
            GoogleCredentials credentials;
            String projectId = "artxchange-a7dea"; // Use the correct project ID
            
            // Try to load service account from resources first
            InputStream serviceAccount = getClass().getClassLoader()
                    .getResourceAsStream("firebase-service-account.json");
            
            if (serviceAccount != null) {
                logger.info("Loading Firebase credentials from service account file");
                credentials = GoogleCredentials.fromStream(serviceAccount);
            } else {
                // Fallback to Application Default Credentials (for production/cloud deployment)
                logger.info("Loading Firebase credentials from Application Default Credentials");
                credentials = GoogleCredentials.getApplicationDefault();
            }
            
            FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(credentials)
                    .setProjectId(projectId)
                    .build();
            
            firebaseApp = FirebaseApp.initializeApp(options);
            firestore = FirestoreClient.getFirestore();
            
            logger.info("Firebase initialized with project ID: " + projectId);
        }
    }
    
    public static FirebaseApp getFirebaseApp() {
        return firebaseApp;
    }
    
    public static Firestore getFirestore() {
        return firestore;
    }
    
    public static FirebaseAuth getFirebaseAuth() {
        return FirebaseAuth.getInstance(firebaseApp);
    }
}