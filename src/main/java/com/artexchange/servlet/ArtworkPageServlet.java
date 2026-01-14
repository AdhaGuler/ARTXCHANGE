package com.artexchange.servlet;

import com.artexchange.dao.ArtworkDAO;
import com.artexchange.model.Artwork;
import com.artexchange.util.SessionUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.concurrent.ExecutionException;
import java.util.logging.Logger;

/**
 * Servlet for handling artwork detail page requests
 */
@WebServlet(name = "ArtworkPageServlet", urlPatterns = {"/artwork/*"})
public class ArtworkPageServlet extends HttpServlet {
    private static final Logger logger = Logger.getLogger(ArtworkPageServlet.class.getName());
    private ArtworkDAO artworkDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        artworkDAO = new ArtworkDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String pathInfo = request.getPathInfo();
        
        if (pathInfo == null || pathInfo.equals("/")) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Artwork ID is required");
            return;
        }
        
        // Extract artwork ID from path
        String artworkId = pathInfo.substring(1); // Remove leading slash
        
        try {
            // Fetch artwork from database
            Artwork artwork = artworkDAO.findById(artworkId);
            
            if (artwork == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Artwork not found");
                return;
            }
            
            // Increment view count
            artwork.incrementViews();
            artworkDAO.updateArtwork(artwork);
            
            // Set artwork as request attribute
            request.setAttribute("artwork", artwork);
            
            // Forward to artwork detail JSP
            request.getRequestDispatcher("/artwork-detail.jsp").forward(request, response);
            
        } catch (ExecutionException | InterruptedException e) {
            logger.severe("Error loading artwork: " + e.getMessage());
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading artwork");
        }
    }
}
