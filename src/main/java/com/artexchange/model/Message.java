package com.artexchange.model;

import java.time.LocalDateTime;
import java.util.Objects;

/**
 * Message model for in-platform messaging system
 */
public class Message {
    private String messageId;
    private String conversationId;
    private String senderId;
    private String senderName;
    private String receiverId;
    private String receiverName;
    private String content;
    private MessageType type;
    private boolean isRead;
    private LocalDateTime sentAt;
    private LocalDateTime readAt;
    private String artworkId; // Optional: if message is related to an artwork
    private String attachmentUrl; // Optional: for image attachments
    
    public enum MessageType {
        TEXT, IMAGE, SYSTEM, ARTWORK_INQUIRY, OFFER, BID_NOTIFICATION, PURCHASE_NOTIFICATION
    }
    
    // Constructors
    public Message() {
        this.isRead = false;
        this.sentAt = LocalDateTime.now();
        this.type = MessageType.TEXT;
    }
    
    public Message(String senderId, String receiverId, String content) {
        this();
        this.senderId = senderId;
        this.receiverId = receiverId;
        this.content = content;
    }
    
    public Message(String conversationId, String senderId, String receiverId, String content) {
        this(senderId, receiverId, content);
        this.conversationId = conversationId;
    }
    
    // Getters and Setters
    public String getMessageId() { return messageId; }
    public void setMessageId(String messageId) { this.messageId = messageId; }
    
    public String getConversationId() { return conversationId; }
    public void setConversationId(String conversationId) { this.conversationId = conversationId; }
    
    public String getSenderId() { return senderId; }
    public void setSenderId(String senderId) { this.senderId = senderId; }
    
    public String getSenderName() { return senderName; }
    public void setSenderName(String senderName) { this.senderName = senderName; }
    
    public String getReceiverId() { return receiverId; }
    public void setReceiverId(String receiverId) { this.receiverId = receiverId; }
    
    public String getReceiverName() { return receiverName; }
    public void setReceiverName(String receiverName) { this.receiverName = receiverName; }
    
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    
    public MessageType getType() { return type; }
    public void setType(MessageType type) { this.type = type; }
    
    public boolean isRead() { return isRead; }
    public void setRead(boolean read) { 
        this.isRead = read;
        if (read && readAt == null) {
            this.readAt = LocalDateTime.now();
        }
    }
    
    public LocalDateTime getSentAt() { return sentAt; }
    public void setSentAt(LocalDateTime sentAt) { this.sentAt = sentAt; }
    
    public LocalDateTime getReadAt() { return readAt; }
    public void setReadAt(LocalDateTime readAt) { this.readAt = readAt; }
    
    public String getArtworkId() { return artworkId; }
    public void setArtworkId(String artworkId) { this.artworkId = artworkId; }
    
    public String getAttachmentUrl() { return attachmentUrl; }
    public void setAttachmentUrl(String attachmentUrl) { this.attachmentUrl = attachmentUrl; }
    
    // Compatibility methods for DAO usage
    public String getId() { return messageId; }
    public void setId(String id) { this.messageId = id; }
    
    public java.util.Date getTimestamp() { 
        return sentAt != null ? java.sql.Timestamp.valueOf(sentAt) : null; 
    }
    public void setTimestamp(java.util.Date timestamp) { 
        this.sentAt = timestamp != null ? timestamp.toInstant().atZone(java.time.ZoneId.systemDefault()).toLocalDateTime() : null; 
    }
    
    public MessageType getMessageType() { return type; }
    public void setMessageType(MessageType type) { this.type = type; }
    
    // Utility methods
    public boolean hasAttachment() {
        return attachmentUrl != null && !attachmentUrl.trim().isEmpty();
    }
    
    public boolean isArtworkRelated() {
        return artworkId != null && !artworkId.trim().isEmpty();
    }
    
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Message message = (Message) o;
        return Objects.equals(messageId, message.messageId);
    }
    
    @Override
    public int hashCode() {
        return Objects.hash(messageId);
    }
    
    @Override
    public String toString() {
        return "Message{" +
                "messageId='" + messageId + '\'' +
                ", conversationId='" + conversationId + '\'' +
                ", senderId='" + senderId + '\'' +
                ", content='" + content + '\'' +
                ", type=" + type +
                ", isRead=" + isRead +
                ", sentAt=" + sentAt +
                '}';
    }
}
