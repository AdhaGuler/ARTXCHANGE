package com.artexchange.servlet;

import com.artexchange.dao.UserDAO;
import com.artexchange.dao.ArtworkDAO;
import com.artexchange.model.User;
import com.artexchange.model.Artwork;
import com.artexchange.util.GsonUtil;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;

/**
 * Servlet for handling artist directory API requests
 */
@WebServlet(name = "ArtistsServlet", urlPatterns = {"/api/artists"})
public class ArtistsServlet extends HttpServlet {
    
    private UserDAO userDAO;
    private ArtworkDAO artworkDAO;
    private Gson gson;
    
    @Override
    public void init() throws ServletException {
        super.init();
        this.userDAO = new UserDAO();
        this.artworkDAO = new ArtworkDAO();
        this.gson = GsonUtil.getGson();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "*");
        
        try {
            // Get all artists from database
            List<User> artists = userDAO.findAllArtists();
            
            // Transform artists to include additional data (artwork count, etc.)
            List<Map<String, Object>> artistData = new ArrayList<>();
            
            for (User artist : artists) {
                Map<String, Object> artistMap = new HashMap<>();
                artistMap.put("id", artist.getUserId());
                artistMap.put("userId", artist.getUserId());
                artistMap.put("name", artist.getDisplayName());
                artistMap.put("username", artist.getUsername());
                artistMap.put("firstName", artist.getFirstName());
                artistMap.put("lastName", artist.getLastName());
                artistMap.put("avatar", artist.getProfileImageUrl() != null ? artist.getProfileImageUrl() : "");
                artistMap.put("bio", artist.getBio() != null ? artist.getBio() : "");
                artistMap.put("location", formatLocation(artist));
                artistMap.put("joinDate", artist.getCreatedAt() != null ? artist.getCreatedAt().toString() : "");
                artistMap.put("verified", artist.isVerified());
                
                // Get artwork count for this artist
                try {
                    List<Artwork> artworks = artworkDAO.findByArtistId(artist.getUserId());
                    artistMap.put("artworksCount", artworks != null ? artworks.size() : 0);
                    
                    // Get portfolio thumbnails (first 3 artworks)
                    List<String> portfolio = new ArrayList<>();
                    if (artworks != null && !artworks.isEmpty()) {
                        int count = Math.min(3, artworks.size());
                        for (int i = 0; i < count; i++) {
                            if (artworks.get(i).getImageUrls() != null && !artworks.get(i).getImageUrls().isEmpty()) {
                                portfolio.add(artworks.get(i).getImageUrls().get(0));
                            }
                        }
                    }
                    artistMap.put("portfolio", portfolio);
                } catch (Exception e) {
                    artistMap.put("artworksCount", 0);
                    artistMap.put("portfolio", new ArrayList<>());
                }
                
                // Get follower count
                artistMap.put("followersCount", artist.getFollowerCount());
                
                // Calculate average rating (would need ReviewDAO - for now set to 0)
                artistMap.put("rating", 0.0);
                
                // Map specialty from artist statement or default
                artistMap.put("specialty", "MIXED_MEDIA"); // Default, could be enhanced
                
                artistData.add(artistMap);
            }
            
            // Build response
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("success", true);
            responseData.put("artists", artistData);
            responseData.put("total", artistData.size());
            
            response.getWriter().write(gson.toJson(responseData));
            
        } catch (ExecutionException | InterruptedException e) {
            e.printStackTrace();
            JsonObject error = new JsonObject();
            error.addProperty("success", false);
            error.addProperty("error", "Failed to fetch artists: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write(gson.toJson(error));
        }
    }
    
    /**
     * Format location string from user address fields
     */
    private String formatLocation(User user) {
        List<String> parts = new ArrayList<>();
        if (user.getCity() != null && !user.getCity().isEmpty()) {
            parts.add(user.getCity());
        }
        if (user.getState() != null && !user.getState().isEmpty()) {
            parts.add(user.getState());
        }
        if (user.getCountry() != null && !user.getCountry().isEmpty()) {
            parts.add(user.getCountry());
        }
        return parts.isEmpty() ? "Location not specified" : String.join(", ", parts);
    }
}

