/**
 * Messages Page JavaScript
 * Handles conversation list, chat window, and WebSocket communication
 * Works with component-based UI structure
 */

let currentConversation = null;
let chatWebSocket = null;
let conversations = [];
let typingTimeout = null;

// Messages menu functionality - declare variables first
let messagesMenuInitialized = false;
const initializedMenus = new Set();

// Watch for menu elements to be added to DOM
function watchForMenuElements() {
  const observer = new MutationObserver(function(mutations) {
    const trigger1 = document.getElementById("messagesMenuTrigger");
    const trigger2 = document.getElementById("messagesMenuTriggerPlaceholder");
    
    if ((trigger1 || trigger2) && !messagesMenuInitialized) {
      console.log("Menu elements detected in DOM, initializing...");
      initializeMessagesMenu();
    }
  });
  
  observer.observe(document.body, {
    childList: true,
    subtree: true
  });
  
  // Also try immediate initialization
  setTimeout(initializeMessagesMenu, 100);
  setTimeout(initializeMessagesMenu, 500);
  setTimeout(initializeMessagesMenu, 1000);
  setTimeout(initializeMessagesMenu, 2000);
}

// Initialize page
document.addEventListener("DOMContentLoaded", function () {
  // Start watching for menu elements
  watchForMenuElements();
  
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
          body: JSON.stringify({ idToken: idToken }),
        });

        if (response.ok) {
          const data = await response.json();
          if (data.success && data.user) {
            currentUser = data.user;
            loadUserProfile();
            loadConversations().then(() => {
              // Handle URL parameters for direct artist contact after conversations are loaded
              checkForDirectContact();
            });
            initializeWebSocket();
            // Re-initialize menu after everything is loaded
            setTimeout(() => {
              console.log("User authenticated, re-initializing menu...");
              messagesMenuInitialized = false;
              initializedMenus.clear();
              initializeMessagesMenu();
            }, 1000);
            setTimeout(() => {
              messagesMenuInitialized = false;
              initializedMenus.clear();
              initializeMessagesMenu();
            }, 2000);
          } else {
            console.warn(
              "User verification failed on messages:",
              data.message
            );
            window.location.href = "/";
          }
        } else if (response.status === 404) {
          console.warn("User not found in database on messages");
          window.location.href = "/";
        } else {
          console.error(
            "Authentication verification failed on messages with status:",
            response.status
          );
          window.location.href = "/";
        }
      } catch (error) {
        console.error("Auth verification error on messages:", error);
        window.location.href = "/";
      }
    } else {
      window.location.href = "/";
    }
  });
});

// Load user profile
function loadUserProfile() {
  const userAvatar = document.getElementById("userAvatar");
  const userName = document.getElementById("userName");
  const onlineIndicator = document.getElementById("userOnlineIndicator");

  if (userAvatar) {
    userAvatar.src =
      currentUser.profileImageUrl ||
      "/assets/images/default-avatar.svg";
    userAvatar.onerror = function() {
      this.src = "/assets/images/default-avatar.svg";
    };
  }
  
  if (userName) {
    userName.textContent =
      currentUser.firstName || currentUser.username || currentUser.email || "User";
  }

  // Show online indicator (bonus feature)
  if (onlineIndicator && currentUser) {
    // You can add logic here to check if user is online
    // For now, we'll show it by default
    onlineIndicator.style.display = "block";
  }
}

// Initialize WebSocket connection
function initializeWebSocket() {
  if (chatWebSocket) {
    chatWebSocket.close();
  }

  const protocol = window.location.protocol === "https:" ? "wss:" : "ws:";
  const wsUrl =
    protocol +
    "//" +
    window.location.host +
    "/chat/" +
    currentUser.userId;

  chatWebSocket = new WebSocket(wsUrl);

  chatWebSocket.onopen = function (event) {
    console.log("WebSocket connected");
  };

  chatWebSocket.onmessage = function (event) {
    const message = JSON.parse(event.data);
    handleWebSocketMessage(message);
  };

  chatWebSocket.onclose = function (event) {
    console.log("WebSocket disconnected");
    // Attempt to reconnect after 3 seconds
    setTimeout(initializeWebSocket, 3000);
  };

  chatWebSocket.onerror = function (error) {
    console.error("WebSocket error:", error);
  };
}

