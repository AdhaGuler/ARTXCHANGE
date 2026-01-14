package com.artexchange.servlet;

import com.artexchange.dao.ArtworkDAO;
import com.artexchange.dao.PurchaseDAO;
import com.artexchange.model.Artwork;
import com.artexchange.model.Purchase;
import com.artexchange.util.SessionUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.concurrent.ExecutionException;

/**
 * Servlet responsible for rendering the checkout experience for fixed-price artworks.
 */
@WebServlet(name = "CheckoutServlet", urlPatterns = {"/checkout/*"})
public class CheckoutServlet extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(CheckoutServlet.class);
    private transient ArtworkDAO artworkDAO;
    private transient PurchaseDAO purchaseDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        artworkDAO = new ArtworkDAO();
        purchaseDAO = new PurchaseDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();
        if (pathInfo == null || "/".equals(pathInfo) || pathInfo.trim().length() <= 1) {
            response.sendRedirect(request.getContextPath() + "/browse.jsp");
            return;
        }

        // Check if this is a purchase-based checkout (for auction wins)
        // Pattern: /checkout/purchase/{purchaseId}
        if (pathInfo.startsWith("/purchase/")) {
            handlePurchaseCheckout(request, response);
            return;
        }

        // Regular artwork checkout
        String artworkId = pathInfo.substring(1);

        try {
            Artwork artwork = artworkDAO.findById(artworkId);
            if (artwork == null) {
                response.sendRedirect(request.getContextPath() + "/browse.jsp");
                return;
            }

            boolean checkoutDisabled = false;
            String checkoutError = null;

            if (artwork.getSaleType() == Artwork.SaleType.AUCTION) {
                checkoutDisabled = true;
                checkoutError = "This artwork is currently available through auction bidding only.";
            } else if (artwork.getStatus() == Artwork.ArtworkStatus.SOLD) {
                checkoutDisabled = true;
                checkoutError = "This artwork has already been sold.";
            } else if (artwork.getStatus() != Artwork.ArtworkStatus.ACTIVE) {
                checkoutDisabled = true;
                checkoutError = "This artwork is not available for purchase right now.";
            }

            request.setAttribute("artwork", artwork);
            request.setAttribute("checkoutDisabled", checkoutDisabled);
            request.setAttribute("checkoutError", checkoutError);
            request.setAttribute("isAuctionWin", false);

            request.getRequestDispatcher("/checkout.jsp").forward(request, response);

        } catch (ExecutionException e) {
            logger.error("Failed to load checkout page for artwork {}", artworkId, e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Unable to load checkout page");
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            logger.error("Checkout page loading interrupted for artwork {}", artworkId, e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Unable to load checkout page");
        }
    }
    
    /**
     * Handle checkout for auction win purchases
     */
    private void handlePurchaseCheckout(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String pathInfo = request.getPathInfo();
        String purchaseId = pathInfo.substring("/purchase/".length());
        
        // Check authentication
        String currentUserId = SessionUtil.getCurrentUserId(request);
        if (currentUserId == null) {
            response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
            return;
        }
        
        try {
            Purchase purchase = purchaseDAO.findById(purchaseId);
            if (purchase == null) {
                logger.warn("Purchase not found: {}", purchaseId);
                response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
                return;
            }
            
            // Authorization check: only the buyer can complete payment
            if (!currentUserId.equals(purchase.getBuyerId())) {
                logger.warn("User {} attempted to access purchase {} owned by {}", 
                           currentUserId, purchaseId, purchase.getBuyerId());
                response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
                return;
            }
            
            // Check if purchase is in PENDING_PAYMENT status
            if (!"PENDING_PAYMENT".equals(purchase.getStatus())) {
                logger.warn("Purchase {} is not pending payment. Status: {}", purchaseId, purchase.getStatus());
                response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
                return;
            }
            
            // Check if payment deadline has passed
            if (purchase.getPaymentDeadline() != null && 
                purchase.getPaymentDeadline().isBefore(LocalDateTime.now())) {
                logger.warn("Payment deadline expired for purchase {}", purchaseId);
                request.setAttribute("checkoutError", "Payment deadline has expired. Please contact support.");
                request.setAttribute("checkoutDisabled", true);
            }
            
            // Get artwork details
            Artwork artwork = artworkDAO.findById(purchase.getArtworkId());
            if (artwork == null) {
                logger.error("Artwork not found for purchase {}", purchaseId);
                response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
                return;
            }
            
            // Set attributes for checkout page
            request.setAttribute("artwork", artwork);
            request.setAttribute("purchase", purchase);
            request.setAttribute("isAuctionWin", true);
            request.setAttribute("checkoutDisabled", false);
            request.setAttribute("checkoutError", null);
            
            request.getRequestDispatcher("/checkout.jsp").forward(request, response);
            
        } catch (ExecutionException e) {
            logger.error("Failed to load checkout page for purchase {}", purchaseId, e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Unable to load checkout page");
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            logger.error("Checkout page loading interrupted for purchase {}", purchaseId, e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Unable to load checkout page");
        }
    }
}

