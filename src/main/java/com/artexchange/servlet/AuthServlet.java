package com.artexchange.servlet;

import com.artexchange.dao.UserDAO;
import com.artexchange.model.User;
import com.artexchange.util.SessionUtil;
import com.artexchange.util.GsonUtil;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutionException;

/**
 * Authentication servlet handling user login, registration, and Firebase token verification
 */
@WebServlet(name = "AuthServlet", urlPatterns = {"/auth/*"})
public class AuthServlet extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(AuthServlet.class);
    private UserDAO userDAO;
    private Gson gson;
    
    @Override
    public void init() throws ServletException {
        super.init();
        userDAO = new UserDAO();
        gson = GsonUtil.getGson();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String pathInfo = request.getPathInfo();
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            switch (pathInfo) {
                case "/login":
                    handleLogin(request, response);
                    break;
                case "/register":
                    handleRegister(request, response);
                    break;
                case "/logout":
                    handleLogout(request, response);
                    break;
                case "/verify-token":
                    handleVerifyToken(request, response);
                    break;
                default:
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    sendErrorResponse(response, "Endpoint not found");
            }
        } catch (Exception e) {
            logger.error("Error in AuthServlet: {}", e.getMessage(), e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            sendErrorResponse(response, "Internal server error");
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String pathInfo = request.getPathInfo();
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            if ("/profile".equals(pathInfo)) {
                handleGetProfile(request, response);
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                sendErrorResponse(response, "Endpoint not found");
            }
        } catch (Exception e) {
            logger.error("Error in AuthServlet GET: {}", e.getMessage(), e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            sendErrorResponse(response, "Internal server error");
        }
    }
    
    /**
     * Handle get current user profile
     */
    private void handleGetProfile(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        // Get current user from session
        User currentUser = SessionUtil.getCurrentUser(request);
        
        if (currentUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            sendErrorResponse(response, "Authentication required");
            return;
        }
        
        // Send success response with user data
        Map<String, Object> responseData = new HashMap<>();
        responseData.put("success", true);
        responseData.put("user", createUserResponseData(currentUser));
        
        response.getWriter().write(gson.toJson(responseData));
    }

    /**
     * Handle user login with Firebase token
     */
    private void handleLogin(HttpServletRequest request, HttpServletResponse response) 
            throws IOException, ExecutionException, InterruptedException {
        
        JsonObject requestData = parseRequestBody(request);
        String idToken = requestData.get("idToken").getAsString();
        
        try {
            // Verify Firebase token
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
            String firebaseUid = decodedToken.getUid();
            String email = decodedToken.getEmail();
            
            // Find user in database
            User user = userDAO.findByFirebaseUid(firebaseUid);
            
            if (user == null) {
                // User not found in database
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                sendErrorResponse(response, "User not registered in the platform");
                return;
            }
            
            if (!user.isActive()) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                sendErrorResponse(response, "Account is inactive");
                return;
            }
            
            // Create session
            SessionUtil.createUserSession(request, user);
            
            // Update last login (optional)
            user.setUpdatedAt(LocalDateTime.now());
            userDAO.updateUser(user);
            
            // Send success response
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("success", true);
            responseData.put("message", "Login successful");
            responseData.put("user", createUserResponseData(user));
            
            response.getWriter().write(gson.toJson(responseData));
            
        } catch (Exception e) {
            logger.error("Login error: {}", e.getMessage(), e);
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            sendErrorResponse(response, "Invalid token or authentication failed");
        }
    }
    
    /**
     * Handle user registration
     */
    private void handleRegister(HttpServletRequest request, HttpServletResponse response) 
            throws IOException, ExecutionException, InterruptedException {
        
        JsonObject requestData = parseRequestBody(request);
        
        String idToken = requestData.get("idToken").getAsString();
        String username = requestData.get("username").getAsString();
        String firstName = requestData.get("firstName").getAsString();
        String lastName = requestData.get("lastName").getAsString();
        String roleStr = requestData.get("role").getAsString();
        
        try {
            // Verify Firebase token
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
            String firebaseUid = decodedToken.getUid();
            String email = decodedToken.getEmail();
            
            // Check if user already exists
            logger.info("Checking registration for Firebase UID: {}, email: {}, username: {}", firebaseUid, email, username);
            
            User existingUserByUid = userDAO.findByFirebaseUid(firebaseUid);
            if (existingUserByUid != null) {
                logger.warn("User already registered with Firebase UID: {} - existing user: {}", firebaseUid, existingUserByUid.getEmail());
                response.setStatus(HttpServletResponse.SC_CONFLICT);
                sendErrorResponse(response, "User already registered with this Firebase account");
                return;
            }
            logger.info("Firebase UID check passed - no existing user found");
            
            // Check if username or email already exists
            if (userDAO.usernameExists(username)) {
                logger.warn("Username already exists: {}", username);
                response.setStatus(HttpServletResponse.SC_CONFLICT);
                sendErrorResponse(response, "Username already exists");
                return;
            }
            logger.info("Username check passed - username '{}' is available", username);
            
            if (userDAO.emailExists(email)) {
                logger.warn("Email already registered: {}", email);
                response.setStatus(HttpServletResponse.SC_CONFLICT);
                sendErrorResponse(response, "Email already registered");
                return;
            }
            logger.info("Email check passed - email '{}' is available", email);
            
            logger.info("Registration checks passed for user: {}", email);
            
            // Create new user
            User user = new User();
            user.setEmail(email);
            user.setUsername(username);
            user.setFirstName(firstName);
            user.setLastName(lastName);
            user.setFirebaseUid(firebaseUid);
            
            // Validate and set role
            try {
                User.UserRole userRole = User.UserRole.valueOf(roleStr.toUpperCase());
                user.setRole(userRole);
                logger.info("User registration: role '{}' validated successfully as {}", roleStr, userRole);
            } catch (IllegalArgumentException e) {
                logger.error("Invalid role '{}' provided. Valid roles are: {}", roleStr, Arrays.toString(User.UserRole.values()));
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                sendErrorResponse(response, "Invalid role. Valid roles are: " + Arrays.toString(User.UserRole.values()));
                return;
            }
            
            user.setActive(true);
            user.setVerified(decodedToken.isEmailVerified());
            user.setCreatedAt(LocalDateTime.now());
            user.setUpdatedAt(LocalDateTime.now());
            
            // Optional fields from request
            if (requestData.has("bio")) {
                user.setBio(requestData.get("bio").getAsString());
            }
            if (requestData.has("phone")) {
                user.setPhone(requestData.get("phone").getAsString());
            }
            if (requestData.has("city")) {
                user.setCity(requestData.get("city").getAsString());
            }
            if (requestData.has("country")) {
                user.setCountry(requestData.get("country").getAsString());
            }
            
            // Save user to database
            String userId = userDAO.saveUser(user);
            user.setUserId(userId);
            
            // Create session
            SessionUtil.createUserSession(request, user);
            
            // Send success response
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("success", true);
            responseData.put("message", "Registration successful");
            responseData.put("user", createUserResponseData(user));
            
            response.getWriter().write(gson.toJson(responseData));
            
        } catch (Exception e) {
            logger.error("Registration error: {}", e.getMessage(), e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            sendErrorResponse(response, "Registration failed");
        }
    }
    
    /**
     * Handle user logout
     */
    private void handleLogout(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        SessionUtil.destroyUserSession(request);
        
        Map<String, Object> responseData = new HashMap<>();
        responseData.put("success", true);
        responseData.put("message", "Logout successful");
        
        response.getWriter().write(gson.toJson(responseData));
    }
    
    /**
     * Verify Firebase token and return user info
     */
    private void handleVerifyToken(HttpServletRequest request, HttpServletResponse response) 
            throws IOException, ExecutionException, InterruptedException {
        
        JsonObject requestData = parseRequestBody(request);
        String idToken = requestData.get("idToken").getAsString();
        
        try {
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
            String firebaseUid = decodedToken.getUid();
            
            User user = userDAO.findByFirebaseUid(firebaseUid);
            
            if (user == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                sendErrorResponse(response, "User not found");
                return;
            }
            
            // Create user session for subsequent requests
            SessionUtil.createUserSession(request, user);
            
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("success", true);
            responseData.put("user", createUserResponseData(user));
            
            response.getWriter().write(gson.toJson(responseData));
            
        } catch (Exception e) {
            logger.error("Token verification error: {}", e.getMessage(), e);
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            sendErrorResponse(response, "Invalid token");
        }
    }
    
    /**
     * Parse JSON request body
     */
    private JsonObject parseRequestBody(HttpServletRequest request) throws IOException {
        StringBuilder buffer = new StringBuilder();
        BufferedReader reader = request.getReader();
        String line;
        
        while ((line = reader.readLine()) != null) {
            buffer.append(line);
        }
        
        return gson.fromJson(buffer.toString(), JsonObject.class);
    }
    
    /**
     * Create user response data (excluding sensitive information)
     */
    private Map<String, Object> createUserResponseData(User user) {
        Map<String, Object> userData = new HashMap<>();
        userData.put("userId", user.getUserId());
        userData.put("email", user.getEmail());
        userData.put("username", user.getUsername());
        userData.put("firstName", user.getFirstName());
        userData.put("lastName", user.getLastName());
        userData.put("fullName", user.getFullName());
        userData.put("profileImage", user.getProfileImage());
        userData.put("bio", user.getBio());
        userData.put("role", user.getRole().name());
        userData.put("isVerified", user.isVerified());
        userData.put("city", user.getCity());
        userData.put("country", user.getCountry());
        
        if (user.getRole() == User.UserRole.ARTIST) {
            userData.put("artistStatement", user.getArtistStatement());
            userData.put("website", user.getWebsite());
        }
        
        return userData;
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