// Handle WebSocket messages
function handleWebSocketMessage(message) {
  switch (message.type) {
    case "new_message":
      handleNewMessage(message);
      break;
    case "message_sent":
      handleMessageSent(message);
      break;
    case "typing_indicator":
      handleTypingIndicator(message);
      break;
    case "message_read":
      handleMessageRead(message);
      break;
    case "connection":
      console.log("Connected to chat server");
      break;
    default:
      console.log("Unknown message type:", message.type);
  }
}

// Handle new message received
function handleNewMessage(message) {
  console.log("Received new_message event:", message);
  
  // Update conversation list
  updateConversationLastMessage(message);

  // If this message is for the current conversation, add it to chat
  if (
    currentConversation &&
    (message.senderId === currentConversation.partnerId ||
      message.receiverId === currentConversation.partnerId)
  ) {
    console.log("Adding message to current chat:", message);
    addMessageToChat(message);

    // Mark as read if chat is open
    if (message.receiverId === currentUser.userId) {
      markMessageAsRead(message.messageId);
    }
  }
}

// Handle message sent confirmation
function handleMessageSent(message) {
  console.log("Message sent confirmation:", message);
}

// Handle typing indicator
function handleTypingIndicator(message) {
  if (
    currentConversation &&
    message.senderId === currentConversation.partnerId
  ) {
    const typingIndicator = document.getElementById("typingIndicator");
    const typingUser = document.getElementById("typingUser");

    if (message.isTyping) {
      if (typingUser) typingUser.textContent = currentConversation.partnerName;
      if (typingIndicator) typingIndicator.classList.remove("hidden");
    } else {
      if (typingIndicator) typingIndicator.classList.add("hidden");
    }
  }
}

// Handle message read
function handleMessageRead(message) {
  console.log("Message read:", message.messageId);
}

// Load conversations
function loadConversations() {
  return fetch("/api/messages/")
    .then((response) => response.json())
    .then((data) => {
      if (data.success) {
        conversations = data.conversations;
        if (conversationListComponent) {
          conversationListComponent.render(conversations);
        }
      } else {
        if (conversationListComponent) {
          conversationListComponent.render([]);
        }
      }
    })
    .catch((error) => {
      console.error("Error loading conversations:", error);
      if (conversationListComponent) {
        conversationListComponent.render([]);
      }
    });
}

// Select conversation
function selectConversation(partnerId, partnerName, partnerAvatar) {
  console.log("selectConversation called with:", {partnerId, partnerName, partnerAvatar});
  
  // Update conversation list active state
  if (conversationListComponent) {
    conversationListComponent.setActive(partnerId);
  }

  // Set current conversation
  currentConversation = {
    partnerId: partnerId,
    partnerName: partnerName,
    partnerAvatar: partnerAvatar,
  };
  
  console.log("Current conversation set to:", currentConversation);

  // Show conversation in chat window
  if (chatWindowComponent) {
    chatWindowComponent.showConversation(currentConversation);
    // Menu will be re-initialized in showConversation method
  }

  // Load conversation messages
  loadConversationMessages(partnerId);
  
  // Close mobile sidebar
  if (window.innerWidth <= 1024) {
    toggleSidebar(false);
  }
}

// Load conversation messages
function loadConversationMessages(partnerId) {
  fetch("/api/messages/conversation/" + partnerId)
    .then((response) => response.json())
    .then((data) => {
      if (data.success) {
        displayMessages(data.messages);
      }
    })
    .catch((error) => {
      console.error("Error loading messages:", error);
    });
}

