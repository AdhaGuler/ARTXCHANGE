package com.artexchange.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Purchase model representing completed artwork purchases
 */
public class Purchase {
    private String purchaseId;
    private String artworkId;
    private String buyerId;
    private String sellerId; // artistId
    private BigDecimal purchasePrice;
    private LocalDateTime purchaseDate;
    private String status; // PENDING, COMPLETED, CANCELLED, REFUNDED
    private String paymentMethod;
    private String transactionId;
    private String shippingAddress;
    private BigDecimal shippingCost;
    private String notes;
    
    // Payment deadline fields for auction wins
    private LocalDateTime paymentDeadline; // 24 hours from auction end
    private boolean paymentExpired; // True if payment deadline has passed
    private LocalDateTime paidAt; // Timestamp when payment was completed
    
    // Constructors
    public Purchase() {
        this.purchaseDate = LocalDateTime.now();
        this.status = "PENDING";
    }
    
    public Purchase(String artworkId, String buyerId, String sellerId, BigDecimal purchasePrice) {
        this();
        this.artworkId = artworkId;
        this.buyerId = buyerId;
        this.sellerId = sellerId;
        this.purchasePrice = purchasePrice;
    }
    
    // Getters and Setters
    public String getPurchaseId() {
        return purchaseId;
    }
    
    public void setPurchaseId(String purchaseId) {
        this.purchaseId = purchaseId;
    }
    
    public String getArtworkId() {
        return artworkId;
    }
    
    public void setArtworkId(String artworkId) {
        this.artworkId = artworkId;
    }
    
    public String getBuyerId() {
        return buyerId;
    }
    
    public void setBuyerId(String buyerId) {
        this.buyerId = buyerId;
    }
    
    public String getSellerId() {
        return sellerId;
    }
    
    public void setSellerId(String sellerId) {
        this.sellerId = sellerId;
    }
    
    public BigDecimal getPurchasePrice() {
        return purchasePrice;
    }
    
    public void setPurchasePrice(BigDecimal purchasePrice) {
        this.purchasePrice = purchasePrice;
    }
    
    public LocalDateTime getPurchaseDate() {
        return purchaseDate;
    }
    
    public void setPurchaseDate(LocalDateTime purchaseDate) {
        this.purchaseDate = purchaseDate;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public String getPaymentMethod() {
        return paymentMethod;
    }
    
    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }
    
    public String getTransactionId() {
        return transactionId;
    }
    
    public void setTransactionId(String transactionId) {
        this.transactionId = transactionId;
    }
    
    public String getShippingAddress() {
        return shippingAddress;
    }
    
    public void setShippingAddress(String shippingAddress) {
        this.shippingAddress = shippingAddress;
    }
    
    public BigDecimal getShippingCost() {
        return shippingCost;
    }
    
    public void setShippingCost(BigDecimal shippingCost) {
        this.shippingCost = shippingCost;
    }
    
    public String getNotes() {
        return notes;
    }
    
    public void setNotes(String notes) {
        this.notes = notes;
    }
    
    public LocalDateTime getPaymentDeadline() {
        return paymentDeadline;
    }
    
    public void setPaymentDeadline(LocalDateTime paymentDeadline) {
        this.paymentDeadline = paymentDeadline;
    }
    
    public boolean isPaymentExpired() {
        return paymentExpired;
    }
    
    public void setPaymentExpired(boolean paymentExpired) {
        this.paymentExpired = paymentExpired;
    }
    
    public LocalDateTime getPaidAt() {
        return paidAt;
    }
    
    public void setPaidAt(LocalDateTime paidAt) {
        this.paidAt = paidAt;
    }
    
    @Override
    public String toString() {
        return "Purchase{" +
                "purchaseId='" + purchaseId + '\'' +
                ", artworkId='" + artworkId + '\'' +
                ", buyerId='" + buyerId + '\'' +
                ", sellerId='" + sellerId + '\'' +
                ", purchasePrice=" + purchasePrice +
                ", purchaseDate=" + purchaseDate +
                ", status='" + status + '\'' +
                '}';
    }
}
