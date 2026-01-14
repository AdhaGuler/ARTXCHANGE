package com.artexchange.listener;

import com.artexchange.util.AuctionProcessor;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.logging.Logger;

/**
 * Context listener to start automatic auction processing on application startup
 * Checks for ended auctions every 60 seconds and processes them automatically
 */
@WebListener
public class AuctionSchedulerListener implements ServletContextListener {
    private static final Logger logger = Logger.getLogger(AuctionSchedulerListener.class.getName());
    private ScheduledExecutorService scheduler;
    
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        logger.info("=== AuctionScheduler Initializing ===");
        
        // Create scheduled executor service with 1 thread
        scheduler = Executors.newScheduledThreadPool(1);
        
        // Schedule auction processing to run every 60 seconds
        // Initial delay of 30 seconds to allow app to fully start
        scheduler.scheduleAtFixedRate(() -> {
            try {
                logger.info("Running scheduled auction processing...");
                AuctionProcessor.processAllEndedAuctions();
                // Also process expired payments
                AuctionProcessor.processExpiredPayments();
            } catch (Exception e) {
                logger.severe("Error in scheduled auction processing: " + e.getMessage());
                e.printStackTrace();
            }
        }, 30, 60, TimeUnit.SECONDS);
        
        logger.info("=== AuctionScheduler Started Successfully ===");
        logger.info("Automatic auction processing will run every 60 seconds");
    }
    
    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        logger.info("=== AuctionScheduler Shutting Down ===");
        
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdown();
            try {
                // Wait up to 10 seconds for tasks to complete
                if (!scheduler.awaitTermination(10, TimeUnit.SECONDS)) {
                    logger.warning("Scheduler did not terminate in time, forcing shutdown");
                    scheduler.shutdownNow();
                }
                logger.info("=== AuctionScheduler Shut Down Successfully ===");
            } catch (InterruptedException e) {
                logger.warning("Interrupted while waiting for scheduler shutdown");
                scheduler.shutdownNow();
                Thread.currentThread().interrupt();
            }
        }
    }
}