// Display messages
function displayMessages(messages) {
  const chatContainer = document.getElementById("chatMessages");
  if (!chatContainer) return;

  if (messages.length === 0) {
    chatContainer.innerHTML = `
      <div class="flex items-center justify-center h-full">
        <div class="text-center">
          <div class="text-4xl text-gray-300 mb-3">
            <i class="fas fa-comments"></i>
          </div>
          <p class="text-sm text-gray-500">No messages yet. Start the conversation!</p>
        </div>
        <div id="messagesEndRef"></div>
      </div>
    `;
    return;
  }

  chatContainer.innerHTML = messages
    .map((message) => {
      const isSent = message.senderId === currentUser.userId;
      return MessageBubble.render(message, isSent, currentUser.userId);
    })
    .join("") + '<div id="messagesEndRef"></div>';

  // Scroll to bottom after messages are rendered
  scrollToBottom();

  // Mark unread messages as read
  markConversationAsRead(messages);
}

// Add message to chat
function addMessageToChat(message) {
  console.log("addMessageToChat called with:", message);
  const chatContainer = document.getElementById("chatMessages");
  if (!chatContainer) {
    console.error("Chat messages container not found");
    return;
  }
  
  // Remove empty state if present
  const emptyState = chatContainer.querySelector('div[class*="justify-center"]');
  if (emptyState && emptyState.querySelector('i.fa-comments')) {
    emptyState.remove();
  }
  
  // Remove old messagesEndRef if exists
  const oldEndRef = document.getElementById("messagesEndRef");
  if (oldEndRef) {
    oldEndRef.remove();
  }
  
  const isSent = message.senderId === currentUser.userId;
  const messageHTML = MessageBubble.render(message, isSent, currentUser.userId);
  
  // Create and append message element
  const tempDiv = document.createElement('div');
  tempDiv.innerHTML = messageHTML;
  const messageElement = tempDiv.firstElementChild;
  
  chatContainer.appendChild(messageElement);
  
  // Add messagesEndRef after the message
  const messagesEndRef = document.createElement('div');
  messagesEndRef.id = "messagesEndRef";
  chatContainer.appendChild(messagesEndRef);
  
  // Scroll to bottom after message is added
  scrollToBottom();
  
  console.log("Message added to chat");
}

// Scroll to bottom of messages
function scrollToBottom() {
  const messagesEndRef = document.getElementById("messagesEndRef");
  if (messagesEndRef) {
    // Use scrollIntoView for smooth scrolling
    setTimeout(() => {
      messagesEndRef.scrollIntoView({ behavior: "smooth", block: "end" });
    }, 50);
  }
  
  // Fallback: direct scroll
  const chatContainer = document.getElementById("chatMessages");
  if (chatContainer) {
    setTimeout(() => {
      chatContainer.scrollTop = chatContainer.scrollHeight;
    }, 100);
    requestAnimationFrame(() => {
      chatContainer.scrollTop = chatContainer.scrollHeight;
    });
  }
}

// Send message
function sendMessage() {
  const messageInput = document.getElementById("messageInput");
  if (!messageInput) {
    console.error("Message input not found");
    return;
  }
  const content = messageInput.value.trim();

  if (!content || !currentConversation) {
    return;
  }

  // Send via WebSocket
  const message = {
    type: "chat_message",
    receiverId: currentConversation.partnerId,
    content: content,
  };

  if (chatWebSocket && chatWebSocket.readyState === WebSocket.OPEN) {
    chatWebSocket.send(JSON.stringify(message));
    
    // Immediately display the message locally for better UX
    const localMessage = {
      senderId: currentUser.userId,
      receiverId: currentConversation.partnerId,
      content: content,
      timestamp: Date.now(),
      messageId: 'temp-' + Date.now()
    };
    
    console.log("Displaying message locally:", localMessage);
    addMessageToChat(localMessage);
    
    messageInput.value = "";

    // Stop typing indicator
    sendTypingIndicator(false);
  } else {
    alert("Connection lost. Please refresh the page.");
  }
}

// Send typing indicator
function sendTypingIndicator(isTyping) {
  if (
    !currentConversation ||
    !chatWebSocket ||
    chatWebSocket.readyState !== WebSocket.OPEN
  ) {
    return;
  }

  const message = {
    type: "typing",
    receiverId: currentConversation.partnerId,
    isTyping: isTyping,
  };

  chatWebSocket.send(JSON.stringify(message));
}

