package com.artexchange.servlet;

import com.artexchange.dao.ArtworkDAO;
import com.artexchange.dao.UserDAO;
import com.artexchange.model.User;
import com.artexchange.model.Artwork;
import com.artexchange.util.SessionUtil;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonArray;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.logging.Logger;

/**
 * Admin servlet for managing users and content
 */
@WebServlet("/admin/*")
public class AdminServlet extends HttpServlet {
    private static final Logger logger = Logger.getLogger(AdminServlet.class.getName());
    private final Gson gson = new Gson();
    private final UserDAO userDAO = new UserDAO();
    private final ArtworkDAO artworkDAO = new ArtworkDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check admin authorization
        if (!SessionUtil.isCurrentUserAdmin(request)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().write("{\"error\": \"Admin access required\"}");
            return;
        }
        
        String pathInfo = request.getPathInfo();
        if (pathInfo == null) {
            // Redirect to admin dashboard
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            return;
        }
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            switch (pathInfo) {
                case "/dashboard":
                    handleDashboard(request, response);
                    break;
                case "/users":
                    handleGetUsers(request, response);
                    break;
                case "/artworks":
                    handleGetArtworks(request, response);
                    break;
                case "/stats":
                    handleGetStats(request, response);
                    break;
                default:
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    response.getWriter().write("{\"error\": \"Endpoint not found\"}");
            }
        } catch (Exception e) {
            logger.severe("Error in AdminServlet: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\": \"Internal server error\"}");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check admin authorization
        if (!SessionUtil.isCurrentUserAdmin(request)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().write("{\"error\": \"Admin access required\"}");
            return;
        }
        
        String pathInfo = request.getPathInfo();
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            switch (pathInfo) {
                case "/users/activate":
                    handleActivateUser(request, response);
                    break;
                case "/users/deactivate":
                    handleDeactivateUser(request, response);
                    break;
                case "/users/verify":
                    handleVerifyUser(request, response);
                    break;
                case "/artworks/feature":
                    handleFeatureArtwork(request, response);
                    break;
                case "/artworks/remove":
                    handleRemoveArtwork(request, response);
                    break;
                default:
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    response.getWriter().write("{\"error\": \"Endpoint not found\"}");
            }
        } catch (Exception e) {
            logger.severe("Error in AdminServlet POST: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\": \"Internal server error\"}");
        }
    }
    
    private void handleDashboard(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Forward to admin dashboard JSP
        request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
    }
    
    private void handleGetUsers(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        String page = request.getParameter("page");
        String limit = request.getParameter("limit");
        String search = request.getParameter("search");
        String role = request.getParameter("role");
        
        int pageNum = page != null ? Integer.parseInt(page) : 0;
        int limitNum = limit != null ? Integer.parseInt(limit) : 20;
        
        List<User> users = userDAO.getAllUsers(pageNum, limitNum, search, role);
        long totalUsers = userDAO.getTotalUsersCount(search, role);
        
        JsonObject response_data = new JsonObject();
        response_data.addProperty("success", true);
        response_data.add("users", gson.toJsonTree(users));
        response_data.addProperty("totalUsers", totalUsers);
        response_data.addProperty("totalPages", (totalUsers + limitNum - 1) / limitNum);
        response_data.addProperty("currentPage", pageNum);
        
        response.getWriter().write(gson.toJson(response_data));
    }
    
    private void handleGetArtworks(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        String page = request.getParameter("page");
        String limit = request.getParameter("limit");
        String search = request.getParameter("search");
        String status = request.getParameter("status");
        
        int pageNum = page != null ? Integer.parseInt(page) : 0;
        int limitNum = limit != null ? Integer.parseInt(limit) : 20;
        
        List<Artwork> artworks = artworkDAO.getAllArtworksForAdmin(pageNum, limitNum, search, status);
        long totalArtworks = artworkDAO.getTotalArtworksCount(search, status);
        
        JsonObject response_data = new JsonObject();
        response_data.addProperty("success", true);
        response_data.add("artworks", gson.toJsonTree(artworks));
        response_data.addProperty("totalArtworks", totalArtworks);
        response_data.addProperty("totalPages", (totalArtworks + limitNum - 1) / limitNum);
        response_data.addProperty("currentPage", pageNum);
        
        response.getWriter().write(gson.toJson(response_data));
    }
    
    private void handleGetStats(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        JsonObject stats = new JsonObject();
        
        // Get platform statistics
        stats.addProperty("totalUsers", userDAO.getTotalUsersCount(null, null));
        stats.addProperty("totalArtists", userDAO.getTotalUsersCount(null, "ARTIST"));
        stats.addProperty("totalBuyers", userDAO.getTotalUsersCount(null, "BUYER"));
        stats.addProperty("totalArtworks", artworkDAO.getTotalArtworksCount(null, null));
        stats.addProperty("activeAuctions", artworkDAO.getActiveAuctionsCount());
        stats.addProperty("totalRevenue", artworkDAO.getTotalPlatformRevenue());
        stats.addProperty("monthlyRevenue", artworkDAO.getMonthlyRevenue());
        stats.addProperty("newUsersThisMonth", userDAO.getNewUsersThisMonth());
        
        JsonObject response_data = new JsonObject();
        response_data.addProperty("success", true);
        response_data.add("stats", stats);
        
        response.getWriter().write(gson.toJson(response_data));
    }
    
    private void handleActivateUser(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        String userId = request.getParameter("userId");
        
        if (userId == null || userId.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\": \"User ID is required\"}");
            return;
        }
        
        boolean success = userDAO.updateUserStatus(userId, true);
        
        JsonObject response_data = new JsonObject();
        response_data.addProperty("success", success);
        response_data.addProperty("message", success ? "User activated successfully" : "Failed to activate user");
        
        response.getWriter().write(gson.toJson(response_data));
    }
    
    private void handleDeactivateUser(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        String userId = request.getParameter("userId");
        
        if (userId == null || userId.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\": \"User ID is required\"}");
            return;
        }
        
        boolean success = userDAO.updateUserStatus(userId, false);
        
        JsonObject response_data = new JsonObject();
        response_data.addProperty("success", success);
        response_data.addProperty("message", success ? "User deactivated successfully" : "Failed to deactivate user");
        
        response.getWriter().write(gson.toJson(response_data));
    }
    
    private void handleVerifyUser(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        String userId = request.getParameter("userId");
        
        if (userId == null || userId.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\": \"User ID is required\"}");
            return;
        }
        
        boolean success = userDAO.updateUserVerification(userId, true);
        
        JsonObject response_data = new JsonObject();
        response_data.addProperty("success", success);
        response_data.addProperty("message", success ? "User verified successfully" : "Failed to verify user");
        
        response.getWriter().write(gson.toJson(response_data));
    }
    
    private void handleFeatureArtwork(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        String artworkId = request.getParameter("artworkId");
        String featured = request.getParameter("featured");
        
        if (artworkId == null || artworkId.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\": \"Artwork ID is required\"}");
            return;
        }
        
        boolean isFeatured = "true".equalsIgnoreCase(featured);
        boolean success = artworkDAO.updateArtworkFeatureStatus(artworkId, isFeatured);
        
        JsonObject response_data = new JsonObject();
        response_data.addProperty("success", success);
        response_data.addProperty("message", success ? 
            (isFeatured ? "Artwork featured successfully" : "Artwork unfeatured successfully") : 
            "Failed to update artwork feature status");
        
        response.getWriter().write(gson.toJson(response_data));
    }
    
    private void handleRemoveArtwork(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        String artworkId = request.getParameter("artworkId");
        
        if (artworkId == null || artworkId.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\": \"Artwork ID is required\"}");
            return;
        }
        
        boolean success = artworkDAO.removeArtwork(artworkId);
        
        JsonObject response_data = new JsonObject();
        response_data.addProperty("success", success);
        response_data.addProperty("message", success ? "Artwork removed successfully" : "Failed to remove artwork");
        
        response.getWriter().write(gson.toJson(response_data));
    }
}
