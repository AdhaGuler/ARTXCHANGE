package com.artexchange.servlet;

import com.artexchange.dao.ArtworkDAO;
import com.artexchange.dao.PurchaseDAO;
import com.artexchange.model.Artwork;
import com.artexchange.model.Purchase;
import com.artexchange.model.User;
import com.artexchange.util.SessionUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.concurrent.ExecutionException;

/**
 * Servlet responsible for rendering the purchase receipt view.
 */
@WebServlet(name = "ReceiptServlet", urlPatterns = {"/receipt/*"})
public class ReceiptServlet extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(ReceiptServlet.class);
    private transient PurchaseDAO purchaseDAO;
    private transient ArtworkDAO artworkDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        purchaseDAO = new PurchaseDAO();
        artworkDAO = new ArtworkDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = SessionUtil.getCurrentUser(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }

        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.length() <= 1) {
            response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
            return;
        }

        String purchaseId = pathInfo.substring(1);

        try {
            Purchase purchase = purchaseDAO.findById(purchaseId);
            if (purchase == null) {
                response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
                return;
            }

            boolean isBuyer = currentUser.getUserId().equals(purchase.getBuyerId());
            boolean isSeller = currentUser.getUserId().equals(purchase.getSellerId());

            if (!isBuyer && !isSeller) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "You do not have access to this receipt.");
                return;
            }

            Artwork artwork = artworkDAO.findById(purchase.getArtworkId());

            request.setAttribute("purchase", purchase);
            request.setAttribute("artwork", artwork);
            request.setAttribute("isBuyer", isBuyer);
            request.setAttribute("isSeller", isSeller);

            request.getRequestDispatcher("/receipt.jsp").forward(request, response);
        } catch (ExecutionException e) {
            logger.error("Failed to load purchase receipt {}", purchaseId, e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Unable to load receipt");
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            logger.error("Receipt loading interrupted {}", purchaseId, e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Unable to load receipt");
        }
    }
}