// Mark message as read
function markMessageAsRead(messageId) {
  fetch("/api/messages/mark-read", {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: "messageId=" + messageId,
  }).catch((error) => {
    console.error("Error marking message as read:", error);
  });
}

// Mark conversation as read
function markConversationAsRead(messages) {
  const unreadMessages = messages.filter(
    (msg) => msg.receiverId === currentUser.userId && !msg.read
  );

  unreadMessages.forEach((msg) => {
    markMessageAsRead(msg.id);
  });
}

// Update conversation last message
function updateConversationLastMessage(message) {
  const partnerId =
    message.senderId === currentUser.userId
      ? message.receiverId
      : message.senderId;

  // Find and update conversation in list
  const convIndex = conversations.findIndex(
    (conv) => conv.partnerId === partnerId
  );
  if (convIndex !== -1) {
    conversations[convIndex].lastMessage = message.content;
    conversations[convIndex].lastMessageTime = message.timestamp;

    if (message.receiverId === currentUser.userId) {
      conversations[convIndex].unreadCount =
        (conversations[convIndex].unreadCount || 0) + 1;
    }

    // Re-render conversations
    if (conversationListComponent) {
      conversationListComponent.render(conversations);
      // Maintain active state
      if (currentConversation) {
        conversationListComponent.setActive(currentConversation.partnerId);
      }
    }
  }
}

// Toggle mobile sidebar
function toggleSidebar(forceState) {
  const sidebar = document.getElementById("conversationsSidebar");
  if (sidebar) {
    if (forceState !== undefined) {
      if (forceState) {
        sidebar.classList.add("open");
      } else {
        sidebar.classList.remove("open");
      }
    } else {
      sidebar.classList.toggle("open");
    }
  }
}

// Message input event handlers
document.addEventListener("DOMContentLoaded", function() {
  // Wait for message input to be available
  setTimeout(() => {
    const messageInput = document.getElementById("messageInput");
    if (messageInput) {
      messageInput.addEventListener("keypress", function (e) {
        if (e.key === "Enter") {
          e.preventDefault();
          sendMessage();
        } else {
          // Send typing indicator
          sendTypingIndicator(true);

          // Clear previous timeout
          if (typingTimeout) {
            clearTimeout(typingTimeout);
          }

          // Stop typing indicator after 3 seconds of inactivity
          typingTimeout = setTimeout(() => {
            sendTypingIndicator(false);
          }, 3000);
        }
      });

      messageInput.addEventListener("blur", function () {
        sendTypingIndicator(false);
      });
    }
  }, 1000);
});

// Messages menu functionality - variables already declared at top of file

