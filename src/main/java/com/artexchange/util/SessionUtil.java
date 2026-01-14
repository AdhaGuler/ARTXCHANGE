package com.artexchange.util;

import com.artexchange.model.User;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

/**
 * Utility class for managing user sessions
 */
public class SessionUtil {
    private static final String USER_SESSION_KEY = "currentUser";
    private static final String USER_ID_SESSION_KEY = "userId";
    private static final String USER_ROLE_SESSION_KEY = "userRole";
    
    /**
     * Create a user session
     */
    public static void createUserSession(HttpServletRequest request, User user) {
        HttpSession session = request.getSession(true);
        session.setAttribute(USER_SESSION_KEY, user);
        session.setAttribute(USER_ID_SESSION_KEY, user.getUserId());
        session.setAttribute(USER_ROLE_SESSION_KEY, user.getRole().name());
        session.setMaxInactiveInterval(3600); // 1 hour
    }
    
    /**
     * Get current user from session
     */
    public static User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            return (User) session.getAttribute(USER_SESSION_KEY);
        }
        return null;
    }
    
    /**
     * Get current user ID from session
     */
    public static String getCurrentUserId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            return (String) session.getAttribute(USER_ID_SESSION_KEY);
        }
        return null;
    }
    
    /**
     * Get current user role from session
     */
    public static String getCurrentUserRole(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            return (String) session.getAttribute(USER_ROLE_SESSION_KEY);
        }
        return null;
    }
    
    /**
     * Check if user is logged in
     */
    public static boolean isUserLoggedIn(HttpServletRequest request) {
        return getCurrentUser(request) != null;
    }
    
    /**
     * Check if current user is admin
     */
    public static boolean isCurrentUserAdmin(HttpServletRequest request) {
        String role = getCurrentUserRole(request);
        return "ADMIN".equals(role);
    }
    
    /**
     * Check if current user is artist
     */
    public static boolean isCurrentUserArtist(HttpServletRequest request) {
        String role = getCurrentUserRole(request);
        return "ARTIST".equals(role);
    }
    
    /**
     * Check if current user owns the resource
     */
    public static boolean isCurrentUserOwner(HttpServletRequest request, String ownerId) {
        String currentUserId = getCurrentUserId(request);
        return currentUserId != null && currentUserId.equals(ownerId);
    }
    
    /**
     * Destroy user session
     */
    public static void destroyUserSession(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.removeAttribute(USER_SESSION_KEY);
            session.removeAttribute(USER_ID_SESSION_KEY);
            session.removeAttribute(USER_ROLE_SESSION_KEY);
            session.invalidate();
        }
    }
    
    /**
     * Update user in session
     */
    public static void updateUserSession(HttpServletRequest request, User user) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.setAttribute(USER_SESSION_KEY, user);
            session.setAttribute(USER_ID_SESSION_KEY, user.getUserId());
            session.setAttribute(USER_ROLE_SESSION_KEY, user.getRole().name());
        }
    }
}
