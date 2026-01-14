package com.artexchange.servlet;

import com.artexchange.dao.AuctionDAO;
import com.artexchange.util.SessionUtil;
import com.artexchange.util.GsonUtil;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/api/biddings")
public class BiddingsServlet extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(BiddingsServlet.class);
    private final Gson gson = GsonUtil.getGson();
    private final AuctionDAO auctionDAO = new AuctionDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        // Use session user ID - SIMPLE!
        String currentUserId = SessionUtil.getCurrentUserId(request);
        logger.info("=== BiddingsServlet: Session user ID from SessionUtil: '" + currentUserId + "' ===");

        // For debugging, let's see what's in the session
        HttpSession session = request.getSession(false);
        if (session != null) {
            logger.info("Session ID: " + session.getId());
            logger.info("Session User ID Attribute ('userId'): '" + session.getAttribute("userId") + "'");
            logger.info("Session User Role Attribute ('userRole'): '" + session.getAttribute("userRole") + "'");
        } else {
            logger.warn("BiddingsServlet: HttpSession is null!");
        }

        if (currentUserId == null || currentUserId.trim().isEmpty()) {
            logger.error("BiddingsServlet: currentUserId is null or empty. Cannot fetch biddings.");
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            JsonObject error = new JsonObject();
            error.addProperty("error", "Authentication required: User ID not found in session.");
            response.getWriter().write(gson.toJson(error));
            return;
        }
        
        logger.info("=== BiddingsServlet: Getting bids for user ID: '" + currentUserId + "' ===");
        
        try {
            // Get status filter
            String status = request.getParameter("status");
            
            // Get user's biddings using the SESSION USER ID
            List<Map<String, Object>> biddings = auctionDAO.getUserBiddings(currentUserId, status);
            
            logger.info("Found " + biddings.size() + " biddings for user " + currentUserId);
            
            // Prepare response
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("success", true);
            responseData.put("biddings", biddings);
            responseData.put("totalCount", biddings.size());
            
            response.getWriter().write(gson.toJson(responseData));
            
        } catch (Exception e) {
            logger.error("Error in BiddingsServlet: ", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JsonObject error = new JsonObject();
            error.addProperty("error", "Internal server error");
            response.getWriter().write(gson.toJson(error));
        }
    }
}
