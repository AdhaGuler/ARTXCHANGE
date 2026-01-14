/**
 * JavaScript for user profile functionality
 */

class UserProfileManager {
    constructor() {
        this.currentUserId = null;
        this.currentPage = 1;
        this.currentCategory = 'All';
        this.isLoading = false;
        this.hasMore = true;
        this.isOwnProfile = false;
        this.userRole = null;
        this.purchasedPage = 1;
        this.hasMorePurchased = true;
        
        this.init();
    }
    
    init() {
        // Get user ID from URL parameters
        const urlParams = new URLSearchParams(window.location.search);
        this.currentUserId = urlParams.get('userId');
        
        // Try to hide buyer sections early if we can detect buyer role
        if (!this.currentUserId) {
            // Try to get user role from auth to hide sections early
            fetch('/auth/profile', {
                credentials: 'include',
                headers: { 'Accept': 'application/json' }
            })
            .then(response => response.json())
            .then(data => {
                if (data.success && data.user && data.user.role === 'BUYER') {
                    this.hideBuyerSections();
                }
            })
            .catch(() => {
                // If auth fails, sections will be hidden after profile loads
            });
        }
        
        if (!this.currentUserId) {
            // If no userId provided, try to get current user's profile
            this.loadCurrentUserProfile();
            return;
        }
        
        this.loadUserProfile();
        this.setupEventListeners();
    }
    
    hideBuyerSections() {
        // Hide stats section for buyers
        const statsContainer = document.getElementById('statsContainer');
        if (statsContainer) {
            statsContainer.style.display = 'none';
            console.log('Stats section hidden for buyer');
        }
        
        // Hide artworks section for buyers
        const artworksSection = document.getElementById('artworksSection');
        if (artworksSection) {
            artworksSection.style.display = 'none';
            console.log('Artworks section hidden for buyer');
        }
    }
    
    setupEventListeners() {
        // Category filter buttons
        document.querySelectorAll('.category-filter').forEach(button => {
            button.addEventListener('click', (e) => {
                this.handleCategoryFilter(e.target.dataset.category);
            });
        });
        
        // Follow button
        const followBtn = document.getElementById('followBtn');
        if (followBtn) {
            followBtn.addEventListener('click', () => {
                this.toggleFollow();
            });
        }
        
        // Edit button
        const editBtn = document.getElementById('editBtn');
        if (editBtn) {
            editBtn.addEventListener('click', () => {
                this.showEditProfileModal();
            });
        }
        
        // Profile picture preview
        const profilePictureInput = document.getElementById('editProfilePicture');
        if (profilePictureInput) {
            profilePictureInput.addEventListener('change', (e) => {
                this.handleProfilePicturePreview(e);
            });
        }
        
        // Bio character counter
        const bioTextarea = document.getElementById('editBio');
        if (bioTextarea) {
            bioTextarea.addEventListener('input', () => {
                this.updateBioCharCount();
            });
        }
        
        // Message button
        const messageBtn = document.getElementById('messageBtn');
        if (messageBtn) {
            messageBtn.addEventListener('click', () => {
                this.startConversation();
            });
        }
        
        // Load more button
        const loadMoreBtn = document.getElementById('loadMoreBtn');
        if (loadMoreBtn) {
            loadMoreBtn.addEventListener('click', () => {
                this.loadMoreArtworks();
            });
        }
        
        // Load more purchased button
        const loadMorePurchasedBtn = document.getElementById('loadMorePurchasedBtn');
        if (loadMorePurchasedBtn) {
            loadMorePurchasedBtn.addEventListener('click', () => {
                this.loadMorePurchasedArtworks();
            });
        }
        
        // Infinite scroll (optional)
        window.addEventListener('scroll', () => {
            if (this.isNearBottom() && !this.isLoading && this.hasMore) {
                this.loadMoreArtworks();
            }
        });
    }
    