function initializeMenuForElement(triggerId, dropdownId) {
  const menuTrigger = document.getElementById(triggerId);
  const menuDropdown = document.getElementById(dropdownId);
  
  if (!menuTrigger) {
    console.log(`Menu trigger not found: ${triggerId}`);
    console.log(`Available elements with 'messagesMenu' in id:`, 
      Array.from(document.querySelectorAll('[id*="messagesMenu"]')).map(el => el.id));
    return false;
  }
  
  if (!menuDropdown) {
    console.log(`Menu dropdown not found: ${dropdownId}`);
    return false;
  }
  
  // Skip if already initialized
  if (initializedMenus.has(triggerId)) {
    console.log(`Menu already initialized: ${triggerId}`);
    return true;
  }
  
  console.log(`Initializing menu: ${triggerId}`, {
    trigger: menuTrigger,
    dropdown: menuDropdown,
    triggerVisible: menuTrigger.offsetParent !== null,
    triggerDisplay: window.getComputedStyle(menuTrigger).display
  });

  // Get context path from page - try to get from a data attribute or use window location
  let contextPath = '';
  const contextPathElement = document.querySelector('[data-context-path]');
  if (contextPathElement) {
    contextPath = contextPathElement.getAttribute('data-context-path') || '';
  } else {
    // Fallback: try to extract from existing navigation links
    const existingLink = document.querySelector('a[href*="dashboard.jsp"]');
    if (existingLink) {
      const existingHref = existingLink.getAttribute('href');
      if (existingHref) {
        const pathMatch = existingHref.match(/^(.+)\/dashboard\.jsp/);
        if (pathMatch && pathMatch[1]) {
          contextPath = pathMatch[1];
        }
      }
    }
  }
  
  // Update menu links with context path
  const menuLinks = menuDropdown.querySelectorAll('.messages-menu-item[href]');
  menuLinks.forEach(link => {
    let href = link.getAttribute('href');
    if (href && href.startsWith('/')) {
      // Only update if context path exists and href doesn't already include it
      if (contextPath && !href.startsWith(contextPath)) {
        link.setAttribute('href', contextPath + href);
      }
    }
  });

  // Position menu relative to trigger
  function positionMenu() {
    const triggerRect = menuTrigger.getBoundingClientRect();
    const dropdownWidth = 180;
    const dropdownHeight = menuDropdown.offsetHeight || 250; // Estimate if not rendered
    const spacing = 8;
    
    let left = triggerRect.right - dropdownWidth;
    let top = triggerRect.bottom + spacing;
    
    // Adjust if menu goes off screen
    if (left < 8) {
      left = 8;
    }
    if (window.innerWidth - left < dropdownWidth) {
      left = window.innerWidth - dropdownWidth - 8;
    }
    
    // If menu goes below viewport, show above
    if (top + dropdownHeight > window.innerHeight - 8) {
      top = triggerRect.top - dropdownHeight - spacing;
    }
    
    menuDropdown.style.left = left + 'px';
    menuDropdown.style.top = top + 'px';
  }

  // Toggle menu
  function toggleMenu(show) {
    // Close all other menus first
    initializedMenus.forEach(id => {
      if (id !== triggerId) {
        const otherTrigger = document.getElementById(id);
        const otherDropdown = document.getElementById(id.replace('Trigger', 'Dropdown'));
        if (otherDropdown && otherDropdown.classList.contains('show')) {
          otherDropdown.classList.remove('show');
          if (otherTrigger) otherTrigger.setAttribute('aria-expanded', 'false');
        }
      }
    });
    
    const isShowing = menuDropdown.classList.contains('show');
    if (show === undefined) {
      show = !isShowing;
    }
    
    if (show) {
      positionMenu();
      menuDropdown.classList.add('show');
      menuTrigger.setAttribute('aria-expanded', 'true');
    } else {
      menuDropdown.classList.remove('show');
      menuTrigger.setAttribute('aria-expanded', 'false');
    }
  }

  // Click handler for trigger
  menuTrigger.addEventListener('click', function(e) {
    e.stopPropagation();
    e.preventDefault();
    console.log(`Menu button clicked: ${triggerId}`);
    toggleMenu();
  });

  // Make sure button is visible
  menuTrigger.style.display = 'flex';
  menuTrigger.style.visibility = 'visible';
  
  // Mark as initialized
  initializedMenus.add(triggerId);
  
  console.log(`Menu successfully initialized: ${triggerId}`);
  return true; // Return true if menu was initialized
}

