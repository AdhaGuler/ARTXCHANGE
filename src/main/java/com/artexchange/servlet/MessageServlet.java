package com.artexchange.servlet;

import com.artexchange.dao.MessageDAO;
import com.artexchange.dao.UserDAO;
import com.artexchange.model.Message;
import com.artexchange.model.User;
import com.artexchange.util.SessionUtil;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.logging.Logger;

@WebServlet("/api/messages/*")
public class MessageServlet extends HttpServlet {
    private static final Logger logger = Logger.getLogger(MessageServlet.class.getName());
    private final Gson gson = new Gson();
    private final MessageDAO messageDAO = new MessageDAO();
    private final UserDAO userDAO = new UserDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        // Check authentication
        String currentUserId = SessionUtil.getCurrentUserId(request);
        if (currentUserId == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            JsonObject error = new JsonObject();
            error.addProperty("error", "Authentication required");
            response.getWriter().write(gson.toJson(error));
            return;
        }
        
        String pathInfo = request.getPathInfo();
        
        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                // Get all conversations for user
                handleGetConversations(request, response, currentUserId);
            } else if (pathInfo.startsWith("/conversation/")) {
                // Get specific conversation
                String[] parts = pathInfo.split("/");
                if (parts.length >= 3) {
                    String otherUserId = parts[2];
                    String artworkId = request.getParameter("artworkId");
                    handleGetConversation(request, response, currentUserId, otherUserId, artworkId);
                }
            } else if (pathInfo.equals("/unread-count")) {
                // Get unread message count
                handleGetUnreadCount(request, response, currentUserId);
            }
        } catch (Exception e) {
            logger.severe("Error in MessageServlet GET: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JsonObject error = new JsonObject();
            error.addProperty("error", "Internal server error");
            response.getWriter().write(gson.toJson(error));
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        // Check authentication
        String currentUserId = SessionUtil.getCurrentUserId(request);
        if (currentUserId == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            JsonObject error = new JsonObject();
            error.addProperty("error", "Authentication required");
            response.getWriter().write(gson.toJson(error));
            return;
        }
        
        String pathInfo = request.getPathInfo();
        
        try {
            if (pathInfo != null && pathInfo.equals("/mark-read")) {
                handleMarkAsRead(request, response, currentUserId);
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                JsonObject error = new JsonObject();
                error.addProperty("error", "Endpoint not found");
                response.getWriter().write(gson.toJson(error));
            }
        } catch (Exception e) {
            logger.severe("Error in MessageServlet POST: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JsonObject error = new JsonObject();
            error.addProperty("error", "Internal server error");
            response.getWriter().write(gson.toJson(error));
        }
    }
    
    private void handleGetConversations(HttpServletRequest request, HttpServletResponse response, String userId)
            throws Exception {
        
        List<String> conversationPartners = messageDAO.getUserConversations(userId);
        JsonArray conversations = new JsonArray();
        
        for (String partnerId : conversationPartners) {
            // Handle SYSTEM notifications specially
            if ("SYSTEM".equals(partnerId)) {
                // Get all system messages for this user
                List<Message> systemMessages = messageDAO.getConversation(userId, "SYSTEM", null);
                
                if (!systemMessages.isEmpty()) {
                    JsonObject conversation = new JsonObject();
                    conversation.addProperty("partnerId", "SYSTEM");
                    conversation.addProperty("partnerName", "System Notifications");
                    conversation.addProperty("partnerAvatar", "/assets/images/default-avatar.svg");
                    
                    Message latestMessage = systemMessages.get(systemMessages.size() - 1);
                    conversation.addProperty("lastMessage", latestMessage.getContent());
                    conversation.addProperty("lastMessageTime", latestMessage.getTimestamp().getTime());
                    conversation.addProperty("lastMessageSenderId", latestMessage.getSenderId());
                    
                    // Count unread system messages
                    long unreadCount = systemMessages.stream()
                            .filter(m -> m.getReceiverId().equals(userId) && !m.isRead())
                            .count();
                    conversation.addProperty("unreadCount", unreadCount);
                    
                    conversations.add(conversation);
                }
            } else {
                // Handle regular user conversations
                User partner = userDAO.findById(partnerId);
                if (partner != null) {
                    // Get latest message in conversation
                    List<Message> messages = messageDAO.getConversation(userId, partnerId, null);
                    
                    JsonObject conversation = new JsonObject();
                    conversation.addProperty("partnerId", partnerId);
                    conversation.addProperty("partnerName", partner.getDisplayName());
                    conversation.addProperty("partnerAvatar", partner.getProfileImageUrl());
                    
                    if (!messages.isEmpty()) {
                        Message latestMessage = messages.get(messages.size() - 1);
                        conversation.addProperty("lastMessage", latestMessage.getContent());
                        conversation.addProperty("lastMessageTime", latestMessage.getTimestamp().getTime());
                        conversation.addProperty("lastMessageSenderId", latestMessage.getSenderId());
                    }
                    
                    // Count unread messages from this partner
                    long unreadCount = messages.stream()
                            .filter(m -> m.getReceiverId().equals(userId) && !m.isRead())
                            .count();
                    conversation.addProperty("unreadCount", unreadCount);
                    
                    conversations.add(conversation);
                }
            }
        }
        
        JsonObject jsonResponse = new JsonObject();
        jsonResponse.addProperty("success", true);
        jsonResponse.add("conversations", conversations);
        
        response.getWriter().write(gson.toJson(jsonResponse));
    }
    
    private void handleGetConversation(HttpServletRequest request, HttpServletResponse response, 
                                     String userId, String otherUserId, String artworkId) throws Exception {
        
        List<Message> messages = messageDAO.getConversation(userId, otherUserId, artworkId);
        JsonArray messagesArray = new JsonArray();
        
        for (Message message : messages) {
            JsonObject messageObj = new JsonObject();
            messageObj.addProperty("id", message.getId());
            messageObj.addProperty("senderId", message.getSenderId());
            messageObj.addProperty("receiverId", message.getReceiverId());
            messageObj.addProperty("content", message.getContent());
            messageObj.addProperty("timestamp", message.getTimestamp().getTime());
            messageObj.addProperty("read", message.isRead());
            messageObj.addProperty("artworkId", message.getArtworkId());
            messageObj.addProperty("messageType", message.getMessageType().toString());
            
            messagesArray.add(messageObj);
        }
        
        JsonObject jsonResponse = new JsonObject();
        jsonResponse.addProperty("success", true);
        jsonResponse.add("messages", messagesArray);
        
        response.getWriter().write(gson.toJson(jsonResponse));
    }
    
    private void handleGetUnreadCount(HttpServletRequest request, HttpServletResponse response, String userId)
            throws Exception {
        
        long unreadCount = messageDAO.getUnreadCount(userId);
        
        JsonObject jsonResponse = new JsonObject();
        jsonResponse.addProperty("success", true);
        jsonResponse.addProperty("unreadCount", unreadCount);
        
        response.getWriter().write(gson.toJson(jsonResponse));
    }
    
    private void handleMarkAsRead(HttpServletRequest request, HttpServletResponse response, String userId)
            throws Exception {
        
        String messageId = request.getParameter("messageId");
        
        if (messageId == null || messageId.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            JsonObject error = new JsonObject();
            error.addProperty("error", "Message ID is required");
            response.getWriter().write(gson.toJson(error));
            return;
        }
        
        boolean success = messageDAO.markAsRead(messageId);
        
        JsonObject jsonResponse = new JsonObject();
        jsonResponse.addProperty("success", success);
        
        if (success) {
            jsonResponse.addProperty("message", "Message marked as read");
        } else {
            jsonResponse.addProperty("message", "Failed to mark message as read");
        }
        
        response.getWriter().write(gson.toJson(jsonResponse));
    }
}