    async loadUserProfile() {
        try {
            console.log('Loading profile for userId:', this.currentUserId);
            
            // Immediately try to get current user info to replace "Loading..." quickly (only if logged in)
            this.loadCurrentUserInfo();
            
            // Allow public access - don't require credentials for viewing profiles
            const response = await fetch(`/api/users/${this.currentUserId}`, {
                credentials: 'include', // Include credentials if available, but don't fail if not
                headers: {
                    'Accept': 'application/json'
                }
            });
            
            if (!response.ok) {
                if (response.status === 404) {
                    this.showError('User profile not found');
                    return;
                }
                const errorText = await response.text();
                console.error('HTTP error response:', response.status, errorText);
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            
            const result = await response.json();
            console.log('Profile response:', result);
            
            // Backend returns: {success: true, data: {user: {...}, isOwnProfile: true, isFollowing: false}}
            if (!result.success) {
                this.showError(result.error || 'Failed to load user profile');
                return;
            }
            
            // Extract profile data from response
            const profileData = result.data || result;
            console.log('Profile data extracted:', profileData);
            
            // Check if we have user data
            if (profileData && (profileData.user || profileData.userId || profileData.firstName)) {
                console.log('Rendering profile with data:', profileData);
                // Render profile header FIRST (replaces "Loading..." immediately)
                this.renderUserProfile(profileData);
                // Then load stats and artworks
                this.loadUserStats();
            } else {
                console.error('Invalid profile data structure:', profileData);
                this.showError('Invalid profile data received. Expected user object.');
            }
        } catch (error) {
            console.error('Error loading user profile:', error);
            this.showError('Failed to load user profile: ' + error.message);
        }
    }
    
    async loadCurrentUserInfo() {
        // Try to quickly load current user info to replace "Loading..." text
        try {
            const response = await fetch('/auth/profile', {
                credentials: 'include',
                headers: {
                    'Accept': 'application/json'
                }
            });
            
            if (response.ok) {
                const result = await response.json();
                if (result.success && result.user) {
                    const user = result.user;
                    // Immediately update username if viewing own profile
                    if (user.userId === this.currentUserId) {
                        const nameEl = document.getElementById('userName');
                        if (nameEl && nameEl.textContent === 'Loading...') {
                            const displayName = user.displayName || 
                                              (user.firstName && user.lastName ? user.firstName + ' ' + user.lastName : '') ||
                                              user.firstName || 
                                              user.username || 
                                              'User';
                            nameEl.textContent = displayName;
                        }
                        
                        const usernameEl = document.getElementById('userUsername');
                        if (usernameEl && usernameEl.textContent === '@loading') {
                            usernameEl.textContent = '@' + (user.username || 'user');
                        }
                        
                        // Update profile picture immediately
                        const avatarEl = document.getElementById('userAvatar');
                        if (avatarEl && user.profileImage) {
                            let avatarUrl = user.profileImage;
                            if (!avatarUrl.startsWith('http') && !avatarUrl.startsWith('/')) {
                                avatarUrl = '/' + avatarUrl;
                            }
                            avatarEl.src = avatarUrl + (avatarUrl.includes('?') ? '&' : '?') + 't=' + Date.now();
                        }
                    }
                }
            }
        } catch (error) {
            console.log('Could not load current user info quickly:', error);
            // Continue with normal profile load
        }
    }
    
    async loadCurrentUserProfile() {
        try {
            console.log('Loading current user profile...');
            
            // Get current user's profile from auth endpoint
            const response = await fetch('/auth/profile', {
                credentials: 'include',
                headers: {
                    'Accept': 'application/json'
                }
            });
            
            if (!response.ok) {
                console.log('Not logged in or auth failed, checking if viewing other user profile');
                // Check if we have a userId in URL (viewing someone else's profile)
                const urlParams = new URLSearchParams(window.location.search);
                const userId = urlParams.get('userId');
                if (userId) {
                    // Viewing another user's profile, allow it
                    this.currentUserId = userId;
                    this.loadUserProfile();
                    this.setupEventListeners();
                    return;
                }
                // No userId and not logged in, redirect to home
                console.error('Auth profile response not OK and no userId in URL:', response.status);
                window.location.href = '/';
                return;
            }
            
            const result = await response.json();
            console.log('Auth profile response:', result);
            
            if (result.success && result.user) {
                this.currentUserId = result.user.userId || result.user.id;
                console.log('Current user ID:', this.currentUserId);
                
                // Update URL to include userId
                const newUrl = window.location.pathname + '?userId=' + this.currentUserId;
                window.history.replaceState({}, '', newUrl);
                
                this.loadUserProfile();
                this.setupEventListeners();
            } else {
                console.warn('No user data in auth profile response');
                // Check if viewing another user's profile
                const urlParams = new URLSearchParams(window.location.search);
                const userId = urlParams.get('userId');
                if (userId) {
                    this.currentUserId = userId;
                    this.loadUserProfile();
                    this.setupEventListeners();
                    return;
                }
                // User not logged in and no userId, redirect to home
                window.location.href = '/';
            }
        } catch (error) {
            console.error('Error loading current user profile:', error);
            // Check if viewing another user's profile (public access)
            const urlParams = new URLSearchParams(window.location.search);
            const userId = urlParams.get('userId');
            if (userId) {
                console.log('Allowing public profile access for userId:', userId);
                this.currentUserId = userId;
                this.loadUserProfile();
                this.setupEventListeners();
                return;
            }
            this.showError('Please log in to view your profile');
            setTimeout(() => {
                window.location.href = '/';
            }, 2000);
        }
    }
    
    renderUserProfile(data) {
        console.log('Rendering profile with data:', data);
        
        // Handle both response formats: {user, isOwnProfile, isFollowing} or direct user object
        let user = null;
        let isOwnProfile = false;
        let isFollowing = false;
        
        if (data.user) {
            // Format: {user: {...}, isOwnProfile: true, isFollowing: false}
            user = data.user;
            isOwnProfile = data.isOwnProfile || false;
            isFollowing = data.isFollowing || false;
        } else if (data.userId || data.firstName || data.username) {
            // Direct user object
            user = data;
        } else {
            console.error('No user data found in response:', data);
            this.showError('Invalid profile data received');
            return;
        }
        
        console.log('Extracted user:', user);
        
        // Update profile header - Avatar
        // Use profileImage field from database (not profileImageUrl)
        const avatarEl = document.getElementById('userAvatar');
        if (avatarEl) {
            // Check profileImage field first (this is the actual database field)
            let avatarUrl = user.profileImage || user.avatar_url || user.profileImageUrl;
            
            console.log('Profile image from user object:', avatarUrl);
            
            // Only use default if profileImage is null or empty
            if (!avatarUrl || avatarUrl.trim() === '' || avatarUrl === 'null' || avatarUrl === 'undefined') {
                avatarUrl = '/assets/images/default-avatar.svg';
                console.log('Using default avatar - no profile image found');
            } else {
                // ProfileServlet may return paths with context path like: /artexchange/uploads/profiles/filename.jpg
                // FileServlet is mapped to /uploads/*, so we need to strip context path if present
                // Get context path from current page
                const contextPath = window.location.pathname.split('/')[1] || '';
                
                // Ensure absolute URL if relative path
                if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')) {
                    // Already absolute URL - use as is
                    console.log('Using absolute URL:', avatarUrl);
                } else if (avatarUrl.startsWith('/')) {
                    // Already absolute path - strip context path if present
                    // If path is /artexchange/uploads/profiles/..., strip /artexchange
                    if (contextPath && avatarUrl.startsWith('/' + contextPath + '/')) {
                        avatarUrl = avatarUrl.substring(contextPath.length + 1);
                        console.log('Stripped context path, new URL:', avatarUrl);
                    }
                    console.log('Using absolute path:', avatarUrl);
                } else if (avatarUrl.startsWith('uploads/')) {
                    avatarUrl = '/' + avatarUrl;
                    console.log('Prepending / to uploads path:', avatarUrl);
                } else {
                    // Try different possible paths
                    if (!avatarUrl.includes('/')) {
                        // Just filename, assume it's in profiles directory
                        avatarUrl = '/uploads/profiles/' + avatarUrl;
                        console.log('Assuming filename in profiles directory:', avatarUrl);
                    } else {
                        // Already has path, just prepend /
                        if (!avatarUrl.startsWith('/')) {
                            avatarUrl = '/' + avatarUrl;
                        }
                        // Strip context path if present
                        if (contextPath && avatarUrl.startsWith('/' + contextPath + '/')) {
                            avatarUrl = avatarUrl.substring(contextPath.length + 1);
                        }
                        console.log('Using provided path:', avatarUrl);
                    }
                }
            }
            
            // Set avatar - DO NOT add cache busting if it's the default avatar
            if (avatarUrl.includes('default-avatar')) {
                avatarEl.src = avatarUrl;
            } else {
                // For uploaded images, ensure path is correct
                // ProfileServlet returns paths like: /artexchange/uploads/profiles/filename.jpg
                // or: /uploads/profiles/filename.jpg
                // We need to handle both cases
                
                // If path includes context path, use as-is
                // Otherwise, ensure it starts with /
                if (!avatarUrl.startsWith('/')) {
                    avatarUrl = '/' + avatarUrl;
                }
                
                // Add cache busting for uploaded images to force refresh
                const separator = avatarUrl.includes('?') ? '&' : '?';
                avatarEl.src = avatarUrl + separator + 't=' + Date.now();
            }
            
            // Error handler - try multiple path variations before giving up
            let retryCount = 0;
            avatarEl.onerror = function() {
                const currentSrc = this.src;
                console.warn('Profile image failed to load (attempt ' + (retryCount + 1) + '):', currentSrc);
                
                if (currentSrc.includes('default-avatar')) {
                    // Already using default, don't retry
                    return;
                }
                
                retryCount++;
                const originalUrl = user.profileImage || user.avatar_url || user.profileImageUrl;
                
                if (retryCount === 1 && originalUrl) {
                    // First retry: try without cache busting
                    const cleanUrl = originalUrl.split('?')[0];
                    if (!cleanUrl.startsWith('/')) {
                        this.src = '/' + cleanUrl;
                    } else {
                        this.src = cleanUrl;
                    }
                    console.log('Retry 1: Trying clean URL:', this.src);
                } else if (retryCount === 2 && originalUrl) {
                    // Second retry: try with /uploads/profiles/ prefix if not already there
                    let altUrl = originalUrl.split('?')[0];
                    if (!altUrl.includes('uploads/profiles') && !altUrl.startsWith('/')) {
                        altUrl = '/uploads/profiles/' + altUrl;
                    } else if (!altUrl.startsWith('/')) {
                        altUrl = '/' + altUrl;
                    }
                    this.src = altUrl;
                    console.log('Retry 2: Trying alternative path:', this.src);
                } else {
                    // Final fallback to default
                    console.log('All retries failed, using default avatar');
                    this.src = '/assets/images/default-avatar.svg';
                    this.onerror = null; // Prevent infinite loop
                }
            };
            console.log('Set avatar to:', avatarEl.src);
        }
        
        // Update profile header - Name (replace "Loading..." immediately)
        const nameEl = document.getElementById('userName');
        if (nameEl) {
            let displayName = '';
            // Try multiple possible fields for display name
            if (user.displayName && user.displayName.trim() !== '') {
                displayName = user.displayName;
            } else if (user.display_name && user.display_name.trim() !== '') {
                displayName = user.display_name;
            } else if (user.firstName && user.lastName) {
                displayName = (user.firstName + ' ' + user.lastName).trim();
            } else if (user.firstName && user.firstName.trim() !== '') {
                displayName = user.firstName;
            } else if (user.fullName && user.fullName.trim() !== '') {
                displayName = user.fullName;
            } else if (user.username && user.username.trim() !== '') {
                displayName = user.username;
            } else {
                displayName = 'User';
            }
            
            // Replace "Loading..." immediately
            if (nameEl.textContent === 'Loading...' || nameEl.textContent.trim() === '') {
                nameEl.textContent = displayName;
            } else {
                nameEl.textContent = displayName;
            }
            console.log('Set name to:', displayName);
        }
        
        // Update profile header - Username (replace "@loading" immediately)
        const usernameEl = document.getElementById('userUsername');
        if (usernameEl) {
            const username = user.username || 'user';
            usernameEl.textContent = '@' + username;
            console.log('Set username to:', '@' + username);
        }
        
        // Update profile header - Role (replace "User" with actual role)
        const roleEl = document.getElementById('userRole');
        if (roleEl) {
            const role = user.role || 'BUYER';
            // Format role for display
            let roleDisplay = role;
            if (role === 'ARTIST') {
                roleDisplay = 'Artist';
            } else if (role === 'BUYER') {
                roleDisplay = 'Buyer';
            } else if (role === 'ADMIN') {
                roleDisplay = 'Admin';
            }
            roleEl.textContent = roleDisplay;
            console.log('Set role to:', roleDisplay);
        }
        
        // Update verification badge
        const verifiedBadge = document.getElementById('verifiedBadge');
        if (verifiedBadge) {
            if (user.isVerified) {
                verifiedBadge.style.display = 'inline';
            } else {
                verifiedBadge.style.display = 'none';
            }
        }
        
        // Update bio
        const bioSection = document.getElementById('userBio');
        if (bioSection) {
            if (user.bio && user.bio.trim() !== '') {
                bioSection.textContent = user.bio;
            } else {
                bioSection.textContent = this.isOwnProfile ? 
                    'Add a bio to tell others about yourself.' : 
                    'This user has no bio yet.';
            }
            bioSection.style.display = 'block';
            console.log('Set bio to:', user.bio || 'No bio');
        }
        
        // Update location
        const locationEl = document.getElementById('userLocation');
        if (locationEl) {
            const location = [user.city, user.state, user.country]
                .filter(part => part && part.trim() !== '')
                .join(', ');
            locationEl.textContent = location || 'Location not specified';
        }
        
        // Update join date
        const joinDateEl = document.getElementById('userJoinDate');
        if (joinDateEl && user.createdAt) {
            try {
                const joinDate = new Date(user.createdAt);
                const now = new Date();
                const diffTime = Math.abs(now - joinDate);
                const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
                
                if (diffDays < 30) {
                    joinDateEl.textContent = diffDays === 1 ? 'yesterday' : `${diffDays} days ago`;
                } else if (diffDays < 365) {
                    const months = Math.floor(diffDays / 30);
                    joinDateEl.textContent = months === 1 ? '1 month ago' : `${months} months ago`;
                } else {
                    const years = Math.floor(diffDays / 365);
                    joinDateEl.textContent = years === 1 ? '1 year ago' : `${years} years ago`;
                }
            } catch (e) {
                joinDateEl.textContent = 'Recently';
            }
        }
        
        // Update artist statement (for artists)
        const artistStatement = document.getElementById('artistStatement');
        if (user.role === 'ARTIST' && user.artistStatement) {
            artistStatement.textContent = user.artistStatement;
            artistStatement.parentElement.style.display = 'block';
        } else {
            artistStatement.parentElement.style.display = 'none';
        }
        
        // Update social media links
        if (user.socialMediaLinks) {
            try {
                const socialLinks = JSON.parse(user.socialMediaLinks);
                this.renderSocialLinks(socialLinks);
            } catch (e) {
                console.warn('Invalid social media links format');
            }
        }
        
        // Store profile state
        this.isOwnProfile = isOwnProfile;
        this.userRole = user.role;
        
        // Update action buttons
        this.updateActionButtons(isOwnProfile, isFollowing);
        
        // For buyers: Hide stats and artworks sections entirely
        // For artists: Ensure stats and artworks sections are visible
        if (this.userRole === 'BUYER') {
            this.hideBuyerSections();
        } else if (this.userRole === 'ARTIST' || this.userRole === 'ADMIN') {
            // Ensure stats section is visible for artists
            const statsContainer = document.getElementById('statsContainer');
            if (statsContainer) {
                statsContainer.style.display = 'block';
            }
            // Ensure artworks section is visible for artists
            const artworksSection = document.getElementById('artworksSection');
            if (artworksSection) {
                artworksSection.style.display = 'block';
            }
        }
        
        // Load sections based on user role (this will load artworks)
        this.loadUserSections();
        
        // Note: Stats are loaded separately after profile header is rendered (only for non-buyers)
    }
    
