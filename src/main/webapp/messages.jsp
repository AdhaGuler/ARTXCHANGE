<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Messages - ArtXchange</title>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Font Awesome -->
    <link
      href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"
      rel="stylesheet"
    />
    <!-- Bootstrap for navbar only -->
    <link
      href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"
      rel="stylesheet"
    />
    <style>
      /* Global full height */
      html, body {
        height: 100%;
        margin: 0;
        padding: 0;
      }

      /* Black and white theme for navbar */
      .navbar-purple-gradient {
        background: #1a1a1a;
        color: white;
        border-bottom: 1px solid #e0e0e0;
      }

      /* Custom scrollbar styling */
      .custom-scrollbar::-webkit-scrollbar {
        width: 6px;
      }
      .custom-scrollbar::-webkit-scrollbar-track {
        background: transparent;
      }
      .custom-scrollbar::-webkit-scrollbar-thumb {
        background: #cbd5e1;
        border-radius: 3px;
      }
      .custom-scrollbar::-webkit-scrollbar-thumb:hover {
        background: #94a3b8;
      }
      
      /* Smooth scrolling */
      .smooth-scroll {
        scroll-behavior: smooth;
      }
      
      /* Message bubble animations */
      @keyframes fadeIn {
        from {
          opacity: 0;
          transform: translateY(4px);
        }
        to {
          opacity: 1;
          transform: translateY(0);
        }
      }
      .message-enter {
        animation: fadeIn 0.2s ease-out;
      }

      /* Messages wrapper - full height flex */
      .messages-wrapper {
        display: flex;
        height: calc(100vh - 56px);
        overflow: hidden;
      }

      /* Sidebar - fixed width, scrollable */
      .conversations-sidebar {
        display: flex;
        flex-direction: column;
        width: 280px;
        min-width: 280px;
        background-color: white;
        border-right: 1px solid #e5e7eb;
        height: 100vh;
      }

      /* Chat column - flex column */
      .chat-column {
        display: flex;
        flex-direction: column;
        flex: 1;
        height: 100%;
        background-color: #f9fafb;
        min-height: 0;
      }

      /* Messages body - scrollable */
      .messages-body {
        flex: 1;
        overflow-y: auto;
        -webkit-overflow-scrolling: touch;
        scroll-behavior: smooth;
        min-height: 0;
      }

      /* Chat input - fixed */
      .chat-input {
        flex: 0 0 auto;
      }

      /* User Menu Styles */
      .user-menu-wrapper {
        position: relative;
        overflow: visible;
      }

      .navbar-nav {
        position: relative;
        overflow: visible;
      }

      .nav-item {
        position: static;
        overflow: visible;
      }

      .navbar .container {
        overflow: visible !important;
      }

      .navbar {
        overflow: visible !important;
      }

      .user-menu-trigger {
        display: flex;
        align-items: center;
        gap: 8px;
        background: transparent;
        border: none;
        color: rgba(255, 255, 255, 0.95);
        padding: 6px 12px;
        border-radius: 20px;
        cursor: pointer;
        transition: background-color 0.2s ease;
        font-size: 14px;
      }

      .user-menu-trigger:hover {
        background-color: rgba(255, 255, 255, 0.15);
      }

      .user-menu-trigger:focus {
        outline: 2px solid rgba(255, 255, 255, 0.5);
        outline-offset: 2px;
      }

      .user-avatar-wrapper {
        position: relative;
        flex-shrink: 0;
      }

      .user-avatar {
        width: 32px;
        height: 32px;
        border-radius: 50%;
        object-fit: cover;
        border: 2px solid rgba(255, 255, 255, 0.4);
      }

      .online-indicator {
        position: absolute;
        bottom: 0;
        right: 0;
        width: 10px;
        height: 10px;
        background-color: #31a24c;
        border: 2px solid white;
        border-radius: 50%;
      }

      .user-name {
        font-weight: 500;
      }

      .user-menu-arrow {
        font-size: 10px;
        transition: transform 0.2s ease;
      }

      .user-menu-trigger[aria-expanded="true"] .user-menu-arrow {
        transform: rotate(180deg);
      }

      .user-menu-dropdown {
        /* Original dropdown - hidden, used as template */
        display: none;
      }

      .user-menu-dropdown-portal {
        /* Portal dropdown - rendered to body */
        position: fixed;
        background: white;
        border: 1px solid #e6e6e6;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        min-width: 180px;
        padding: 4px 0;
        opacity: 0;
        visibility: hidden;
        transform: translateY(-8px);
        transition: opacity 0.15s ease, transform 0.15s ease, visibility 0.15s ease;
        z-index: 9999;
        display: block;
        pointer-events: none;
      }

      .user-menu-dropdown-portal.show {
        opacity: 1;
        visibility: visible;
        transform: translateY(0);
        pointer-events: auto;
      }


      .user-menu-item {
        display: block;
        width: 100%;
        padding: 12px 16px;
        color: #333;
        text-decoration: none;
        font-size: 14px;
        text-align: left;
        background: none;
        border: none;
        cursor: pointer;
        transition: background-color 0.15s ease;
      }

      .user-menu-item:hover,
      .user-menu-item:focus {
        background-color: #f5f5f5;
        outline: none;
      }

      .user-menu-item-button {
        width: 100%;
        text-align: left;
      }

      .user-menu-divider {
        height: 1px;
        background-color: #e6e6e6;
        margin: 4px 0;
      }

      /* Messages Page Menu Styles */
      .messages-menu-wrapper {
        position: relative;
        overflow: visible;
      }

      .messages-menu-trigger {
        display: flex !important;
        visibility: visible !important;
        opacity: 1 !important;
        align-items: center;
        justify-content: center;
        background: #ffffff !important;
        border: 1px solid #e5e7eb !important;
        cursor: pointer;
        transition: all 0.2s ease;
        position: relative;
        z-index: 10;
        box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        width: 36px;
        height: 36px;
      }

      .messages-menu-trigger:hover {
        background-color: #f3f4f6 !important;
        border-color: #d1d5db !important;
        transform: scale(1.05);
      }
      
      .messages-menu-trigger i {
        color: #374151 !important;
        font-size: 16px !important;
        display: inline-block !important;
        font-weight: 600;
      }

      .messages-menu-trigger:focus {
        outline: 2px solid rgba(99, 102, 241, 0.5);
        outline-offset: 2px;
      }

      .messages-menu-trigger[aria-expanded="true"] {
        background-color: rgba(0, 0, 0, 0.08);
      }

      .messages-menu-dropdown {
        position: fixed;
        background: white;
        border: 1px solid #e6e6e6;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        min-width: 180px;
        padding: 4px 0;
        opacity: 0;
        visibility: hidden;
        transform: translateY(-8px);
        transition: opacity 0.15s ease, transform 0.15s ease, visibility 0.15s ease;
        z-index: 9999;
        pointer-events: none;
      }

      .messages-menu-dropdown.show {
        opacity: 1;
        visibility: visible;
        transform: translateY(0);
        pointer-events: auto;
      }

      .messages-menu-item {
        display: flex;
        align-items: center;
        width: 100%;
        padding: 10px 16px;
        color: #333;
        text-decoration: none;
        font-size: 14px;
        text-align: left;
        background: none;
        border: none;
        cursor: pointer;
        transition: background-color 0.15s ease;
      }

      .messages-menu-item:hover,
      .messages-menu-item:focus {
        background-color: #f5f5f5;
        outline: none;
      }

      .messages-menu-item i {
        width: 16px;
        text-align: center;
      }

      .messages-menu-item-button {
        width: 100%;
        text-align: left;
      }

      .messages-menu-divider {
        height: 1px;
        background-color: #e6e6e6;
        margin: 4px 0;
      }

      /* Mobile responsive */
      @media (max-width: 1024px) {
        .conversations-sidebar {
          position: fixed;
          left: -280px;
          z-index: 1000;
          transition: left 0.3s ease;
          box-shadow: 2px 0 8px rgba(0, 0, 0, 0.1);
        }
        .conversations-sidebar.open {
          left: 0;
        }

        .user-name {
          display: none;
        }

        .user-menu-dropdown-portal {
          min-width: 160px;
        }

        .messages-menu-dropdown {
          min-width: 160px;
        }
      }
    </style>
  </head>
  <body>
    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark navbar-purple-gradient" style="position: fixed; top: 0; left: 0; right: 0; z-index: 1000; height: 56px; overflow: visible;">
      <div class="container" style="overflow: visible; position: relative;">
        <a
          class="navbar-brand fw-bold"
          href="${pageContext.request.contextPath}/"
          style="color: white;"
        >
          <i class="fas fa-palette me-2"></i>ArtXchange
        </a>

        <button
          class="navbar-toggler"
          type="button"
          data-bs-toggle="collapse"
          data-bs-target="#navbarNav"
        >
          <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbarNav">
          <ul class="navbar-nav me-auto">
            <li class="nav-item">
              <a
                class="nav-link"
                href="${pageContext.request.contextPath}/browse.jsp"
                style="color: rgba(255, 255, 255, 0.95);"
                >Browse</a
              >
            </li>
            <li class="nav-item">
              <a
                class="nav-link"
                href="${pageContext.request.contextPath}/dashboard.jsp"
                style="color: rgba(255, 255, 255, 0.95);"
                >Dashboard</a
              >
            </li>
            <li class="nav-item">
              <a
                class="nav-link active"
                href="${pageContext.request.contextPath}/messages.jsp"
                style="color: white; font-weight: 500;"
                >Messages</a
              >
            </li>
            <li class="nav-item" id="biddings-nav" style="display: none;">
              <a
                class="nav-link"
                href="${pageContext.request.contextPath}/biddings.jsp"
                style="color: rgba(255, 255, 255, 0.95);"
                ><i class="fas fa-gavel me-1"></i>Biddings</a
              >
            </li>
          </ul>

          <ul class="navbar-nav">
            <li class="nav-item">
              <div class="user-menu-wrapper">
                <button
                  id="userMenuTrigger"
                  class="user-menu-trigger"
                  aria-haspopup="true"
                  aria-expanded="false"
                  aria-label="User menu"
                >
                  <div class="user-avatar-wrapper">
                    <img
                      id="userAvatar"
                      src=""
                      alt="User"
                      class="user-avatar"
                      width="32"
                      height="32"
                    />
                    <span class="online-indicator" id="userOnlineIndicator" style="display: none;"></span>
                  </div>
                  <span id="userName" class="user-name">Loading...</span>
                  <i class="fas fa-chevron-down user-menu-arrow"></i>
                </button>
                <div
                  id="userMenuDropdown"
                  class="user-menu-dropdown"
                  role="menu"
                  aria-labelledby="userMenuTrigger"
                >
                  <a
                    href="${pageContext.request.contextPath}/profile.jsp"
                    class="user-menu-item"
                    role="menuitem"
                    tabindex="0"
                  >
                    My Profile
                  </a>
                  <a
                    href="${pageContext.request.contextPath}/dashboard.jsp"
                    class="user-menu-item"
                    role="menuitem"
                    tabindex="0"
                  >
                    My Dashboard
                  </a>
                  <a
                    href="${pageContext.request.contextPath}/messages.jsp"
                    class="user-menu-item"
                    role="menuitem"
                    tabindex="0"
                  >
                    Messages
                  </a>
                  <div class="user-menu-divider"></div>
                  <button
                    class="user-menu-item user-menu-item-button"
                    role="menuitem"
                    tabindex="0"
                    onclick="handleLogout()"
                  >
                    Logout
                  </button>
                </div>
              </div>
            </li>
          </ul>
        </div>
      </div>
    </nav>

    <!-- Messages Wrapper - Full Height Flex -->
    <div class="messages-wrapper" style="margin-top: 56px;" data-context-path="${pageContext.request.contextPath}">
      <!-- Mobile Sidebar Toggle -->
      <button 
        class="lg:hidden fixed top-20 left-4 z-50 bg-white border border-gray-200 rounded-full w-10 h-10 flex items-center justify-center shadow-md hover:bg-gray-50 transition-colors"
        onclick="toggleSidebar()"
        aria-label="Toggle conversations"
        id="sidebarToggle"
      >
        <i class="fas fa-bars text-gray-600"></i>
      </button>

      <!-- Left Sidebar - Conversations List -->
      <div class="conversations-sidebar" id="conversationsSidebar">
        <div id="conversationListContainer"></div>
      </div>

      <!-- Right Panel - Chat Column -->
      <div class="chat-column">
        <div id="chatWindowContainer" style="display: flex; flex-direction: column; height: 100%; min-height: 0;"></div>
      </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-auth-compat.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/firebase-config.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/auth.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/user-menu.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/messages-components.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/messages.js"></script>
  </body>
</html>
