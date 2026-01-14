<%@ page contentType="text/html;charset=UTF-8" language="java" %> <%@ taglib
uri="http://java.sun.com/jsp/jstl/core" prefix="c" %> <%@ taglib
uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Dashboard - ArtXchange</title>
    <link
      href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"
      rel="stylesheet"
    />
    <link
      href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"
      rel="stylesheet"
    />
    <link
      href="${pageContext.request.contextPath}/assets/css/main.css"
      rel="stylesheet"
    />
  </head>
  <body>
    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark sticky-top" style="background: #1a1a1a; border-bottom: 1px solid rgba(255, 255, 255, 0.08);">
      <div class="container">
        <a
          class="navbar-brand fw-bold"
          href="${pageContext.request.contextPath}/"
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
                >Browse</a
              >
            </li>
            <li class="nav-item">
              <a
                class="nav-link active"
                href="${pageContext.request.contextPath}/dashboard.jsp"
                >Dashboard</a
              >
            </li>
            <li class="nav-item">
              <a
                class="nav-link"
                href="${pageContext.request.contextPath}/messages.jsp"
              >
                Messages
                <span
                  class="badge bg-danger ms-1"
                  id="unreadMessageCount"
                  style="display: none"
                  >0</span
                >
              </a>
            </li>
            <li class="nav-item" id="biddings-nav" style="display: none;">
              <a
                class="nav-link"
                href="${pageContext.request.contextPath}/biddings.jsp"
              >
                <i class="fas fa-gavel me-1"></i>Biddings
              </a>
            </li>
          </ul>

          <ul class="navbar-nav">
            <li class="nav-item dropdown">
              <a
                class="nav-link dropdown-toggle"
                href="#"
                id="userDropdown"
                role="button"
                data-bs-toggle="dropdown"
              >
                <img
                  id="userAvatar"
                  src=""
                  alt="User"
                  class="rounded-circle me-2"
                  width="30"
                  height="30"
                />
                <span id="userName">Loading...</span>
              </a>
              <ul class="dropdown-menu">
                <li>
                  <a class="dropdown-item" href="#" onclick="showProfile()"
                    ><i class="fas fa-user me-2"></i>Profile</a
                  >
                </li>
                <li>
                  <a class="dropdown-item" href="#" onclick="logout()"
                    ><i class="fas fa-sign-out-alt me-2"></i>Logout</a
                  >
                </li>
              </ul>
            </li>
          </ul>
        </div>
      </div>
    </nav>

    <!-- Dashboard Content -->
    <div class="container my-4">
      <!-- Dashboard Header -->
      <div class="d-flex justify-content-between align-items-center mb-4">
        <h2>Dashboard</h2>
        <div>
          <button
            class="btn btn-primary"
            onclick="showUploadModal()"
            id="uploadBtn"
            style="display: none"
          >
            <i class="fas fa-plus me-2"></i>Upload Artwork
          </button>
        </div>
      </div>

      <!-- Dashboard Stats -->
      <div class="row mb-4" id="dashboardStats">
        <!-- Stats will be loaded here -->
        <div class="col-12 text-center py-4">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Loading...</span>
          </div>
          <p class="mt-2 text-muted">Initializing dashboard...</p>
        </div>
      </div>

      <!-- Dashboard Tabs -->
      <ul class="nav nav-tabs" id="dashboardTabs" role="tablist">
        <li class="nav-item" role="presentation">
          <button
            class="nav-link active"
            id="overview-tab"
            data-bs-toggle="tab"
            data-bs-target="#overview"
            type="button"
            role="tab"
          >
            <i class="fas fa-chart-line me-2"></i>Overview
          </button>
        </li>
        <li
          class="nav-item"
          role="presentation"
          id="artworksTabItem"
          style="display: none"
        >
          <button
            class="nav-link"
            id="artworks-tab"
            data-bs-toggle="tab"
            data-bs-target="#artworks"
            type="button"
            role="tab"
          >
            <i class="fas fa-paint-brush me-2"></i>My Artworks
          </button>
        </li>
        <li class="nav-item" role="presentation">
          <button
            class="nav-link"
            id="purchases-tab"
            data-bs-toggle="tab"
            data-bs-target="#purchases"
            type="button"
            role="tab"
          >
            <i class="fas fa-shopping-bag me-2"></i>Purchases
          </button>
        </li>
        <li class="nav-item" role="presentation" id="bids-tab-nav">
          <button
            class="nav-link"
            id="bids-tab"
            data-bs-toggle="tab"
            data-bs-target="#bids"
            type="button"
            role="tab"
          >
            <i class="fas fa-gavel me-2"></i>My Bids
          </button>
        </li>
        <li
          class="nav-item"
          role="presentation"
          id="salesReportTabItem"
          style="display: none"
        >
          <button
            class="nav-link"
            id="sales-report-tab"
            data-bs-toggle="tab"
            data-bs-target="#sales-report"
            type="button"
            role="tab"
          >
            <i class="fas fa-chart-bar me-2"></i>Sales Report
          </button>
        </li>
      </ul>

      <div class="tab-content mt-3" id="dashboardTabContent">
        <!-- Overview Tab -->
        <div class="tab-pane fade show active" id="overview" role="tabpanel">
          <div class="row">
            <div class="col-md-6">
              <div class="card">
                <div class="card-header">
                  <h5 class="mb-0">
                    <i class="fas fa-chart-bar me-2"></i>Activity Summary
                  </h5>
                </div>
                <div class="card-body" id="activitySummary">
                  <!-- Activity summary will be loaded here -->
                </div>
              </div>
            </div>

            <div class="col-md-6">
              <div class="card">
                <div class="card-header">
                  <h5 class="mb-0">
                    <i class="fas fa-star me-2"></i>Recent Activity
                  </h5>
                </div>
                <div class="card-body" id="recentActivity">
                  <!-- Recent activity will be loaded here -->
                </div>
              </div>
            </div>
          </div>
          
          <!-- Active Auctions Section (for artists) -->
          <div class="row mt-4" id="auctionsSection" style="display: none;">
            <div class="col-12">
              <div class="card">
                <div class="card-header">
                  <h5 class="mb-0">
                    <i class="fas fa-gavel me-2"></i>Active Auctions
                  </h5>
                </div>
                <div class="card-body">
                  <div id="auctionsList">
                    <!-- Auctions will be loaded here -->
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- My Artworks Tab -->
        <div class="tab-pane fade" id="artworks" role="tabpanel">
          <div class="d-flex justify-content-between align-items-center mb-3">
            <h4>My Artworks</h4>
            <button class="btn btn-primary" onclick="showUploadModal()">
              <i class="fas fa-plus me-2"></i>Upload New Artwork
            </button>
          </div>

          <!-- Filter Controls -->
          <div class="card mb-4">
            <div class="card-body">
              <div class="d-flex justify-content-between align-items-center flex-wrap gap-3">
                <div>
                  <h6 class="mb-0">
                    <i class="fas fa-filter me-2"></i>Filter Artworks
                  </h6>
                  <small class="text-muted" id="artworkFilterCount">Showing all artworks</small>
                </div>
                <div class="btn-group" role="group" aria-label="Artwork filters">
                  <input type="radio" class="btn-check" name="artworkFilter" id="filterAll" value="ALL" checked autocomplete="off">
                  <label class="btn btn-outline-primary" for="filterAll">
                    <i class="fas fa-th me-1"></i>All Artworks
                  </label>
                  
                  <input type="radio" class="btn-check" name="artworkFilter" id="filterAvailable" value="AVAILABLE" autocomplete="off">
                  <label class="btn btn-outline-success" for="filterAvailable">
                    <i class="fas fa-check-circle me-1"></i>Available
                  </label>
                  
                  <input type="radio" class="btn-check" name="artworkFilter" id="filterSold" value="SOLD" autocomplete="off">
                  <label class="btn btn-outline-danger" for="filterSold">
                    <i class="fas fa-times-circle me-1"></i>Sold
                  </label>
                  
                  <input type="radio" class="btn-check" name="artworkFilter" id="filterFixed" value="FIXED_PRICE" autocomplete="off">
                  <label class="btn btn-outline-info" for="filterFixed">
                    <i class="fas fa-tag me-1"></i>Fixed Price
                  </label>
                  
                  <input type="radio" class="btn-check" name="artworkFilter" id="filterAuction" value="AUCTION" autocomplete="off">
                  <label class="btn btn-outline-warning" for="filterAuction">
                    <i class="fas fa-gavel me-1"></i>Auctions
                  </label>
                </div>
              </div>
            </div>
          </div>

          <div class="row" id="myArtworksGrid">
            <!-- Artworks will be loaded here -->
          </div>
        </div>

        <!-- Purchases Tab -->
        <div class="tab-pane fade" id="purchases" role="tabpanel">
          <h4>Purchase History</h4>
          <div id="purchasesContent">
            <!-- Purchases will be loaded here -->
          </div>
        </div>

        <!-- Bids Tab -->
        <div class="tab-pane fade" id="bids" role="tabpanel">
          <div class="d-flex justify-content-between align-items-center mb-3">
            <h4>My Bidding</h4>
          </div>
          <div id="bidsContent">
            <!-- Bids and won auctions will be loaded here -->
          </div>
        </div>

        <!-- Sales Report Tab -->
        <div class="tab-pane fade" id="sales-report" role="tabpanel">
          <div class="card">
            <div class="card-header">
              <div class="d-flex justify-content-between align-items-center">
                <h5 class="mb-0">
                  <i class="fas fa-chart-bar me-2"></i>Sales Report
                </h5>
                <div class="btn-group">
                  <button class="btn btn-sm btn-outline-primary" id="downloadPdfBtn" onclick="downloadReport('pdf')">
                    <i class="fas fa-file-pdf me-1"></i>PDF
                  </button>
                  <button class="btn btn-sm btn-outline-success" id="downloadCsvBtn" onclick="downloadReport('csv')">
                    <i class="fas fa-file-csv me-1"></i>CSV
                  </button>
                </div>
              </div>
            </div>
            <div class="card-body">
              <!-- Date Filter -->
              <div class="row mb-4">
                <div class="col-md-12">
                  <div class="card bg-light">
                    <div class="card-body">
                      <h6 class="card-title mb-3">
                        <i class="fas fa-filter me-2"></i>Filter by Date Range
                      </h6>
                      <div class="row g-3">
                        <div class="col-md-3">
                          <label class="form-label">Quick Filter</label>
                          <select class="form-select" id="quickFilter" onchange="applyQuickFilter()">
                            <option value="">All Time</option>
                            <option value="thisMonth">This Month</option>
                            <option value="last3Months">Last 3 Months</option>
                            <option value="last6Months">Last 6 Months</option>
                            <option value="thisYear">This Year</option>
                          </select>
                        </div>
                        <div class="col-md-4">
                          <label class="form-label">Start Date</label>
                          <input type="date" class="form-control" id="startDate" onchange="applyDateFilter()">
                        </div>
                        <div class="col-md-4">
                          <label class="form-label">End Date</label>
                          <input type="date" class="form-control" id="endDate" onchange="applyDateFilter()">
                        </div>
                        <div class="col-md-1">
                          <label class="form-label">&nbsp;</label>
                          <button class="btn btn-primary w-100" onclick="applyDateFilter()">
                            <i class="fas fa-search"></i>
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Summary Cards -->
              <div class="row mb-4" id="salesSummaryCards">
                <div class="col-md-3">
                  <div class="card text-center border-primary">
                    <div class="card-body">
                      <h6 class="text-muted mb-2">Total Artworks Sold</h6>
                      <h3 class="mb-0" id="totalArtworksSold">-</h3>
                    </div>
                  </div>
                </div>
                <div class="col-md-3">
                  <div class="card text-center border-success">
                    <div class="card-body">
                      <h6 class="text-muted mb-2">Total Revenue</h6>
                      <h3 class="mb-0 text-success" id="totalRevenue">MYR 0.00</h3>
                    </div>
                  </div>
                </div>
                <div class="col-md-3">
                  <div class="card text-center border-info">
                    <div class="card-body">
                      <h6 class="text-muted mb-2">Direct Purchases</h6>
                      <h5 class="mb-1" id="directPurchaseCount">-</h5>
                      <small class="text-muted" id="directPurchaseRevenue">MYR 0.00</small>
                    </div>
                  </div>
                </div>
                <div class="col-md-3">
                  <div class="card text-center border-warning">
                    <div class="card-body">
                      <h6 class="text-muted mb-2">Auction Sales</h6>
                      <h5 class="mb-1" id="auctionSaleCount">-</h5>
                      <small class="text-muted" id="auctionSaleRevenue">MYR 0.00</small>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Sales Records Table -->
              <div class="table-responsive">
                <table class="table table-hover" id="salesTable">
                  <thead class="table-light">
                    <tr>
                      <th>Artwork Title</th>
                      <th>Buyer</th>
                      <th>Sale Type</th>
                      <th>Final Price</th>
                      <th>Sale Date</th>
                    </tr>
                  </thead>
                  <tbody id="salesTableBody">
                    <tr>
                      <td colspan="5" class="text-center py-4">
                        <div class="spinner-border text-primary" role="status">
                          <span class="visually-hidden">Loading...</span>
                        </div>
                        <p class="mt-2 text-muted">Loading sales data...</p>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>

              <!-- Empty State -->
              <div id="salesEmptyState" class="text-center py-5" style="display: none;">
                <i class="fas fa-chart-line fa-3x text-muted mb-3"></i>
                <h5 class="text-muted">No Sales Found</h5>
                <p class="text-muted">You haven't made any sales in the selected time period.</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- View Bidders Modal -->
    <div class="modal fade" id="biddersModal" tabindex="-1" aria-labelledby="biddersModalLabel" aria-hidden="true">
      <div class="modal-dialog modal-xl">
        <div class="modal-content">
          <div class="modal-header bg-primary text-white">
            <h5 class="modal-title" id="biddersModalLabel">
              <i class="fas fa-gavel me-2"></i>Auction Bidders Details
            </h5>
            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <div class="card mb-3 border-0 bg-light">
              <div class="card-body">
                <div class="d-flex justify-content-between align-items-start flex-wrap gap-3">
                  <div>
                    <h6 class="mb-1"><i class="fas fa-palette me-2"></i><span id="biddersArtworkTitle" class="fw-bold"></span></h6>
                    <small class="text-muted" id="biddersCount">Loading...</small>
                  </div>
                  <div class="btn-group" role="group">
                    <input type="radio" class="btn-check" name="sortBidders" id="sortByAmount" value="amount" checked>
                    <label class="btn btn-outline-primary btn-sm" for="sortByAmount">
                      <i class="fas fa-sort-amount-down me-1"></i>Highest First
                    </label>
                    
                    <input type="radio" class="btn-check" name="sortBidders" id="sortByLatest" value="latest">
                    <label class="btn btn-outline-primary btn-sm" for="sortByLatest">
                      <i class="fas fa-clock me-1"></i>Latest First
                    </label>
                  </div>
                </div>
              </div>
            </div>
            <div id="biddersList">
              <div class="text-center py-5">
                <div class="spinner-border text-primary" role="status">
                  <span class="visually-hidden">Loading...</span>
                </div>
                <p class="mt-2 text-muted">Loading bidders...</p>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <div class="me-auto">
              <small class="text-muted">
                <i class="fas fa-info-circle me-1"></i>
                Only you can view these bidder details
              </small>
            </div>
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
          </div>
        </div>
      </div>
    </div>

    <!-- Upload Artwork Modal -->
    <div class="modal fade" id="uploadModal" tabindex="-1">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Upload Artwork</h5>
            <button
              type="button"
              class="btn-close"
              data-bs-dismiss="modal"
            ></button>
          </div>
          <div class="modal-body">
            <form id="uploadForm" enctype="multipart/form-data">
              <div class="row">
                <div class="col-md-6">
                  <div class="mb-3">
                    <label class="form-label">Title *</label>
                    <input
                      type="text"
                      class="form-control"
                      id="artworkTitle"
                      required
                    />
                  </div>

                  <div class="mb-3">
                    <label class="form-label">Category *</label>
                    <select class="form-select" id="artworkCategory" required>
                      <option value="">Select Category</option>
                      <option value="PAINTING">Painting</option>
                      <option value="SCULPTURE">Sculpture</option>
                      <option value="PHOTOGRAPHY">Photography</option>
                      <option value="DIGITAL_ART">Digital Art</option>
                      <option value="MIXED_MEDIA">Mixed Media</option>
                      <option value="OTHER">Other</option>
                    </select>
                  </div>

                  <div class="mb-3">
                    <label class="form-label">Listing Type *</label>
                    <select
                      class="form-select"
                      id="listingType"
                      required
                      onchange="toggleAuctionFields()"
                    >
                      <option value="">Select Type</option>
                      <option value="FIXED_PRICE">Fixed Price</option>
                      <option value="AUCTION">Auction</option>
                    </select>
                  </div>

                  <div class="mb-3">
                    <label class="form-label">Price (RM) *</label>
                    <input
                      type="number"
                      class="form-control"
                      id="artworkPrice"
                      step="0.01"
                      min="0"
                      required
                    />
                    <small class="form-text text-muted" id="priceHelp"
                      >Fixed price or starting bid for auctions</small
                    >
                  </div>

                  <div class="mb-3" id="auctionEndField" style="display: none">
                    <label class="form-label">Auction End Time *</label>
                    <input
                      type="datetime-local"
                      class="form-control"
                      id="auctionEndTime"
                      required
                    />
                    <small class="form-text text-muted">
                      Auction must end between 5 minutes and 30 days from now
                    </small>
                  </div>
                </div>

                <div class="col-md-6">
                  <div class="mb-3">
                    <label class="form-label">Description *</label>
                    <textarea
                      class="form-control"
                      id="artworkDescription"
                      rows="4"
                      required
                    ></textarea>
                  </div>

                  <div class="mb-3">
                    <label class="form-label">Artwork Images * (1-10 images)</label>
                    <input
                      type="file"
                      class="form-control"
                      id="artworkImages"
                      accept="image/*"
                      multiple
                      required
                    />
                    <small class="form-text text-muted"
                      >Min: 1 image, Max: 10 images. Max size per file: 10MB. Supported formats: JPG, PNG, GIF,
                      WebP</small
                    >
                    <div id="imageCount" class="text-danger mt-1" style="display: none;"></div>
                  </div>

                  <div class="mb-3">
                    <div class="form-check">
                      <input
                        class="form-check-input"
                        type="checkbox"
                        id="isFeatured"
                      />
                      <label class="form-check-label" for="isFeatured">
                        Feature this artwork
                      </label>
                    </div>
                  </div>

                  <div id="imagePreview" style="display: none;">
                    <div class="row g-2" id="imagePreviewContainer">
                      <!-- Image previews will be inserted here -->
                    </div>
                  </div>
                </div>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button
              type="button"
              class="btn btn-secondary"
              data-bs-dismiss="modal"
            >
              Cancel
            </button>
            <button
              type="button"
              class="btn btn-primary"
              id="uploadArtworkBtn"
              onclick="uploadArtwork()"
            >
              <i class="fas fa-upload me-2"></i>Upload Artwork
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Review Modal -->
    <div class="modal fade" id="reviewModal" tabindex="-1" aria-labelledby="reviewModalLabel" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header" style="border-bottom: 1px solid #f0f0f0;">
            <h5 class="modal-title" id="reviewModalLabel">
              <i class="fas fa-star me-2"></i>Leave a Review
            </h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <!-- Artwork Info -->
            <div class="d-flex mb-4 pb-3" style="border-bottom: 1px solid #f0f0f0;">
              <img id="reviewArtworkImage" src="" alt="Artwork" class="img-fluid" style="width: 80px; height: 80px; object-fit: cover; border: 1px solid #e0e0e0;">
              <div class="ms-3">
                <h6 class="mb-1" id="reviewArtworkTitle"></h6>
                <p class="text-muted small mb-0" id="reviewArtistName"></p>
              </div>
            </div>
            
            <!-- Star Rating -->
            <div class="mb-4">
              <label class="form-label mb-2">Rating *</label>
              <div class="star-rating" id="starRating">
                <span class="star" data-rating="1" title="1 star">
                  <i class="far fa-star"></i>
                </span>
                <span class="star" data-rating="2" title="2 stars">
                  <i class="far fa-star"></i>
                </span>
                <span class="star" data-rating="3" title="3 stars">
                  <i class="far fa-star"></i>
                </span>
                <span class="star" data-rating="4" title="4 stars">
                  <i class="far fa-star"></i>
                </span>
                <span class="star" data-rating="5" title="5 stars">
                  <i class="far fa-star"></i>
                </span>
              </div>
              <input type="hidden" id="reviewRating" value="0" required>
              <small class="text-danger d-none" id="ratingError">Please select a rating</small>
            </div>
            
            <!-- Review Text -->
            <div class="mb-3">
              <label for="reviewText" class="form-label">Your Review *</label>
              <textarea 
                class="form-control" 
                id="reviewText" 
                rows="5" 
                placeholder="Share your experience with this artwork..."
                required
                style="border: 1px solid #e0e0e0; border-radius: 0; resize: vertical;"
              ></textarea>
            </div>
            
            <!-- Helper Text -->
            <small class="text-muted">
              <i class="fas fa-info-circle me-1"></i>Only verified buyers can submit a review.
            </small>
            
            <input type="hidden" id="reviewPurchaseId" value="">
          </div>
          <div class="modal-footer" style="border-top: 1px solid #f0f0f0;">
            <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
            <button type="button" class="btn btn-dark" id="submitReviewBtn" onclick="submitReview()">
              Submit Review
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Toast Notification Container -->
    <div class="toast-container position-fixed top-0 end-0 p-3" style="z-index: 9999;">
      <div id="toastContainer"></div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-auth-compat.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/firebase-config.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/auth.js"></script>
    <script>
      // Initialize page (currentUser is already declared in auth.js)
      // currentUser is available from auth.js, no need to redeclare

      document.addEventListener("DOMContentLoaded", function () {
        // Use the proper auth check from auth.js instead of direct Firebase
        if (typeof firebase === 'undefined' || !firebase.auth) {
          console.error("Firebase is not loaded");
          window.location.href = "/";
          return;
        }

        firebase.auth().onAuthStateChanged(async function (user) {
          if (user) {
            try {
              // Verify token with backend like in auth.js
              const idToken = await user.getIdToken();
              const response = await fetch("/auth/verify-token", {
                method: "POST",
                headers: {
                  "Content-Type": "application/json",
                },
                credentials: 'include', // Ensure cookies are sent
                body: JSON.stringify({ idToken: idToken }),
              });

              if (response.ok) {
                const data = await response.json();
                if (data.success && data.user) {
                  currentUser = data.user;
                  // #region agent log
                  fetch('http://127.0.0.1:7242/ingest/a9f50aca-30b6-483f-bffe-fc28103e8173',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'dashboard.jsp:515',message:'Current user set from auth',data:{userId:currentUser.userId,role:currentUser.role},timestamp:Date.now(),sessionId:'debug-session',runId:'run1',hypothesisId:'B'})}).catch(()=>{});
                  // #endregion
                  console.log("Current user loaded:", currentUser);
                  loadUserProfile();
                  // Add a small delay to ensure session cookie is set before making API calls
                  setTimeout(function() {
                    loadDashboardData();
                  }, 300);
                } else {
                  console.warn(
                    "User verification failed on dashboard:",
                    data ? data.message : "Unknown error"
                  );
                  window.location.href = "/";
                }
              } else if (response.status === 404) {
                console.warn("User not found in database on dashboard");
                window.location.href = "/";
              } else {
                console.error(
                  "Authentication verification failed on dashboard with status:",
                  response.status
                );
                window.location.href = "/";
              }
            } catch (error) {
              console.error("Auth verification error on dashboard:", error);
              window.location.href = "/";
            }
          } else {
            console.warn("No user authenticated, redirecting to home");
            window.location.href = "/";
          }
        });
      });

      function loadUserProfile() {
        // Add null check for currentUser
        if (!currentUser) {
          console.error("currentUser is not defined");
          return;
        }

        const userAvatar = document.getElementById("userAvatar");
        const userName = document.getElementById("userName");

        if (!userAvatar || !userName) {
          console.error("User profile elements not found");
          return;
        }

        // Use the verified currentUser data from backend instead of Firebase user
        userAvatar.src =
          (currentUser.profileImageUrl || currentUser.profileImage) ||
          "/assets/images/default-avatar.svg";
        userName.textContent =
          (currentUser.firstName || currentUser.username || currentUser.email || "User");

        // Show artist-specific features if user is an artist
        if (currentUser.role === "ARTIST") {
          console.log("User is an artist, showing artist features");
          const uploadBtn = document.getElementById("uploadBtn");
          const artworksTab = document.getElementById("artworksTabItem");
          const salesReportTab = document.getElementById("salesReportTabItem");

          if (uploadBtn) {
            uploadBtn.style.display = "block";
            console.log("Upload button shown");
          } else {
            console.error("Upload button element not found");
          }

          if (artworksTab) {
            artworksTab.style.display = "block";
            console.log("Artworks tab shown");
          } else {
            console.error("Artworks tab element not found");
          }

          if (salesReportTab) {
            salesReportTab.style.display = "block";
            console.log("Sales Report tab shown");
          } else {
            console.error("Sales Report tab element not found");
          }
        } else {
          console.log("User is not an artist, role:", currentUser.role);
        }
      }

      function loadDashboardData() {
        // #region agent log
        fetch('http://127.0.0.1:7242/ingest/a9f50aca-30b6-483f-bffe-fc28103e8173',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'dashboard.jsp:597',message:'loadDashboardData called',data:{currentUserExists:!!currentUser,currentUserRole:currentUser?currentUser.role:'null'},timestamp:Date.now(),sessionId:'debug-session',runId:'run1',hypothesisId:'B'})}).catch(()=>{});
        // #endregion
        console.log("=== loadDashboardData called ===");
        console.log("Current user:", currentUser);
        console.log("Current user role:", currentUser ? currentUser.role : "null");
        
        // Always load stats first - these should work for all users
        loadDashboardStats();
        loadActivitySummary();
        loadRecentActivity();
        loadUnreadMessageCount();
        
        // Load seller dashboard data if user is an artist
        // Small delay to ensure session is established
        setTimeout(function() {
          if (currentUser && currentUser.role === "ARTIST") {
            // #region agent log
            fetch('http://127.0.0.1:7242/ingest/a9f50aca-30b6-483f-bffe-fc28103e8173',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'dashboard.jsp:611',message:'Artist detected, loading seller dashboard',data:{role:currentUser.role},timestamp:Date.now(),sessionId:'debug-session',runId:'run1',hypothesisId:'B'})}).catch(()=>{});
            // #endregion
            console.log("User is an artist, loading seller dashboard data");
            loadSellerDashboard();
            // Also load artworks for the artworks tab
            loadMyArtworks();
          } else {
            // #region agent log
            fetch('http://127.0.0.1:7242/ingest/a9f50aca-30b6-483f-bffe-fc28103e8173',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'dashboard.jsp:617',message:'Not artist or currentUser not set',data:{currentUser:!!currentUser,role:currentUser?currentUser.role:'undefined'},timestamp:Date.now(),sessionId:'debug-session',runId:'run1',hypothesisId:'B'})}).catch(()=>{});
            // #endregion
            console.log("User is not an artist, role:", currentUser ? currentUser.role : "undefined");
          }
        }, 200);
      }
      
      function loadSellerDashboard() {
        console.log("=== loadSellerDashboard called ===");
        
        const auctionsSection = document.getElementById("auctionsSection");
        const auctionsList = document.getElementById("auctionsList");
        
        if (!auctionsSection || !auctionsList) {
          console.error("Auctions section elements not found");
          return;
        }
        
        // Show loading state
        auctionsList.innerHTML = 
          '<div class="text-center py-4">' +
            '<div class="spinner-border text-primary" role="status">' +
              '<span class="visually-hidden">Loading auctions...</span>' +
            '</div>' +
            '<p class="mt-2 text-muted">Loading active auctions...</p>' +
          '</div>';
        auctionsSection.style.display = "block";
        
        fetch("/api/dashboard/seller", { 
          credentials: 'include',
          headers: {
            'Accept': 'application/json'
          }
        })
          .then((response) => {
            // #region agent log
            fetch('http://127.0.0.1:7242/ingest/a9f50aca-30b6-483f-bffe-fc28103e8173',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'dashboard.jsp:649',message:'Seller dashboard API response',data:{status:response.status,ok:response.ok},timestamp:Date.now(),sessionId:'debug-session',runId:'run1',hypothesisId:'A'})}).catch(()=>{});
            // #endregion
            console.log("Seller dashboard response status:", response.status);
            console.log("Seller dashboard response headers:", response.headers);
            if (!response.ok) {
              if (response.status === 401) {
                // #region agent log
                fetch('http://127.0.0.1:7242/ingest/a9f50aca-30b6-483f-bffe-fc28103e8173',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'dashboard.jsp:653',message:'401 Unauthorized from seller API',data:{status:401},timestamp:Date.now(),sessionId:'debug-session',runId:'run1',hypothesisId:'A'})}).catch(()=>{});
                // #endregion
                console.error("Authentication failed - session may not be established");
                throw new Error("Authentication required. Please refresh the page.");
              } else if (response.status === 403) {
                console.warn("Access denied - user may not be an artist");
                throw new Error("Access denied. This endpoint is only for artists.");
              } else {
                throw new Error("Failed to load seller dashboard: " + response.status);
              }
            }
            return response.json();
          })
          .then((data) => {
            // #region agent log
            fetch('http://127.0.0.1:7242/ingest/a9f50aca-30b6-483f-bffe-fc28103e8173',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'dashboard.jsp:665',message:'Seller dashboard data received',data:{success:data.success,hasData:!!data.data,dataKeys:data.data?Object.keys(data.data):[]},timestamp:Date.now(),sessionId:'debug-session',runId:'run1',hypothesisId:'D'})}).catch(()=>{});
            // #endregion
            console.log("=== Seller dashboard response ===");
            console.log("Full response:", data);
            
            if (data.success && data.data) {
              const dashboardData = data.data;
              console.log("Dashboard data:", dashboardData);
              console.log("Likes count:", dashboardData.likesCount);
              console.log("Purchases count:", dashboardData.purchasesCount);
              console.log("Auctions:", dashboardData.auctions);
              
              displaySellerDashboard(dashboardData);
            } else {
              // #region agent log
              fetch('http://127.0.0.1:7242/ingest/a9f50aca-30b6-483f-bffe-fc28103e8173',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'dashboard.jsp:677',message:'Seller dashboard invalid response',data:{success:data.success,hasData:!!data.data,error:data.error},timestamp:Date.now(),sessionId:'debug-session',runId:'run1',hypothesisId:'D'})}).catch(()=>{});
              // #endregion
              console.error("Invalid seller dashboard response:", data);
              throw new Error(data.error || "Invalid response format");
            }
          })
          .catch((error) => {
            console.error("Error loading seller dashboard:", error);
            console.error("Error stack:", error.stack);
            const errorMessage = error.message || "Error loading seller dashboard data";
            console.error("Error message:", errorMessage);
            
            if (auctionsList) {
              auctionsList.innerHTML = 
                '<div class="alert alert-warning" role="alert">' +
                  '<i class="fas fa-exclamation-triangle me-2"></i>' + 
                  errorMessage +
                  '<br><small class="text-muted mt-2 d-block">Please refresh the page or try again later.</small>' +
                '</div>';
            }
            // Still show the section even on error
            if (auctionsSection) {
              auctionsSection.style.display = "block";
            }
          });
      }
      
      function displaySellerDashboard(data) {
        console.log("=== displaySellerDashboard called ===");
        console.log("Data:", data);
        console.log("Data type:", typeof data);
        console.log("Data keys:", data ? Object.keys(data) : "data is null/undefined");
        
        const auctionsList = document.getElementById("auctionsList");
        if (!auctionsList) {
          console.error("auctionsList element not found");
          return;
        }
        
        // Validate data structure
        if (!data) {
          console.error("displaySellerDashboard: data is null or undefined");
          auctionsList.innerHTML = 
            '<div class="alert alert-danger">' +
              '<i class="fas fa-exclamation-triangle me-2"></i>Invalid data received from server' +
            '</div>';
          return;
        }
        
        // Display likes and purchases counts in the activity summary if available
        const likesCount = data.likesCount || 0;
        const purchasesCount = data.purchasesCount || 0;
        console.log("Likes count:", likesCount, "Purchases count:", purchasesCount);
        
        // Update activity summary with seller-specific data
        const activitySummary = document.getElementById("activitySummary");
        if (activitySummary) {
          activitySummary.innerHTML = 
            '<div class="d-flex align-items-center mb-3">' +
              '<i class="fas fa-heart text-danger me-3"></i>' +
              '<div>' +
                '<h6 class="mb-0">Total Likes Received</h6>' +
                '<small class="text-muted">' + likesCount + ' like' + (likesCount !== 1 ? 's' : '') + ' on your artworks</small>' +
              '</div>' +
            '</div>' +
            '<div class="d-flex align-items-center mb-3">' +
              '<i class="fas fa-shopping-bag text-success me-3"></i>' +
              '<div>' +
                '<h6 class="mb-0">Total Purchases</h6>' +
                '<small class="text-muted">' + purchasesCount + ' purchase' + (purchasesCount !== 1 ? 's' : '') + ' of your artworks</small>' +
              '</div>' +
            '</div>' +
            '<div class="d-flex align-items-center">' +
              '<i class="fas fa-gavel text-warning me-3"></i>' +
              '<div>' +
                '<h6 class="mb-0">Active Auctions</h6>' +
                '<small class="text-muted" id="activeAuctionsCount">Loading...</small>' +
              '</div>' +
            '</div>';
        }
        
        // Get auctions array - handle both array and non-array cases
        let auctions = [];
        if (data.auctions) {
          if (Array.isArray(data.auctions)) {
            auctions = data.auctions;
          } else {
            console.warn("data.auctions is not an array:", typeof data.auctions);
            auctions = [];
          }
        }
        
        console.log("Number of auctions:", auctions.length);
        console.log("Auctions data:", JSON.stringify(auctions, null, 2));
        
        // Filter to show only ACTIVE auctions in the list
        const activeAuctions = auctions.filter(function(auction) {
          const status = auction.status || "ACTIVE";
          return status === "ACTIVE";
        });
        
        console.log("Total auctions:", auctions.length);
        console.log("Active auctions:", activeAuctions.length);
        console.log("Active auctions data:", JSON.stringify(activeAuctions, null, 2));
        
        // Update active auctions count in activity summary
        if (activitySummary) {
          const activeCountElement = document.getElementById("activeAuctionsCount");
          if (activeCountElement) {
            activeCountElement.textContent = activeAuctions.length + ' active auction' + (activeAuctions.length !== 1 ? 's' : '');
          }
        }
        
        // Show the auctions section
        if (auctionsSection) {
          auctionsSection.style.display = "block";
        }
        
        // Check if there are any ACTIVE auctions
        if (activeAuctions.length === 0) {
          auctionsList.innerHTML = 
            '<div class="text-center py-5">' +
              '<i class="fas fa-gavel fa-3x text-muted mb-3"></i>' +
              '<h5 class="text-muted">You have no active auctions</h5>' +
              '<p class="text-muted">Create an auction listing to start receiving bids</p>' +
              '<button class="btn btn-primary mt-2" onclick="showUploadModal()">' +
                '<i class="fas fa-plus me-2"></i>Create Auction' +
              '</button>' +
            '</div>';
          return;
        }
        
        // Build auctions list HTML - only show ACTIVE auctions
        let auctionsHTML = '<div class="list-group">';
        
        activeAuctions.forEach(function(auction) {
          const auctionId = auction.auctionId || "";
          const title = auction.artworkTitle || "Untitled";
          const currentBid = parseFloat(auction.currentBid || 0).toFixed(2);
          const biddersCount = auction.biddersCount || 0;
          
          auctionsHTML +=
            '<div class="list-group-item" data-auction-id="' + auctionId + '">' +
              '<div class="d-flex justify-content-between align-items-start">' +
                '<div class="flex-grow-1">' +
                  '<h6 class="mb-1">' + escapeHtml(title) + '</h6>' +
                  '<p class="mb-1 text-muted">Current Bid: <strong class="text-primary">RM ' + currentBid + '</strong></p>' +
                  '<small class="text-muted">' + biddersCount + ' bidder' + (biddersCount !== 1 ? 's' : '') + '</small>' +
                '</div>' +
                '<div class="ms-3 d-flex gap-2 flex-wrap">' +
                  '<button class="btn btn-sm btn-outline-primary" onclick="viewAuctionBidders(\'' + 
                    auctionId + '\', \'' + escapeHtml(title).replace(/'/g, "\\'") + '\')">' +
                    '<i class="fas fa-users me-1"></i>View Bidders' +
                  '</button>' +
                '</div>' +
              '</div>' +
            '</div>';
        });
        
        auctionsHTML += '</div>';
        auctionsList.innerHTML = auctionsHTML;
        
        // Ensure the auctions section is visible
        if (auctionsSection) {
          auctionsSection.style.display = "block";
        }
      }
      
      // Helper function to escape HTML
      function escapeHtml(text) {
        if (!text) return "";
        const map = {
          '&': '&amp;',
          '<': '&lt;',
          '>': '&gt;',
          '"': '&quot;',
          "'": '&#039;'
        };
        return text.toString().replace(/[&<>"']/g, function(m) { return map[m]; });
      }

      function loadDashboardStats() {
        // #region agent log
        fetch('http://127.0.0.1:7242/ingest/a9f50aca-30b6-483f-bffe-fc28103e8173',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'dashboard.jsp:824',message:'loadDashboardStats called',data:{statsContainerExists:!!document.getElementById("dashboardStats")},timestamp:Date.now(),sessionId:'debug-session',runId:'run1',hypothesisId:'D'})}).catch(()=>{});
        // #endregion
        console.log("=== loadDashboardStats called ===");
        console.log("Making request to: /api/dashboard/stats");
        
        const statsContainer = document.getElementById("dashboardStats");
        if (!statsContainer) {
          // #region agent log
          fetch('http://127.0.0.1:7242/ingest/a9f50aca-30b6-483f-bffe-fc28103e8173',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'dashboard.jsp:832',message:'Stats container not found',data:{},timestamp:Date.now(),sessionId:'debug-session',runId:'run1',hypothesisId:'E'})}).catch(()=>{});
          // #endregion
          console.error("Stats container not found - this should not happen!");
          // Show placeholder stats even if container lookup fails (shouldn't happen)
          return;
        }
        
        // Show loading state
        statsContainer.innerHTML = 
          '<div class="col-12 text-center py-4">' +
            '<div class="spinner-border text-primary" role="status">' +
              '<span class="visually-hidden">Loading...</span>' +
            '</div>' +
            '<p class="mt-2 text-muted">Loading dashboard stats...</p>' +
          '</div>';
        
        fetch("/api/dashboard/stats", { 
          credentials: 'include',
          headers: {
            'Accept': 'application/json'
          }
        })
          .then((response) => {
            // #region agent log
            fetch('http://127.0.0.1:7242/ingest/a9f50aca-30b6-483f-bffe-fc28103e8173',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'dashboard.jsp:818',message:'Stats API response received',data:{status:response.status,ok:response.ok},timestamp:Date.now(),sessionId:'debug-session',runId:'run1',hypothesisId:'A'})}).catch(()=>{});
            // #endregion
            console.log("Response status:", response.status);
            console.log("Response headers:", response.headers);
            if (!response.ok) {
              if (response.status === 401) {
                // #region agent log
                fetch('http://127.0.0.1:7242/ingest/a9f50aca-30b6-483f-bffe-fc28103e8173',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'dashboard.jsp:822',message:'401 Unauthorized from stats API',data:{status:401},timestamp:Date.now(),sessionId:'debug-session',runId:'run1',hypothesisId:'A'})}).catch(()=>{});
                // #endregion
                console.error("Authentication failed for stats - session may not be established");
                throw new Error("Authentication required. Please refresh the page.");
              } else if (response.status === 403) {
                throw new Error("Access denied. You don't have permission to view this dashboard.");
              } else {
                throw new Error("Failed to load dashboard stats: " + response.status);
              }
            }
            return response.json();
          })
          .then((data) => {
            // #region agent log
            fetch('http://127.0.0.1:7242/ingest/a9f50aca-30b6-483f-bffe-fc28103e8173',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'dashboard.jsp:833',message:'Stats API data received',data:{success:data.success,hasStats:!!data.stats,statsKeys:data.stats?Object.keys(data.stats):[]},timestamp:Date.now(),sessionId:'debug-session',runId:'run1',hypothesisId:'D'})}).catch(()=>{});
            // #endregion
            console.log("=== Dashboard stats response ===");
            console.log("Full response data:", data);
            console.log("Data success:", data.success);
            console.log("Data stats:", data.stats);
            
            if (data.success && data.stats) {
              console.log("Stats object properties:");
              console.log("  - totalArtworks:", data.stats.totalArtworks);
              console.log("  - totalPurchases:", data.stats.totalPurchases);
              console.log("  - activeBids:", data.stats.activeBids);
              console.log("  - totalEarnings:", data.stats.totalEarnings);
              console.log("  - totalLikes:", data.stats.totalLikes);
              
              displayDashboardStats(data.stats);
            } else {
              // #region agent log
              fetch('http://127.0.0.1:7242/ingest/a9f50aca-30b6-483f-bffe-fc28103e8173',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'dashboard.jsp:849',message:'Stats response failed or missing stats',data:{success:data.success,hasStats:!!data.stats},timestamp:Date.now(),sessionId:'debug-session',runId:'run1',hypothesisId:'D'})}).catch(()=>{});
              // #endregion
              console.error("Dashboard stats response failed or missing stats");
              console.error("Response data:", data);
              // Show placeholder stats with zeros instead of error
              const placeholderStats = {
                totalArtworks: 0,
                totalPurchases: 0,
                activeBids: 0,
                totalEarnings: 0,
                totalLikes: 0
              };
              displayDashboardStats(placeholderStats);
              console.warn("Displaying placeholder stats due to missing data");
            }
          })
          .catch((error) => {
            // #region agent log
            fetch('http://127.0.0.1:7242/ingest/a9f50aca-30b6-483f-bffe-fc28103e8173',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'dashboard.jsp:915',message:'Stats API error',data:{error:error.message},timestamp:Date.now(),sessionId:'debug-session',runId:'run1',hypothesisId:'C'})}).catch(()=>{});
            // #endregion
            console.error("Error loading dashboard stats:", error);
            console.error("Error details:", error.message);
            
            // Get statsContainer again in case of scope issues
            const statsContainer = document.getElementById("dashboardStats");
            if (statsContainer) {
              // Show placeholder stats instead of error to prevent blank page
              console.warn("Showing placeholder stats due to API error");
              const placeholderStats = {
                totalArtworks: 0,
                totalPurchases: 0,
                activeBids: 0,
                totalEarnings: 0,
                totalLikes: 0
              };
              displayDashboardStats(placeholderStats);
            } else {
              console.error("Stats container not found when trying to handle error");
            }
          });
      }

      function displayDashboardStats(stats) {
        // #region agent log
        fetch('http://127.0.0.1:7242/ingest/a9f50aca-30b6-483f-bffe-fc28103e8173',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'dashboard.jsp:820',message:'displayDashboardStats called',data:{statsExists:!!stats,statsContainerExists:!!document.getElementById("dashboardStats")},timestamp:Date.now(),sessionId:'debug-session',runId:'run1',hypothesisId:'E'})}).catch(()=>{});
        // #endregion
        console.log("=== displayDashboardStats called ===");
        console.log("Stats parameter:", stats);
        console.log("Stats type:", typeof stats);
        console.log("Stats activeBids:", stats ? stats.activeBids : "stats is null");
        console.log("Stats activeBids type:", stats ? typeof stats.activeBids : "N/A");
        
        if (!stats) {
          // #region agent log
          fetch('http://127.0.0.1:7242/ingest/a9f50aca-30b6-483f-bffe-fc28103e8173',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'dashboard.jsp:827',message:'Stats object is null',data:{},timestamp:Date.now(),sessionId:'debug-session',runId:'run1',hypothesisId:'D'})}).catch(()=>{});
          // #endregion
          console.error("Stats object is null or undefined");
          return;
        }
        
        const statsContainer = document.getElementById("dashboardStats");
        console.log("Stats container found:", statsContainer !== null);
        
        if (!statsContainer) {
          // #region agent log
          fetch('http://127.0.0.1:7242/ingest/a9f50aca-30b6-483f-bffe-fc28103e8173',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'dashboard.jsp:836',message:'Stats container element not found',data:{},timestamp:Date.now(),sessionId:'debug-session',runId:'run1',hypothesisId:'E'})}).catch(()=>{});
          // #endregion
          console.error("Stats container element not found");
          return;
        }

        // Calculate values safely - ensure they display as 0 if null/undefined
        const totalArtworks = stats.totalArtworks || 0;
        const totalPurchases = stats.totalPurchases || 0;
        const totalLikes = stats.totalLikes || 0;
        const activeBids = stats.activeBids || 0;
        const totalEarnings = stats.totalEarnings || 0;
        
        console.log("Displaying stats - Artworks:", totalArtworks, "Likes:", totalLikes, "Purchases:", totalPurchases, "Bids:", activeBids);

        let statsHTML =
          '<div class="col-md-3">' +
          '<div class="card text-center">' +
          '<div class="card-body">' +
          '<i class="fas fa-paint-brush fa-2x text-primary mb-2"></i>' +
          '<h4 class="mb-0">' + totalArtworks + '</h4>' +
          '<p class="text-muted">Artworks</p>' +
          '</div>' +
          '</div>' +
          '</div>' +
          '<div class="col-md-3">' +
          '<div class="card text-center">' +
          '<div class="card-body">' +
          '<i class="fas fa-heart fa-2x text-danger mb-2"></i>' +
          '<h4 class="mb-0">' + totalLikes + '</h4>' +
          '<p class="text-muted">Total Likes</p>' +
          '</div>' +
          '</div>' +
          '</div>' +
          '<div class="col-md-3">' +
          '<div class="card text-center">' +
          '<div class="card-body">' +
          '<i class="fas fa-shopping-bag fa-2x text-success mb-2"></i>' +
          '<h4 class="mb-0">' + totalPurchases + '</h4>' +
          '<p class="text-muted">Purchases</p>' +
          '</div>' +
          '</div>' +
          '</div>' +
          '<div class="col-md-3">' +
          '<div class="card text-center">' +
          '<div class="card-body">' +
          '<i class="fas fa-gavel fa-2x text-warning mb-2"></i>' +
          '<h4 class="mb-0">' + activeBids + '</h4>' +
          '<p class="text-muted">Total Bids Received</p>' +
          '</div>' +
          '</div>' +
          '</div>';
        
        // Add earnings card if artist has earnings
        if (totalEarnings > 0 || (currentUser && currentUser.role === "ARTIST")) {
          statsHTML +=
            '<div class="col-md-3">' +
            '<div class="card text-center">' +
            '<div class="card-body">' +
            '<i class="fas fa-dollar-sign fa-2x text-info mb-2"></i>' +
            '<h4 class="mb-0">RM ' + totalEarnings.toFixed(2) + '</h4>' +
            '<p class="text-muted">Total Earnings</p>' +
            '</div>' +
            '</div>' +
            '</div>';
        }

        console.log("=== Final statsHTML ===");
        console.log("Generated HTML length:", statsHTML.length);
        console.log("Setting innerHTML...");
        
        // #region agent log
        fetch('http://127.0.0.1:7242/ingest/a9f50aca-30b6-483f-bffe-fc28103e8173',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'dashboard.jsp:905',message:'Setting stats HTML',data:{htmlLength:statsHTML.length,containerExists:!!statsContainer},timestamp:Date.now(),sessionId:'debug-session',runId:'run1',hypothesisId:'E'})}).catch(()=>{});
        // #endregion
        statsContainer.innerHTML = statsHTML;
        
        // #region agent log
        fetch('http://127.0.0.1:7242/ingest/a9f50aca-30b6-483f-bffe-fc28103e8173',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'dashboard.jsp:907',message:'Stats HTML set',data:{innerHTMLLength:statsContainer.innerHTML.length},timestamp:Date.now(),sessionId:'debug-session',runId:'run1',hypothesisId:'E'})}).catch(()=>{});
        // #endregion
        console.log("=== displayDashboardStats completed ===");
      }

      function loadActivitySummary() {
        console.log("=== loadActivitySummary called ===");
        const summary = document.getElementById("activitySummary");
        if (!summary) {
          console.error("activitySummary element not found");
          return;
        }
        
        // Show loading state
        summary.innerHTML = 
          '<div class="text-center py-3">' +
            '<div class="spinner-border spinner-border-sm text-primary" role="status">' +
              '<span class="visually-hidden">Loading...</span>' +
            '</div>' +
          '</div>';
        
        // For artists, the seller dashboard will update this section
        // For non-artists, show basic stats
        if (currentUser && currentUser.role !== "ARTIST") {
          // Fetch stats to get real data for non-artists
          fetch("/api/dashboard/stats", { 
            credentials: 'include',
            headers: {
              'Accept': 'application/json'
            }
          })
            .then((response) => {
              console.log("Activity summary response status:", response.status);
              if (!response.ok) {
                throw new Error("Failed to load activity summary: " + response.status);
              }
              return response.json();
            })
            .then((data) => {
              console.log("Activity summary data:", data);
              if (data.success && data.stats) {
                const totalLikes = data.stats.totalLikes || 0;
                const totalPurchases = data.stats.totalPurchases || 0;
                const profileViews = data.stats.profileViews || 0;
                
                console.log("Displaying activity summary - Likes:", totalLikes, "Purchases:", totalPurchases);
                
                summary.innerHTML = 
                  '<div class="d-flex align-items-center mb-3">' +
                    '<i class="fas fa-heart text-danger me-3"></i>' +
                    '<div>' +
                      '<h6 class="mb-0">Total Likes</h6>' +
                      '<small class="text-muted">' + totalLikes + ' like' + (totalLikes !== 1 ? 's' : '') + '</small>' +
                    '</div>' +
                  '</div>' +
                  '<div class="d-flex align-items-center mb-3">' +
                    '<i class="fas fa-shopping-bag text-success me-3"></i>' +
                    '<div>' +
                      '<h6 class="mb-0">Total Purchases</h6>' +
                      '<small class="text-muted">' + totalPurchases + ' purchase' + (totalPurchases !== 1 ? 's' : '') + '</small>' +
                    '</div>' +
                  '</div>' +
                  '<div class="d-flex align-items-center">' +
                    '<i class="fas fa-eye text-primary me-3"></i>' +
                    '<div>' +
                      '<h6 class="mb-0">Profile Views</h6>' +
                      '<small class="text-muted">' + profileViews + ' view' + (profileViews !== 1 ? 's' : '') + '</small>' +
                    '</div>' +
                  '</div>';
              } else {
                console.error("Invalid response format for activity summary:", data);
                throw new Error("Invalid response format");
              }
            })
            .catch((error) => {
              console.error("Error loading activity summary:", error);
              summary.innerHTML = 
                '<div class="alert alert-warning" role="alert">' +
                  '<i class="fas fa-exclamation-triangle me-2"></i>Unable to load activity summary: ' + (error.message || "Unknown error") +
                '</div>';
            });
        } else {
          // For artists, wait for seller dashboard to populate this
          // Show placeholder if seller dashboard hasn't loaded yet
          setTimeout(function() {
            if (summary.innerHTML.includes("spinner-border")) {
              summary.innerHTML = 
                '<div class="d-flex align-items-center mb-3">' +
                  '<i class="fas fa-heart text-danger me-3"></i>' +
                  '<div>' +
                    '<h6 class="mb-0">Total Likes Received</h6>' +
                    '<small class="text-muted">0 likes on your artworks</small>' +
                  '</div>' +
                '</div>' +
                '<div class="d-flex align-items-center mb-3">' +
                  '<i class="fas fa-shopping-bag text-success me-3"></i>' +
                  '<div>' +
                    '<h6 class="mb-0">Total Purchases</h6>' +
                    '<small class="text-muted">0 purchases of your artworks</small>' +
                  '</div>' +
                '</div>';
            }
          }, 1000);
        }
      }

      function loadRecentActivity() {
        const activity = document.getElementById("recentActivity");
        if (!activity) {
          console.error("recentActivity element not found");
          return;
        }
        
        // Load recent artworks to show activity
        fetch("/api/artworks/my-artworks?limit=3", { 
          credentials: 'include',
          headers: {
            'Accept': 'application/json'
          }
        })
          .then((response) => {
            console.log("Recent activity response status:", response.status);
            if (!response.ok) {
              if (response.status === 401) {
                console.warn("Not authenticated for recent activity - user may not have artworks");
                throw new Error("Authentication required");
              } else {
                throw new Error("Failed to load recent activity: " + response.status);
              }
            }
            return response.json();
          })
          .then((data) => {
            if (data.success && data.artworks && data.artworks.length > 0) {
              let activityHTML = '<div class="timeline">';
              
              // Show up to 3 most recent artworks
              data.artworks.slice(0, 3).forEach(function(artwork) {
                const title = artwork.title || "Untitled";
                const uploadDate = artwork.createdAt ? new Date(artwork.createdAt).toLocaleDateString() : "Recently";
                activityHTML +=
                  '<div class="timeline-item mb-3">' +
                    '<div class="d-flex">' +
                      '<div class="flex-shrink-0">' +
                        '<i class="fas fa-plus-circle text-success"></i>' +
                      '</div>' +
                      '<div class="flex-grow-1 ms-3">' +
                        '<h6 class="mb-1">Artwork uploaded</h6>' +
                        '<p class="text-muted small mb-0">"' + title + '" was successfully uploaded</p>' +
                        '<small class="text-muted">' + uploadDate + '</small>' +
                      '</div>' +
                    '</div>' +
                  '</div>';
              });
              
              activityHTML += '</div>';
              activity.innerHTML = activityHTML;
            } else {
              // Show empty state
              activity.innerHTML = 
                '<div class="text-center py-4">' +
                  '<i class="fas fa-clock fa-2x text-muted mb-3"></i>' +
                  '<p class="text-muted">No recent activity</p>' +
                  '<p class="text-muted small">Your recent artwork uploads and bids will appear here</p>' +
                '</div>';
            }
          })
          .catch((error) => {
            console.error("Error loading recent activity:", error);
            activity.innerHTML = 
              '<div class="text-center py-4">' +
                '<i class="fas fa-clock fa-2x text-muted mb-3"></i>' +
                '<p class="text-muted">Unable to load recent activity</p>' +
              '</div>';
          });
      }

      function loadUnreadMessageCount() {
        fetch("/api/messages/unread-count", {
          credentials: 'include',
          headers: {
            'Accept': 'application/json'
          }
        })
          .then((response) => {
            if (!response.ok) {
              console.warn("Failed to load unread message count:", response.status);
              return { success: false, unreadCount: 0 };
            }
            return response.json();
          })
          .then((data) => {
            if (data.success && data.unreadCount > 0) {
              const badge = document.getElementById("unreadMessageCount");
              if (badge) {
                badge.textContent = data.unreadCount;
                badge.style.display = "inline";
              }
            }
          })
          .catch((error) =>
            console.error("Error loading unread count:", error)
          );
      }

      function showUploadModal() {
        new bootstrap.Modal(document.getElementById("uploadModal")).show();
      }

      function toggleAuctionFields() {
        const listingType = document.getElementById("listingType").value;
        const auctionField = document.getElementById("auctionEndField");
        const priceHelp = document.getElementById("priceHelp");
        const auctionEndTimeInput = document.getElementById("auctionEndTime");

        if (listingType === "AUCTION") {
          auctionField.style.display = "block";
          priceHelp.textContent = "Starting bid amount";
          auctionEndTimeInput.required = true;

          // Set minimum auction end time to 5 minutes from now
          const minTime = new Date();
          minTime.setMinutes(minTime.getMinutes() + 5);
          auctionEndTimeInput.min = minTime.toISOString().slice(0, 16);

          // Set maximum auction end time to 30 days from now
          const maxTime = new Date();
          maxTime.setDate(maxTime.getDate() + 30);
          auctionEndTimeInput.max = maxTime.toISOString().slice(0, 16);

          // Clear any previous value when switching to auction
          auctionEndTimeInput.value = "";
        } else {
          auctionField.style.display = "none";
          priceHelp.textContent = "Fixed price for the artwork";
          auctionEndTimeInput.required = false; // avoid blocking fixed price submissions
          auctionEndTimeInput.value = "";
          auctionEndTimeInput.min = "";
          auctionEndTimeInput.max = "";
        }
      }

      // Multiple image preview functionality
      document
        .getElementById("artworkImages")
        .addEventListener("change", function (e) {
          const files = e.target.files;
          const imageCountEl = document.getElementById("imageCount");
          const previewContainer = document.getElementById("imagePreviewContainer");
          
          // Validate number of images (1-10)
          if (files.length === 0) {
            imageCountEl.style.display = "none";
            document.getElementById("imagePreview").style.display = "none";
            previewContainer.innerHTML = "";
            return;
          }
          
          if (files.length < 1) {
            imageCountEl.textContent = "Please select at least 1 image.";
            imageCountEl.style.display = "block";
            e.target.value = "";
            previewContainer.innerHTML = "";
            document.getElementById("imagePreview").style.display = "none";
            return;
          }
          
          if (files.length > 10) {
            imageCountEl.textContent = "Maximum 10 images allowed. Please select fewer images.";
            imageCountEl.style.display = "block";
            e.target.value = "";
            previewContainer.innerHTML = "";
            document.getElementById("imagePreview").style.display = "none";
            return;
          }
          
          imageCountEl.style.display = "none";
          previewContainer.innerHTML = "";
          
          // Display previews for all selected images
          for (let i = 0; i < files.length; i++) {
            const file = files[i];
            if (file.type.startsWith("image/")) {
              const reader = new FileReader();
              reader.onload = function (e) {
                const col = document.createElement("div");
                col.className = "col-6 col-md-4";
                // Use string concatenation instead of template literals to avoid JSP EL parsing issues
                const primaryBadge = i === 0 ? '<span class="badge bg-primary position-absolute top-0 start-0 m-1">Primary</span>' : '';
                col.innerHTML = 
                  '<div class="position-relative">' +
                    '<img' +
                      ' src="' + e.target.result + '"' +
                      ' alt="Preview ' + (i + 1) + '"' +
                      ' class="img-fluid rounded mb-2"' +
                      ' style="max-height: 150px; width: 100%; object-fit: cover; cursor: pointer;"' +
                    '/>' +
                    primaryBadge +
                  '</div>';
                previewContainer.appendChild(col);
              };
              reader.readAsDataURL(file);
            }
          }
          
          document.getElementById("imagePreview").style.display = "block";
        });

      function uploadArtwork() {
        const form = document.getElementById("uploadForm");
        if (!form.checkValidity()) {
          form.reportValidity();
          return;
        }

        const imageFiles = document.getElementById("artworkImages").files;
        
        // Validate image count
        if (imageFiles.length < 1) {
          alert("Please select at least 1 image.");
          return;
        }
        
        if (imageFiles.length > 10) {
          alert("Maximum 10 images allowed. Please select fewer images.");
          return;
        }

        // Show loading state - find the upload button
        const uploadBtn = document.getElementById('uploadArtworkBtn');
        const originalText = uploadBtn ? uploadBtn.innerHTML : '';
        if (uploadBtn) {
          uploadBtn.disabled = true;
          uploadBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Uploading...';
        }

        // Upload all images sequentially
        uploadMultipleImages(Array.from(imageFiles))
          .then((imageUrls) => {
            console.log("All images uploaded:", imageUrls);
            // Create artwork with image URLs
            createArtwork(imageUrls, uploadBtn, originalText);
          })
          .catch((error) => {
            console.error("Error uploading images:", error);
            alert("Error uploading images: " + error.message);
            if (uploadBtn) {
              uploadBtn.disabled = false;
              uploadBtn.innerHTML = originalText;
            }
          });
      }

      function uploadMultipleImages(files) {
        const uploadPromises = files.map((file) => {
          const formData = new FormData();
          formData.append("file", file);

          return fetch("/api/upload", {
            method: "POST",
            body: formData,
          })
            .then((response) => response.json())
            .then((data) => {
              if (data.success) {
                return data.fileUrl;
              } else {
                throw new Error(data.message || "Failed to upload image");
              }
            });
        });

        return Promise.all(uploadPromises);
      }

      function createArtwork(imageUrls, uploadBtn, originalText) {
        console.log("Creating artwork with image URLs:", imageUrls);
        
        // Ensure imageUrls is an array
        if (!Array.isArray(imageUrls)) {
          imageUrls = [imageUrls];
        }
        
        const artworkData = {
          title: document.getElementById("artworkTitle").value,
          description: document.getElementById("artworkDescription").value,
          category: document.getElementById("artworkCategory").value,
          price: parseFloat(document.getElementById("artworkPrice").value),
          listingType: document.getElementById("listingType").value,
          isFeatured: document.getElementById("isFeatured").checked,
          imageUrl: imageUrls[0], // Primary image (first one)
          imageUrls: imageUrls,    // All images
        };

        console.log("Artwork data:", artworkData);

        if (artworkData.listingType === "AUCTION") {
          const auctionEndTimeValue = document.getElementById("auctionEndTime").value;
          
          // Validate auction end time
          if (!auctionEndTimeValue) {
            if (uploadBtn) {
              uploadBtn.disabled = false;
              uploadBtn.innerHTML = originalText;
            }
            alert("Auction end time is required for auction listings.");
            return;
          }

          const endTime = new Date(auctionEndTimeValue);
          const now = new Date();
          const minTime = new Date(now.getTime() + 5 * 60 * 1000); // 5 minutes from now
          const maxTime = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000); // 30 days from now

          if (endTime < minTime) {
            if (uploadBtn) {
              uploadBtn.disabled = false;
              uploadBtn.innerHTML = originalText;
            }
            alert("Auction end time must be at least 5 minutes from now. Please select a later time.");
            return;
          }

          if (endTime > maxTime) {
            if (uploadBtn) {
              uploadBtn.disabled = false;
              uploadBtn.innerHTML = originalText;
            }
            alert("Auction end time cannot be more than 30 days from now. Please select an earlier time.");
            return;
          }

          artworkData.auctionEndTime = auctionEndTimeValue;
        }

        fetch("/api/artworks", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify(artworkData),
        })
          .then((response) => response.json())
          .then((data) => {
            if (data.success) {
              // Reset button state
              if (uploadBtn) {
                uploadBtn.disabled = false;
                uploadBtn.innerHTML = originalText;
              }
              
              bootstrap.Modal.getInstance(
                document.getElementById("uploadModal")
              ).hide();
              document.getElementById("uploadForm").reset();
              document.getElementById("imagePreview").style.display = "none";
              document.getElementById("imagePreviewContainer").innerHTML = "";
              document.getElementById("imageCount").style.display = "none";

              // Refresh dashboard data
              loadDashboardData();
              
              // Reload artworks tab if it's currently active
              const artworksTab = document.getElementById("artworks-tab");
              if (artworksTab && artworksTab.classList.contains("active")) {
                loadMyArtworks();
              }

              alert("Artwork uploaded successfully!");
            } else {
              // Reset button state on error
              if (uploadBtn) {
                uploadBtn.disabled = false;
                uploadBtn.innerHTML = originalText;
              }
              alert("Error creating artwork: " + data.message);
            }
          })
          .catch((error) => {
            console.error("Error creating artwork:", error);
            // Reset button state on error
            if (uploadBtn) {
              uploadBtn.disabled = false;
              uploadBtn.innerHTML = originalText;
            }
            alert("Error creating artwork");
          });
      }

      // Tab event handlers with null checks
      document.addEventListener("DOMContentLoaded", function() {
        const artworksTab = document.getElementById("artworks-tab");
        if (artworksTab) {
          artworksTab.addEventListener("click", function () {
            loadMyArtworks();
          });
        }

        const purchasesTab = document.getElementById("purchases-tab");
        if (purchasesTab) {
          purchasesTab.addEventListener("click", function () {
            loadPurchases();
          });
        }

        const bidsTab = document.getElementById("bids-tab");
        if (bidsTab) {
          bidsTab.addEventListener("click", function () {
            loadBids();
          });
        }

        // Artwork filter event listeners
        const filterButtons = document.querySelectorAll('input[name="artworkFilter"]');
        filterButtons.forEach(button => {
          button.addEventListener('change', function() {
            if (this.checked) {
              applyArtworkFilter(this.value);
            }
          });
        });

        const salesReportTab = document.getElementById("sales-report-tab");
        if (salesReportTab) {
          salesReportTab.addEventListener("click", function () {
            loadSalesReport();
          });
        }
      });

      // Store all artworks for filtering
      let allMyArtworks = [];
      let currentArtworkFilter = 'ALL';

      function loadMyArtworks() {
        console.log("=== loadMyArtworks called ===");
        fetch("/api/artworks/my-artworks", {
          credentials: 'include',
          headers: {
            'Accept': 'application/json'
          }
        })
          .then((response) => {
            console.log("My artworks response status:", response.status);
            if (!response.ok) {
              if (response.status === 401) {
                console.error("Authentication failed for my artworks");
                throw new Error("Authentication required. Please refresh the page.");
              } else {
                throw new Error("Failed to load artworks: " + response.status);
              }
            }
            return response.json();
          })
          .then((data) => {
            console.log("My artworks response data:", data);
            if (data && data.success) {
              const artworks = data.artworks || [];
              console.log("Number of artworks loaded:", artworks.length);
              
              // Store all artworks for filtering
              allMyArtworks = artworks;
              
              // Display with current filter
              displayMyArtworks(filterMyArtworks(currentArtworkFilter));
            } else {
              console.error("Failed to load artworks - invalid response:", data);
              const grid = document.getElementById("myArtworksGrid");
              if (grid) {
                grid.innerHTML = `
                  <div class="col-12">
                    <div class="alert alert-warning" role="alert">
                      <i class="fas fa-exclamation-triangle me-2"></i>No artworks found or invalid response.
                      ${data && data.message ? '<br><small>' + data.message + '</small>' : ''}
                    </div>
                  </div>
                `;
              }
            }
          })
          .catch((error) => {
            console.error("Error loading artworks:", error);
            console.error("Error details:", error.message, error.stack);
            const grid = document.getElementById("myArtworksGrid");
            if (grid) {
              grid.innerHTML = `
                <div class="col-12">
                  <div class="alert alert-danger" role="alert">
                    <i class="fas fa-exclamation-triangle me-2"></i>Error loading artworks: ${error.message || 'Unknown error'}
                    <br><small class="text-muted mt-2 d-block">Please refresh the page or try again later.</small>
                  </div>
                </div>
              `;
            }
          });
      }

      function filterMyArtworks(filterType) {
        console.log("Filtering artworks by:", filterType);
        
        if (!allMyArtworks || allMyArtworks.length === 0) {
          return [];
        }
        
        if (filterType === 'ALL') {
          return allMyArtworks;
        }
        
        // Filter by status (Available/Sold)
        if (filterType === 'AVAILABLE') {
          const filtered = allMyArtworks.filter(artwork => artwork.status !== 'SOLD');
          console.log("Filtered available artworks count:", filtered.length);
          return filtered;
        }
        
        if (filterType === 'SOLD') {
          const filtered = allMyArtworks.filter(artwork => artwork.status === 'SOLD');
          console.log("Filtered sold artworks count:", filtered.length);
          return filtered;
        }
        
        // Filter by saleType
        const filtered = allMyArtworks.filter(artwork => {
          const saleType = artwork.saleType || artwork.listingType || '';
          return saleType === filterType;
        });
        
        console.log("Filtered artworks count:", filtered.length);
        return filtered;
      }

      function applyArtworkFilter(filterType) {
        currentArtworkFilter = filterType;
        const filteredArtworks = filterMyArtworks(filterType);
        displayMyArtworks(filteredArtworks);
        updateFilterCount(filteredArtworks.length, allMyArtworks.length, filterType);
      }

      function updateFilterCount(filteredCount, totalCount, filterType) {
        const countElement = document.getElementById('artworkFilterCount');
        if (!countElement) return;
        
        let filterLabel = '';
        switch(filterType) {
          case 'ALL':
            filterLabel = 'all artworks';
            break;
          case 'AVAILABLE':
            filterLabel = 'available artworks';
            break;
          case 'SOLD':
            filterLabel = 'sold artworks';
            break;
          case 'FIXED_PRICE':
            filterLabel = 'fixed price artworks';
            break;
          case 'AUCTION':
            filterLabel = 'auction artworks';
            break;
        }
        
        if (filterType === 'ALL') {
          countElement.textContent = 'Showing ' + totalCount + ' ' + (totalCount === 1 ? 'artwork' : 'artworks');
        } else {
          countElement.textContent = 'Showing ' + filteredCount + ' of ' + totalCount + ' ' + filterLabel;
        }
      }

      function displayMyArtworks(artworks) {
        const grid = document.getElementById("myArtworksGrid");
        
        if (!grid) {
          console.error("myArtworksGrid element not found");
          return;
        }
        
        if (!artworks || !Array.isArray(artworks) || artworks.length === 0) {
          console.log("No artworks to display");
          grid.innerHTML = 
            '<div class="col-12 text-center py-5">' +
              '<i class="fas fa-paint-brush fa-3x text-muted mb-3"></i>' +
              '<h4 class="text-muted">No artworks yet</h4>' +
              '<p class="text-muted">Upload your first artwork to get started</p>' +
              '<button class="btn btn-primary" onclick="showUploadModal()">' +
                '<i class="fas fa-plus me-2"></i>Upload Artwork' +
              '</button>' +
            '</div>';
          return;
        }
        
        console.log("Displaying " + artworks.length + " artworks");

        grid.innerHTML = artworks
          .map((artwork) => {
            // Check if artwork is sold
            const isSold = artwork.status === 'SOLD';
            
            // Fix: Use primaryImageUrl instead of imageUrl
            const imageUrl =
              artwork.primaryImageUrl ||
              artwork.imageUrl ||
              "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjIwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cmVjdCB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiBmaWxsPSIjZjhmOWZhIi8+PHRleHQgeD0iNTAlIiB5PSI1MCUiIGZvbnQtZmFtaWx5PSJBcmlhbCIgZm9udC1zaXplPSIxNCIgZmlsbD0iIzZjNzU3ZCIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZHk9Ii4zZW0iPk5vIEltYWdlPC90ZXh0Pjwvc3ZnPg==";

            const title = artwork.title || "Untitled";
            const description =
              (artwork.description || "No description available");
            const descriptionText = description.length > 100 
              ? description.substring(0, 100) + "..." 
              : description;
            const artworkId = artwork.artworkId || artwork.id || "";
            
            // Determine price to display
            let displayPrice = artwork.price || 0;
            if (isSold && artwork.saleType === 'AUCTION' && artwork.winningBidAmount) {
              displayPrice = artwork.winningBidAmount;
            } else if (!isSold && artwork.saleType === 'AUCTION' && artwork.currentBid) {
              displayPrice = artwork.currentBid;
            }
            
            // Sold badge
            const soldBadge = isSold ? '<div class="sold-badge"><i class="fas fa-check-circle me-1"></i>SOLD</div>' : '';
            
            // Card class with sold overlay
            const cardClass = isSold ? 'card sold-overlay' : 'card';
            
            return (
              '<div class="col-md-4 mb-4" data-artwork-id="' + artworkId + '">' +
              '<div class="' + cardClass + '">' +
              '<div class="position-relative">' +
              '<img src="' +
              imageUrl +
              '" class="card-img-top" alt="' +
              title +
              '" style="height: 200px; object-fit: cover;">' +
              soldBadge +
              '</div>' +
              '<div class="card-body">' +
              '<h5 class="card-title">' +
              title +
              "</h5>" +
              '<p class="card-text">' +
              descriptionText +
              "</p>" +
              '<div class="d-flex justify-content-between align-items-center">' +
              '<span class="' + (isSold ? 'text-danger' : 'text-primary') + ' fw-bold">' +
              (isSold ? 'Sold: ' : '') + 'RM ' +
              parseFloat(displayPrice).toFixed(2) +
              "</span>" +
              '<span class="badge bg-' +
              (isSold ? 'danger' : (artwork.saleType == "AUCTION" ? "warning" : "success")) +
              '">' +
              (isSold ? 'SOLD' : (artwork.saleType || artwork.listingType)) +
              "</span>" +
              "</div>" +
              (isSold && artwork.saleType === 'AUCTION' && artwork.winnerName ? 
                '<div class="mt-1"><small class="text-muted"><i class="fas fa-trophy me-1"></i>Won by ' + artwork.winnerName + '</small></div>' : '') +
              '<div class="mt-2">' +
              '<small class="text-muted">' +
              '<i class="fas fa-heart text-danger me-1"></i>' +
              (artwork.likes || 0) +
              " likes" +
              '<i class="fas fa-eye text-info ms-2 me-1"></i>' +
              (artwork.views || 0) +
              " views" +
              "</small>" +
              "</div>" +
              '<div class="mt-2">' +
              (artwork.saleType == "AUCTION" || artwork.listingType == "AUCTION" 
                ? (artworkId && !isSold ? '<button class="btn btn-sm btn-outline-primary w-100 mb-2" onclick="viewAuctionBidders(\'' + artworkId + '\', \'' + title.replace(/'/g, "\\'") + '\')">' +
                  '<i class="fas fa-users me-1"></i>View Bidders (' + (artwork.bidCount || 0) + ')' +
                  '</button>' : (isSold ? '<small class="text-muted"><i class="fas fa-check-circle me-1"></i>Auction completed</small>' : '<small class="text-muted">Auction</small>'))
                : '') +
              "</div>" +
              "</div>" +
              "</div>" +
              "</div>"
            );
          })
          .join("");
      }

      function loadPurchases() {
        const purchasesContent = document.getElementById("purchasesContent");
        if (!purchasesContent) {
          console.error("purchasesContent element not found");
          return;
        }
        
        // Show loading state
        purchasesContent.innerHTML = `
          <div class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Loading...</span>
            </div>
            <p class="mt-2 text-muted">Loading your purchases...</p>
          </div>
        `;
        
        // Fetch purchases from API
        fetch('/api/me/purchases', {
          credentials: 'include',
          headers: {
            'Content-Type': 'application/json'
          }
        })
        .then(response => {
          if (!response.ok) {
            if (response.status === 401) {
              throw new Error('Please login to view your purchases');
            }
            // Try to get error message from response
            return response.json().then(data => {
              throw new Error(data.message || data.error || 'Failed to load purchases');
            }).catch(() => {
              throw new Error('Failed to load purchases (Status: ' + response.status + ')');
            });
          }
          return response.json();
        })
        .then(data => {
          if (data.success === false) {
            throw new Error(data.message || data.error || 'Failed to load purchases');
          }
          if (data.success && data.purchases && data.purchases.length > 0) {
            displayPurchases(data.purchases);
          } else {
            showNoPurchases();
          }
        })
        .catch(error => {
          console.error('Error loading purchases:', error);
          const errorMessage = error.message || 'Failed to load purchases. Please try again later.';
          purchasesContent.innerHTML = '<div class="alert alert-danger" role="alert">' +
            '<i class="fas fa-exclamation-circle me-2"></i>' +
            errorMessage +
            '</div>';
        });
      }
      
      function displayPurchases(purchases) {
        const purchasesContent = document.getElementById("purchasesContent");
        if (!purchasesContent) return;
        
        purchasesContent.innerHTML = purchases.map(purchase => {
          const artwork = purchase.artwork || {};
          const seller = purchase.seller || {};
          const purchaseDate = purchase.purchaseDate ? new Date(purchase.purchaseDate) : new Date();
          const formattedDate = purchaseDate.toLocaleDateString('en-US', { 
            year: 'numeric', 
            month: 'long', 
            day: 'numeric' 
          });
          
          const statusClass = purchase.status === 'COMPLETED' ? 'success' : 
                             purchase.status === 'REFUNDED' ? 'danger' : 
                             purchase.status === 'CANCELLED' ? 'secondary' : 
                             purchase.status === 'EXPIRED' ? 'danger' :
                             purchase.status === 'PENDING_PAYMENT' ? 'warning' : 'warning';
          
          const statusIcon = purchase.status === 'COMPLETED' ? 'fa-check-circle' : 
                            purchase.status === 'REFUNDED' ? 'fa-undo' : 
                            purchase.status === 'CANCELLED' ? 'fa-times-circle' : 
                            purchase.status === 'EXPIRED' ? 'fa-exclamation-triangle' :
                            purchase.status === 'PENDING_PAYMENT' ? 'fa-clock' : 'fa-clock';
          
          const totalPrice = (purchase.purchasePrice || 0) + (purchase.shippingCost || 0);
          const imageUrl = artwork.primaryImageUrl || '/assets/images/placeholder-artwork.jpg';
          const artworkTitle = artwork.title || 'Untitled Artwork';
          const artistName = seller.displayName || artwork.artistName || 'Unknown Artist';
          const refundedClass = purchase.status === 'REFUNDED' ? 'opacity-75' : '';
          const refundedText = purchase.status === 'REFUNDED' ? '<span class="text-decoration-line-through text-muted">(Refunded)</span>' : '';
          const categoryBadge = artwork.category ? '<span class="badge bg-secondary me-1">' + artwork.category + '</span>' : '';
          const shippingText = purchase.shippingCost > 0 ? '<small class="text-muted d-block">Shipping: RM ' + purchase.shippingCost.toFixed(2) + '</small>' : '';
          const transactionText = purchase.transactionId ? '<p class="mb-1 small text-muted"><i class="fas fa-receipt me-1"></i>Transaction ID: ' + purchase.transactionId + '</p>' : '';
          const artworkLink = artwork.artworkId ? '<a href="/artwork-detail.jsp?id=' + artwork.artworkId + '" class="btn btn-outline-secondary btn-sm"><i class="fas fa-eye me-1"></i>View Artwork</a>' : '';
          const paymentMethod = purchase.paymentMethod || 'N/A';
          const purchaseStatus = purchase.status || 'PENDING';
          
          // Check if this is a pending payment auction win
          const isPendingAuctionWin = purchase.status === 'PENDING_PAYMENT' && purchase.paymentMethod === 'AUCTION_WIN';
          
          // Review functionality - check if review has been submitted (mocked - in real app, check purchase.reviewId)
          const hasReview = purchase.reviewId || false; // Mock: assume no reviews exist initially
          const canReview = purchase.status === 'COMPLETED' && !hasReview;
          
          // Payment deadline countdown for pending payments
          let paymentDeadlineText = '';
          if (isPendingAuctionWin && purchase.paymentDeadline) {
            const deadline = new Date(purchase.paymentDeadline);
            const now = new Date();
            const diff = deadline - now;
            
            if (diff > 0) {
              const hours = Math.floor(diff / (1000 * 60 * 60));
              const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
              paymentDeadlineText = '<p class="mb-1 small text-warning"><i class="fas fa-clock me-1"></i>Payment due in: ' + hours + 'h ' + minutes + 'm</p>';
            } else {
              paymentDeadlineText = '<p class="mb-1 small text-danger"><i class="fas fa-exclamation-triangle me-1"></i>Payment deadline expired</p>';
            }
          }
          
          return '<div class="card mb-3 purchase-card ' + refundedClass + '" data-purchase-id="' + purchase.purchaseId + '">' +
            '<div class="row g-0">' +
              '<div class="col-md-3">' +
                '<img src="' + imageUrl + '" ' +
                     'class="img-fluid rounded-start" ' +
                     'alt="' + artworkTitle + '" ' +
                     'style="height: 200px; object-fit: cover; width: 100%;" ' +
                     'onerror="this.src=\'/assets/images/placeholder-artwork.jpg\'">' +
              '</div>' +
              '<div class="col-md-9">' +
                '<div class="card-body">' +
                  '<div class="d-flex justify-content-between align-items-start mb-2">' +
                    '<div>' +
                      '<h5 class="card-title mb-1">' +
                        artworkTitle + ' ' + refundedText +
                      '</h5>' +
                      '<p class="text-muted mb-1 small">' +
                        '<i class="fas fa-user me-1"></i>Artist: ' + artistName +
                      '</p>' +
                      categoryBadge +
                      '<span class="badge bg-' + statusClass + '">' +
                        '<i class="fas ' + statusIcon + ' me-1"></i>' + purchaseStatus +
                      '</span>' +
                    '</div>' +
                    '<div class="text-end">' +
                      '<strong class="text-primary fs-4">RM ' + totalPrice.toFixed(2) + '</strong>' +
                      shippingText +
                    '</div>' +
                  '</div>' +
                  '<div class="row mt-3">' +
                    '<div class="col-md-6">' +
                      '<p class="mb-1 small text-muted">' +
                        '<i class="fas fa-calendar me-1"></i>' + 
                        (purchase.status === 'PENDING_PAYMENT' ? 'Won on: ' : 'Purchased: ') + formattedDate +
                      '</p>' +
                      '<p class="mb-1 small text-muted">' +
                        '<i class="fas fa-credit-card me-1"></i>Payment: ' + paymentMethod +
                      '</p>' +
                      (isPendingAuctionWin ? '<p class="mb-1 small text-warning"><i class="fas fa-trophy me-1"></i>Auction Win - Payment Pending</p>' : '') +
                      transactionText +
                    '</div>' +
                    '<div class="col-md-6 text-end">' +
                      (isPendingAuctionWin ? 
                        '<a href="/checkout/purchase/' + purchase.purchaseId + '" ' +
                           'class="btn btn-success btn-sm me-2">' +
                          '<i class="fas fa-credit-card me-1"></i>Pay Now' +
                        '</a>' : 
                        (purchase.status === 'COMPLETED' ? 
                          '<a href="/receipt/' + purchase.purchaseId + '" ' +
                             'class="btn btn-outline-primary btn-sm me-2" ' +
                             'target="_blank">' +
                            '<i class="fas fa-file-invoice me-1"></i>View Receipt' +
                          '</a>' : '')) +
                      // Review button - only show for COMPLETED purchases without existing review
                      (canReview ? 
                        '<button type="button" class="btn btn-outline-dark btn-sm me-2" ' +
                           'onclick="openReviewModal(\'' + purchase.purchaseId + '\', \'' + 
                           escapeHtml(artworkTitle).replace(/'/g, "\\'") + '\', \'' + 
                           escapeHtml(artistName).replace(/'/g, "\\'") + '\', \'' + 
                           imageUrl.replace(/'/g, "\\'") + '\')" ' +
                           'data-purchase-id="' + purchase.purchaseId + '" ' +
                           'data-artwork-title="' + escapeHtml(artworkTitle) + '" ' +
                           'data-artist-name="' + escapeHtml(artistName) + '" ' +
                           'data-image-url="' + imageUrl + '">' +
                          '<i class="fas fa-star me-1"></i>Leave Review' +
                        '</button>' : 
                        (hasReview ? 
                          '<span class="text-muted small me-2"><i class="fas fa-check-circle me-1"></i>Review Submitted</span>' +
                          '<a href="#" class="text-muted small text-decoration-none" onclick="openReviewModal(\'' + purchase.purchaseId + '\', \'' + 
                           escapeHtml(artworkTitle).replace(/'/g, "\\'") + '\', \'' + 
                           escapeHtml(artistName).replace(/'/g, "\\'") + '\', \'' + 
                           imageUrl.replace(/'/g, "\\'") + '\'); return false;">Edit Review</a>' : '')) +
                      artworkLink +
                      paymentDeadlineText +
                    '</div>' +
                  '</div>' +
                '</div>' +
              '</div>' +
            '</div>' +
          '</div>';
        }).join('');
      }
      
      function showNoPurchases() {
        const purchasesContent = document.getElementById("purchasesContent");
        if (!purchasesContent) return;
        
        purchasesContent.innerHTML = `
          <div class="text-center py-5">
            <i class="fas fa-shopping-bag fa-3x text-muted mb-3"></i>
            <h4 class="text-muted">No purchases yet</h4>
            <p class="text-muted">Start browsing artworks to make your first purchase</p>
            <a href="/browse.jsp" class="btn btn-primary">
              <i class="fas fa-search me-2"></i>Browse Artworks
            </a>
          </div>
        `;
      }

      let currentAuctionId = null;

      function viewAuctionBidders(artworkId, artworkTitle) {
        if (!artworkId) {
          console.error("Artwork ID is required");
          alert("Error: Artwork ID is missing");
          return;
        }
        
        currentAuctionId = artworkId;
        
        const titleElement = document.getElementById("biddersArtworkTitle");
        const countElement = document.getElementById("biddersCount");
        const listElement = document.getElementById("biddersList");
        const modalElement = document.getElementById("biddersModal");
        
        if (!titleElement || !countElement || !listElement || !modalElement) {
          console.error("Bidders modal elements not found");
          alert("Error: Unable to open bidders view");
          return;
        }
        
        titleElement.textContent = artworkTitle || "Untitled";
        countElement.textContent = "Loading...";
        listElement.innerHTML = 
          '<div class="text-center py-4">' +
            '<div class="spinner-border text-primary" role="status">' +
              '<span class="visually-hidden">Loading...</span>' +
            '</div>' +
          '</div>';
        
        const modal = new bootstrap.Modal(modalElement);
        modal.show();
        
        loadBidders(artworkId, "amount");
      }

      function loadBidders(artworkId, sortBy) {
        // Use string concatenation instead of template literal to avoid JSP EL conflicts
        const url = "/api/artworks/" + artworkId + "/bidders" + (sortBy ? "?sortBy=" + sortBy : "");
        
        fetch(url)
          .then((response) => {
            if (!response.ok) {
              if (response.status === 403) {
                throw new Error("You can only view bidders for your own auctions");
              } else if (response.status === 404) {
                throw new Error("Artwork not found");
              } else {
                throw new Error("Failed to load bidders");
              }
            }
            return response.json();
          })
          .then((data) => {
            console.log("Bidders API response:", data);
            if (data.success) {
              // Use the actual bidders count from the response (same data source)
              const actualCount = data.bidders ? data.bidders.length : 0;
              displayBidders(data.bidders || [], actualCount, sortBy || "amount");
            } else {
              throw new Error(data.message || "Failed to load bidders");
            }
          })
          .catch((error) => {
            console.error("Error loading bidders:", error);
            const errorMessage = error.message || "Unknown error";
            const biddersListEl = document.getElementById("biddersList");
            const biddersCountEl = document.getElementById("biddersCount");
            
            if (biddersListEl) {
              biddersListEl.innerHTML = 
                '<div class="alert alert-danger" role="alert">' +
                  '<i class="fas fa-exclamation-triangle me-2"></i>' + errorMessage +
                '</div>';
            }
            
            if (biddersCountEl) {
              biddersCountEl.textContent = "Error loading bidders";
            }
          });
      }

      // Helper function to escape HTML
      function escapeHtml(text) {
        if (!text) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
      }

      function displayBidders(bidders, totalBidders, sortBy) {
        const biddersList = document.getElementById("biddersList");
        const biddersCountElement = document.getElementById("biddersCount");
        
        if (!biddersList || !biddersCountElement) {
          console.error("Bidders list or count element not found");
          return;
        }
        
        // Use string concatenation instead of template literal to avoid JSP EL conflicts
        const bidderText = totalBidders + " bidder" + (totalBidders !== 1 ? "s" : "");
        biddersCountElement.textContent = bidderText;

        if (!bidders || bidders.length === 0) {
          biddersList.innerHTML = 
            '<div class="text-center py-5">' +
              '<i class="fas fa-users fa-3x text-muted mb-3"></i>' +
              '<h5 class="text-muted">No bids yet</h5>' +
              '<p class="text-muted">This auction hasn\'t received any bids yet.</p>' +
            '</div>';
          return;
        }

        // Log bidders data for debugging
        console.log("Displaying bidders:", bidders);
        console.log("Total bidders:", totalBidders);
        console.log("Sort by:", sortBy);
        
        // Create table layout for better display
        let tableHTML = 
          '<div class="table-responsive">' +
            '<table class="table table-hover align-middle">' +
              '<thead class="table-light">' +
                '<tr>' +
                  '<th scope="col"><i class="fas fa-user me-2"></i>Bidder</th>' +
                  '<th scope="col"><i class="fas fa-envelope me-2"></i>Email</th>' +
                  '<th scope="col"><i class="fas fa-money-bill-wave me-2"></i>Bid Amount</th>' +
                  '<th scope="col"><i class="fas fa-clock me-2"></i>Bid Time</th>' +
                  '<th scope="col"><i class="fas fa-info-circle me-2"></i>Status</th>' +
                '</tr>' +
              '</thead>' +
              '<tbody>';
        
        bidders.forEach(function(bidder, index) {
          const bidAmount = parseFloat(bidder.bidAmount || 0).toFixed(2);
          const username = bidder.username || bidder.bidderName || "Unknown User";
          const fullName = bidder.fullName || bidder.bidderName || username;
          const email = bidder.email || "N/A";
          const bidStatus = bidder.bidStatus || "UNKNOWN";
          const auctionStatus = bidder.auctionStatus || "ACTIVE";
          const timestamp = bidder.timestamp || "";
          
          // Parse timestamp properly
          let bidDate = "Unknown time";
          try {
            if (timestamp) {
              if (typeof timestamp === 'string') {
                bidDate = new Date(timestamp).toLocaleString();
              } else if (timestamp.toDate) {
                bidDate = timestamp.toDate().toLocaleString();
              } else if (timestamp instanceof Date) {
                bidDate = timestamp.toLocaleString();
              }
            }
          } catch (e) {
            console.warn("Error parsing timestamp:", e);
          }
          
          // Determine status badge
          let statusBadge = '';
          let rowClass = '';
          
          if (bidStatus === 'WINNING') {
            statusBadge = '<span class="badge bg-success"><i class="fas fa-trophy me-1"></i>Winning Bid</span>';
            rowClass = 'table-success';
          } else if (bidStatus === 'HIGHEST') {
            statusBadge = '<span class="badge bg-primary"><i class="fas fa-crown me-1"></i>Highest Bid</span>';
            rowClass = 'table-info';
          } else if (bidStatus === 'OUTBID') {
            statusBadge = '<span class="badge bg-secondary"><i class="fas fa-arrow-down me-1"></i>Outbid</span>';
          }
          
          tableHTML += 
            '<tr class="' + rowClass + '">' +
              '<td>' +
                '<div class="fw-bold">' + escapeHtml(fullName) + '</div>' +
                '<small class="text-muted">@' + escapeHtml(username) + '</small>' +
              '</td>' +
              '<td>' +
                '<small>' + escapeHtml(email) + '</small>' +
              '</td>' +
              '<td>' +
                '<span class="fw-bold text-primary">RM ' + bidAmount + '</span>' +
              '</td>' +
              '<td>' +
                '<small>' + bidDate + '</small>' +
              '</td>' +
              '<td>' +
                statusBadge +
              '</td>' +
            '</tr>';
        });
        
        tableHTML += 
              '</tbody>' +
            '</table>' +
          '</div>';
        
        biddersList.innerHTML = tableHTML;
      }

      // Add event listeners for sort buttons
      document.addEventListener("DOMContentLoaded", function() {
        const sortButtons = document.querySelectorAll('input[name="sortBidders"]');
        sortButtons.forEach((button) => {
          button.addEventListener("change", function() {
            if (currentAuctionId) {
              loadBidders(currentAuctionId, this.value);
            }
          });
        });
      });

      function loadBids() {
        const bidsContent = document.getElementById("bidsContent");
        if (!bidsContent) {
          console.error("bidsContent element not found");
          return;
        }
        
        // Show loading state
        bidsContent.innerHTML = 
          '<div class="text-center py-5">' +
            '<div class="spinner-border text-primary" role="status">' +
              '<span class="visually-hidden">Loading...</span>' +
            '</div>' +
            '<p class="mt-2 text-muted">Loading your bidding history...</p>' +
          '</div>';
        
        // Fetch both user bids and purchases (which include auction wins)
        Promise.all([
          fetch('/api/biddings', { credentials: 'include' }).then(r => r.ok ? r.json() : { success: false, biddings: [] }),
          fetch('/api/me/purchases', { credentials: 'include' }).then(r => r.ok ? r.json() : { success: false, purchases: [] })
        ])
        .then(([bidsData, purchasesData]) => {
          const bids = bidsData.biddings || [];
          const purchases = purchasesData.purchases || [];
          
          // Filter for auction wins that are pending payment (purchases with paymentMethod = AUCTION_WIN and status = PENDING_PAYMENT)
          const wonAuctions = purchases.filter(p => {
            const isAuctionWin = p.paymentMethod === 'AUCTION_WIN' && p.status === 'PENDING_PAYMENT';
            if (isAuctionWin) {
              console.log('Found won auction pending payment:', {
                purchaseId: p.purchaseId,
                artworkId: p.artworkId,
                artworkTitle: p.artwork?.title,
                price: p.purchasePrice,
                status: p.status,
                paymentDeadline: p.paymentDeadline
              });
            }
            return isAuctionWin;
          });
          
          console.log('Total purchases:', purchases.length);
          console.log('Won auctions:', wonAuctions.length);
          purchases.forEach(p => {
            console.log('Purchase:', {
              purchaseId: p.purchaseId,
              paymentMethod: p.paymentMethod,
              status: p.status,
              artworkTitle: p.artwork?.title
            });
          });
          
          if (bids.length === 0 && wonAuctions.length === 0) {
            bidsContent.innerHTML = 
              '<div class="text-center py-5">' +
                '<i class="fas fa-gavel fa-3x text-muted mb-3"></i>' +
                '<h4 class="text-muted">No bids yet</h4>' +
                '<p class="text-muted">Start bidding on auctions to see your bid history</p>' +
                '<a href="/browse.jsp?type=auction" class="btn btn-primary">View Auctions</a>' +
              '</div>';
            return;
          }
          
          let html = '';
          
          // Display Won Auctions section
          if (wonAuctions.length > 0) {
            html += '<div class="mb-4">' +
              '<h5 class="mb-3"><i class="fas fa-trophy text-warning me-2"></i>Won Auctions</h5>' +
              '<div class="row">';
            
            wonAuctions.forEach(purchase => {
              const artwork = purchase.artwork || {};
              const price = parseFloat(purchase.purchasePrice || 0).toFixed(2);
              const purchaseId = escapeHtml(purchase.purchaseId || '');
              const deadlineId = 'deadline-' + purchaseId;
              
              // Calculate time remaining
              let timeRemaining = '';
              let isExpired = false;
              if (purchase.paymentDeadline) {
                const deadline = new Date(purchase.paymentDeadline);
                const now = new Date();
                const diff = deadline - now;
                
                if (diff <= 0) {
                  isExpired = true;
                  timeRemaining = '<span class="text-danger"><i class="fas fa-exclamation-triangle me-1"></i>Payment deadline expired</span>';
                } else {
                  const hours = Math.floor(diff / (1000 * 60 * 60));
                  const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
                  const seconds = Math.floor((diff % (1000 * 60)) / 1000);
                  timeRemaining = '<span class="text-warning" id="' + deadlineId + '"><i class="fas fa-clock me-1"></i>' + 
                    hours + 'h ' + minutes + 'm ' + seconds + 's remaining</span>';
                }
              }
              
              html += '<div class="col-md-6 mb-3">' +
                '<div class="card border-warning">' +
                  '<div class="card-body">' +
                    '<div class="d-flex align-items-start">' +
                      (artwork.primaryImageUrl ? 
                        '<img src="' + escapeHtml(artwork.primaryImageUrl) + '" alt="' + escapeHtml(artwork.title || 'Artwork') + 
                        '" class="img-thumbnail me-3" style="width: 100px; height: 100px; object-fit: cover;">' : '') +
                      '<div class="flex-grow-1">' +
                        '<h6 class="mb-1">' + escapeHtml(artwork.title || 'Unknown Artwork') + '</h6>' +
                        '<p class="text-muted mb-1 small">Artist: ' + escapeHtml(artwork.artistName || 'Unknown') + '</p>' +
                        '<p class="mb-2"><strong class="text-success">Winning Bid: RM ' + price + '</strong></p>' +
                        '<p class="mb-2 small">' + timeRemaining + '</p>' +
                        '<div class="d-flex gap-2 flex-wrap">' +
                          '<a href="/artwork-detail.jsp?id=' + escapeHtml(purchase.artworkId || '') + '" class="btn btn-sm btn-outline-primary">' +
                            '<i class="fas fa-eye me-1"></i>View Artwork</a>' +
                          (!isExpired ? 
                            '<button class="btn btn-sm btn-success" onclick="proceedToAuctionPayment(\'' + purchaseId + '\')">' +
                              '<i class="fas fa-credit-card me-1"></i>Proceed to Payment</button>' :
                            '<span class="btn btn-sm btn-secondary disabled">Payment Expired</span>') +
                        '</div>' +
                      '</div>' +
                    '</div>' +
                  '</div>' +
                '</div>' +
              '</div>';
            });
            
            html += '</div></div>';
          }
          
          // Display Active Bids section
          if (bids.length > 0) {
            html += '<div class="mb-4">' +
              '<h5 class="mb-3"><i class="fas fa-gavel me-2"></i>Active Bids</h5>' +
              '<div class="row">';
            
            bids.forEach(bid => {
              const artwork = bid.artwork || {};
              const amount = parseFloat(bid.amount || 0).toFixed(2);
              
              html += '<div class="col-md-6 mb-3">' +
                '<div class="card">' +
                  '<div class="card-body">' +
                    '<div class="d-flex align-items-start">' +
                      (artwork.imageUrl ? 
                        '<img src="' + escapeHtml(artwork.imageUrl) + '" alt="' + escapeHtml(artwork.title || 'Artwork') + 
                        '" class="img-thumbnail me-3" style="width: 100px; height: 100px; object-fit: cover;">' : '') +
                      '<div class="flex-grow-1">' +
                        '<h6 class="mb-1">' + escapeHtml(artwork.title || 'Unknown Artwork') + '</h6>' +
                        '<p class="text-muted mb-1 small">Artist: ' + escapeHtml(artwork.artistName || 'Unknown') + '</p>' +
                        '<p class="mb-2"><strong>Your Bid: RM ' + amount + '</strong></p>' +
                        '<p class="mb-2 small text-muted">Current Bid: RM ' + 
                          parseFloat(artwork.currentBid || 0).toFixed(2) + '</p>' +
                        '<a href="/artwork/' + escapeHtml(artwork.id || '') + '" class="btn btn-sm btn-primary">' +
                          '<i class="fas fa-eye me-1"></i>View Auction</a>' +
                      '</div>' +
                    '</div>' +
                  '</div>' +
                '</div>' +
              '</div>';
            });
            
            html += '</div></div>';
          }
          
          bidsContent.innerHTML = html;
          
          // Start countdown timers for payment deadlines
          wonAuctions.forEach(purchase => {
            if (purchase.paymentDeadline) {
              startPaymentCountdown(purchase.purchaseId, purchase.paymentDeadline);
            }
          });
        })
        .catch(error => {
          console.error('Error loading bids:', error);
          bidsContent.innerHTML = 
            '<div class="alert alert-danger" role="alert">' +
              '<i class="fas fa-exclamation-triangle me-2"></i>' +
              'Error loading bidding history. Please try again later.' +
            '</div>';
        });
      }
      
      function startPaymentCountdown(purchaseId, deadlineStr) {
        const deadlineId = 'deadline-' + purchaseId;
        const deadlineElement = document.getElementById(deadlineId);
        if (!deadlineElement) return;
        
        const deadline = new Date(deadlineStr);
        
        function updateCountdown() {
          const now = new Date();
          const diff = deadline - now;
          
          if (diff <= 0) {
            deadlineElement.innerHTML = '<span class="text-danger"><i class="fas fa-exclamation-triangle me-1"></i>Payment deadline expired</span>';
            // Reload the page to update the UI
            setTimeout(() => {
              loadBids();
            }, 5000);
            return;
          }
          
          const hours = Math.floor(diff / (1000 * 60 * 60));
          const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
          const seconds = Math.floor((diff % (1000 * 60)) / 1000);
          
          deadlineElement.innerHTML = '<span class="text-warning"><i class="fas fa-clock me-1"></i>' + 
            hours + 'h ' + minutes + 'm ' + seconds + 's remaining</span>';
        }
        
        // Update immediately
        updateCountdown();
        
        // Update every second
        const interval = setInterval(updateCountdown, 1000);
        
        // Clear interval when element is removed
        const observer = new MutationObserver(() => {
          if (!document.getElementById(deadlineId)) {
            clearInterval(interval);
            observer.disconnect();
          }
        });
        observer.observe(document.body, { childList: true, subtree: true });
      }
      
      function proceedToAuctionPayment(purchaseId) {
        // Show payment modal or redirect to payment page
        // For now, we'll create a simple payment modal
        showAuctionPaymentModal(purchaseId);
      }
      
      function showAuctionPaymentModal(purchaseId) {
        // Fetch purchase details first
        fetch('/api/purchases/' + purchaseId, {
          credentials: 'include',
          headers: {
            'Content-Type': 'application/json'
          }
        })
        .then(response => response.json())
        .then(data => {
          if (data.success && data.purchase) {
            const purchase = data.purchase;
            const artwork = purchase.artwork || {};
            const price = parseFloat(purchase.purchasePrice || 0).toFixed(2);
            
            // Create and show payment modal
            const modalHtml = 
              '<div class="modal fade" id="auctionPaymentModal" tabindex="-1">' +
                '<div class="modal-dialog">' +
                  '<div class="modal-content">' +
                    '<div class="modal-header">' +
                      '<h5 class="modal-title">Complete Payment</h5>' +
                      '<button type="button" class="btn-close" data-bs-dismiss="modal"></button>' +
                    '</div>' +
                    '<div class="modal-body">' +
                      '<p><strong>' + escapeHtml(artwork.title || 'Artwork') + '</strong></p>' +
                      '<p>Winning Bid: <strong>RM ' + price + '</strong></p>' +
                      '<form id="auctionPaymentForm">' +
                        '<div class="mb-3">' +
                          '<label class="form-label">Payment Method *</label>' +
                          '<select class="form-select" name="paymentMethod" required>' +
                            '<option value="">Select payment method</option>' +
                            '<option value="BANK_TRANSFER">Bank Transfer</option>' +
                            '<option value="CREDIT_CARD">Credit Card</option>' +
                            '<option value="DEBIT_CARD">Debit Card</option>' +
                            '<option value="E_WALLET">E-Wallet</option>' +
                          '</select>' +
                        '</div>' +
                        '<div class="mb-3">' +
                          '<label class="form-label">Shipping Address *</label>' +
                          '<textarea class="form-control" name="shippingAddress" rows="3" required placeholder="Enter your complete shipping address"></textarea>' +
                        '</div>' +
                        '<div class="mb-3">' +
                          '<label class="form-label">Notes (Optional)</label>' +
                          '<textarea class="form-control" name="notes" rows="2" placeholder="Any additional notes"></textarea>' +
                        '</div>' +
                      '</form>' +
                    '</div>' +
                    '<div class="modal-footer">' +
                      '<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>' +
                      '<button type="button" class="btn btn-success" onclick="submitAuctionPayment(\'' + purchaseId + '\')">Complete Payment</button>' +
                    '</div>' +
                  '</div>' +
                '</div>' +
              '</div>';
            
            // Remove existing modal if any
            const existingModal = document.getElementById('auctionPaymentModal');
            if (existingModal) {
              existingModal.remove();
            }
            
            // Add modal to body
            document.body.insertAdjacentHTML('beforeend', modalHtml);
            
            // Show modal
            const modal = new bootstrap.Modal(document.getElementById('auctionPaymentModal'));
            modal.show();
            
            // Clean up when modal is hidden
            document.getElementById('auctionPaymentModal').addEventListener('hidden.bs.modal', function() {
              this.remove();
            });
          } else {
            showToast('Failed to load purchase details', 'error');
          }
        })
        .catch(error => {
          console.error('Error loading purchase:', error);
          showToast('Error loading purchase details', 'error');
        });
      }
      
      function submitAuctionPayment(purchaseId) {
        const form = document.getElementById('auctionPaymentForm');
        if (!form.checkValidity()) {
          form.reportValidity();
          return;
        }
        
        const formData = new FormData(form);
        const paymentData = {
          paymentMethod: formData.get('paymentMethod'),
          shippingAddress: formData.get('shippingAddress'),
          notes: formData.get('notes') || ''
        };
        
        // Disable submit button
        const submitBtn = event.target;
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Processing...';
        
        fetch('/api/purchases/' + purchaseId + '/complete-payment', {
          method: 'POST',
          credentials: 'include',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(paymentData)
        })
        .then(response => response.json())
        .then(data => {
          if (data.success) {
            showToast('Payment completed successfully!', 'success');
            // Close modal
            const modal = bootstrap.Modal.getInstance(document.getElementById('auctionPaymentModal'));
            modal.hide();
            // Reload purchases and bids
            setTimeout(() => {
              loadPurchases();
              loadBids();
            }, 1000);
          } else {
            showToast(data.error || 'Payment failed', 'error');
            submitBtn.disabled = false;
            submitBtn.innerHTML = 'Complete Payment';
          }
        })
        .catch(error => {
          console.error('Error completing payment:', error);
          showToast('Error completing payment', 'error');
          submitBtn.disabled = false;
          submitBtn.innerHTML = 'Complete Payment';
        });
      }
      
      function proceedToPayment(purchaseId) {
        // Redirect to payment page or checkout
        window.location.href = '/checkout/' + purchaseId;
      }
      
      function escapeHtml(text) {
        if (!text) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
      }

      // Toast Notification Functions
      function showToast(message, type) {
        type = type || "info";
        const toastContainer = document.getElementById('toastContainer');
        if (!toastContainer) {
          console.error("Toast container not found");
          return;
        }

        const toastId = 'toast-' + Date.now();
        const bgColor = type === 'success' ? 'bg-success' : type === 'error' ? 'bg-danger' : 'bg-info';
        const icon = type === 'success' ? 'fa-check-circle' : type === 'error' ? 'fa-exclamation-circle' : 'fa-info-circle';
        const titleText = type === 'success' ? 'Success' : type === 'error' ? 'Error' : 'Info';

        // Use string concatenation instead of template literals to avoid JSP EL conflicts
        const toastHTML = 
          '<div id="' + toastId + '" class="toast ' + bgColor + ' text-white" role="alert" aria-live="assertive" aria-atomic="true">' +
            '<div class="toast-header ' + bgColor + ' text-white">' +
              '<i class="fas ' + icon + ' me-2"></i>' +
              '<strong class="me-auto">' + titleText + '</strong>' +
              '<button type="button" class="btn-close btn-close-white" data-bs-dismiss="toast" aria-label="Close"></button>' +
            '</div>' +
            '<div class="toast-body">' +
              escapeHtml(message) +
            '</div>' +
          '</div>';

        toastContainer.insertAdjacentHTML('beforeend', toastHTML);
        
        const toastElement = document.getElementById(toastId);
        const toast = new bootstrap.Toast(toastElement, {
          autohide: true,
          delay: 5000
        });
        toast.show();

        // Remove toast element after it's hidden
        toastElement.addEventListener('hidden.bs.toast', function() {
          toastElement.remove();
        });
      }
      
      // Mock test function for UI validation (temporary - remove in production)
      // Call mockTest() in browser console to test UI rendering with fake data
      function mockTest() {
        console.log("=== Running mock test ===");
        
        // Mock dashboard stats
        const mockStats = {
          totalArtworks: 5,
          totalLikes: 12,
          totalPurchases: 3,
          activeBids: 8,
          totalEarnings: 1500.00
        };
        displayDashboardStats(mockStats);
        
        // Mock seller dashboard data
        const mockSellerData = {
          likesCount: 12,
          purchasesCount: 3,
          auctions: [
            {
              auctionId: "mock1",
              artworkTitle: "Sunset Over KL",
              currentBid: 150.00,
              biddersCount: 4
            },
            {
              auctionId: "mock2",
              artworkTitle: "City Lights",
              currentBid: 250.00,
              biddersCount: 2
            }
          ]
        };
        displaySellerDashboard(mockSellerData);
        
        // Mock bidders
        const mockBidders = [
          {
            bidderId: "user1",
            bidderName: "Ali",
            bidAmount: 150.00,
            previousBid: 120.00,
            timestamp: new Date().toISOString()
          },
          {
            bidderId: "user2",
            bidderName: "Sarah",
            bidAmount: 140.00,
            previousBid: null,
            timestamp: new Date(Date.now() - 3600000).toISOString()
          }
        ];
        displayBidders(mockBidders, 2, "amount");
        
        console.log("Mock test completed - check UI for rendered data");
        alert("Mock test completed! Check the dashboard for rendered mock data.");
      }

      // Sales Report Functions
      let currentSalesReportData = null;

      function loadSalesReport() {
        console.log("=== loadSalesReport called ===");
        const tableBody = document.getElementById("salesTableBody");
        const emptyState = document.getElementById("salesEmptyState");
        
        if (!tableBody) {
          console.error("Sales table body not found");
          return;
        }

        // Show loading state
        tableBody.innerHTML = '<tr><td colspan="5" class="text-center py-4"><div class="spinner-border text-primary" role="status"><span class="visually-hidden">Loading...</span></div><p class="mt-2 text-muted">Loading sales data...</p></td></tr>';
        emptyState.style.display = "none";

        // Get date filters
        const startDate = document.getElementById("startDate")?.value || "";
        const endDate = document.getElementById("endDate")?.value || "";

        // Build URL with query parameters
        let url = "/api/sales-report";
        const params = new URLSearchParams();
        if (startDate) params.append("startDate", startDate);
        if (endDate) params.append("endDate", endDate);
        if (params.toString()) url += "?" + params.toString();

        fetch(url, {
          credentials: 'include',
          headers: {
            'Accept': 'application/json'
          }
        })
          .then(response => {
            if (!response.ok) {
              if (response.status === 401) {
                throw new Error("Authentication required. Please refresh the page.");
              } else if (response.status === 403) {
                throw new Error("Access denied. This feature is only available for artists.");
              } else {
                throw new Error("Failed to load sales report: " + response.status);
              }
            }
            return response.json();
          })
          .then(data => {
            console.log("Sales report response:", data);
            if (data.success && data.data) {
              currentSalesReportData = data.data;
              displaySalesReport(data.data);
            } else {
              throw new Error(data.error || "Invalid response format");
            }
          })
          .catch(error => {
            console.error("Error loading sales report:", error);
            tableBody.innerHTML = '<tr><td colspan="5" class="text-center py-4"><div class="alert alert-danger">' + error.message + '</div></td></tr>';
          });
      }

      function displaySalesReport(reportData) {
        // Update summary cards
        document.getElementById("totalArtworksSold").textContent = reportData.totalArtworksSold || 0;
        document.getElementById("totalRevenue").textContent = "MYR " + (reportData.totalRevenue || 0).toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
        document.getElementById("directPurchaseCount").textContent = reportData.directPurchaseCount || 0;
        document.getElementById("directPurchaseRevenue").textContent = "MYR " + (reportData.directPurchaseRevenue || 0).toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
        document.getElementById("auctionSaleCount").textContent = reportData.auctionSaleCount || 0;
        document.getElementById("auctionSaleRevenue").textContent = "MYR " + (reportData.auctionSaleRevenue || 0).toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});

        // Update table
        const tableBody = document.getElementById("salesTableBody");
        const emptyState = document.getElementById("salesEmptyState");
        const salesRecords = reportData.salesRecords || [];

        if (salesRecords.length === 0) {
          tableBody.innerHTML = "";
          emptyState.style.display = "block";
          return;
        }

        emptyState.style.display = "none";
        tableBody.innerHTML = "";

        // Sort sales records by date (newest first)
        salesRecords.sort((a, b) => {
          const dateA = new Date(a.saleDate || 0);
          const dateB = new Date(b.saleDate || 0);
          return dateB - dateA;
        });

        salesRecords.forEach(function(record) {
          const row = document.createElement("tr");
          const saleDate = record.saleDate ? new Date(record.saleDate) : null;
          const formattedDate = saleDate ? saleDate.toLocaleDateString('en-US', { 
            year: 'numeric', 
            month: 'short', 
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
          }) : "N/A";

          const saleTypeBadge = record.saleType === "AUCTION" 
            ? '<span class="badge bg-warning text-dark"><i class="fas fa-gavel me-1"></i>Auction</span>'
            : '<span class="badge bg-primary"><i class="fas fa-shopping-cart me-1"></i>Direct Purchase</span>';

          const artworkTitle = escapeHtml(record.artworkTitle || "Unknown");
          const buyerUsername = escapeHtml(record.buyerUsername || "Unknown");
          const finalPrice = parseFloat(record.finalPrice || 0).toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
          
          row.innerHTML = '<td>' + artworkTitle + '</td>' +
            '<td>' + buyerUsername + '</td>' +
            '<td>' + saleTypeBadge + '</td>' +
            '<td><strong>MYR ' + finalPrice + '</strong></td>' +
            '<td>' + formattedDate + '</td>';
          tableBody.appendChild(row);
        });
      }

      function applyQuickFilter() {
        const filterValue = document.getElementById("quickFilter").value;
        const today = new Date();
        const startDateInput = document.getElementById("startDate");
        const endDateInput = document.getElementById("endDate");

        if (!filterValue) {
          // All time - clear dates
          startDateInput.value = "";
          endDateInput.value = "";
        } else if (filterValue === "thisMonth") {
          const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
          startDateInput.value = startOfMonth.toISOString().split('T')[0];
          endDateInput.value = today.toISOString().split('T')[0];
        } else if (filterValue === "last3Months") {
          const threeMonthsAgo = new Date(today);
          threeMonthsAgo.setMonth(today.getMonth() - 3);
          startDateInput.value = threeMonthsAgo.toISOString().split('T')[0];
          endDateInput.value = today.toISOString().split('T')[0];
        } else if (filterValue === "last6Months") {
          const sixMonthsAgo = new Date(today);
          sixMonthsAgo.setMonth(today.getMonth() - 6);
          startDateInput.value = sixMonthsAgo.toISOString().split('T')[0];
          endDateInput.value = today.toISOString().split('T')[0];
        } else if (filterValue === "thisYear") {
          const startOfYear = new Date(today.getFullYear(), 0, 1);
          startDateInput.value = startOfYear.toISOString().split('T')[0];
          endDateInput.value = today.toISOString().split('T')[0];
        }

        applyDateFilter();
      }

      function applyDateFilter() {
        // Reset quick filter when manually selecting dates
        document.getElementById("quickFilter").value = "";
        loadSalesReport();
      }

      function downloadReport(format) {
        if (!currentSalesReportData) {
          alert("Please load the sales report first.");
          return;
        }

        if (format === "csv") {
          downloadCSV(currentSalesReportData);
        } else if (format === "pdf") {
          downloadPDF(currentSalesReportData);
        }
      }

      function downloadCSV(reportData) {
        const salesRecords = reportData.salesRecords || [];
        let csv = "Artwork Title,Buyer Username,Sale Type,Final Price,Sale Date\n";

        salesRecords.forEach(function(record) {
          const saleDate = record.saleDate ? new Date(record.saleDate).toLocaleDateString() : "N/A";
          const artworkTitle = (record.artworkTitle || "Unknown").replace(/"/g, '""');
          const buyerUsername = (record.buyerUsername || "Unknown").replace(/"/g, '""');
          const saleType = record.saleType || "Unknown";
          const finalPrice = record.finalPrice || 0;
          
          csv += '"' + artworkTitle + '",';
          csv += '"' + buyerUsername + '",';
          csv += '"' + saleType + '",';
          csv += finalPrice + ',';
          csv += '"' + saleDate + '"\n';
        });

        const blob = new Blob([csv], { type: "text/csv;charset=utf-8;" });
        const link = document.createElement("a");
        const url = URL.createObjectURL(blob);
        link.setAttribute("href", url);
        const dateStr = new Date().toISOString().split('T')[0];
        link.setAttribute("download", "sales-report-" + dateStr + ".csv");
        link.style.visibility = "hidden";
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
      }

      function downloadPDF(reportData) {
        // Create a simple HTML table for PDF generation
        const salesRecords = reportData.salesRecords || [];
        
        // Use string concatenation to avoid JSP EL parsing issues
        const totalSold = reportData.totalArtworksSold || 0;
        const totalRevenue = (reportData.totalRevenue || 0).toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
        const directCount = reportData.directPurchaseCount || 0;
        const directRevenue = (reportData.directPurchaseRevenue || 0).toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
        const auctionCount = reportData.auctionSaleCount || 0;
        const auctionRevenue = (reportData.auctionSaleRevenue || 0).toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
        
        let html = '<!DOCTYPE html>\n' +
          '<html>\n' +
          '<head>\n' +
          '  <title>Sales Report</title>\n' +
          '  <style>\n' +
          '    body { font-family: Arial, sans-serif; margin: 20px; }\n' +
          '    h1 { color: #333; }\n' +
          '    .summary { margin: 20px 0; }\n' +
          '    .summary-item { margin: 10px 0; }\n' +
          '    table { width: 100%; border-collapse: collapse; margin-top: 20px; }\n' +
          '    th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }\n' +
          '    th { background-color: #f2f2f2; }\n' +
          '    .total { font-weight: bold; }\n' +
          '  </style>\n' +
          '</head>\n' +
          '<body>\n' +
          '  <h1>Sales Report</h1>\n' +
          '  <div class="summary">\n' +
          '    <div class="summary-item"><strong>Total Artworks Sold:</strong> ' + totalSold + '</div>\n' +
          '    <div class="summary-item"><strong>Total Revenue:</strong> MYR ' + totalRevenue + '</div>\n' +
          '    <div class="summary-item"><strong>Direct Purchases:</strong> ' + directCount + ' (MYR ' + directRevenue + ')</div>\n' +
          '    <div class="summary-item"><strong>Auction Sales:</strong> ' + auctionCount + ' (MYR ' + auctionRevenue + ')</div>\n' +
          '  </div>\n' +
          '  <table>\n' +
          '    <thead>\n' +
          '      <tr>\n' +
          '        <th>Artwork Title</th>\n' +
          '        <th>Buyer Username</th>\n' +
          '        <th>Sale Type</th>\n' +
          '        <th>Final Price</th>\n' +
          '        <th>Sale Date</th>\n' +
          '      </tr>\n' +
          '    </thead>\n' +
          '    <tbody>\n';

        salesRecords.forEach(function(record) {
          const saleDate = record.saleDate ? new Date(record.saleDate).toLocaleDateString() : "N/A";
          const artworkTitle = escapeHtml(record.artworkTitle || "Unknown");
          const buyerUsername = escapeHtml(record.buyerUsername || "Unknown");
          const saleType = record.saleType || "Unknown";
          const finalPrice = parseFloat(record.finalPrice || 0).toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
          
          html += '      <tr>\n' +
            '        <td>' + artworkTitle + '</td>\n' +
            '        <td>' + buyerUsername + '</td>\n' +
            '        <td>' + saleType + '</td>\n' +
            '        <td>MYR ' + finalPrice + '</td>\n' +
            '        <td>' + saleDate + '</td>\n' +
            '      </tr>\n';
        });

        const generatedDate = new Date().toLocaleString();
        html += '    </tbody>\n' +
          '  </table>\n' +
          '  <div style="margin-top: 20px; font-size: 12px; color: #666;">\n' +
          '    Generated on ' + generatedDate + '\n' +
          '  </div>\n' +
          '</body>\n' +
          '</html>\n';

        // Open in new window and trigger print (user can save as PDF)
        const printWindow = window.open('', '_blank');
        printWindow.document.write(html);
        printWindow.document.close();
        printWindow.focus();
        setTimeout(function() {
          printWindow.print();
        }, 250);
      }

      function escapeHtml(text) {
        const map = {
          '&': '&amp;',
          '<': '&lt;',
          '>': '&gt;',
          '"': '&quot;',
          "'": '&#039;'
        };
        return String(text).replace(/[&<>"']/g, function(m) { return map[m]; });
      }

      // ============================================
      // REVIEW FUNCTIONALITY
      // ============================================
      
      // Track submitted reviews (mocked - in real app, this would come from backend)
      const submittedReviews = new Set();
      
      /**
       * Open review modal for a purchase
       * @param {string} purchaseId - The purchase ID
       * @param {string} artworkTitle - The artwork title
       * @param {string} artistName - The artist name
       * @param {string} imageUrl - The artwork image URL
       */
      function openReviewModal(purchaseId, artworkTitle, artistName, imageUrl) {
        // Reset form
        document.getElementById('reviewRating').value = '0';
        document.getElementById('reviewText').value = '';
        document.getElementById('reviewPurchaseId').value = purchaseId;
        
        // Update artwork info
        document.getElementById('reviewArtworkTitle').textContent = artworkTitle;
        document.getElementById('reviewArtistName').textContent = 'by ' + artistName;
        document.getElementById('reviewArtworkImage').src = imageUrl;
        
        // Reset star rating display
        const stars = document.querySelectorAll('#starRating .star');
        stars.forEach(star => {
          star.classList.remove('selected', 'hovered');
          const icon = star.querySelector('i');
          if (icon) {
            icon.className = 'far fa-star';
          }
        });
        
        // Hide rating error
        document.getElementById('ratingError').classList.add('d-none');
        
        // Show modal
        const reviewModal = new bootstrap.Modal(document.getElementById('reviewModal'));
        reviewModal.show();
        
        // Initialize star rating interactions
        initializeStarRating();
      }
      
      /**
       * Initialize star rating interaction
       */
      function initializeStarRating() {
        const stars = document.querySelectorAll('#starRating .star');
        const ratingInput = document.getElementById('reviewRating');
        
        stars.forEach((star, index) => {
          // Remove existing event listeners by cloning
          const newStar = star.cloneNode(true);
          star.parentNode.replaceChild(newStar, star);
          
          // Click event - set rating
          newStar.addEventListener('click', function() {
            const rating = parseInt(this.getAttribute('data-rating'));
            setStarRating(rating);
            ratingInput.value = rating;
            document.getElementById('ratingError').classList.add('d-none');
          });
          
          // Mouse enter - preview rating
          newStar.addEventListener('mouseenter', function() {
            const rating = parseInt(this.getAttribute('data-rating'));
            previewStarRating(rating);
          });
        });
        
        // Mouse leave - restore to selected rating
        const starRating = document.getElementById('starRating');
        starRating.addEventListener('mouseleave', function() {
          const currentRating = parseInt(ratingInput.value) || 0;
          if (currentRating > 0) {
            setStarRating(currentRating);
          } else {
            clearStarRating();
          }
        });
      }
      
      /**
       * Set star rating display
       * @param {number} rating - Rating value (1-5)
       */
      function setStarRating(rating) {
        const stars = document.querySelectorAll('#starRating .star');
        stars.forEach((star, index) => {
          const starRating = parseInt(star.getAttribute('data-rating'));
          const icon = star.querySelector('i');
          
          if (starRating <= rating) {
            star.classList.add('selected');
            star.classList.remove('hovered');
            if (icon) {
              icon.className = 'fas fa-star';
            }
          } else {
            star.classList.remove('selected', 'hovered');
            if (icon) {
              icon.className = 'far fa-star';
            }
          }
        });
      }
      
      /**
       * Preview star rating on hover
       * @param {number} rating - Rating value (1-5)
       */
      function previewStarRating(rating) {
        const stars = document.querySelectorAll('#starRating .star');
        stars.forEach((star, index) => {
          const starRating = parseInt(star.getAttribute('data-rating'));
          const icon = star.querySelector('i');
          
          if (starRating <= rating) {
            star.classList.add('hovered');
            if (icon) {
              icon.className = 'fas fa-star';
            }
          } else {
            star.classList.remove('hovered');
            if (icon && !star.classList.contains('selected')) {
              icon.className = 'far fa-star';
            }
          }
        });
      }
      
      /**
       * Clear star rating display
       */
      function clearStarRating() {
        const stars = document.querySelectorAll('#starRating .star');
        stars.forEach(star => {
          star.classList.remove('selected', 'hovered');
          const icon = star.querySelector('i');
          if (icon) {
            icon.className = 'far fa-star';
          }
        });
      }
      
      /**
       * Submit review to API
       * This saves the review with artist_id from the purchase/artwork
       */
      function submitReview() {
        const purchaseId = document.getElementById('reviewPurchaseId').value;
        const rating = parseInt(document.getElementById('reviewRating').value);
        const reviewText = document.getElementById('reviewText').value.trim();
        
        // Validation
        if (!rating || rating < 1 || rating > 5) {
          document.getElementById('ratingError').classList.remove('d-none');
          return;
        }
        
        if (!reviewText) {
          showToast('Please enter your review text', 'error');
          document.getElementById('reviewText').focus();
          return;
        }
        
        // Debug log
        console.log('Submitting review:', {
          purchaseId: purchaseId,
          rating: rating,
          reviewText: reviewText
        });
        
        // Get submit button and disable it
        const submitBtn = document.getElementById('submitReviewBtn');
        const originalText = submitBtn.innerHTML;
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Submitting...';
        
        // Submit review to API
        fetch('/api/reviews', {
          method: 'POST',
          credentials: 'include',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            purchaseId: purchaseId,
            rating: rating,
            reviewText: reviewText
          })
        })
        .then(response => {
          if (!response.ok) {
            return response.json().then(err => {
              throw new Error(err.error || 'Failed to submit review');
            });
          }
          return response.json();
        })
        .then(data => {
          console.log('Review submitted successfully:', data);
          
          // Debug: Log artist_id from response
          if (data.data && data.data.artistId) {
            console.log('Review saved with artist_id:', data.data.artistId);
          }
          
          // Mark as submitted
          submittedReviews.add(purchaseId);
          
          // Close modal
          const reviewModal = bootstrap.Modal.getInstance(document.getElementById('reviewModal'));
          reviewModal.hide();
          
          // Update UI - replace "Leave Review" button with "Review Submitted"
          updatePurchaseCardAfterReview(purchaseId);
          
          // Show success message
          showToast('Review submitted successfully!', 'success');
          
          // Reset button
          submitBtn.disabled = false;
          submitBtn.innerHTML = originalText;
        })
        .catch(error => {
          console.error('Error submitting review:', error);
          showToast('Failed to submit review: ' + error.message, 'error');
          
          // Reset button
          submitBtn.disabled = false;
          submitBtn.innerHTML = originalText;
        });
      }
      
      /**
       * Update purchase card after review submission
       * @param {string} purchaseId - The purchase ID
       */
      function updatePurchaseCardAfterReview(purchaseId) {
        const purchaseCard = document.querySelector(`.purchase-card[data-purchase-id="${purchaseId}"]`);
        if (!purchaseCard) return;
        
        // Find the review button container
        const actionContainer = purchaseCard.querySelector('.col-md-6.text-end');
        if (!actionContainer) return;
        
        // Find and replace the review button
        const reviewButton = actionContainer.querySelector('button[data-purchase-id="' + purchaseId + '"]');
        if (reviewButton) {
          // Get artwork details from button data attributes
          const artworkTitle = reviewButton.getAttribute('data-artwork-title') || '';
          const artistName = reviewButton.getAttribute('data-artist-name') || '';
          const imageUrl = reviewButton.getAttribute('data-image-url') || '';
          
          // Create replacement HTML
          const replacement = document.createElement('span');
          replacement.innerHTML = 
            '<span class="text-muted small me-2"><i class="fas fa-check-circle me-1"></i>Review Submitted</span>' +
            '<a href="#" class="text-muted small text-decoration-none" onclick="openReviewModal(\'' + purchaseId + '\', \'' + 
            artworkTitle.replace(/'/g, "\\'") + '\', \'' + 
            artistName.replace(/'/g, "\\'") + '\', \'' + 
            imageUrl.replace(/'/g, "\\'") + '\'); return false;">Edit Review</a>';
          
          reviewButton.replaceWith(replacement);
        }
      }
    </script>
  </body>
</html>