    loadUserSections() {
        // Show/hide sections based on role and ownership
        const artworksSection = document.getElementById('artworksSection');
        const purchasedSection = document.getElementById('purchasedArtworksSection');
        
        console.log('Loading user sections, isOwnProfile:', this.isOwnProfile, 'userRole:', this.userRole);
        
        // Determine what to show based on user role
        const isArtist = this.userRole === 'ARTIST' || this.userRole === 'ADMIN';
        const isBuyer = this.userRole === 'BUYER';
        
        // For BUYERS: Show ONLY purchased artworks section (hide uploaded/sold artworks)
        if (isBuyer) {
            // Hide sold & uploaded artworks section for buyers
            if (artworksSection) {
                artworksSection.style.display = 'none';
                console.log('Artworks section hidden for buyer - buyers do not upload artworks');
            }
            
            // Show purchased artworks section ONLY for profile owner
            if (this.isOwnProfile) {
                if (purchasedSection) {
                    purchasedSection.style.display = 'block';
                    console.log('Purchased section displayed for buyer (own profile)');
                    this.loadPurchasedArtworks();
                }
            } else {
                // Hide purchased artworks for public viewers (always private)
                if (purchasedSection) {
                    purchasedSection.style.display = 'none';
                    console.log('Purchased section hidden (private - only visible to owner)');
                }
            }
        } 
        // For ARTISTS/SELLERS: Show sold & uploaded artworks section (public view)
        else if (isArtist) {
            console.log('Processing artist profile - showing artworks section');
            
            // Show stats section for artists
            const statsContainer = document.getElementById('statsContainer');
            if (statsContainer) {
                statsContainer.style.display = 'block';
                console.log('Stats section displayed for artist');
            } else {
                console.warn('Stats container not found');
            }
            
            // Show artworks section for artists - FORCE display with !important
            if (artworksSection) {
                artworksSection.style.display = 'block';
                artworksSection.style.visibility = 'visible';
                artworksSection.removeAttribute('hidden');
                artworksSection.setAttribute('style', 'display: block !important; visibility: visible !important;');
                console.log('Artworks section displayed for artist/seller - FORCED with !important');
                
                // Update section title to "Uploaded Artworks" for artists
                const sectionTitle = artworksSection.querySelector('.section-title');
                if (sectionTitle) {
                    sectionTitle.textContent = 'Uploaded Artworks';
                    console.log('Section title updated to "Uploaded Artworks"');
                }
                
                // Load and display artworks
                console.log('Calling loadUserArtworks() for artist');
                this.loadUserArtworks();
                
                // Fallback: Force section visible again after a short delay (in case something hides it)
                setTimeout(() => {
                    const section = document.getElementById('artworksSection');
                    if (section && (this.userRole === 'ARTIST' || this.userRole === 'ADMIN')) {
                        section.style.display = 'block';
                        section.style.visibility = 'visible';
                        section.setAttribute('style', 'display: block !important; visibility: visible !important;');
                        console.log('Fallback: Artworks section forced visible after 500ms delay');
                    }
                }, 500);
            } else {
                console.error('Artworks section element not found! Cannot display artworks.');
            }
            
            // If artist is viewing own profile, also show purchased artworks (if they have any)
            if (this.isOwnProfile) {
                if (purchasedSection) {
                    purchasedSection.style.display = 'block';
                    console.log('Purchased section also displayed for artist (own profile, may have purchases)');
                    this.loadPurchasedArtworks();
                }
            } else {
                // Hide purchased artworks for public viewers
                if (purchasedSection) {
                    purchasedSection.style.display = 'none';
                }
            }
        }
        // For users with no specific role or mixed roles
        else {
            // Default behavior: hide uploaded artworks, show purchased if own profile
            if (artworksSection) {
                artworksSection.style.display = 'none';
            }
            
            if (this.isOwnProfile && purchasedSection) {
                purchasedSection.style.display = 'block';
                this.loadPurchasedArtworks();
            } else if (purchasedSection) {
                purchasedSection.style.display = 'none';
            }
        }
    }
    
