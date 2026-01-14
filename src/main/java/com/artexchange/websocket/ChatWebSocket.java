package com.artexchange.websocket;

import com.artexchange.dao.MessageDAO;
import com.artexchange.model.Message;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import jakarta.websocket.*;
import jakarta.websocket.server.PathParam;
import jakarta.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.Date;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Logger;

@ServerEndpoint("/chat/{userId}")
public class ChatWebSocket {
    private static final Logger logger = Logger.getLogger(ChatWebSocket.class.getName());
    private static final ConcurrentHashMap<String, Session> userSessions = new ConcurrentHashMap<>();
    private static final Gson gson = new Gson();
    private static final MessageDAO messageDAO = new MessageDAO();
    
    @OnOpen
    public void onOpen(Session session, @PathParam("userId") String userId) {
        userSessions.put(userId, session);
        logger.info("User connected: " + userId);
        
        // Send connection confirmation
        JsonObject response = new JsonObject();
        response.addProperty("type", "connection");
        response.addProperty("status", "connected");
        response.addProperty("userId", userId);
        
        try {
            session.getBasicRemote().sendText(gson.toJson(response));
        } catch (IOException e) {
            logger.severe("Error sending connection confirmation: " + e.getMessage());
        }
    }
    
    @OnMessage
    public void onMessage(String messageText, Session session, @PathParam("userId") String userId) {
        try {
            JsonObject messageJson = JsonParser.parseString(messageText).getAsJsonObject();
            String type = messageJson.get("type").getAsString();
            
            switch (type) {
                case "chat_message":
                    handleChatMessage(messageJson, userId);
                    break;
                case "typing":
                    handleTypingIndicator(messageJson, userId);
                    break;
                case "mark_read":
                    handleMarkRead(messageJson, userId);
                    break;
                default:
                    logger.warning("Unknown message type: " + type);
            }
            
        } catch (Exception e) {
            logger.severe("Error processing message: " + e.getMessage());
            sendErrorMessage(session, "Error processing message");
        }
    }
    
    @OnClose
    public void onClose(Session session, @PathParam("userId") String userId) {
        userSessions.remove(userId);
        logger.info("User disconnected: " + userId);
    }
    
    @OnError
    public void onError(Session session, Throwable throwable) {
        logger.severe("WebSocket error: " + throwable.getMessage());
    }
    
    private void handleChatMessage(JsonObject messageJson, String senderId) {
        try {
            String receiverId = messageJson.get("receiverId").getAsString();
            String content = messageJson.get("content").getAsString();
            String artworkId = messageJson.has("artworkId") ? 
                messageJson.get("artworkId").getAsString() : null;
            
            // Create message object
            Message message = new Message();
            message.setSenderId(senderId);
            message.setReceiverId(receiverId);
            message.setContent(content);
            message.setArtworkId(artworkId);
            message.setTimestamp(new Date());
            message.setRead(false);
            message.setMessageType(Message.MessageType.TEXT);
            
            // Save to database
            String messageId = messageDAO.createMessage(message);
            message.setId(messageId);
            
            // Prepare response
            JsonObject response = new JsonObject();
            response.addProperty("type", "new_message");
            response.addProperty("messageId", messageId);
            response.addProperty("senderId", senderId);
            response.addProperty("receiverId", receiverId);
            response.addProperty("content", content);
            response.addProperty("artworkId", artworkId);
            response.addProperty("timestamp", message.getTimestamp().getTime());
            response.addProperty("read", false);
            
            // Send to receiver if online
            Session receiverSession = userSessions.get(receiverId);
            if (receiverSession != null && receiverSession.isOpen()) {
                receiverSession.getBasicRemote().sendText(gson.toJson(response));
            }
            
            // Send confirmation to sender
            Session senderSession = userSessions.get(senderId);
            if (senderSession != null && senderSession.isOpen()) {
                JsonObject confirmation = new JsonObject();
                confirmation.addProperty("type", "message_sent");
                confirmation.addProperty("messageId", messageId);
                confirmation.addProperty("timestamp", message.getTimestamp().getTime());
                senderSession.getBasicRemote().sendText(gson.toJson(confirmation));
            }
            
        } catch (Exception e) {
            logger.severe("Error handling chat message: " + e.getMessage());
        }
    }
    
    private void handleTypingIndicator(JsonObject messageJson, String senderId) {
        try {
            String receiverId = messageJson.get("receiverId").getAsString();
            boolean isTyping = messageJson.get("isTyping").getAsBoolean();
            
            Session receiverSession = userSessions.get(receiverId);
            if (receiverSession != null && receiverSession.isOpen()) {
                JsonObject response = new JsonObject();
                response.addProperty("type", "typing_indicator");
                response.addProperty("senderId", senderId);
                response.addProperty("isTyping", isTyping);
                
                receiverSession.getBasicRemote().sendText(gson.toJson(response));
            }
            
        } catch (Exception e) {
            logger.severe("Error handling typing indicator: " + e.getMessage());
        }
    }
    
    private void handleMarkRead(JsonObject messageJson, String userId) {
        try {
            String messageId = messageJson.get("messageId").getAsString();
            
            // Mark message as read in database
            messageDAO.markAsRead(messageId);
            
            // Send confirmation
            Session userSession = userSessions.get(userId);
            if (userSession != null && userSession.isOpen()) {
                JsonObject response = new JsonObject();
                response.addProperty("type", "message_read");
                response.addProperty("messageId", messageId);
                
                userSession.getBasicRemote().sendText(gson.toJson(response));
            }
            
        } catch (Exception e) {
            logger.severe("Error marking message as read: " + e.getMessage());
        }
    }
    
    private void sendErrorMessage(Session session, String error) {
        try {
            JsonObject response = new JsonObject();
            response.addProperty("type", "error");
            response.addProperty("message", error);
            
            session.getBasicRemote().sendText(gson.toJson(response));
        } catch (IOException e) {
            logger.severe("Error sending error message: " + e.getMessage());
        }
    }
    
    // Utility method to send notifications to specific users
    public static void sendNotificationToUser(String userId, JsonObject notification) {
        Session userSession = userSessions.get(userId);
        if (userSession != null && userSession.isOpen()) {
            try {
                userSession.getBasicRemote().sendText(gson.toJson(notification));
            } catch (IOException e) {
                logger.severe("Error sending notification to user " + userId + ": " + e.getMessage());
            }
        }
    }
    
    // Check if user is online
    public static boolean isUserOnline(String userId) {
        Session session = userSessions.get(userId);
        return session != null && session.isOpen();
    }
}
