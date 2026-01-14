package com.artexchange.dao;

import com.artexchange.config.FirebaseConfig;
import com.artexchange.model.Purchase;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;

/**
 * Data Access Object for Purchase operations with Firestore
 */
public class PurchaseDAO {
    private static final Logger logger = LoggerFactory.getLogger(PurchaseDAO.class);
    private static final String COLLECTION_NAME = "purchases";
    private final Firestore firestore;
    
    public PurchaseDAO() {
        this.firestore = FirebaseConfig.getFirestore();
    }
    
    /**
     * Save purchase to Firestore
     */
    public String savePurchase(Purchase purchase) throws ExecutionException, InterruptedException {
        try {
            // Generate ID if not provided
            if (purchase.getPurchaseId() == null || purchase.getPurchaseId().isEmpty()) {
                DocumentReference docRef = firestore.collection(COLLECTION_NAME).document();
                purchase.setPurchaseId(docRef.getId());
            }
            
            Map<String, Object> purchaseData = purchaseToMap(purchase);
            
            ApiFuture<WriteResult> result = firestore.collection(COLLECTION_NAME)
                .document(purchase.getPurchaseId())
                .set(purchaseData);
            
            result.get();
            logger.info("Purchase saved successfully: {}", purchase.getPurchaseId());
            return purchase.getPurchaseId();
            
        } catch (Exception e) {
            logger.error("Error saving purchase: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Find purchase by ID
     */
    public Purchase findById(String purchaseId) throws ExecutionException, InterruptedException {
        try {
            DocumentReference docRef = firestore.collection(COLLECTION_NAME).document(purchaseId);
            ApiFuture<DocumentSnapshot> future = docRef.get();
            DocumentSnapshot document = future.get();
            
            if (document.exists()) {
                return mapToPurchase(document);
            }
            return null;
            
        } catch (Exception e) {
            logger.error("Error finding purchase by ID: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Find purchases by buyer ID
     */
    public List<Purchase> findByBuyerId(String buyerId) throws ExecutionException, InterruptedException {
        try {
            // First try with orderBy - if index doesn't exist, Firestore will throw an error
            Query query = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("buyerId", buyerId)
                .orderBy("purchaseDate", Query.Direction.DESCENDING);
            
            try {
                ApiFuture<QuerySnapshot> querySnapshot = query.get();
                List<QueryDocumentSnapshot> documents = querySnapshot.get().getDocuments();
                
                List<Purchase> purchases = new ArrayList<>();
                for (DocumentSnapshot doc : documents) {
                    try {
                        Purchase purchase = mapToPurchase(doc);
                        if (purchase != null) {
                            purchases.add(purchase);
                        }
                    } catch (Exception e) {
                        logger.warn("Error mapping purchase document {}: {}", doc.getId(), e.getMessage());
                    }
                }
                
                return purchases;
                
            } catch (Exception orderByError) {
                // If orderBy fails (likely due to missing index), fetch without ordering
                logger.warn("OrderBy failed, fetching without ordering: {}", orderByError.getMessage());
                Query simpleQuery = firestore.collection(COLLECTION_NAME)
                    .whereEqualTo("buyerId", buyerId);
                
                ApiFuture<QuerySnapshot> querySnapshot = simpleQuery.get();
                List<QueryDocumentSnapshot> documents = querySnapshot.get().getDocuments();
                
                List<Purchase> purchases = new ArrayList<>();
                for (DocumentSnapshot doc : documents) {
                    try {
                        Purchase purchase = mapToPurchase(doc);
                        if (purchase != null) {
                            purchases.add(purchase);
                        }
                    } catch (Exception e) {
                        logger.warn("Error mapping purchase document {}: {}", doc.getId(), e.getMessage());
                    }
                }
                
                // Sort in memory
                purchases.sort((p1, p2) -> {
                    if (p1.getPurchaseDate() == null && p2.getPurchaseDate() == null) return 0;
                    if (p1.getPurchaseDate() == null) return 1;
                    if (p2.getPurchaseDate() == null) return -1;
                    return p2.getPurchaseDate().compareTo(p1.getPurchaseDate());
                });
                
                return purchases;
            }
            
        } catch (Exception e) {
            logger.error("Error finding purchases by buyer: {}", e.getMessage(), e);
            // Return empty list instead of throwing to prevent 500 error
            return new ArrayList<>();
        }
    }
    
    /**
     * Find purchases by seller ID
     */
    public List<Purchase> findBySellerId(String sellerId) throws ExecutionException, InterruptedException {
        try {
            // First try with orderBy - if index doesn't exist, Firestore will throw an error
            Query query = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("sellerId", sellerId)
                .orderBy("purchaseDate", Query.Direction.DESCENDING);
            
            try {
                ApiFuture<QuerySnapshot> querySnapshot = query.get();
                List<QueryDocumentSnapshot> documents = querySnapshot.get().getDocuments();
                
                List<Purchase> purchases = new ArrayList<>();
                for (DocumentSnapshot doc : documents) {
                    try {
                        Purchase purchase = mapToPurchase(doc);
                        if (purchase != null) {
                            purchases.add(purchase);
                        }
                    } catch (Exception e) {
                        logger.warn("Error mapping purchase document {}: {}", doc.getId(), e.getMessage());
                    }
                }
                
                return purchases;
                
            } catch (Exception orderByError) {
                // If orderBy fails (likely due to missing index), fetch without ordering
                logger.warn("OrderBy failed for seller purchases, fetching without ordering: {}", orderByError.getMessage());
                Query simpleQuery = firestore.collection(COLLECTION_NAME)
                    .whereEqualTo("sellerId", sellerId);
                
                ApiFuture<QuerySnapshot> querySnapshot = simpleQuery.get();
                List<QueryDocumentSnapshot> documents = querySnapshot.get().getDocuments();
                
                List<Purchase> purchases = new ArrayList<>();
                for (DocumentSnapshot doc : documents) {
                    try {
                        Purchase purchase = mapToPurchase(doc);
                        if (purchase != null) {
                            purchases.add(purchase);
                        }
                    } catch (Exception e) {
                        logger.warn("Error mapping purchase document {}: {}", doc.getId(), e.getMessage());
                    }
                }
                
                // Sort in memory
                purchases.sort((p1, p2) -> {
                    if (p1.getPurchaseDate() == null && p2.getPurchaseDate() == null) return 0;
                    if (p1.getPurchaseDate() == null) return 1;
                    if (p2.getPurchaseDate() == null) return -1;
                    return p2.getPurchaseDate().compareTo(p1.getPurchaseDate());
                });
                
                return purchases;
            }
            
        } catch (Exception e) {
            logger.error("Error finding purchases by seller: {}", e.getMessage(), e);
            // Return empty list instead of throwing to prevent 500 error
            return new ArrayList<>();
        }
    }
    
    /**
     * Find purchase by artwork ID
     */
    public Purchase findByArtworkId(String artworkId) throws ExecutionException, InterruptedException {
        try {
            Query query = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("artworkId", artworkId)
                .limit(1);
            
            ApiFuture<QuerySnapshot> querySnapshot = query.get();
            List<QueryDocumentSnapshot> documents = querySnapshot.get().getDocuments();
            
            if (!documents.isEmpty()) {
                return mapToPurchase(documents.get(0));
            }
            return null;
            
        } catch (Exception e) {
            logger.error("Error finding purchase by artwork: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Update purchase status
     */
    public void updatePurchaseStatus(String purchaseId, String status) throws ExecutionException, InterruptedException {
        try {
            Map<String, Object> updates = new HashMap<>();
            updates.put("status", status);
            
            ApiFuture<WriteResult> result = firestore.collection(COLLECTION_NAME)
                .document(purchaseId)
                .update(updates);
            
            result.get();
            logger.info("Purchase status updated: {} -> {}", purchaseId, status);
            
        } catch (Exception e) {
            logger.error("Error updating purchase status: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Get purchase count for a user (buyer)
     */
    public long getUserPurchaseCount(String buyerId) throws ExecutionException, InterruptedException {
        try {
            Query query = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("buyerId", buyerId);
            
            QuerySnapshot querySnapshot = query.get().get();
            return querySnapshot.size();
            
        } catch (Exception e) {
            logger.error("Error getting user purchase count", e);
            return 0;
        }
    }
    
    /**
     * Get sales count for a user (seller/artist)
     */
    public long getUserSalesCount(String sellerId) throws ExecutionException, InterruptedException {
        try {
            Query query = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("sellerId", sellerId)
                .whereEqualTo("status", "COMPLETED");
            
            QuerySnapshot querySnapshot = query.get().get();
            return querySnapshot.size();
            
        } catch (Exception e) {
            logger.error("Error getting user sales count", e);
            return 0;
        }
    }
    
    /**
     * Find purchases with pending payment (for auction wins)
     */
    public List<Purchase> findPendingPaymentPurchases() throws ExecutionException, InterruptedException {
        try {
            Query query = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("status", "PENDING_PAYMENT");
            
            ApiFuture<QuerySnapshot> querySnapshot = query.get();
            List<QueryDocumentSnapshot> documents = querySnapshot.get().getDocuments();
            
            List<Purchase> purchases = new ArrayList<>();
            for (DocumentSnapshot doc : documents) {
                try {
                    Purchase purchase = mapToPurchase(doc);
                    if (purchase != null) {
                        purchases.add(purchase);
                    }
                } catch (Exception e) {
                    logger.warn("Error mapping purchase document {}: {}", doc.getId(), e.getMessage());
                }
            }
            
            return purchases;
            
        } catch (Exception e) {
            logger.error("Error finding pending payment purchases: {}", e.getMessage(), e);
            return new ArrayList<>();
        }
    }
    
    /**
     * Mark purchase payment as expired
     */
    public void markPaymentAsExpired(String purchaseId) throws ExecutionException, InterruptedException {
        try {
            Map<String, Object> updates = new HashMap<>();
            updates.put("status", "EXPIRED");
            updates.put("paymentExpired", true);
            
            ApiFuture<WriteResult> result = firestore.collection(COLLECTION_NAME)
                .document(purchaseId)
                .update(updates);
            
            result.get();
            logger.info("Purchase payment marked as expired: {}", purchaseId);
            
        } catch (Exception e) {
            logger.error("Error marking payment as expired: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Get total earnings for a seller
     */
    public BigDecimal getUserTotalEarnings(String sellerId) throws ExecutionException, InterruptedException {
        try {
            Query query = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("sellerId", sellerId)
                .whereEqualTo("status", "COMPLETED");
            
            QuerySnapshot querySnapshot = query.get().get();
            BigDecimal totalEarnings = BigDecimal.ZERO;
            
            for (QueryDocumentSnapshot document : querySnapshot.getDocuments()) {
                String priceStr = document.getString("purchasePrice");
                if (priceStr != null) {
                    totalEarnings = totalEarnings.add(new BigDecimal(priceStr));
                }
            }
            
            return totalEarnings;
            
        } catch (Exception e) {
            logger.error("Error getting user total earnings", e);
            return BigDecimal.ZERO;
        }
    }
    
    /**
     * Convert Purchase object to Firestore Map
     */
    private Map<String, Object> purchaseToMap(Purchase purchase) {
        Map<String, Object> map = new HashMap<>();
        map.put("purchaseId", purchase.getPurchaseId());
        map.put("artworkId", purchase.getArtworkId());
        map.put("buyerId", purchase.getBuyerId());
        map.put("sellerId", purchase.getSellerId());
        map.put("purchasePrice", purchase.getPurchasePrice() != null ? purchase.getPurchasePrice().toString() : null);
        map.put("purchaseDate", purchase.getPurchaseDate() != null ? purchase.getPurchaseDate().toString() : null);
        map.put("status", purchase.getStatus());
        map.put("paymentMethod", purchase.getPaymentMethod());
        map.put("transactionId", purchase.getTransactionId());
        map.put("shippingAddress", purchase.getShippingAddress());
        map.put("shippingCost", purchase.getShippingCost() != null ? purchase.getShippingCost().toString() : null);
        map.put("notes", purchase.getNotes());
        map.put("paymentDeadline", purchase.getPaymentDeadline() != null ? purchase.getPaymentDeadline().toString() : null);
        map.put("paymentExpired", purchase.isPaymentExpired());
        map.put("paidAt", purchase.getPaidAt() != null ? purchase.getPaidAt().toString() : null);
        
        return map;
    }
    
    /**
     * Convert Firestore DocumentSnapshot to Purchase object
     */
    private Purchase mapToPurchase(DocumentSnapshot doc) {
        Purchase purchase = new Purchase();
        purchase.setPurchaseId(doc.getId());
        purchase.setArtworkId(doc.getString("artworkId"));
        purchase.setBuyerId(doc.getString("buyerId"));
        purchase.setSellerId(doc.getString("sellerId"));
        
        String priceStr = doc.getString("purchasePrice");
        if (priceStr != null) {
            purchase.setPurchasePrice(new BigDecimal(priceStr));
        }
        
        String dateStr = doc.getString("purchaseDate");
        if (dateStr != null) {
            purchase.setPurchaseDate(LocalDateTime.parse(dateStr));
        }
        
        purchase.setStatus(doc.getString("status"));
        purchase.setPaymentMethod(doc.getString("paymentMethod"));
        purchase.setTransactionId(doc.getString("transactionId"));
        purchase.setShippingAddress(doc.getString("shippingAddress"));
        
        String shippingCostStr = doc.getString("shippingCost");
        if (shippingCostStr != null) {
            purchase.setShippingCost(new BigDecimal(shippingCostStr));
        }
        
        purchase.setNotes(doc.getString("notes"));
        
        // Payment deadline fields
        String paymentDeadlineStr = doc.getString("paymentDeadline");
        if (paymentDeadlineStr != null) {
            purchase.setPaymentDeadline(LocalDateTime.parse(paymentDeadlineStr));
        }
        
        Boolean paymentExpired = doc.getBoolean("paymentExpired");
        if (paymentExpired != null) {
            purchase.setPaymentExpired(paymentExpired);
        }
        
        String paidAtStr = doc.getString("paidAt");
        if (paidAtStr != null) {
            purchase.setPaidAt(LocalDateTime.parse(paidAtStr));
        }
        
        return purchase;
    }
}