    async loadUserStats() {
        // Skip loading stats for buyers - they don't need stats
        if (this.userRole === 'BUYER') {
            console.log('Skipping stats load for buyer');
            return;
        }
        
        try {
            const response = await fetch(`/api/users/${this.currentUserId}/stats`);
            const result = await response.json();
            
            if (result.success) {
                this.updateStatsDisplay(result.data);
            }
        } catch (error) {
            console.error('Error loading user stats:', error);
        }
    }
    
    updateStatsDisplay(stats) {
        const artworkCountEl = document.getElementById('artworkCount');
        const likesCountEl = document.getElementById('likesCount');
        const salesCountEl = document.getElementById('salesCount');
        const followerCountEl = document.getElementById('followerCount');
        
        // For BUYERS: Hide artist-specific stats (Sales, Sold count)
        // Show only relevant stats: Purchased artworks count, Likes, Followers
        const isBuyer = this.userRole === 'BUYER';
        
        if (isBuyer) {
            // For buyers: Show purchased count instead of uploaded artworks count
            if (artworkCountEl) {
                artworkCountEl.textContent = stats.purchasedCount || 0;
                // Update label if needed
                const labelEl = artworkCountEl.nextElementSibling;
                if (labelEl && labelEl.textContent.includes('Artworks')) {
                    labelEl.textContent = 'Purchased';
                }
            }
            
            // Hide Sales stat for buyers
            if (salesCountEl) {
                const salesCard = salesCountEl.closest('.stats-card').parentElement;
                if (salesCard && salesCard.parentElement && salesCard.parentElement.id === 'statsContainer') {
                    salesCard.style.display = 'none';
                }
            }
        } else {
            // For artists: Show all stats
            if (artworkCountEl) artworkCountEl.textContent = stats.artworkCount || 0;
            if (salesCountEl) {
                const salesCard = salesCountEl.closest('.stats-card').parentElement;
                if (salesCard && salesCard.parentElement && salesCard.parentElement.id === 'statsContainer') {
                    salesCard.style.display = 'block';
                }
                salesCountEl.textContent = stats.salesCount || 0;
            }
        }
        
        // Common stats for both buyers and artists
        if (likesCountEl) likesCountEl.textContent = stats.likesCount || 0;
        if (followerCountEl) followerCountEl.textContent = stats.followerCount || 0;
    }
    
    updateActionButtons(isOwnProfile, isFollowing) {
        const followBtn = document.getElementById('followBtn');
        const messageBtn = document.getElementById('messageBtn');
        const editBtn = document.getElementById('editBtn');
        
        if (isOwnProfile) {
            // Show edit button, hide follow/message buttons
            if (editBtn) editBtn.style.display = 'inline-block';
            if (followBtn) followBtn.style.display = 'none';
            if (messageBtn) messageBtn.style.display = 'none';
        } else {
            // Show follow/message buttons, hide edit button
            if (editBtn) editBtn.style.display = 'none';
            if (followBtn) {
                followBtn.style.display = 'inline-block';
                this.updateFollowButton(isFollowing);
            }
            if (messageBtn) messageBtn.style.display = 'inline-block';
        }
    }
    
    updateFollowButton(isFollowing) {
        const followBtn = document.getElementById('followBtn');
        if (!followBtn) return;
        
        if (isFollowing) {
            followBtn.innerHTML = '<i class=\"fas fa-user-minus\"></i> Unfollow';
            followBtn.className = 'btn btn-outline-primary';
        } else {
            followBtn.innerHTML = '<i class=\"fas fa-user-plus\"></i> Follow';
            followBtn.className = 'btn btn-primary';
        }
    }
    
