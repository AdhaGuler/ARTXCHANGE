<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - ArtXchange</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/main.css" rel="stylesheet">
    <style>
        .admin-sidebar {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            color: white;
        }
        
        .admin-content {
            background-color: #f8f9fa;
            min-height: 100vh;
        }
        
        .stat-card {
            background: white;
            border-radius: 10px;
            padding: 25px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            transition: transform 0.3s ease;
        }
        
        .stat-card:hover {
            transform: translateY(-5px);
        }
        
        .stat-icon {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            color: white;
        }
        
        .table-responsive {
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .nav-pills .nav-link {
            color: rgba(255,255,255,0.8);
            border-radius: 50px;
            margin-bottom: 10px;
        }
        
        .nav-pills .nav-link.active {
            background-color: rgba(255,255,255,0.2);
            color: white;
        }
        
        .nav-pills .nav-link:hover {
            background-color: rgba(255,255,255,0.1);
            color: white;
        }
    </style>
</head>
<body>
    <%
        com.artexchange.model.User currentUser = (com.artexchange.model.User) session.getAttribute("currentUser");
        if (currentUser == null || currentUser.getRole() == null || !"ADMIN".equals(currentUser.getRole().name())) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }
    %>
    <div class="container-fluid">
        <div class="row">
            <!-- Admin Sidebar -->
            <div class="col-md-3 col-lg-2 admin-sidebar p-0">
                <div class="p-4">
                    <div class="text-center mb-4">
                        <h4 class="mb-0">
                            <i class="fas fa-palette me-2"></i>ArtXchange
                        </h4>
                        <small class="text-white-50">Admin Panel</small>
                    </div>
                    
                    <ul class="nav nav-pills flex-column">
                        <li class="nav-item">
                            <a class="nav-link active" href="#" onclick="showDashboard()">
                                <i class="fas fa-chart-bar me-2"></i>Dashboard
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="#" onclick="showUsers()">
                                <i class="fas fa-users me-2"></i>Users
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="#" onclick="showArtworks()">
                                <i class="fas fa-palette me-2"></i>Artworks
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="#" onclick="showReports()">
                                <i class="fas fa-chart-line me-2"></i>Reports
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="#" onclick="showSettings()">
                                <i class="fas fa-cog me-2"></i>Settings
                            </a>
                        </li>
                        <li class="nav-item mt-3">
                            <a class="nav-link" href="${pageContext.request.contextPath}/">
                                <i class="fas fa-arrow-left me-2"></i>Back to Site
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="#" onclick="logout()">
                                <i class="fas fa-sign-out-alt me-2"></i>Logout
                            </a>
                        </li>
                    </ul>
                </div>
            </div>
            
            <!-- Main Content -->
            <div class="col-md-9 col-lg-10 admin-content">
                <!-- Header -->
                <div class="bg-white border-bottom p-4">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h2 class="mb-0" id="pageTitle">Admin Dashboard</h2>
                            <p class="text-muted mb-0" id="pageSubtitle">Welcome to the ArtXchange admin panel</p>
                        </div>
                        <div class="d-flex align-items-center">
                            <div class="me-3">
                                <small class="text-muted">Last updated:</small>
                                <div id="lastUpdated" class="fw-bold">Loading...</div>
                            </div>
                            <button class="btn btn-primary" onclick="refreshData()">
                                <i class="fas fa-sync-alt me-2"></i>Refresh
                            </button>
                        </div>
                    </div>
                </div>
                
                <!-- Content Area -->
                <div class="p-4">
                    <!-- Dashboard View -->
                    <div id="dashboardView">
                        <!-- Stats Cards -->
                        <div class="row mb-4" id="statsContainer">
                            <!-- Stats will be loaded here -->
                        </div>
                        
                        <!-- Charts Row -->
                        <div class="row mb-4">
                            <div class="col-md-6">
                                <div class="card">
                                    <div class="card-header">
                                        <h5 class="mb-0"><i class="fas fa-chart-line me-2"></i>User Growth</h5>
                                    </div>
                                    <div class="card-body">
                                        <canvas id="userGrowthChart" height="300"></canvas>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="card">
                                    <div class="card-header">
                                        <h5 class="mb-0"><i class="fas fa-dollar-sign me-2"></i>Revenue Overview</h5>
                                    </div>
                                    <div class="card-body">
                                        <canvas id="revenueChart" height="300"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Recent Activity -->
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h5 class="mb-0"><i class="fas fa-clock me-2"></i>Recent Activity</h5>
                                    </div>
                                    <div class="card-body" id="recentActivity">
                                        <!-- Activity will be loaded here -->
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Users View -->
                    <div id="usersView" style="display: none;">
                        <div class="card">
                            <div class="card-header">
                                <div class="row">
                                    <div class="col-md-6">
                                        <h5 class="mb-0"><i class="fas fa-users me-2"></i>User Management</h5>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="d-flex gap-2">
                                            <input type="text" class="form-control" id="userSearch" placeholder="Search users...">
                                            <select class="form-select" id="roleFilter">
                                                <option value="">All Roles</option>
                                                <option value="BUYER">Buyers</option>
                                                <option value="ARTIST">Artists</option>
                                                <option value="ADMIN">Admins</option>
                                            </select>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-hover">
                                        <thead class="table-dark">
                                            <tr>
                                                <th>User</th>
                                                <th>Email</th>
                                                <th>Role</th>
                                                <th>Status</th>
                                                <th>Joined</th>
                                                <th>Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody id="usersTableBody">
                                            <!-- Users will be loaded here -->
                                        </tbody>
                                    </table>
                                </div>
                                
                                <!-- Pagination -->
                                <div id="usersPagination" class="d-flex justify-content-center mt-3">
                                    <!-- Pagination will be loaded here -->
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Artworks View -->
                    <div id="artworksView" style="display: none;">
                        <div class="card">
                            <div class="card-header">
                                <div class="row">
                                    <div class="col-md-6">
                                        <h5 class="mb-0"><i class="fas fa-palette me-2"></i>Artwork Management</h5>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="d-flex gap-2">
                                            <input type="text" class="form-control" id="artworkSearch" placeholder="Search artworks...">
                                            <select class="form-select" id="statusFilter">
                                                <option value="">All Status</option>
                                                <option value="ACTIVE">Active</option>
                                                <option value="SOLD">Sold</option>
                                                <option value="REMOVED">Removed</option>
                                            </select>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-hover">
                                        <thead class="table-dark">
                                            <tr>
                                                <th>Artwork</th>
                                                <th>Artist</th>
                                                <th>Category</th>
                                                <th>Price</th>
                                                <th>Status</th>
                                                <th>Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody id="artworksTableBody">
                                            <!-- Artworks will be loaded here -->
                                        </tbody>
                                    </table>
                                </div>
                                
                                <!-- Pagination -->
                                <div id="artworksPagination" class="d-flex justify-content-center mt-3">
                                    <!-- Pagination will be loaded here -->
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Reports View -->
                    <div id="reportsView" style="display: none;">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="card">
                                    <div class="card-header">
                                        <h5 class="mb-0"><i class="fas fa-chart-pie me-2"></i>Sales Report</h5>
                                    </div>
                                    <div class="card-body">
                                        <canvas id="salesChart" height="300"></canvas>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="card">
                                    <div class="card-header">
                                        <h5 class="mb-0"><i class="fas fa-users me-2"></i>User Analytics</h5>
                                    </div>
                                    <div class="card-body">
                                        <canvas id="userAnalyticsChart" height="300"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Settings View -->
                    <div id="settingsView" style="display: none;">
                        <div class="card">
                            <div class="card-header">
                                <h5 class="mb-0"><i class="fas fa-cog me-2"></i>Platform Settings</h5>
                            </div>
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-md-6">
                                        <h6>General Settings</h6>
                                        <div class="mb-3">
                                            <label class="form-label">Platform Commission (%)</label>
                                            <input type="number" class="form-control" value="5" min="0" max="20">
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label">Max File Size (MB)</label>
                                            <input type="number" class="form-control" value="10" min="1" max="50">
                                        </div>
                                        <div class="form-check">
                                            <input class="form-check-input" type="checkbox" id="autoApprove" checked>
                                            <label class="form-check-label" for="autoApprove">
                                                Auto-approve new artworks
                                            </label>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <h6>Email Settings</h6>
                                        <div class="form-check">
                                            <input class="form-check-input" type="checkbox" id="emailNotifications" checked>
                                            <label class="form-check-label" for="emailNotifications">
                                                Send email notifications
                                            </label>
                                        </div>
                                        <div class="form-check">
                                            <input class="form-check-input" type="checkbox" id="weeklyReports" checked>
                                            <label class="form-check-label" for="weeklyReports">
                                                Send weekly reports
                                            </label>
                                        </div>
                                    </div>
                                </div>
                                <button class="btn btn-primary mt-3">Save Settings</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-auth-compat.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/firebase-config.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/auth.js"></script>
    <script>
        let currentUser = null;
        let currentView = 'dashboard';
        let currentPage = 0;
        let platformStats = {};
        
        // Initialize page
        document.addEventListener('DOMContentLoaded', function() {
            firebase.auth().onAuthStateChanged(async function(user) {
                if (user) {
                    try {
                        // Verify token with backend like in auth.js
                        const idToken = await user.getIdToken();
                        const response = await fetch('/auth/verify-token', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json',
                            },
                            body: JSON.stringify({ idToken: idToken })
                        });
                        
                        if (response.ok) {
                            const data = await response.json();
                            if (data.success && data.user) {
                                currentUser = data.user;
                                checkAdminAccess();
                            } else {
                                console.warn('User verification failed on admin dashboard:', data.message);
                                window.location.href = '/';
                            }
                        } else if (response.status === 404) {
                            console.warn('User not found in database on admin dashboard');
                            window.location.href = '/';
                        } else {
                            console.error('Authentication verification failed on admin dashboard with status:', response.status);
                            window.location.href = '/';
                        }
                    } catch (error) {
                        console.error('Auth verification error on admin dashboard:', error);
                        window.location.href = '/';
                    }
                } else {
                    window.location.href = '/';
                }
            });
        });
        
        function checkAdminAccess() {
            // Verify admin access with backend
            fetch('/api/auth/profile')
                .then(response => response.json())
                .then(data => {
                    if (data.success && data.user.role === 'ADMIN') {
                        initializeAdminPanel();
                    } else {
                        alert('Access denied. Admin privileges required.');
                        window.location.href = '/';
                    }
                })
                .catch(error => {
                    console.error('Error checking admin access:', error);
                    window.location.href = '/';
                });
        }
        
        function initializeAdminPanel() {
            loadPlatformStats();
            showDashboard();
            updateLastUpdated();
            
            // Set up search and filter handlers
            document.getElementById('userSearch').addEventListener('input', debounce(loadUsers, 500));
            document.getElementById('roleFilter').addEventListener('change', loadUsers);
            document.getElementById('artworkSearch').addEventListener('input', debounce(loadArtworks, 500));
            document.getElementById('statusFilter').addEventListener('change', loadArtworks);
        }
        
        function loadPlatformStats() {
            fetch('/artexchange/admin/stats')
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        platformStats = data.stats;
                        displayPlatformStats(platformStats);
                    }
                })
                .catch(error => console.error('Error loading platform stats:', error));
        }
        
        function displayPlatformStats(stats) {
            const container = document.getElementById('statsContainer');
            container.innerHTML = 
                '<div class="col-md-3">' +
                    '<div class="stat-card text-center">' +
                        '<div class="stat-icon bg-primary mx-auto mb-3">' +
                            '<i class="fas fa-users"></i>' +
                        '</div>' +
                        '<h3 class="mb-0">' + (stats.totalUsers || 0) + '</h3>' +
                        '<p class="text-muted mb-0">Total Users</p>' +
                        '<small class="text-success">+' + (stats.newUsersThisMonth || 0) + ' this month</small>' +
                    '</div>' +
                '</div>' +
                '<div class="col-md-3">' +
                    '<div class="stat-card text-center">' +
                        '<div class="stat-icon bg-success mx-auto mb-3">' +
                            '<i class="fas fa-palette"></i>' +
                        '</div>' +
                        '<h3 class="mb-0">' + (stats.totalArtworks || 0) + '</h3>' +
                        '<p class="text-muted mb-0">Total Artworks</p>' +
                        '<small class="text-info">' + (stats.activeAuctions || 0) + ' active auctions</small>' +
                    '</div>' +
                '</div>' +
                '<div class="col-md-3">' +
                    '<div class="stat-card text-center">' +
                        '<div class="stat-icon bg-warning mx-auto mb-3">' +
                            '<i class="fas fa-dollar-sign"></i>' +
                        '</div>' +
                        '<h3 class="mb-0">RM ' + (stats.totalRevenue || 0).toLocaleString() + '</h3>' +
                        '<p class="text-muted mb-0">Total Revenue</p>' +
                        '<small class="text-success">+RM ' + (stats.monthlyRevenue || 0).toLocaleString() + ' this month</small>' +
                    '</div>' +
                '</div>' +
                '<div class="col-md-3">' +
                    '<div class="stat-card text-center">' +
                        '<div class="stat-icon bg-info mx-auto mb-3">' +
                            '<i class="fas fa-chart-line"></i>' +
                        '</div>' +
                        '<h3 class="mb-0">' + (stats.totalArtists || 0) + '</h3>' +
                        '<p class="text-muted mb-0">Active Artists</p>' +
                        '<small class="text-primary">' + (stats.totalBuyers || 0) + ' buyers</small>' +
                    '</div>' +
                '</div>';
        }
        
        // Navigation functions
        function showDashboard() {
            setActiveView('dashboard');
            document.getElementById('pageTitle').textContent = 'Admin Dashboard';
            document.getElementById('pageSubtitle').textContent = 'Welcome to the ArtXchange admin panel';
            loadRecentActivity();
            initializeCharts();
        }
        
        function showUsers() {
            setActiveView('users');
            document.getElementById('pageTitle').textContent = 'User Management';
            document.getElementById('pageSubtitle').textContent = 'Manage platform users and their access';
            loadUsers();
        }
        
        function showArtworks() {
            setActiveView('artworks');
            document.getElementById('pageTitle').textContent = 'Artwork Management';
            document.getElementById('pageSubtitle').textContent = 'Manage artworks and content moderation';
            loadArtworks();
        }
        
        function showReports() {
            setActiveView('reports');
            document.getElementById('pageTitle').textContent = 'Reports & Analytics';
            document.getElementById('pageSubtitle').textContent = 'Platform performance and analytics';
            initializeReportsCharts();
        }
        
        function showSettings() {
            setActiveView('settings');
            document.getElementById('pageTitle').textContent = 'Platform Settings';
            document.getElementById('pageSubtitle').textContent = 'Configure platform settings and preferences';
        }
        
        function setActiveView(viewName) {
            // Hide all views
            document.querySelectorAll('[id$="View"]').forEach(view => {
                view.style.display = 'none';
            });
            
            // Show selected view
            document.getElementById(viewName + 'View').style.display = 'block';
            
            // Update navigation
            document.querySelectorAll('.nav-pills .nav-link').forEach(link => {
                link.classList.remove('active');
            });
            
            currentView = viewName;
        }
        
        function loadUsers() {
            const search = document.getElementById('userSearch').value;
            const role = document.getElementById('roleFilter').value;
            
            const params = new URLSearchParams({
                page: currentPage,
                limit: 20
            });
            
            if (search) params.append('search', search);
            if (role) params.append('role', role);
            
            fetch(`/artexchange/admin/users?${params}`)
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        displayUsers(data.users);
                        displayUsersPagination(data.currentPage, data.totalPages);
                    }
                })
                .catch(error => console.error('Error loading users:', error));
        }
        
        function displayUsers(users) {
            const tbody = document.getElementById('usersTableBody');
            tbody.innerHTML = users.map(user => 
                '<tr>' +
                    '<td>' +
                        '<div class="d-flex align-items-center">' +
                            '<img src="' + (user.profileImage || '/assets/images/default-avatar.svg') + '" ' +
                                 'alt="' + user.username + '" class="rounded-circle me-2" width="40" height="40">' +
                            '<div>' +
                                '<div class="fw-bold">' + user.firstName + ' ' + user.lastName + '</div>' +
                                '<small class="text-muted">@' + user.username + '</small>' +
                            '</div>' +
                        '</div>' +
                    '</td>' +
                    '<td>' + user.email + '</td>' +
                    '<td><span class="badge bg-' + getRoleColor(user.role) + '">' + user.role + '</span></td>' +
                    '<td>' +
                        '<span class="badge bg-' + (user.isActive ? 'success' : 'danger') + '">' +
                            (user.isActive ? 'Active' : 'Inactive') +
                        '</span>' +
                        (user.isVerified ? '<i class="fas fa-check-circle text-success ms-1" title="Verified"></i>' : '') +
                    '</td>' +
                    '<td>' + formatDate(user.createdAt) + '</td>' +
                    '<td>' +
                        '<div class="btn-group" role="group">' +
                            '<button class="btn btn-sm btn-outline-primary" onclick="viewUser(\'' + user.userId + '\')">' +
                                '<i class="fas fa-eye"></i>' +
                            '</button>' +
                            (user.isActive ? 
                                '<button class="btn btn-sm btn-outline-warning" onclick="deactivateUser(\'' + user.userId + '\')">' +
                                    '<i class="fas fa-ban"></i>' +
                                '</button>' :
                                '<button class="btn btn-sm btn-outline-success" onclick="activateUser(\'' + user.userId + '\')">' +
                                    '<i class="fas fa-check"></i>' +
                                '</button>'
                            ) +
                            (!user.isVerified ? 
                                '<button class="btn btn-sm btn-outline-info" onclick="verifyUser(\'' + user.userId + '\')">' +
                                    '<i class="fas fa-certificate"></i>' +
                                '</button>' : ''
                            ) +
                        '</div>' +
                    '</td>' +
                '</tr>'
            ).join('');
        }
        
        function loadArtworks() {
            const search = document.getElementById('artworkSearch').value;
            const status = document.getElementById('statusFilter').value;
            
            const params = new URLSearchParams({
                page: currentPage,
                limit: 20
            });
            
            if (search) params.append('search', search);
            if (status) params.append('status', status);
            
            fetch(`/artexchange/admin/artworks?${params}`)
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        displayArtworks(data.artworks);
                        displayArtworksPagination(data.currentPage, data.totalPages);
                    }
                })
                .catch(error => console.error('Error loading artworks:', error));
        }
        
        function displayArtworks(artworks) {
            const tbody = document.getElementById('artworksTableBody');
            tbody.innerHTML = artworks.map(artwork => 
                '<tr>' +
                    '<td>' +
                        '<div class="d-flex align-items-center">' +
                            '<img src="' + (artwork.imageUrl || '/artexchange/assets/images/placeholder.jpg') + '" ' +
                                 'alt="' + artwork.title + '" class="rounded me-2" width="50" height="50" style="object-fit: cover;">' +
                            '<div>' +
                                '<div class="fw-bold">' + artwork.title + '</div>' +
                                '<small class="text-muted">' + artwork.category + '</small>' +
                            '</div>' +
                        '</div>' +
                    '</td>' +
                    '<td>' + (artwork.artistName || 'Unknown') + '</td>' +
                    '<td><span class="badge bg-secondary">' + artwork.category + '</span></td>' +
                    '<td>RM ' + (artwork.price || artwork.currentBid || 0).toFixed(2) + '</td>' +
                    '<td><span class="badge bg-' + getStatusColor(artwork.status) + '">' + artwork.status + '</span></td>' +
                    '<td>' +
                        '<div class="btn-group" role="group">' +
                            '<button class="btn btn-sm btn-outline-primary" onclick="viewArtwork(\'' + artwork.artworkId + '\')">' +
                                '<i class="fas fa-eye"></i>' +
                            '</button>' +
                            '<button class="btn btn-sm btn-outline-' + (artwork.isFeatured ? 'warning' : 'info') + '" ' +
                                    'onclick="toggleFeature(\'' + artwork.artworkId + '\', ' + !artwork.isFeatured + ')">' +
                                '<i class="fas fa-star"></i>' +
                            '</button>' +
                            '<button class="btn btn-sm btn-outline-danger" onclick="removeArtwork(\'' + artwork.artworkId + '\')">' +
                                '<i class="fas fa-trash"></i>' +
                            '</button>' +
                        '</div>' +
                    '</td>' +
                '</tr>'
            ).join('');
        }
        
        // User management functions
        function activateUser(userId) {
            if (confirm('Are you sure you want to activate this user?')) {
                fetch('/artexchange/admin/users/activate', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: `userId=${userId}`
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        showNotification('User activated successfully', 'success');
                        loadUsers();
                    } else {
                        showNotification('Failed to activate user', 'error');
                    }
                });
            }
        }
        
        function deactivateUser(userId) {
            if (confirm('Are you sure you want to deactivate this user?')) {
                fetch('/artexchange/admin/users/deactivate', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: `userId=${userId}`
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        showNotification('User deactivated successfully', 'success');
                        loadUsers();
                    } else {
                        showNotification('Failed to deactivate user', 'error');
                    }
                });
            }
        }
        
        function verifyUser(userId) {
            if (confirm('Are you sure you want to verify this user?')) {
                fetch('/artexchange/admin/users/verify', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: `userId=${userId}`
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        showNotification('User verified successfully', 'success');
                        loadUsers();
                    } else {
                        showNotification('Failed to verify user', 'error');
                    }
                });
            }
        }
        
        // Artwork management functions
        function toggleFeature(artworkId, featured) {
            fetch('/artexchange/admin/artworks/feature', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: `artworkId=${artworkId}&featured=${featured}`
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    showNotification(data.message, 'success');
                    loadArtworks();
                } else {
                    showNotification('Failed to update artwork feature status', 'error');
                }
            });
        }
        
        function removeArtwork(artworkId) {
            if (confirm('Are you sure you want to remove this artwork?')) {
                fetch('/artexchange/admin/artworks/remove', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: `artworkId=${artworkId}`
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        showNotification('Artwork removed successfully', 'success');
                        loadArtworks();
                    } else {
                        showNotification('Failed to remove artwork', 'error');
                    }
                });
            }
        }
        
        // Utility functions
        function getRoleColor(role) {
            switch(role) {
                case 'ADMIN': return 'danger';
                case 'ARTIST': return 'primary';
                case 'BUYER': return 'success';
                default: return 'secondary';
            }
        }
        
        function getStatusColor(status) {
            switch(status) {
                case 'ACTIVE': return 'success';
                case 'SOLD': return 'info';
                case 'REMOVED': return 'danger';
                default: return 'secondary';
            }
        }
        
        function formatDate(dateString) {
            if (!dateString) return 'N/A';
            return new Date(dateString).toLocaleDateString();
        }
        
        function updateLastUpdated() {
            document.getElementById('lastUpdated').textContent = new Date().toLocaleTimeString();
        }
        
        function refreshData() {
            loadPlatformStats();
            updateLastUpdated();
            
            switch(currentView) {
                case 'users':
                    loadUsers();
                    break;
                case 'artworks':
                    loadArtworks();
                    break;
                case 'dashboard':
                    loadRecentActivity();
                    break;
            }
        }
        
        function debounce(func, wait) {
            let timeout;
            return function executedFunction(...args) {
                const later = () => {
                    clearTimeout(timeout);
                    func(...args);
                };
                clearTimeout(timeout);
                timeout = setTimeout(later, wait);
            };
        }
        
        function showNotification(message, type) {
            // Create toast notification
            const toast = document.createElement('div');
            toast.className = 'toast align-items-center text-white bg-' + (type === 'error' ? 'danger' : 'success') + ' border-0';
            toast.setAttribute('role', 'alert');
            toast.innerHTML = 
                '<div class="d-flex">' +
                    '<div class="toast-body">' + message + '</div>' +
                    '<button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>' +
                '</div>';
            
            // Add to page and show
            document.body.appendChild(toast);
            const bsToast = new bootstrap.Toast(toast);
            bsToast.show();
            
            // Remove after hiding
            toast.addEventListener('hidden.bs.toast', () => toast.remove());
        }
        
        // Placeholder functions for other features
        function loadRecentActivity() {
            document.getElementById('recentActivity').innerHTML = `
                <div class="timeline">
                    <div class="d-flex mb-3">
                        <div class="flex-shrink-0">
                            <i class="fas fa-user-plus text-success"></i>
                        </div>
                        <div class="flex-grow-1 ms-3">
                            <h6 class="mb-1">New user registered</h6>
                            <p class="text-muted small mb-0">John Doe joined as an artist</p>
                            <small class="text-muted">2 hours ago</small>
                        </div>
                    </div>
                    <div class="d-flex mb-3">
                        <div class="flex-shrink-0">
                            <i class="fas fa-palette text-primary"></i>
                        </div>
                        <div class="flex-grow-1 ms-3">
                            <h6 class="mb-1">New artwork uploaded</h6>
                            <p class="text-muted small mb-0">"Digital Landscape" by Sarah Ahmad</p>
                            <small class="text-muted">4 hours ago</small>
                        </div>
                    </div>
                    <div class="d-flex">
                        <div class="flex-shrink-0">
                            <i class="fas fa-gavel text-warning"></i>
                        </div>
                        <div class="flex-grow-1 ms-3">
                            <h6 class="mb-1">Auction completed</h6>
                            <p class="text-muted small mb-0">"City Lights" sold for RM 2,500</p>
                            <small class="text-muted">6 hours ago</small>
                        </div>
                    </div>
                </div>
            `;
        }
        
        function initializeCharts() {
            // Placeholder chart implementations
            setTimeout(() => {
                // User Growth Chart
                const userCtx = document.getElementById('userGrowthChart');
                if (userCtx) {
                    new Chart(userCtx, {
                        type: 'line',
                        data: {
                            labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
                            datasets: [{
                                label: 'Users',
                                data: [10, 25, 45, 78, 120, 156],
                                borderColor: '#667eea',
                                tension: 0.1
                            }]
                        },
                        options: { responsive: true, maintainAspectRatio: false }
                    });
                }
                
                // Revenue Chart
                const revenueCtx = document.getElementById('revenueChart');
                if (revenueCtx) {
                    new Chart(revenueCtx, {
                        type: 'bar',
                        data: {
                            labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
                            datasets: [{
                                label: 'Revenue (RM)',
                                data: [1200, 1900, 3000, 2500, 2200, 3400],
                                backgroundColor: '#28a745'
                            }]
                        },
                        options: { responsive: true, maintainAspectRatio: false }
                    });
                }
            }, 100);
        }
        
        function initializeReportsCharts() {
            // Placeholder for reports charts
        }
        
        function displayUsersPagination(currentPage, totalPages) {
            // Implement pagination for users
        }
        
        function displayArtworksPagination(currentPage, totalPages) {
            // Implement pagination for artworks
        }
        
        function viewUser(userId) {
            // Implement user detail view
        }
        
        function viewArtwork(artworkId) {
            // Implement artwork detail view
        }
    </script>
</body>
</html>