function initializeMessagesMenu() {
  console.log("=== initializeMessagesMenu called ===");
  console.log("Checking for menu elements...");
  
  // Check if elements exist
  const trigger1 = document.getElementById("messagesMenuTrigger");
  const dropdown1 = document.getElementById("messagesMenuDropdown");
  const trigger2 = document.getElementById("messagesMenuTriggerPlaceholder");
  const dropdown2 = document.getElementById("messagesMenuDropdownPlaceholder");
  
  console.log("Menu elements found:", {
    trigger1: !!trigger1,
    dropdown1: !!dropdown1,
    trigger2: !!trigger2,
    dropdown2: !!dropdown2
  });
  
  // Make sure buttons are visible if they exist
  if (trigger1) {
    trigger1.style.display = 'flex';
    trigger1.style.visibility = 'visible';
    trigger1.style.opacity = '1';
    trigger1.style.width = '36px';
    trigger1.style.height = '36px';
    trigger1.style.backgroundColor = '#ffffff';
    trigger1.style.border = '1px solid #e5e7eb';
    trigger1.style.boxShadow = '0 1px 3px rgba(0,0,0,0.1)';
    const icon1 = trigger1.querySelector('i');
    if (icon1) {
      icon1.style.color = '#374151';
      icon1.style.fontSize = '16px';
      icon1.style.display = 'inline-block';
    }
    console.log("Made trigger1 visible with enhanced styling");
  }
  
  if (trigger2) {
    trigger2.style.display = 'flex';
    trigger2.style.visibility = 'visible';
    trigger2.style.opacity = '1';
    trigger2.style.width = '36px';
    trigger2.style.height = '36px';
    trigger2.style.backgroundColor = '#ffffff';
    trigger2.style.border = '1px solid #e5e7eb';
    trigger2.style.boxShadow = '0 1px 3px rgba(0,0,0,0.1)';
    const icon2 = trigger2.querySelector('i');
    if (icon2) {
      icon2.style.color = '#374151';
      icon2.style.fontSize = '16px';
      icon2.style.display = 'inline-block';
    }
    console.log("Made trigger2 visible with enhanced styling");
  }
  
  // Initialize both menu instances (chat header and placeholder)
  const initialized1 = initializeMenuForElement("messagesMenuTrigger", "messagesMenuDropdown");
  const initialized2 = initializeMenuForElement("messagesMenuTriggerPlaceholder", "messagesMenuDropdownPlaceholder");
  
  if (!initialized1 && !initialized2) {
    console.log("Messages menu: No menu elements found yet, will retry...");
    messagesMenuInitialized = false; // Allow retry
    return;
  }
  
  console.log("Messages menu initialization status:", { initialized1, initialized2 });
  
  // Only set initialized to true if we actually initialized at least one menu
  if (initialized1 || initialized2) {
    messagesMenuInitialized = true;
    console.log("Messages menu successfully initialized!");
  }

  // Close menu when clicking outside (shared handler)
  document.addEventListener('click', function(e) {
    initializedMenus.forEach(triggerId => {
      const menuTrigger = document.getElementById(triggerId);
      const dropdownId = triggerId.replace('Trigger', 'Dropdown');
      const menuDropdown = document.getElementById(dropdownId);
      
      if (menuDropdown && menuDropdown.classList.contains('show')) {
        const isClickInsideMenu = menuDropdown.contains(e.target);
        const isClickOnTrigger = menuTrigger && menuTrigger.contains(e.target);
        
        if (!isClickInsideMenu && !isClickOnTrigger) {
          menuDropdown.classList.remove('show');
          if (menuTrigger) menuTrigger.setAttribute('aria-expanded', 'false');
        }
      }
    });
  });

  // Close menu on escape key (shared handler)
  document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
      initializedMenus.forEach(triggerId => {
        const menuTrigger = document.getElementById(triggerId);
        const dropdownId = triggerId.replace('Trigger', 'Dropdown');
        const menuDropdown = document.getElementById(dropdownId);
        
        if (menuDropdown && menuDropdown.classList.contains('show')) {
          menuDropdown.classList.remove('show');
          if (menuTrigger) {
            menuTrigger.setAttribute('aria-expanded', 'false');
            menuTrigger.focus();
          }
        }
      });
    }
  });

  // Reposition on window resize (shared handler)
  let resizeTimeout;
  window.addEventListener('resize', function() {
    clearTimeout(resizeTimeout);
    resizeTimeout = setTimeout(function() {
      initializedMenus.forEach(triggerId => {
        const menuTrigger = document.getElementById(triggerId);
        const dropdownId = triggerId.replace('Trigger', 'Dropdown');
        const menuDropdown = document.getElementById(dropdownId);
        
        if (menuDropdown && menuDropdown.classList.contains('show') && menuTrigger) {
          const triggerRect = menuTrigger.getBoundingClientRect();
          const dropdownWidth = 180;
          const dropdownHeight = menuDropdown.offsetHeight || 250;
          const spacing = 8;
          
          let left = triggerRect.right - dropdownWidth;
          let top = triggerRect.bottom + spacing;
          
          if (left < 8) left = 8;
          if (window.innerWidth - left < dropdownWidth) {
            left = window.innerWidth - dropdownWidth - 8;
          }
          
          if (top + dropdownHeight > window.innerHeight - 8) {
            top = triggerRect.top - dropdownHeight - spacing;
          }
          
          menuDropdown.style.left = left + 'px';
          menuDropdown.style.top = top + 'px';
        }
      });
    }, 150);
  });
}