    async toggleFollow() {
        try {
            const followBtn = document.getElementById('followBtn');
            followBtn.disabled = true;
            
            const response = await fetch(`/api/users/${this.currentUserId}/follow`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                }
            });
            
            const result = await response.json();
            
            if (result.success) {
                this.updateFollowButton(result.data.isFollowing);
                
                // Update follower count
                document.getElementById('followerCount').textContent = result.data.followerCount;
                
                // Show success message
                this.showMessage(
                    result.data.action === 'followed' ? 'User followed successfully!' : 'User unfollowed successfully!',
                    'success'
                );
            } else {
                this.showMessage(result.error || 'Failed to update follow status', 'error');
            }
        } catch (error) {
            console.error('Error toggling follow:', error);
            this.showMessage('Failed to update follow status', 'error');
        } finally {
            const followBtn = document.getElementById('followBtn');
            followBtn.disabled = false;
        }
    }
    
    async loadUserArtworks() {
        try {
            console.log('Loading artworks for user:', this.currentUserId);
            this.isLoading = true;
            const loadingEl = document.getElementById('artworksLoading');
            const emptyEl = document.getElementById('artworksEmpty');
            const gridEl = document.getElementById('artworkGrid');
            const sectionEl = document.getElementById('artworksSection');
            
            // Ensure section is visible (especially important for artists) - use !important
            if (sectionEl) {
                sectionEl.style.display = 'block';
                sectionEl.style.visibility = 'visible';
                sectionEl.removeAttribute('hidden');
                sectionEl.setAttribute('style', 'display: block !important; visibility: visible !important;');
                console.log('Artworks section forced to visible in loadUserArtworks() with !important');
            } else {
                console.error('Artworks section element not found in loadUserArtworks()');
            }
            
            if (loadingEl) loadingEl.style.display = 'block';
            if (emptyEl) emptyEl.style.display = 'none';
            if (gridEl) gridEl.innerHTML = '';
            
            const url = `/api/users/${this.currentUserId}/artworks?page=${this.currentPage}&category=${this.currentCategory}&limit=12`;
            console.log('Fetching artworks from:', url);
            
            const response = await fetch(url, {
                credentials: 'include',
                headers: {
                    'Accept': 'application/json'
                }
            });
            
            console.log('Artworks response status:', response.status);
            
            if (!response.ok) {
                const errorText = await response.text();
                console.error('Artworks API error:', response.status, errorText);
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            
            const result = await response.json();
            console.log('Artworks response:', result);
            
            // Force section to be visible after API response - use !important
            if (sectionEl) {
                sectionEl.style.display = 'block';
                sectionEl.style.visibility = 'visible';
                sectionEl.removeAttribute('hidden');
                sectionEl.setAttribute('style', 'display: block !important; visibility: visible !important;');
                console.log('Artworks section forced visible after API response with !important');
            }
            
            if (result.success) {
                const artworks = result.data.artworks || [];
                console.log('Loaded artworks count:', artworks.length);
                
                if (artworks.length === 0 && this.currentPage === 1) {
                    console.log('No artworks found, showing empty state');
                    // Still show the section even if empty
                    if (sectionEl) {
                        sectionEl.style.display = 'block';
                        sectionEl.style.visibility = 'visible';
                    }
                    if (emptyEl) emptyEl.style.display = 'block';
                    if (gridEl) gridEl.innerHTML = '';
                } else {
                    console.log('Rendering', artworks.length, 'artworks');
                    this.renderArtworks(artworks, this.currentPage === 1);
                }
                
                this.hasMore = result.data.hasMore || false;
                this.updateLoadMoreButton();
            } else {
                console.error('Artworks API returned error:', result.error);
                // Still show section even on error
                if (sectionEl) {
                    sectionEl.style.display = 'block';
                    sectionEl.style.visibility = 'visible';
                }
                this.showError(result.error || 'Failed to load artworks');
                if (emptyEl) emptyEl.style.display = 'block';
            }
        } catch (error) {
            console.error('Error loading artworks:', error);
            this.showError('Failed to load artworks: ' + error.message);
            const emptyEl = document.getElementById('artworksEmpty');
            if (emptyEl) emptyEl.style.display = 'block';
        } finally {
            this.isLoading = false;
            const loadingEl = document.getElementById('artworksLoading');
            if (loadingEl) loadingEl.style.display = 'none';
        }
    }
    
    async loadMoreArtworks() {
        if (this.isLoading || !this.hasMore) return;
        
        this.currentPage++;
        await this.loadUserArtworks();
    }
    
    renderArtworks(artworks, clearGrid = false) {
        const artworkGrid = document.getElementById('artworkGrid');
        const emptyEl = document.getElementById('artworksEmpty');
        const loadingEl = document.getElementById('artworksLoading');
        const sectionEl = document.getElementById('artworksSection');
        
        // FORCE section to be visible when rendering artworks - multiple methods
        if (sectionEl) {
            sectionEl.style.display = 'block';
            sectionEl.style.visibility = 'visible';
            sectionEl.removeAttribute('hidden');
            sectionEl.classList.remove('d-none');
            // Use inline style with !important to override any CSS
            sectionEl.setAttribute('style', 'display: block !important; visibility: visible !important;');
            console.log('Artworks section FORCED to visible in renderArtworks() - all methods applied');
        } else {
            console.error('Artworks section element not found in renderArtworks()!');
        }
        
        if (!artworkGrid) {
            console.error('Artwork grid element not found!');
            return;
        }
        
        if (clearGrid) {
            artworkGrid.innerHTML = '';
            if (emptyEl) emptyEl.style.display = 'none';
        }
        
        if (artworks.length === 0 && clearGrid) {
            // Still show section even if empty
            if (sectionEl) {
                sectionEl.style.display = 'block';
                sectionEl.style.visibility = 'visible';
                sectionEl.setAttribute('style', 'display: block !important; visibility: visible !important;');
            }
            if (emptyEl) {
                emptyEl.style.display = 'block';
            } else {
                artworkGrid.innerHTML = `
                    <div class="col-12 text-center py-5">
                        <i class="fas fa-palette fa-3x text-muted mb-3"></i>
                        <h5 class="text-muted">No artworks found</h5>
                        <p class="text-muted">This user hasn't uploaded any artworks yet.</p>
                    </div>
                `;
            }
            return;
        }
        
        // Final check - ensure section is visible when we have artworks
        if (sectionEl) {
            sectionEl.style.display = 'block';
            sectionEl.style.visibility = 'visible';
            sectionEl.setAttribute('style', 'display: block !important; visibility: visible !important;');
            console.log('Final check: Artworks section confirmed visible with', artworks.length, 'artworks');
        }
        
        artworks.forEach(artwork => {
            const artworkCard = this.createArtworkCard(artwork);
            artworkGrid.appendChild(artworkCard);
        });
    }
    
    createArtworkCard(artwork, isPurchased = false) {
        // Match Dashboard artwork card structure exactly
        const col = document.createElement('div');
        col.className = 'col-md-4 mb-4';
        col.setAttribute('data-artwork-id', artwork.artworkId || artwork.id || '');
        
        // Check if artwork is sold (match Dashboard logic)
        const isSold = artwork.status === 'SOLD' || artwork.status === 'sold';
        
        // Get image URL (match Dashboard logic)
        // Use fallback only when image path is missing
        let imageUrl = artwork.primaryImageUrl || 
                      artwork.imageUrl || 
                      (artwork.imageUrls && Array.isArray(artwork.imageUrls) && artwork.imageUrls.length > 0 ? artwork.imageUrls[0] : null);
        
        // Only use placeholder if no valid image URL exists
        if (!imageUrl || imageUrl.trim() === '' || imageUrl === 'null' || imageUrl === 'undefined') {
            imageUrl = '/assets/images/placeholder-artwork.jpg';
        }
        
        const title = artwork.title || 'Untitled';
        const description = artwork.description || 'No description available';
        const descriptionText = description.length > 100 ? description.substring(0, 100) + '...' : description;
        const artworkId = artwork.artworkId || artwork.id || '';
        
        // Validate artworkId exists
        if (!artworkId) {
            console.warn('Artwork card missing artworkId:', artwork);
        }
        
        // Determine price to display (match Dashboard logic)
        let displayPrice = artwork.price || 0;
        if (isSold && artwork.saleType === 'AUCTION' && artwork.winningBidAmount) {
            displayPrice = artwork.winningBidAmount;
        } else if (!isSold && artwork.saleType === 'AUCTION' && artwork.currentBid) {
            displayPrice = artwork.currentBid;
        }
        
        // Sold badge (match Dashboard style)
        const soldBadge = isSold ? 
            '<div class="sold-badge"><i class="fas fa-check-circle me-1"></i>SOLD</div>' : '';
        
        // Card class with sold overlay (match Dashboard)
        const cardClass = isSold ? 'card sold-overlay' : 'card';
        
        // Status badge (match Dashboard)
        const saleType = artwork.saleType || artwork.listingType || '';
        const statusBadge = isSold ? 'SOLD' : (saleType || 'FIXED_PRICE');
        const badgeClass = isSold ? 'danger' : (saleType === 'AUCTION' ? 'warning' : 'success');
        
        // Auction ended indicator
        const auctionEndedText = (isSold && saleType === 'AUCTION' && artwork.winnerName) ? 
            '<div class="mt-1"><small class="text-muted"><i class="fas fa-trophy me-1"></i>Won by ' + this.escapeHtml(artwork.winnerName) + '</small></div>' : '';
        
        // Get artist info for profile link
        const artistId = artwork.artistId || artwork.createdBy || '';
        const artistName = artwork.artistName || 'Unknown Artist';
        const artistProfileLink = artistId ? 
            '<a href="/profile.jsp?userId=' + artistId + '" class="text-decoration-none text-muted" onclick="event.stopPropagation();" title="View artist profile">' +
            '<i class="fas fa-user me-1"></i>' + this.escapeHtml(artistName) +
            '</a>' : 
            '<span class="text-muted"><i class="fas fa-user me-1"></i>' + this.escapeHtml(artistName) + '</span>';
        
        // Build HTML (match Dashboard structure exactly)
        col.innerHTML = 
            '<div class="' + cardClass + '">' +
            '<div class="position-relative">' +
            '<img src="' + imageUrl + '" ' +
            'class="card-img-top" alt="' + this.escapeHtml(title) + '" ' +
            'style="height: 200px; object-fit: cover;" ' +
            'onerror="this.onerror=null; this.src=\'/assets/images/placeholder-artwork.jpg\'">' +
            soldBadge +
            '</div>' +
            '<div class="card-body">' +
            '<h5 class="card-title">' + this.escapeHtml(title) + '</h5>' +
            '<p class="card-text text-muted small mb-2">by ' + artistProfileLink + '</p>' +
            '<p class="card-text">' + this.escapeHtml(descriptionText) + '</p>' +
            '<div class="d-flex justify-content-between align-items-center">' +
            '<span class="' + (isSold ? 'text-danger' : 'text-primary') + ' fw-bold">' +
            (isSold ? 'Sold: ' : '') + 'RM ' + parseFloat(displayPrice).toFixed(2) +
            '</span>' +
            '<span class="badge bg-' + badgeClass + '">' + statusBadge + '</span>' +
            '</div>' +
            auctionEndedText +
            '<div class="mt-2">' +
            '<small class="text-muted">' +
            '<i class="fas fa-heart text-danger me-1"></i>' + (artwork.likes || 0) + ' likes' +
            '<i class="fas fa-eye text-info ms-2 me-1"></i>' + (artwork.views || 0) + ' views' +
            '</small>' +
            '</div>' +
            '<div class="mt-2">' +
            '<a href="/artwork/' + artworkId + '" class="btn btn-sm btn-outline-primary w-100">' +
            '<i class="fas fa-eye me-1"></i>View Details' +
            '</a>' +
            '</div>' +
            '</div>' +
            '</div>';
        
        return col;
    }
    
    escapeHtml(text) {
        if (!text) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
    
    async loadPurchasedArtworks() {
        if (!this.isOwnProfile) {
            // Only show purchased artworks to profile owner
            return;
        }
        
        try {
            this.isLoading = true;
            const loadingEl = document.getElementById('purchasedArtworksLoading');
            const emptyEl = document.getElementById('purchasedArtworksEmpty');
            const gridEl = document.getElementById('purchasedArtworkGrid');
            
            if (loadingEl) loadingEl.style.display = 'block';
            if (emptyEl) emptyEl.style.display = 'none';
            
            const response = await fetch(
                `/api/users/${this.currentUserId}/purchases?page=${this.purchasedPage}&limit=12`,
                {
                    credentials: 'include',
                    headers: {
                        'Accept': 'application/json'
                    }
                }
            );
            
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            
            const result = await response.json();
            
            if (result.success) {
                const purchases = result.data.purchases || [];
                
                if (purchases.length === 0 && this.purchasedPage === 1) {
                    if (emptyEl) emptyEl.style.display = 'block';
                    if (gridEl) gridEl.innerHTML = '';
                } else {
                    this.renderPurchasedArtworks(purchases, this.purchasedPage === 1);
                }
                
                this.hasMorePurchased = result.data.hasMore || false;
                this.updateLoadMorePurchasedButton();
            } else {
                console.error('Failed to load purchased artworks:', result.error);
                if (emptyEl) emptyEl.style.display = 'block';
            }
        } catch (error) {
            console.error('Error loading purchased artworks:', error);
            const emptyEl = document.getElementById('purchasedArtworksEmpty');
            if (emptyEl) emptyEl.style.display = 'block';
        } finally {
            this.isLoading = false;
            const loadingEl = document.getElementById('purchasedArtworksLoading');
            if (loadingEl) loadingEl.style.display = 'none';
        }
    }
    
    renderPurchasedArtworks(purchases, clearGrid = false) {
        const gridEl = document.getElementById('purchasedArtworkGrid');
        if (!gridEl) return;
        
        if (clearGrid) {
            gridEl.innerHTML = '';
        }
        
        // Match Dashboard purchase card format exactly
        purchases.forEach(purchaseData => {
            const purchase = purchaseData;
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
            
            const totalPrice = (parseFloat(purchase.purchasePrice) || 0) + (parseFloat(purchase.shippingCost) || 0);
            const imageUrl = artwork.primaryImageUrl || '/assets/images/placeholder-artwork.jpg';
            const artworkTitle = artwork.title || 'Untitled Artwork';
            const artistName = seller.displayName || artwork.artistName || 'Unknown Artist';
            const refundedClass = purchase.status === 'REFUNDED' ? 'opacity-75' : '';
            const refundedText = purchase.status === 'REFUNDED' ? '<span class="text-decoration-line-through text-muted">(Refunded)</span>' : '';
            const categoryBadge = artwork.category ? '<span class="badge bg-secondary me-1">' + this.escapeHtml(artwork.category) + '</span>' : '';
            const shippingText = parseFloat(purchase.shippingCost) > 0 ? 
                '<small class="text-muted d-block">Shipping: RM ' + parseFloat(purchase.shippingCost).toFixed(2) + '</small>' : '';
            const transactionText = purchase.transactionId ? 
                '<p class="mb-1 small text-muted"><i class="fas fa-receipt me-1"></i>Transaction ID: ' + this.escapeHtml(purchase.transactionId) + '</p>' : '';
            const artworkLink = artwork.artworkId ? 
                '<a href="/artwork/' + artwork.artworkId + '" class="btn btn-outline-secondary btn-sm"><i class="fas fa-eye me-1"></i>View Artwork</a>' : '';
            const paymentMethod = purchase.paymentMethod || 'N/A';
            const purchaseStatus = purchase.status || 'PENDING';
            
            // Create purchase card (match Dashboard format)
            const purchaseCard = document.createElement('div');
            purchaseCard.className = 'card mb-3 purchase-card ' + refundedClass;
            purchaseCard.innerHTML = 
                '<div class="row g-0">' +
                '<div class="col-md-3">' +
                '<img src="' + imageUrl + '" ' +
                'class="img-fluid rounded-start" ' +
                'alt="' + this.escapeHtml(artworkTitle) + '" ' +
                'style="height: 200px; object-fit: cover; width: 100%;" ' +
                'onerror="this.src=\'/assets/images/placeholder-artwork.jpg\'">' +
                '</div>' +
                '<div class="col-md-9">' +
                '<div class="card-body">' +
                '<div class="d-flex justify-content-between align-items-start mb-2">' +
                '<div>' +
                '<h5 class="card-title mb-1">' + this.escapeHtml(artworkTitle) + ' ' + refundedText + '</h5>' +
                '<p class="text-muted mb-1 small">' +
                '<i class="fas fa-user me-1"></i>Artist: ' + this.escapeHtml(artistName) +
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
                '<i class="fas fa-calendar me-1"></i>Purchased: ' + formattedDate +
                '</p>' +
                '<p class="mb-1 small text-muted">' +
                '<i class="fas fa-credit-card me-1"></i>Payment: ' + this.escapeHtml(paymentMethod) +
                '</p>' +
                transactionText +
                '</div>' +
                '<div class="col-md-6 text-end">' +
                artworkLink +
                '</div>' +
                '</div>' +
                '</div>' +
                '</div>' +
                '</div>';
            
            gridEl.appendChild(purchaseCard);
        });
    }
    
    async loadMorePurchasedArtworks() {
        if (this.isLoading || !this.hasMorePurchased) return;
        
        this.purchasedPage++;
        await this.loadPurchasedArtworks();
    }
    
    updateLoadMorePurchasedButton() {
        const loadMoreBtn = document.getElementById('loadMorePurchasedBtn');
        if (!loadMoreBtn) return;
        
        if (this.hasMorePurchased) {
            loadMoreBtn.style.display = 'block';
            loadMoreBtn.disabled = this.isLoading;
            loadMoreBtn.innerHTML = this.isLoading ? 
                '<i class="fas fa-spinner fa-spin"></i> Loading...' : 
                'Load More';
        } else {
            loadMoreBtn.style.display = 'none';
        }
    }
    
    handleCategoryFilter(category) {
        // Update active filter button
        document.querySelectorAll('.category-filter').forEach(btn => {
            btn.classList.remove('active');
        });
        document.querySelector(`[data-category=\"${category}\"]`).classList.add('active');
        
        // Reset pagination and load artworks
        this.currentCategory = category;
        this.currentPage = 1;
        this.hasMore = true;
        this.loadUserArtworks();
    }
    
    updateLoadMoreButton() {
        const loadMoreBtn = document.getElementById('loadMoreBtn');
        if (!loadMoreBtn) return;
        
        if (this.hasMore) {
            loadMoreBtn.style.display = 'block';
            loadMoreBtn.disabled = this.isLoading;
            loadMoreBtn.innerHTML = this.isLoading ? 
                '<i class=\"fas fa-spinner fa-spin\"></i> Loading...' : 
                'Load More';
        } else {
            loadMoreBtn.style.display = 'none';
        }
    }
    
    renderSocialLinks(socialLinks) {
        const socialContainer = document.getElementById('socialLinks');
        if (!socialContainer) return;
        
        socialContainer.innerHTML = '';
        
        Object.entries(socialLinks).forEach(([platform, url]) => {
            if (url) {
                const link = document.createElement('a');
                link.href = url;
                link.target = '_blank';
                link.className = 'text-muted me-3';
                link.innerHTML = `<i class=\"fab fa-${platform}\"></i>`;
                socialContainer.appendChild(link);
            }
        });
    }
    
    startConversation() {
        // Redirect to messaging interface
        window.location.href = `/messages.jsp?userId=${this.currentUserId}`;
    }
    
    isNearBottom() {
        return window.innerHeight + window.scrollY >= document.body.offsetHeight - 1000;
    }
    
    showLoading(containerId) {
        const container = document.getElementById(containerId);
        if (container) {
            container.classList.add('loading');
        }
    }
    
    hideLoading(containerId) {
        const container = document.getElementById(containerId);
        if (container) {
            container.classList.remove('loading');
        }
    }
    
    showMessage(message, type = 'info') {
        // Create and show toast notification
        const toast = document.createElement('div');
        toast.className = `alert alert-${type === 'error' ? 'danger' : 'success'} alert-dismissible fade show position-fixed`;
        toast.style.cssText = 'top: 20px; right: 20px; z-index: 9999; min-width: 300px;';
        toast.innerHTML = `
            ${message}
            <button type=\"button\" class=\"btn-close\" data-bs-dismiss=\"alert\"></button>
        `;
        
        document.body.appendChild(toast);
        
        // Auto remove after 5 seconds
        setTimeout(() => {
            if (toast.parentNode) {
                toast.parentNode.removeChild(toast);
            }
        }, 5000);
    }
    
    showError(message) {
        this.showMessage(message, 'error');
    }
    
    async showEditProfileModal() {
        try {
            // Fetch current profile
            const response = await fetch('/api/me/profile', {
                credentials: 'include',
                headers: {
                    'Accept': 'application/json'
                }
            });
            
            if (!response.ok) {
                throw new Error('Failed to load profile');
            }
            
            const data = await response.json();
            
            if (data.success || data.id) {
                // Populate form
                document.getElementById('editDisplayName').value = data.display_name || '';
                document.getElementById('editBio').value = data.bio || '';
                this.updateBioCharCount();
                
                // Show current avatar preview
                const previewImg = document.getElementById('profilePicturePreviewImg');
                const previewDiv = document.getElementById('profilePicturePreview');
                if (data.avatar_url) {
                    previewImg.src = data.avatar_url;
                    previewDiv.style.display = 'block';
                } else {
                    previewDiv.style.display = 'none';
                }
                
                // Show modal
                const modal = new bootstrap.Modal(document.getElementById('editProfileModal'));
                modal.show();
            } else {
                this.showMessage('Failed to load profile data', 'error');
            }
        } catch (error) {
            console.error('Error loading profile:', error);
            this.showMessage('Error loading profile data', 'error');
        }
    }
    
    handleProfilePicturePreview(event) {
        const file = event.target.files[0];
        if (file) {
            // Validate file size (5MB)
            if (file.size > 5 * 1024 * 1024) {
                this.showMessage('File size exceeds 5MB limit', 'error');
                event.target.value = '';
                return;
            }
            
            // Validate file type
            const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
            if (!allowedTypes.includes(file.type)) {
                this.showMessage('Invalid file type. Please use JPG, PNG, or WebP', 'error');
                event.target.value = '';
                return;
            }
            
            // Show preview
            const reader = new FileReader();
            reader.onload = (e) => {
                const previewImg = document.getElementById('profilePicturePreviewImg');
                const previewDiv = document.getElementById('profilePicturePreview');
                previewImg.src = e.target.result;
                previewDiv.style.display = 'block';
            };
            reader.readAsDataURL(file);
        }
    }
    
    updateBioCharCount() {
        const bioTextarea = document.getElementById('editBio');
        const charCount = document.getElementById('bioCharCount');
        if (bioTextarea && charCount) {
            const count = bioTextarea.value.length;
            charCount.textContent = count;
            if (count > 1000) {
                charCount.style.color = '#e17055';
            } else {
                charCount.style.color = '#666';
            }
        }
    }
}

// Global function for saving profile changes (called from onclick)
async function saveProfileChanges() {
    const profileManager = window.userProfileManager;
    if (!profileManager) {
        console.error('Profile manager not initialized');
        return;
    }
    
    const displayName = document.getElementById('editDisplayName').value.trim();
    const bio = document.getElementById('editBio').value.trim();
    const profilePictureFile = document.getElementById('editProfilePicture').files[0];
    
    // Validate display name
    if (!displayName || displayName.length < 2 || displayName.length > 100) {
        profileManager.showMessage('Display name must be between 2 and 100 characters', 'error');
        return;
    }
    
    // Validate bio length
    if (bio.length > 1000) {
        profileManager.showMessage('Bio must not exceed 1000 characters', 'error');
        return;
    }
    
    try {
        let avatarUrl = null;
        
        // Upload profile picture if provided
        if (profilePictureFile) {
            const formData = new FormData();
            formData.append('profile_picture', profilePictureFile);
            
            const uploadResponse = await fetch('/api/me/profile', {
                method: 'POST',
                body: formData,
                credentials: 'include'
            });
            
            if (!uploadResponse.ok) {
                const errorData = await uploadResponse.json();
                throw new Error(errorData.message || 'Failed to upload profile picture');
            }
            
            const uploadData = await uploadResponse.json();
            if (uploadData.success) {
                avatarUrl = uploadData.avatar_url;
            }
        }
        
        // Update profile data
        const updateData = {
            display_name: displayName,
            bio: bio || null
        };
        
        if (avatarUrl) {
            updateData.profile_picture = avatarUrl;
        }
        
        const updateResponse = await fetch('/api/me/profile', {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json'
            },
            credentials: 'include',
            body: JSON.stringify(updateData)
        });
        
        if (!updateResponse.ok) {
            const errorData = await updateResponse.json();
            throw new Error(errorData.message || 'Failed to update profile');
        }
        
        const updateResult = await updateResponse.json();
        
        if (updateResult.success || updateResult.id) {
            // Close modal
            const modal = bootstrap.Modal.getInstance(document.getElementById('editProfileModal'));
            if (modal) modal.hide();
            
            // Show success message
            profileManager.showMessage('Profile updated successfully', 'success');
            
            // Update profile picture immediately if changed
            const newAvatarUrl = updateResult.avatar_url || avatarUrl;
            if (newAvatarUrl) {
                const avatarEl = document.getElementById('userAvatar');
                if (avatarEl) {
                    // Ensure absolute path
                    let finalUrl = newAvatarUrl;
                    if (!finalUrl.startsWith('http') && !finalUrl.startsWith('/')) {
                        finalUrl = '/' + finalUrl;
                    }
                    // Force reload by adding timestamp
                    avatarEl.src = finalUrl + (finalUrl.includes('?') ? '&' : '?') + 't=' + Date.now();
                    console.log('Updated profile picture to:', finalUrl);
                }
            }
            
            // Reload profile data to get fresh user info
            if (profileManager.currentUserId) {
                // Reload profile without full page reload
                profileManager.loadUserProfile();
            } else {
                profileManager.loadCurrentUserProfile();
            }
        } else {
            throw new Error(updateResult.message || 'Failed to update profile');
        }
        
    } catch (error) {
        console.error('Error saving profile:', error);
        profileManager.showMessage(error.message || 'Failed to update profile', 'error');
    }
}

// Initialize when page loads
document.addEventListener('DOMContentLoaded', () => {
    window.userProfileManager = new UserProfileManager();
    
    // Setup edit button listener
    const editBtn = document.getElementById('editBtn');
    if (editBtn) {
        editBtn.addEventListener('click', () => {
            window.userProfileManager.showEditProfileModal();
        });
    }
    
    // Setup profile picture preview
    const profilePictureInput = document.getElementById('editProfilePicture');
    if (profilePictureInput) {
        profilePictureInput.addEventListener('change', (e) => {
            window.userProfileManager.handleProfilePicturePreview(e);
        });
    }
    
    // Setup bio character counter
    const bioTextarea = document.getElementById('editBio');
    if (bioTextarea) {
        bioTextarea.addEventListener('input', () => {
            window.userProfileManager.updateBioCharCount();
        });
    }
});
