package com.artexchange.servlet;

import com.artexchange.dao.UserDAO;
import com.artexchange.model.User;
import com.artexchange.util.SessionUtil;
import com.artexchange.util.GsonUtil;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.regex.Pattern;

/**
 * Servlet for handling user profile editing
 * Endpoints:
 * - GET /api/me/profile - Get current user's profile
 * - PUT /api/me/profile - Update current user's profile
 */
@WebServlet(name = "ProfileServlet", urlPatterns = {"/api/me/profile"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,  // 1MB
    maxFileSize = 1024 * 1024 * 5,     // 5MB
    maxRequestSize = 1024 * 1024 * 10  // 10MB
)
public class ProfileServlet extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(ProfileServlet.class);
    private UserDAO userDAO;
    private Gson gson;
    private static final String UPLOAD_DIR = "uploads/profiles";
    private static final String[] ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp"};
    private static final int MAX_BIO_LENGTH = 1000;
    private static final int MIN_NAME_LENGTH = 2;
    private static final int MAX_NAME_LENGTH = 100;
    
    // Pattern to remove script tags and dangerous HTML
    private static final Pattern SCRIPT_PATTERN = Pattern.compile(
        "<script[^>]*>.*?</script>", Pattern.CASE_INSENSITIVE | Pattern.DOTALL
    );
    
    @Override
    public void init() throws ServletException {
        super.init();
        userDAO = new UserDAO();
        gson = GsonUtil.getGson();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            User currentUser = SessionUtil.getCurrentUser(request);
            if (currentUser == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                sendErrorResponse(response, "Authentication required");
                return;
            }
            
            // Get fresh user data from database
            User user = userDAO.findById(currentUser.getUserId());
            if (user == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                sendErrorResponse(response, "User not found");
                return;
            }
            
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("success", true);
            responseData.put("id", user.getUserId());
            responseData.put("display_name", user.getDisplayName());
            responseData.put("bio", user.getBio());
            responseData.put("avatar_url", user.getProfileImage());
            
            response.getWriter().write(gson.toJson(responseData));
            
        } catch (Exception e) {
            logger.error("Error getting profile: {}", e.getMessage(), e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            sendErrorResponse(response, "Failed to get profile");
        }
    }
    
    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            User currentUser = SessionUtil.getCurrentUser(request);
            if (currentUser == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                sendErrorResponse(response, "Authentication required");
                return;
            }
            
            // Get fresh user data
            User user = userDAO.findById(currentUser.getUserId());
            if (user == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                sendErrorResponse(response, "User not found");
                return;
            }
            
            // Parse request body
            StringBuilder jsonBuffer = new StringBuilder();
            BufferedReader reader = request.getReader();
            String line;
            while ((line = reader.readLine()) != null) {
                jsonBuffer.append(line);
            }
            
            TypeToken<Map<String, Object>> typeToken = new TypeToken<Map<String, Object>>() {};
            Map<String, Object> requestData = gson.fromJson(jsonBuffer.toString(), typeToken.getType());
            
            // Validate and update display_name
            if (requestData.containsKey("display_name")) {
                String displayName = (String) requestData.get("display_name");
                if (displayName != null) {
                    displayName = displayName.trim();
                    if (displayName.length() < MIN_NAME_LENGTH || displayName.length() > MAX_NAME_LENGTH) {
                        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                        sendErrorResponse(response, 
                            "Display name must be between " + MIN_NAME_LENGTH + " and " + MAX_NAME_LENGTH + " characters");
                        return;
                    }
                    // Split display name into first and last name
                    String[] nameParts = displayName.split("\\s+", 2);
                    if (nameParts.length > 0) {
                        user.setFirstName(nameParts[0]);
                        if (nameParts.length > 1) {
                            user.setLastName(nameParts[1]);
                        } else {
                            user.setLastName("");
                        }
                    }
                }
            }
            
            // Validate and update bio
            if (requestData.containsKey("bio")) {
                String bio = (String) requestData.get("bio");
                if (bio != null) {
                    bio = bio.trim();
                    if (bio.length() > MAX_BIO_LENGTH) {
                        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                        sendErrorResponse(response, "Bio must not exceed " + MAX_BIO_LENGTH + " characters");
                        return;
                    }
                    // Sanitize bio - remove script tags
                    bio = sanitizeBio(bio);
                    user.setBio(bio);
                } else {
                    user.setBio(null);
                }
            }
            
            // Handle profile picture URL (if provided as URL string)
            if (requestData.containsKey("profile_picture") && requestData.get("profile_picture") instanceof String) {
                String profilePictureUrl = (String) requestData.get("profile_picture");
                if (profilePictureUrl != null && !profilePictureUrl.trim().isEmpty()) {
                    user.setProfileImage(profilePictureUrl.trim());
                }
            }
            
            // Update timestamp
            user.setUpdatedAt(LocalDateTime.now());
            
            // Save to database
            userDAO.updateUser(user);
            
            // Return updated profile
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("success", true);
            responseData.put("id", user.getUserId());
            responseData.put("display_name", user.getDisplayName());
            responseData.put("bio", user.getBio());
            responseData.put("avatar_url", user.getProfileImage());
            responseData.put("message", "Profile updated successfully");
            
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write(gson.toJson(responseData));
            
            logger.info("Profile updated successfully for user: {}", user.getUserId());
            
        } catch (Exception e) {
            logger.error("Error updating profile: {}", e.getMessage(), e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            sendErrorResponse(response, "Failed to update profile");
        }
    }
    
    /**
     * Handle profile picture upload via multipart form
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // This handles multipart file uploads for profile pictures
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            User currentUser = SessionUtil.getCurrentUser(request);
            if (currentUser == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                sendErrorResponse(response, "Authentication required");
                return;
            }
            
            User user = userDAO.findById(currentUser.getUserId());
            if (user == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                sendErrorResponse(response, "User not found");
                return;
            }
            
            // Get profile picture file part
            Part filePart = request.getPart("profile_picture");
            
            if (filePart == null || filePart.getSize() == 0) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                sendErrorResponse(response, "No file uploaded");
                return;
            }
            
            // Validate file
            String fileName = getFileName(filePart);
            if (!isValidFileType(fileName)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                sendErrorResponse(response, "Invalid file type. Only JPG, PNG, and WebP files are allowed.");
                return;
            }
            
            // Check file size (5MB max)
            if (filePart.getSize() > 5 * 1024 * 1024) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                sendErrorResponse(response, "File size exceeds 5MB limit");
                return;
            }
            
            // Save and resize image
            String avatarUrl = saveAndResizeProfileImage(filePart, request);
            
            // Delete old avatar if exists
            if (user.getProfileImage() != null && user.getProfileImage().startsWith("/uploads/profiles/")) {
                deleteOldAvatar(user.getProfileImage(), request);
            }
            
            // Update user profile
            user.setProfileImage(avatarUrl);
            user.setUpdatedAt(LocalDateTime.now());
            userDAO.updateUser(user);
            
            // Return success response
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("success", true);
            responseData.put("avatar_url", avatarUrl);
            responseData.put("message", "Profile picture updated successfully");
            
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write(gson.toJson(responseData));
            
        } catch (Exception e) {
            logger.error("Error uploading profile picture: {}", e.getMessage(), e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            sendErrorResponse(response, "Failed to upload profile picture");
        }
    }
    
    /**
     * Save and resize profile image to 300x300
     */
    private String saveAndResizeProfileImage(Part filePart, HttpServletRequest request) 
            throws IOException {
        
        // Get upload directory
        String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }
        
        // Generate unique filename
        String fileExtension = getFileExtension(getFileName(filePart));
        String uniqueFileName = UUID.randomUUID().toString() + fileExtension;
        Path filePath = Paths.get(uploadPath, uniqueFileName);
        
        // Save file
        try (InputStream inputStream = filePart.getInputStream()) {
            Files.copy(inputStream, filePath, StandardCopyOption.REPLACE_EXISTING);
        }
        
        // Note: Image resizing would require a library like Thumbnailator or Java ImageIO
        // For now, we'll save the file and return the URL
        // In production, you should resize to 300x300 here
        
        String fileUrl = request.getContextPath() + "/" + UPLOAD_DIR + "/" + uniqueFileName;
        return fileUrl;
    }
    
    /**
     * Delete old avatar file
     */
    private void deleteOldAvatar(String avatarPath, HttpServletRequest request) {
        try {
            if (avatarPath != null && avatarPath.startsWith("/")) {
                String realPath = getServletContext().getRealPath(avatarPath);
                if (realPath != null) {
                    File oldFile = new File(realPath);
                    if (oldFile.exists()) {
                        oldFile.delete();
                        logger.info("Deleted old avatar: {}", realPath);
                    }
                }
            }
        } catch (Exception e) {
            logger.warn("Failed to delete old avatar: {}", e.getMessage());
        }
    }
    
    /**
     * Sanitize bio text - remove script tags and dangerous content
     */
    private String sanitizeBio(String bio) {
        if (bio == null) return null;
        
        // Remove script tags
        bio = SCRIPT_PATTERN.matcher(bio).replaceAll("");
        
        // Remove other potentially dangerous tags
        bio = bio.replaceAll("(?i)<(iframe|object|embed|form)[^>]*>.*?</\\1>", "");
        
        // Allow basic formatting tags (optional - you can be more restrictive)
        // For now, we'll just strip all HTML tags for safety
        bio = bio.replaceAll("<[^>]+>", "");
        
        return bio.trim();
    }
    
    /**
     * Get filename from part
     */
    private String getFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        if (contentDisposition != null) {
            for (String content : contentDisposition.split(";")) {
                if (content.trim().startsWith("filename")) {
                    return content.substring(content.indexOf('=') + 1).trim().replace("\"", "");
                }
            }
        }
        return "unknown";
    }
    
    /**
     * Get file extension
     */
    private String getFileExtension(String fileName) {
        if (fileName == null) return "";
        int lastDotIndex = fileName.lastIndexOf('.');
        if (lastDotIndex == -1) return "";
        return fileName.substring(lastDotIndex).toLowerCase();
    }
    
    /**
     * Validate file type
     */
    private boolean isValidFileType(String fileName) {
        if (fileName == null) return false;
        String extension = getFileExtension(fileName);
        for (String allowedExt : ALLOWED_EXTENSIONS) {
            if (allowedExt.equals(extension)) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * Send error response
     */
    private void sendErrorResponse(HttpServletResponse response, String message) throws IOException {
        Map<String, Object> errorData = new HashMap<>();
        errorData.put("success", false);
        errorData.put("message", message);
        
        response.getWriter().write(gson.toJson(errorData));
    }
}

