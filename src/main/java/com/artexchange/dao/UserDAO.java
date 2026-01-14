package com.artexchange.dao;

import com.artexchange.config.FirebaseConfig;
import com.artexchange.model.User;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;

/**
 * Data Access Object for User operations with Firestore
 */
public class UserDAO {
    private static final Logger logger = LoggerFactory.getLogger(UserDAO.class);
    private static final String COLLECTION_NAME = "users";
    private final Firestore firestore;
    
    public UserDAO() {
        this.firestore = FirebaseConfig.getFirestore();
    }
    
    /**
     * Save a new user to Firestore
     */
    public String saveUser(User user) throws ExecutionException, InterruptedException {
        try {
            // Generate ID if not provided
            if (user.getUserId() == null || user.getUserId().isEmpty()) {
                DocumentReference docRef = firestore.collection(COLLECTION_NAME).document();
                user.setUserId(docRef.getId());
            }
            
            Map<String, Object> userData = userToMap(user);
            
            ApiFuture<WriteResult> result = firestore.collection(COLLECTION_NAME)
                .document(user.getUserId())
                .set(userData);
            
            result.get(); // Wait for completion
            logger.info("User saved successfully: {}", user.getUserId());
            return user.getUserId();
            
        } catch (Exception e) {
            logger.error("Error saving user: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Find user by ID
     */
    public User findById(String userId) throws ExecutionException, InterruptedException {
        try {
            DocumentReference docRef = firestore.collection(COLLECTION_NAME).document(userId);
            ApiFuture<DocumentSnapshot> future = docRef.get();
            DocumentSnapshot document = future.get();
            
            if (document.exists()) {
                return mapToUser(document);
            }
            return null;
            
        } catch (Exception e) {
            logger.error("Error finding user by ID: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Find user by email
     */
    public User findByEmail(String email) throws ExecutionException, InterruptedException {
        try {
            Query query = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("email", email)
                .limit(1);
            
            ApiFuture<QuerySnapshot> querySnapshot = query.get();
            List<QueryDocumentSnapshot> documents = querySnapshot.get().getDocuments();
            
            if (!documents.isEmpty()) {
                return mapToUser(documents.get(0));
            }
            return null;
            
        } catch (Exception e) {
            logger.error("Error finding user by email: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Find user by username
     */
    public User findByUsername(String username) throws ExecutionException, InterruptedException {
        try {
            Query query = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("username", username)
                .limit(1);
            
            ApiFuture<QuerySnapshot> querySnapshot = query.get();
            List<QueryDocumentSnapshot> documents = querySnapshot.get().getDocuments();
            
            if (!documents.isEmpty()) {
                return mapToUser(documents.get(0));
            }
            return null;
            
        } catch (Exception e) {
            logger.error("Error finding user by username: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Find user by Firebase UID
     */
    public User findByFirebaseUid(String firebaseUid) throws ExecutionException, InterruptedException {
        try {
            Query query = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("firebaseUid", firebaseUid)
                .limit(1);
            
            ApiFuture<QuerySnapshot> querySnapshot = query.get();
            List<QueryDocumentSnapshot> documents = querySnapshot.get().getDocuments();
            
            if (!documents.isEmpty()) {
                return mapToUser(documents.get(0));
            }
            return null;
            
        } catch (Exception e) {
            logger.error("Error finding user by Firebase UID: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Alias for findByFirebaseUid - kept for backward compatibility
     */
    public User getUserByFirebaseId(String firebaseUid) throws ExecutionException, InterruptedException {
        return findByFirebaseUid(firebaseUid);
    }
    
    /**
     * Update user
     */
    public void updateUser(User user) throws ExecutionException, InterruptedException {
        try {
            user.setUpdatedAt(LocalDateTime.now());
            Map<String, Object> userData = userToMap(user);
            
            ApiFuture<WriteResult> result = firestore.collection(COLLECTION_NAME)
                .document(user.getUserId())
                .set(userData);
            
            result.get();
            logger.info("User updated successfully: {}", user.getUserId());
            
        } catch (Exception e) {
            logger.error("Error updating user: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Get all artists
     */
    public List<User> findAllArtists() throws ExecutionException, InterruptedException {
        try {
            Query query = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("role", "ARTIST")
                .whereEqualTo("isActive", true);
            
            ApiFuture<QuerySnapshot> querySnapshot = query.get();
            List<QueryDocumentSnapshot> documents = querySnapshot.get().getDocuments();
            
            List<User> artists = new ArrayList<>();
            for (DocumentSnapshot doc : documents) {
                artists.add(mapToUser(doc));
            }
            
            return artists;
            
        } catch (Exception e) {
            logger.error("Error finding all artists: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Check if email exists
     */
    public boolean emailExists(String email) throws ExecutionException, InterruptedException {
        return findByEmail(email) != null;
    }
    
    /**
     * Check if username exists
     */
    public boolean usernameExists(String username) throws ExecutionException, InterruptedException {
        return findByUsername(username) != null;
    }
    
    /**
     * Get all users with pagination and filtering (Admin only)
     */
    public List<User> getAllUsers(int page, int limit, String search, String role) 
            throws ExecutionException, InterruptedException {
        try {
            Query query = firestore.collection(COLLECTION_NAME)
                .orderBy("createdAt", Query.Direction.DESCENDING);
            
            // Apply role filter
            if (role != null && !role.trim().isEmpty()) {
                query = query.whereEqualTo("role", role);
            }
            
            // Apply search filter (simplified - searches username and email)
            if (search != null && !search.trim().isEmpty()) {
                // Note: Firestore doesn't support full-text search, so this is a basic implementation
                // In production, you'd use a proper search service like Algolia or Elasticsearch
                query = query.whereGreaterThanOrEqualTo("username", search)
                           .whereLessThanOrEqualTo("username", search + '\uf8ff');
            }
            
            ApiFuture<QuerySnapshot> future = query.offset(page * limit).limit(limit).get();
            List<QueryDocumentSnapshot> documents = future.get().getDocuments();
            
            List<User> users = new ArrayList<>();
            for (QueryDocumentSnapshot document : documents) {
                User user = mapToUser(document);
                users.add(user);
            }
            
            return users;
        } catch (Exception e) {
            logger.error("Error getting all users: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Get total users count with filters
     */
    public long getTotalUsersCount(String search, String role) 
            throws ExecutionException, InterruptedException {
        try {
            Query query = firestore.collection(COLLECTION_NAME);
            
            // Apply role filter
            if (role != null && !role.trim().isEmpty()) {
                query = query.whereEqualTo("role", role);
            }
            
            // Apply search filter
            if (search != null && !search.trim().isEmpty()) {
                query = query.whereGreaterThanOrEqualTo("username", search)
                           .whereLessThanOrEqualTo("username", search + '\uf8ff');
            }
            
            ApiFuture<QuerySnapshot> future = query.get();
            return future.get().size();
        } catch (Exception e) {
            logger.error("Error getting users count: {}", e.getMessage(), e);
            return 0;
        }
    }
    
    /**
     * Update user status (active/inactive)
     */
    public boolean updateUserStatus(String userId, boolean isActive) 
            throws ExecutionException, InterruptedException {
        try {
            Map<String, Object> updates = new HashMap<>();
            updates.put("isActive", isActive);
            updates.put("updatedAt", LocalDateTime.now().toString());
            
            ApiFuture<WriteResult> result = firestore.collection(COLLECTION_NAME)
                .document(userId)
                .update(updates);
            
            result.get();
            logger.info("User status updated successfully: {} -> {}", userId, isActive);
            return true;
        } catch (Exception e) {
            logger.error("Error updating user status: {}", e.getMessage(), e);
            return false;
        }
    }
    
    /**
     * Update user verification status
     */
    public boolean updateUserVerification(String userId, boolean isVerified) 
            throws ExecutionException, InterruptedException {
        try {
            Map<String, Object> updates = new HashMap<>();
            updates.put("isVerified", isVerified);
            updates.put("updatedAt", LocalDateTime.now().toString());
            
            ApiFuture<WriteResult> result = firestore.collection(COLLECTION_NAME)
                .document(userId)
                .update(updates);
            
            result.get();
            logger.info("User verification updated successfully: {} -> {}", userId, isVerified);
            return true;
        } catch (Exception e) {
            logger.error("Error updating user verification: {}", e.getMessage(), e);
            return false;
        }
    }
    
    /**
     * Get new users count for this month
     */
    public long getNewUsersThisMonth() throws ExecutionException, InterruptedException {
        try {
            LocalDateTime startOfMonth = LocalDateTime.now().withDayOfMonth(1)
                .withHour(0).withMinute(0).withSecond(0).withNano(0);
            
            Query query = firestore.collection(COLLECTION_NAME)
                .whereGreaterThanOrEqualTo("createdAt", startOfMonth.toString());
            
            ApiFuture<QuerySnapshot> future = query.get();
            return future.get().size();
        } catch (Exception e) {
            logger.error("Error getting new users count: {}", e.getMessage(), e);
            return 0;
        }
    }
    
    /**
     * Delete user
     */
    public void deleteUser(String userId) throws ExecutionException, InterruptedException {
        try {
            ApiFuture<WriteResult> result = firestore.collection(COLLECTION_NAME)
                .document(userId)
                .delete();
            
            result.get();
            logger.info("User deleted successfully: {}", userId);
            
        } catch (Exception e) {
            logger.error("Error deleting user: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Update user statistics
     */
    public void updateUserStats(String userId, int followerCount, int followingCount, 
                               int artworkCount, int likesCount, int salesCount) 
                               throws ExecutionException, InterruptedException {
        try {
            Map<String, Object> updates = new HashMap<>();
            updates.put("followerCount", followerCount);
            updates.put("followingCount", followingCount);
            updates.put("artworkCount", artworkCount);
            updates.put("likesCount", likesCount);
            updates.put("salesCount", salesCount);
            updates.put("updatedAt", LocalDateTime.now().toString());
            
            ApiFuture<WriteResult> result = firestore.collection(COLLECTION_NAME)
                .document(userId)
                .update(updates);
            
            result.get();
            logger.info("User stats updated successfully: {}", userId);
            
        } catch (Exception e) {
            logger.error("Error updating user stats: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Convert User object to Firestore Map
     */
    private Map<String, Object> userToMap(User user) {
        Map<String, Object> map = new HashMap<>();
        map.put("userId", user.getUserId());
        map.put("email", user.getEmail());
        map.put("username", user.getUsername());
        map.put("firstName", user.getFirstName());
        map.put("lastName", user.getLastName());
        map.put("profileImage", user.getProfileImage());
        map.put("bio", user.getBio());
        map.put("role", user.getRole() != null ? user.getRole().name() : null);
        map.put("isActive", user.isActive());
        map.put("isVerified", user.isVerified());
        map.put("createdAt", user.getCreatedAt() != null ? user.getCreatedAt().toString() : null);
        map.put("updatedAt", user.getUpdatedAt() != null ? user.getUpdatedAt().toString() : null);
        map.put("firebaseUid", user.getFirebaseUid());
        map.put("phone", user.getPhone());
        map.put("address", user.getAddress());
        map.put("city", user.getCity());
        map.put("state", user.getState());
        map.put("country", user.getCountry());
        map.put("artistStatement", user.getArtistStatement());
        map.put("website", user.getWebsite());
        map.put("socialMediaLinks", user.getSocialMediaLinks());
        map.put("followerCount", user.getFollowerCount());
        map.put("followingCount", user.getFollowingCount());
        map.put("artworkCount", user.getArtworkCount());
        map.put("likesCount", user.getLikesCount());
        map.put("salesCount", user.getSalesCount());
        return map;
    }
    
    /**
     * Convert Firestore DocumentSnapshot to User object
     */
    private User mapToUser(DocumentSnapshot doc) {
        User user = new User();
        user.setUserId(doc.getId());
        user.setEmail(doc.getString("email"));
        user.setUsername(doc.getString("username"));
        user.setFirstName(doc.getString("firstName"));
        user.setLastName(doc.getString("lastName"));
        user.setProfileImage(doc.getString("profileImage"));
        user.setBio(doc.getString("bio"));
        
        String roleStr = doc.getString("role");
        // Use the safe fromString method which handles invalid roles automatically
        user.setRole(User.UserRole.fromString(roleStr));
        
        user.setActive(Boolean.TRUE.equals(doc.getBoolean("isActive")));
        user.setVerified(Boolean.TRUE.equals(doc.getBoolean("isVerified")));
        
        String createdAtStr = doc.getString("createdAt");
        if (createdAtStr != null) {
            user.setCreatedAt(LocalDateTime.parse(createdAtStr));
        }
        
        String updatedAtStr = doc.getString("updatedAt");
        if (updatedAtStr != null) {
            user.setUpdatedAt(LocalDateTime.parse(updatedAtStr));
        }
        
        user.setFirebaseUid(doc.getString("firebaseUid"));
        user.setPhone(doc.getString("phone"));
        user.setAddress(doc.getString("address"));
        user.setCity(doc.getString("city"));
        user.setState(doc.getString("state"));
        user.setCountry(doc.getString("country"));
        user.setArtistStatement(doc.getString("artistStatement"));
        user.setWebsite(doc.getString("website"));
        user.setSocialMediaLinks(doc.getString("socialMediaLinks"));
        
        // Set statistics fields
        Long followerCount = doc.getLong("followerCount");
        user.setFollowerCount(followerCount != null ? followerCount.intValue() : 0);
        
        Long followingCount = doc.getLong("followingCount");
        user.setFollowingCount(followingCount != null ? followingCount.intValue() : 0);
        
        Long artworkCount = doc.getLong("artworkCount");
        user.setArtworkCount(artworkCount != null ? artworkCount.intValue() : 0);
        
        Long likesCount = doc.getLong("likesCount");
        user.setLikesCount(likesCount != null ? likesCount.intValue() : 0);
        
        Long salesCount = doc.getLong("salesCount");
        user.setSalesCount(salesCount != null ? salesCount.intValue() : 0);
        
        return user;
    }
}
