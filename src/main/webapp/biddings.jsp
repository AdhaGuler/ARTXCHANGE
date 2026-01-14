<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Biddings - ArtXchange</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/main.css" rel="stylesheet">
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary sticky-top">
        <div class="container">
            <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/">
                <i class="fas fa-palette me-2"></i>ArtXchange
            </a>

            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>

            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/browse.jsp">Browse</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/dashboard.jsp">Dashboard</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/messages.jsp">Messages</a>
                    </li>
                    <li class="nav-item" id="biddings-nav" style="display: none;">
                        <a class="nav-link active" href="${pageContext.request.contextPath}/biddings.jsp">
                            <i class="fas fa-gavel me-1"></i>Biddings
                        </a>
                    </li>
                </ul>

                <ul class="navbar-nav">
                    <li class="nav-item dropdown" id="user-menu">
                        <a class="nav-link dropdown-toggle" href="#" id="userDropdown" role="button" data-bs-toggle="dropdown">
                            <img id="userAvatar" src="" alt="User" class="rounded-circle me-2" width="30" height="30">
                            <span id="userName">Loading...</span>
                        </a>
                        <ul class="dropdown-menu">
                            <li><a class="dropdown-item" href="#" onclick="showProfile()"><i class="fas fa-user me-2"></i>Profile</a></li>
                            <li><a class="dropdown-item" href="#" onclick="logout()"><i class="fas fa-sign-out-alt me-2"></i>Logout</a></li>
                        </ul>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <div class="container my-4">
        <div class="row">
            <div class="col-12">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h2><i class="fas fa-gavel me-2"></i>My Biddings</h2>
                    <div class="badge bg-primary fs-6">
                        <span id="totalBidsCount">0</span> Total Bids
                    </div>
                </div>

                <!-- Biddings List -->
                <div id="biddingsContainer">
                    <div class="text-center py-5">
                        <div class="spinner-border text-primary" role="status">
                            <span class="visually-hidden">Loading...</span>
                        </div>
                        <p class="mt-3 text-muted">Loading your biddings...</p>
                    </div>
                </div>

                <!-- Empty State -->
                <div id="emptyState" class="text-center py-5 d-none">
                    <i class="fas fa-gavel fa-3x text-muted mb-3"></i>
                    <h4 class="text-muted">No Bids Found</h4>
                    <p class="text-muted">You haven't placed any bids yet. Start bidding on artworks!</p>
                    <a href="${pageContext.request.contextPath}/browse.jsp" class="btn btn-primary">
                        <i class="fas fa-search me-2"></i>Browse Artworks
                    </a>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- Firebase JS -->
    <script src="https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.22.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.22.0/firebase-firestore-compat.js"></script>
    
    <!-- Custom JS -->
    <script src="${pageContext.request.contextPath}/assets/js/firebase-config.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/auth.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
    
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Wait for Firebase auth to initialize
            firebase.auth().onAuthStateChanged(function(user) {
                if (user) {
                    // User is signed in, load biddings
                    loadBiddings();
                }
            });
        });
        
        function loadBiddings() {
            const container = document.getElementById('biddingsContainer');
            const emptyState = document.getElementById('emptyState');
            
            // Show loading state
            container.innerHTML = '<div class="text-center py-5">' +
                '<div class="spinner-border text-primary" role="status">' +
                '<span class="visually-hidden">Loading...</span>' +
                '</div>' +
                '<p class="mt-3 text-muted">Loading your biddings...</p>' +
                '</div>';
            emptyState.classList.add('d-none');
            
            // SIMPLE - no Firebase token needed, just use session!
            const url = window.location.origin + '/api/biddings';
            
            fetch(url.toString(), {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json'
                }
            })
            .then(response => response.json())
            .then(data => {
                console.log('Biddings response:', data);
                if (data.success) {
                    displayBiddings(data.biddings || []);
                    updateTotalBidsCount(data.totalCount || 0);
                } else {
                    console.error('Error loading biddings:', data.error);
                    showError('Failed to load biddings: ' + data.error);
                }
            })
            .catch(error => {
                console.error('Error:', error);
                showError('Failed to load biddings');
            });
        }
        
        function displayBiddings(biddings) {
            const container = document.getElementById('biddingsContainer');
            const emptyState = document.getElementById('emptyState');
            
            if (biddings.length === 0) {
                container.innerHTML = '';
                emptyState.classList.remove('d-none');
                return;
            }
            
            emptyState.classList.add('d-none');
            
            let html = '<div class="row">';
            
            biddings.forEach(bid => {
                html += '<div class="col-md-6 mb-4">' +
                    '<div class="card h-100">' +
                        '<div class="card-body">' +
                            '<h6 class="card-title">' + bid.artwork.title + '</h6>' +
                            '<p class="text-muted small mb-2">by ' + bid.artwork.artistName + '</p>' +
                            
                            '<div class="d-flex justify-content-between align-items-center mb-2">' +
                                '<span class="fw-bold text-primary">$' + bid.amount + '</span>' +
                            '</div>' +
                            
                            '<div class="small text-muted mb-2">' +
                                '<i class="fas fa-clock me-1"></i>' +
                                new Date(bid.bidTime).toLocaleDateString() +
                            '</div>' +
                            
                            (bid.artwork.currentBid ? 
                                '<div class="small">' +
                                    'Current Bid: <span class="fw-bold">$' + bid.artwork.currentBid + '</span>' +
                                '</div>' : '') +
                        '</div>' +
                        '<div class="card-footer">' +
                            '<a href="' + window.location.origin + '/artwork-detail.jsp?id=' + bid.artwork.id + '" ' +
                               'class="btn btn-sm btn-outline-primary">' +
                                '<i class="fas fa-eye me-1"></i>View Artwork' +
                            '</a>' +
                        '</div>' +
                    '</div>' +
                '</div>';
            });
            
            html += '</div>';
            container.innerHTML = html;
        }
        
        function updateTotalBidsCount(count) {
            document.getElementById('totalBidsCount').textContent = count;
        }
        
        function showError(message) {
            const container = document.getElementById('biddingsContainer');
            container.innerHTML = '<div class="alert alert-danger" role="alert">' +
                '<i class="fas fa-exclamation-triangle me-2"></i>' +
                message +
                '</div>';
        }
    </script>
</body>
</html>