// Re-initialize menu after chat window updates
function reinitializeMessagesMenu() {
  console.log("Re-initializing messages menu...");
  messagesMenuInitialized = false;
  initializedMenus.clear(); // Clear the set to allow re-initialization
  setTimeout(initializeMessagesMenu, 100);
}

// Handle direct contact from URL parameters
function checkForDirectContact() {
  const urlParams = new URLSearchParams(window.location.search);
  const artistId = urlParams.get('artistId');
  const artworkId = urlParams.get('artworkId');
  
  console.log('Checking for direct contact:', { artistId, artworkId });
  
  if (artistId) {
    console.log('Artist ID found in URL, starting conversation with:', artistId);
    // Clear URL parameters
    window.history.replaceState({}, document.title, window.location.pathname);
    
    // Start or find conversation with this artist
    startNewConversation(artistId, artworkId);
  } else {
    console.log('No artist ID found in URL parameters');
  }
}

// Start a new conversation or find existing one
function startNewConversation(artistId, artworkId) {
  console.log('Starting new conversation with artist:', artistId);
  console.log('Current conversations:', conversations);
  
  // First, check if conversation already exists
  const existingConversation = conversations.find(conv => 
    conv.partnerId === artistId
  );
  
  if (existingConversation) {
    console.log('Found existing conversation:', existingConversation);
    // Select existing conversation
    selectConversation(
      existingConversation.partnerId, 
      existingConversation.partnerName, 
      existingConversation.partnerAvatar
    );
    return;
  }
  
  console.log('No existing conversation found, fetching artist info...');
  const fetchUrl = '/api/users/' + artistId;
  console.log('Fetching from URL:', fetchUrl);
  
  // If no existing conversation, fetch artist info and create new conversation
  fetch(fetchUrl)
    .then(response => {
      console.log('Artist fetch response status:', response.status);
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      return response.json();
    })
    .then(data => {
      console.log('Artist fetch response data:', data);
      if (data.success && data.data && data.data.user) {
        const artist = data.data.user;
        
        // Create a new conversation entry
        const newConversation = {
          partnerId: artistId,
          partnerName: artist.firstName ? `${artist.firstName} ${artist.lastName}` : artist.username,
          partnerAvatar: artist.profileImageUrl || '/assets/images/default-avatar.svg',
          lastMessage: '',
          timestamp: new Date().toISOString(),
          isRead: true,
          unreadCount: 0
        };
        
        // Add to conversations list
        conversations.unshift(newConversation);
        
        // Re-render conversations to include the new one
        if (conversationListComponent) {
          conversationListComponent.render(conversations);
        }
        
        // Select the new conversation
        selectConversation(newConversation.partnerId, newConversation.partnerName, newConversation.partnerAvatar);
        
        // If there's an artwork context, send an initial message
        if (artworkId) {
          sendInitialArtworkMessage(artworkId);
        }
      } else {
        console.error('Failed to fetch artist information. Response:', data);
        alert('Failed to start conversation. Artist not found.');
      }
    })
    .catch(error => {
      console.error('Error fetching artist info:', error);
      alert('Failed to start conversation. Network error: ' + error.message);
    });
}

// Send initial message about artwork
function sendInitialArtworkMessage(artworkId) {
  // Fetch artwork details
  fetch(`/api/artworks/${artworkId}`)
    .then(response => response.json())
    .then(data => {
      if (data.success && data.artwork) {
        const artwork = data.artwork;
        const message = `Hi! I'm interested in your artwork "${artwork.title}". Could you tell me more about it?`;
        
        // Auto-populate the message input
        const messageInput = document.getElementById('messageInput');
        if (messageInput) {
          messageInput.value = message;
          messageInput.focus();
        }
      }
    })
    .catch(error => {
      console.error('Error fetching artwork details:', error);
    });
}
