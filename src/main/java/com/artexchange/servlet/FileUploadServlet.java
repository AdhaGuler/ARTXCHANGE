package com.artexchange.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import com.google.gson.JsonObject;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;
import java.util.logging.Logger;

@WebServlet("/api/upload")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 20,      // 20MB per file
    maxRequestSize = 1024 * 1024 * 200   // 200MB total (for multiple files)
)
public class FileUploadServlet extends HttpServlet {
    private static final Logger logger = Logger.getLogger(FileUploadServlet.class.getName());
    private static final String UPLOAD_DIR = "uploads";
    private static final long MAX_FILE_SIZE = 20 * 1024 * 1024; // 20MB in bytes
    private static final String[] ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp"};
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        JsonObject jsonResponse = new JsonObject();
        
        try {
            // Get the upload directory path
            String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
            
            // Log the path for debugging
            logger.info("Upload path resolved to: " + uploadPath);
            
            // Create upload directory if it doesn't exist
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                logger.info("Creating upload directory: " + uploadPath);
                boolean created = uploadDir.mkdirs();
                logger.info("Directory creation result: " + created);
            } else {
                logger.info("Upload directory already exists: " + uploadPath);
            }
            
            // Get the file part from the request
            Part filePart = request.getPart("file");
            
            logger.info("File part received: " + (filePart != null));
            if (filePart != null) {
                logger.info("File part size: " + filePart.getSize());
                logger.info("File part content type: " + filePart.getContentType());
            }
            
            if (filePart == null || filePart.getSize() == 0) {
                logger.warning("No file uploaded or file is empty");
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "No file uploaded");
                response.getWriter().write(jsonResponse.toString());
                return;
            }
            
            // Validate file size (20MB max)
            long fileSize = filePart.getSize();
            if (fileSize > MAX_FILE_SIZE) {
                logger.warning("File size exceeds limit: " + fileSize + " bytes");
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "File size exceeds 20MB limit. Please upload a smaller file.");
                response.getWriter().write(jsonResponse.toString());
                return;
            }
            
            // Get original filename
            String originalFileName = getFileName(filePart);
            
            // Validate file extension
            if (!isValidFileType(originalFileName)) {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Invalid file type. Only JPG, PNG, and WebP files are allowed.");
                response.getWriter().write(jsonResponse.toString());
                return;
            }
            
            // Generate unique filename
            String fileExtension = getFileExtension(originalFileName);
            String uniqueFileName = UUID.randomUUID().toString() + fileExtension;
            
            // Create file path
            Path filePath = Paths.get(uploadPath, uniqueFileName);
            
            logger.info("Saving file to path: " + filePath.toString());
            
            // Save file
            try (InputStream inputStream = filePart.getInputStream()) {
                Files.copy(inputStream, filePath, StandardCopyOption.REPLACE_EXISTING);
                logger.info("File saved successfully: " + uniqueFileName);
            }
            
            // Verify file was created
            File savedFile = filePath.toFile();
            if (savedFile.exists()) {
                logger.info("File verification successful. Size: " + savedFile.length() + " bytes");
            } else {
                logger.severe("File was not created at expected location: " + filePath.toString());
            }
            
            // Generate URL for the uploaded file
            String fileUrl = request.getContextPath() + "/" + UPLOAD_DIR + "/" + uniqueFileName;
            
            logger.info("File uploaded successfully: " + uniqueFileName);
            
            jsonResponse.addProperty("success", true);
            jsonResponse.addProperty("message", "File uploaded successfully");
            jsonResponse.addProperty("fileName", uniqueFileName);
            jsonResponse.addProperty("fileUrl", fileUrl);
            jsonResponse.addProperty("originalName", originalFileName);
            
        } catch (Exception e) {
            logger.severe("Error uploading file: " + e.getMessage());
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Error uploading file: " + e.getMessage());
        }
        
        response.getWriter().write(jsonResponse.toString());
    }
    
    private String getFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        for (String content : contentDisposition.split(";")) {
            if (content.trim().startsWith("filename")) {
                return content.substring(content.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return null;
    }
    
    private String getFileExtension(String fileName) {
        if (fileName == null) return "";
        int lastDotIndex = fileName.lastIndexOf('.');
        if (lastDotIndex == -1) return "";
        return fileName.substring(lastDotIndex).toLowerCase();
    }
    
    private boolean isValidFileType(String fileName) {
        if (fileName == null) return false;
        String extension = getFileExtension(fileName);
        for (String allowedExt : ALLOWED_EXTENSIONS) {
            if (allowedExt.equals(extension)) {
                return true;
            }
        }
        return false;
    }
}
