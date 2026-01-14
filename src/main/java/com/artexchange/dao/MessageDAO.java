package com.artexchange.dao;

import com.artexchange.model.Message;
import com.google.cloud.firestore.*;
import com.google.firebase.cloud.FirestoreClient;
import java.util.*;
import java.util.concurrent.ExecutionException;
import java.util.logging.Logger;

public class MessageDAO {
    private static final Logger logger = Logger.getLogger(MessageDAO.class.getName());
    private static final String COLLECTION_NAME = "messages";
    
    private Firestore getFirestore() {
        return FirestoreClient.getFirestore();
    }
    
    public String createMessage(Message message) throws ExecutionException, InterruptedException {
        Firestore db = getFirestore();
        
        Map<String, Object> messageData = new HashMap<>();
        messageData.put("senderId", message.getSenderId());
        messageData.put("receiverId", message.getReceiverId());
        messageData.put("artworkId", message.getArtworkId());
        messageData.put("content", message.getContent());
        messageData.put("timestamp", message.getTimestamp());
        messageData.put("read", message.isRead());
        messageData.put("messageType", message.getMessageType().toString());
        
        DocumentReference docRef = db.collection(COLLECTION_NAME).document();
        docRef.set(messageData).get();
        
        logger.info("Message created with ID: " + docRef.getId());
        return docRef.getId();
    }
    
    public List<Message> getConversation(String userId1, String userId2, String artworkId) 
            throws ExecutionException, InterruptedException {
        Firestore db = getFirestore();
        
        Query query = db.collection(COLLECTION_NAME)
                .whereIn("senderId", Arrays.asList(userId1, userId2))
                .whereIn("receiverId", Arrays.asList(userId1, userId2));
        
        if (artworkId != null && !artworkId.isEmpty()) {
            query = query.whereEqualTo("artworkId", artworkId);
        }
        
        QuerySnapshot querySnapshot = query.orderBy("timestamp").get().get();
        
        List<Message> messages = new ArrayList<>();
        for (QueryDocumentSnapshot document : querySnapshot.getDocuments()) {
            Message message = documentToMessage(document);
            if (message != null) {
                messages.add(message);
            }
        }
        
        return messages;
    }
    
    public List<Message> getUserMessages(String userId) throws ExecutionException, InterruptedException {
        Firestore db = getFirestore();
        
        // Get messages where user is sender or receiver
        Query senderQuery = db.collection(COLLECTION_NAME)
                .whereEqualTo("senderId", userId);
        Query receiverQuery = db.collection(COLLECTION_NAME)
                .whereEqualTo("receiverId", userId);
        
        List<Message> allMessages = new ArrayList<>();
        
        // Execute both queries
        QuerySnapshot senderSnapshot = senderQuery.get().get();
        QuerySnapshot receiverSnapshot = receiverQuery.get().get();
        
        // Process sender messages
        for (QueryDocumentSnapshot document : senderSnapshot.getDocuments()) {
            Message message = documentToMessage(document);
            if (message != null) {
                allMessages.add(message);
            }
        }
        
        // Process receiver messages
        for (QueryDocumentSnapshot document : receiverSnapshot.getDocuments()) {
            Message message = documentToMessage(document);
            if (message != null) {
                allMessages.add(message);
            }
        }
        
        // Sort by timestamp
        allMessages.sort((m1, m2) -> m2.getTimestamp().compareTo(m1.getTimestamp()));
        
        return allMessages;
    }
    
    public boolean markAsRead(String messageId) throws ExecutionException, InterruptedException {
        Firestore db = getFirestore();
        
        DocumentReference docRef = db.collection(COLLECTION_NAME).document(messageId);
        docRef.update("read", true).get();
        
        logger.info("Message marked as read: " + messageId);
        return true;
    }
    
    public long getUnreadCount(String userId) throws ExecutionException, InterruptedException {
        Firestore db = getFirestore();
        
        Query query = db.collection(COLLECTION_NAME)
                .whereEqualTo("receiverId", userId)
                .whereEqualTo("read", false);
        
        QuerySnapshot querySnapshot = query.get().get();
        return querySnapshot.size();
    }
    
    public List<String> getUserConversations(String userId) throws ExecutionException, InterruptedException {
        Firestore db = getFirestore();
        
        Set<String> conversationPartners = new HashSet<>();
        
        // Get all messages where user is involved
        Query senderQuery = db.collection(COLLECTION_NAME)
                .whereEqualTo("senderId", userId);
        Query receiverQuery = db.collection(COLLECTION_NAME)
                .whereEqualTo("receiverId", userId);
        
        QuerySnapshot senderSnapshot = senderQuery.get().get();
        QuerySnapshot receiverSnapshot = receiverQuery.get().get();
        
        // Extract unique conversation partners
        for (QueryDocumentSnapshot document : senderSnapshot.getDocuments()) {
            String receiverId = document.getString("receiverId");
            if (receiverId != null && !receiverId.equals(userId)) {
                conversationPartners.add(receiverId);
            }
        }
        
        for (QueryDocumentSnapshot document : receiverSnapshot.getDocuments()) {
            String senderId = document.getString("senderId");
            if (senderId != null && !senderId.equals(userId)) {
                conversationPartners.add(senderId);
            }
        }
        
        return new ArrayList<>(conversationPartners);
    }
    
    private Message documentToMessage(QueryDocumentSnapshot document) {
        try {
            Message message = new Message();
            message.setId(document.getId());
            message.setSenderId(document.getString("senderId"));
            message.setReceiverId(document.getString("receiverId"));
            message.setArtworkId(document.getString("artworkId"));
            message.setContent(document.getString("content"));
            message.setTimestamp(document.getDate("timestamp"));
            message.setRead(document.getBoolean("read"));
            
            String messageType = document.getString("messageType");
            if (messageType != null) {
                message.setMessageType(Message.MessageType.valueOf(messageType));
            }
            
            return message;
        } catch (Exception e) {
            logger.severe("Error converting document to Message: " + e.getMessage());
            return null;
        }
    }
}
