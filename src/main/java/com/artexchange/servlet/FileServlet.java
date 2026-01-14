package com.artexchange.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.logging.Logger;

/**
 * Servlet for serving uploaded files
 */
@WebServlet("/uploads/*")
public class FileServlet extends HttpServlet {
    private static final Logger logger = Logger.getLogger(FileServlet.class.getName());
    private static final String UPLOAD_DIR = "uploads";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String pathInfo = request.getPathInfo();
        
        if (pathInfo == null || pathInfo.equals("/")) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        
        // Remove leading slash from pathInfo
        String relativePath = pathInfo.substring(1);
        
        // Validate path to prevent directory traversal attacks
        // Allow subdirectories like "profiles/" but prevent ".."
        if (relativePath.contains("..") || relativePath.contains("\\")) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            logger.warning("Invalid path detected (directory traversal attempt): " + relativePath);
            return;
        }
        
        // Normalize path separators (convert / to system separator)
        String normalizedPath = relativePath.replace("/", File.separator);
        
        try {
            // Get the upload directory path
            String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
            Path filePath = Paths.get(uploadPath, normalizedPath);
            
            // Additional security: ensure the resolved path is within the upload directory
            Path uploadDirPath = Paths.get(uploadPath).normalize();
            Path resolvedFilePath = filePath.normalize();
            
            if (!resolvedFilePath.startsWith(uploadDirPath)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                logger.warning("Path traversal attempt detected: " + relativePath);
                return;
            }
            
            // Check if file exists
            if (!Files.exists(resolvedFilePath) || !Files.isRegularFile(resolvedFilePath)) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                logger.info("File not found: " + resolvedFilePath);
                return;
            }
            
            // Get filename for MIME type detection
            String fileName = resolvedFilePath.getFileName().toString();
            
            // Determine content type
            String mimeType = getServletContext().getMimeType(fileName);
            if (mimeType == null) {
                mimeType = "application/octet-stream";
            }
            response.setContentType(mimeType);
            
            // Set content length
            response.setContentLengthLong(Files.size(resolvedFilePath));
            
            // Set cache headers for images
            if (mimeType.startsWith("image/")) {
                response.setHeader("Cache-Control", "public, max-age=31536000"); // 1 year
                response.setHeader("Expires", "Thu, 31 Dec 2037 23:55:55 GMT");
            }
            
            // Stream the file to the response
            try (InputStream inputStream = Files.newInputStream(resolvedFilePath);
                 OutputStream outputStream = response.getOutputStream()) {
                
                byte[] buffer = new byte[8192];
                int bytesRead;
                while ((bytesRead = inputStream.read(buffer)) != -1) {
                    outputStream.write(buffer, 0, bytesRead);
                }
            }
            
            logger.info("Served file: " + relativePath);
            
        } catch (Exception e) {
            logger.severe("Error serving file " + relativePath + ": " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
