/**
 * Messages Page Components
 * Component-based structure for modular UI rendering
 */

// ConversationList Component
class ConversationList {
  constructor(containerId) {
    this.containerId = containerId;
    this.conversations = [];
    this.activeConversationId = null;
  }

  render(conversations = []) {
    this.conversations = conversations;
    const container = document.getElementById(this.containerId) || document.querySelector(`#${this.containerId}`);
    if (!container) {
      console.error(`Container ${this.containerId} not found`);
      return;
    }

    container.innerHTML = `
      <!-- Header -->
      <div class="px-5 py-4 border-b border-gray-200 bg-white flex-shrink-0">
        <h2 class="text-lg font-light text-gray-900">Conversations</h2>
      </div>

      <!-- Conversations List - Scrollable -->
      <div class="flex-1 overflow-y-auto custom-scrollbar smooth-scroll" id="conversationsListContainer" style="min-height: 0;">
        ${this.renderConversationsList()}
      </div>
    `;

    // Attach click handlers
    this.attachEventListeners();
  }

  renderConversationsList() {
    if (this.conversations.length === 0) {
      return `
        <div class="flex flex-col items-center justify-center h-full px-5 py-12 text-center">
          <div class="text-5xl text-gray-300 mb-4">
            <i class="fas fa-comment-slash"></i>
          </div>
          <h3 class="text-base font-normal text-gray-600 mb-2">No conversations yet</h3>
          <p class="text-sm text-gray-500 mb-6">Start browsing artworks and contact artists to begin conversations</p>
          <a href="/browse.jsp" class="px-4 py-2 bg-indigo-600 text-white text-sm font-medium rounded-lg hover:bg-indigo-700 transition-colors">
            Browse Artworks
          </a>
        </div>
      `;
    }

    return this.conversations
      .map((conv) => this.renderConversationItem(conv))
      .join("");
  }

  renderConversationItem(conv) {
    const isActive = this.activeConversationId === conv.partnerId;
    const unreadBadge = conv.unreadCount > 0 
      ? `<span class="bg-indigo-600 text-white text-xs font-semibold px-2 py-0.5 rounded-full min-w-[18px] text-center">${conv.unreadCount}</span>`
      : "";
    const lastMessage = conv.lastMessage || "No messages yet";
    const lastMessageTime = conv.lastMessageTime ? this.formatTime(conv.lastMessageTime) : "";

    return `
      <div 
        class="conversation-item px-4 py-3 cursor-pointer transition-colors border-b border-gray-100 hover:bg-gray-50 ${
          isActive ? "bg-blue-50" : ""
        }"
        data-partner-id="${conv.partnerId}"
        onclick="selectConversation('${conv.partnerId}', '${this.escapeHtml(conv.partnerName)}', '${conv.partnerAvatar || ""}')"
      >
        <div class="flex items-center gap-3">
          <!-- Avatar -->
          <div class="relative flex-shrink-0">
            <img 
              src="${conv.partnerAvatar || "/assets/images/default-avatar.svg"}" 
              alt="${this.escapeHtml(conv.partnerName)}" 
              class="w-12 h-12 rounded-full object-cover"
              onerror="this.src='/assets/images/default-avatar.svg'"
            />
          </div>

          <!-- Content -->
          <div class="flex-1 min-w-0">
            <div class="flex items-center justify-between gap-2 mb-1">
              <h3 class="text-sm font-medium text-gray-900 truncate">${this.escapeHtml(conv.partnerName)}</h3>
              ${unreadBadge}
            </div>
            <div class="flex items-center justify-between gap-2">
              <p class="text-sm text-gray-500 truncate">${this.escapeHtml(lastMessage)}</p>
              ${lastMessageTime ? `<span class="text-xs text-gray-400 whitespace-nowrap flex-shrink-0">${lastMessageTime}</span>` : ""}
            </div>
          </div>
        </div>
      </div>
    `;
  }

  setActive(partnerId) {
    this.activeConversationId = partnerId;
    // Re-render to update active state
    const container = document.getElementById(this.containerId) || document.querySelector(`#${this.containerId}`);
    if (container) {
      const listContainer = container.querySelector("#conversationsListContainer");
      if (listContainer) {
        listContainer.innerHTML = this.renderConversationsList();
        this.attachEventListeners();
      }
    }
  }

  attachEventListeners() {
    // Event listeners are attached via onclick in the HTML
  }

  formatTime(timestamp) {
    const date = new Date(timestamp);
    const now = new Date();
    const diffInHours = (now - date) / (1000 * 60 * 60);

    if (diffInHours < 24) {
      return date.toLocaleTimeString([], {
        hour: "2-digit",
        minute: "2-digit",
      });
    } else if (diffInHours < 168) {
      return date.toLocaleDateString([], {
        weekday: "short",
        hour: "2-digit",
        minute: "2-digit",
      });
    } else {
      return date.toLocaleDateString([], {
        month: "short",
        day: "numeric",
      });
    }
  }

  escapeHtml(text) {
    const div = document.createElement("div");
    div.textContent = text;
    return div.innerHTML;
  }
}

// ChatWindow Component
class ChatWindow {
  constructor(containerId) {
    this.containerId = containerId;
    this.currentConversation = null;
  }

  render() {
    const container = document.getElementById(this.containerId) || document.querySelector(`#${this.containerId}`);
    if (!container) {
      console.error(`Container ${this.containerId} not found`);
      return;
    }

    // Ensure container is a flex column
    container.style.display = "flex";
    container.style.flexDirection = "column";
    container.style.height = "100%";
    container.style.minHeight = "0";

    container.innerHTML = `
      <!-- Placeholder (shown when no conversation selected) -->
      <div id="chatPlaceholder" class="flex-1 flex flex-col bg-gray-50" style="display: flex;">
        <!-- Placeholder Header with Menu -->
        <div class="px-5 py-3 bg-white border-b border-gray-200 flex items-center justify-end flex-shrink-0 relative" style="height: 60px;">
          <!-- Messages Page Menu Icon -->
          <div class="messages-menu-wrapper relative" style="flex-shrink: 0; z-index: 10;">
            <button
              id="messagesMenuTriggerPlaceholder"
              class="messages-menu-trigger"
              style="width: 36px; height: 36px; display: flex !important; visibility: visible !important; opacity: 1 !important; align-items: center; justify-content: center; border-radius: 50%; border: 1px solid #e5e7eb; background: #ffffff; cursor: pointer; transition: all 0.2s ease; position: relative; z-index: 10; box-shadow: 0 1px 3px rgba(0,0,0,0.1);"
              aria-label="Messages menu"
              aria-haspopup="true"
              aria-expanded="false"
              onmouseover="this.style.backgroundColor='#f3f4f6'; this.style.borderColor='#d1d5db';"
              onmouseout="this.style.backgroundColor='#ffffff'; this.style.borderColor='#e5e7eb';"
            >
              <i class="fas fa-ellipsis-h" style="color: #374151; font-size: 16px; display: inline-block !important; font-weight: 600;"></i>
            </button>
            <div
              id="messagesMenuDropdownPlaceholder"
              class="messages-menu-dropdown"
              role="menu"
              aria-labelledby="messagesMenuTriggerPlaceholder"
            >
              <a
                href="/dashboard.jsp"
                class="messages-menu-item"
                role="menuitem"
              >
                <i class="fas fa-tachometer-alt mr-2"></i>
                Go to Dashboard
              </a>
              <a
                href="/dashboard.jsp"
                class="messages-menu-item"
                role="menuitem"
              >
                <i class="fas fa-paint-brush mr-2"></i>
                My Artworks
              </a>
              <a
                href="/browse.jsp"
                class="messages-menu-item"
                role="menuitem"
              >
                <i class="fas fa-search mr-2"></i>
                Browse Art
              </a>
              <a
                href="/profile.jsp"
                class="messages-menu-item"
                role="menuitem"
              >
                <i class="fas fa-user mr-2"></i>
                Profile
              </a>
              <div class="messages-menu-divider"></div>
              <button
                class="messages-menu-item messages-menu-item-button"
                role="menuitem"
                onclick="handleLogout()"
              >
                <i class="fas fa-sign-out-alt mr-2"></i>
                Logout
              </button>
            </div>
          </div>
        </div>
        <!-- Placeholder Content -->
        <div class="flex-1 flex items-center justify-center">
          <div class="text-center px-5">
            <div class="text-6xl text-gray-300 mb-4">
              <i class="fas fa-comments"></i>
            </div>
            <p class="text-xl font-light text-gray-500">Select a conversation to start messaging</p>
          </div>
        </div>
      </div>

      <!-- Chat Interface (hidden by default) -->
      <div id="chatInterface" class="chat-column" style="display: none;">
        <!-- Chat Header - Fixed -->
        <div class="px-5 py-3 bg-white border-b border-gray-200 flex items-center gap-3 flex-shrink-0 relative" style="height: 60px;">
          <div class="relative">
            <img
              id="chatPartnerAvatar"
              src=""
              alt="Partner"
              class="w-10 h-10 rounded-full object-cover"
              onerror="this.src='/assets/images/default-avatar.svg'"
            />
            <div id="onlineIndicator" class="absolute bottom-0 right-0 w-3 h-3 bg-green-500 rounded-full border-2 border-white hidden"></div>
          </div>
          <div class="flex-1 min-w-0">
            <h3 id="chatPartnerName" class="text-sm font-medium text-gray-900 truncate">Select a conversation</h3>
            <p id="chatPartnerStatus" class="text-xs text-gray-500">Offline</p>
          </div>
          <!-- Messages Page Menu Icon -->
          <div class="messages-menu-wrapper relative" style="flex-shrink: 0; z-index: 10;">
            <button
              id="messagesMenuTrigger"
              class="messages-menu-trigger"
              style="width: 36px; height: 36px; display: flex !important; visibility: visible !important; opacity: 1 !important; align-items: center; justify-content: center; border-radius: 50%; border: 1px solid #e5e7eb; background: #ffffff; cursor: pointer; transition: all 0.2s ease; position: relative; z-index: 10; box-shadow: 0 1px 3px rgba(0,0,0,0.1);"
              aria-label="Messages menu"
              aria-haspopup="true"
              aria-expanded="false"
              onmouseover="this.style.backgroundColor='#f3f4f6'; this.style.borderColor='#d1d5db';"
              onmouseout="this.style.backgroundColor='#ffffff'; this.style.borderColor='#e5e7eb';"
            >
              <i class="fas fa-ellipsis-h" style="color: #374151; font-size: 16px; display: inline-block !important; font-weight: 600;"></i>
            </button>
            <div
              id="messagesMenuDropdown"
              class="messages-menu-dropdown"
              role="menu"
              aria-labelledby="messagesMenuTrigger"
            >
              <a
                href="/dashboard.jsp"
                class="messages-menu-item"
                role="menuitem"
              >
                <i class="fas fa-tachometer-alt mr-2"></i>
                Go to Dashboard
              </a>
              <a
                href="/dashboard.jsp"
                class="messages-menu-item"
                role="menuitem"
              >
                <i class="fas fa-paint-brush mr-2"></i>
                My Artworks
              </a>
              <a
                href="/browse.jsp"
                class="messages-menu-item"
                role="menuitem"
              >
                <i class="fas fa-search mr-2"></i>
                Browse Art
              </a>
              <a
                href="/profile.jsp"
                class="messages-menu-item"
                role="menuitem"
              >
                <i class="fas fa-user mr-2"></i>
                Profile
              </a>
              <div class="messages-menu-divider"></div>
              <button
                class="messages-menu-item messages-menu-item-button"
                role="menuitem"
                onclick="handleLogout()"
              >
                <i class="fas fa-sign-out-alt mr-2"></i>
                Logout
              </button>
            </div>
          </div>
        </div>

        <!-- Messages Area - Scrollable -->
        <div 
          id="chatMessages" 
          class="messages-body custom-scrollbar px-5 py-4 bg-gray-50 space-y-2"
          style="flex: 1; overflow-y: auto; -webkit-overflow-scrolling: touch; scroll-behavior: smooth; min-height: 0;"
        >
          <!-- Messages will be loaded here -->
          <div id="messagesEndRef"></div>
        </div>

        <!-- Typing Indicator -->
        <div id="typingIndicator" class="px-5 py-2 bg-white border-t border-gray-200 text-sm text-gray-500 italic hidden flex-shrink-0">
          <span id="typingUser">Someone</span> is typing...
        </div>

        <!-- Chat Input - Fixed -->
        <div class="chat-input px-5 py-3 bg-white border-t border-gray-200" style="flex: 0 0 auto; height: 70px;">
          <div class="flex items-center gap-2">
            <input
              type="text"
              id="messageInput"
              class="flex-1 bg-gray-100 border-none rounded-full px-4 py-2.5 text-sm text-gray-900 placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:bg-white transition-all"
              placeholder="Type a message..."
              maxlength="1000"
              autocomplete="off"
            />
            <button
              id="sendButton"
              onclick="sendMessage()"
              class="w-10 h-10 bg-indigo-600 text-white rounded-full flex items-center justify-center hover:bg-indigo-700 transition-colors focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed"
              aria-label="Send message"
            >
              <i class="fas fa-paper-plane text-sm"></i>
            </button>
          </div>
        </div>
      </div>
    `;

    this.attachEventListeners();
    
    // Initialize menu after rendering
    if (typeof initializeMessagesMenu === 'function') {
      setTimeout(() => {
        console.log("ChatWindow rendered, initializing menu...");
        initializeMessagesMenu();
      }, 150);
    }
  }

  showConversation(conversation) {
    this.currentConversation = conversation;
    
    const placeholder = document.getElementById("chatPlaceholder");
    const chatInterface = document.getElementById("chatInterface");
    
    if (placeholder) {
      placeholder.style.display = "none";
    }
    if (chatInterface) {
      chatInterface.style.display = "flex";
      chatInterface.style.flexDirection = "column";
      chatInterface.style.height = "100%";
      chatInterface.style.minHeight = "0";
    }

    // Update header
    const avatar = document.getElementById("chatPartnerAvatar");
    const name = document.getElementById("chatPartnerName");
    
    if (avatar) avatar.src = conversation.partnerAvatar || "/assets/images/default-avatar.svg";
    if (name) name.textContent = conversation.partnerName;
    
    // Re-initialize menu after showing conversation
    if (typeof initializeMessagesMenu === 'function') {
      setTimeout(() => {
        console.log("Conversation shown, re-initializing menu...");
        messagesMenuInitialized = false; // Reset to allow re-initialization
        initializeMessagesMenu();
      }, 150);
    }
  }

  showPlaceholder() {
    this.currentConversation = null;
    
    const placeholder = document.getElementById("chatPlaceholder");
    const chatInterface = document.getElementById("chatInterface");
    
    if (placeholder) {
      placeholder.style.display = "flex";
    }
    if (chatInterface) {
      chatInterface.style.display = "none";
    }
  }

  attachEventListeners() {
    const messageInput = document.getElementById("messageInput");
    if (messageInput) {
      messageInput.addEventListener("keypress", (e) => {
        if (e.key === "Enter") {
          e.preventDefault();
          sendMessage();
        }
      });
    }
  }
}

// MessageBubble Component
class MessageBubble {
  static render(message, isSent, currentUserId) {
    const alignment = isSent ? "justify-end" : "justify-start";
    const bubbleColor = isSent 
      ? "bg-indigo-600 text-white" 
      : "bg-white text-gray-900 border border-gray-200";
    const timeColor = isSent ? "text-indigo-100" : "text-gray-400";
    const borderRadius = isSent 
      ? "rounded-2xl rounded-br-md" 
      : "rounded-2xl rounded-bl-md";

    const time = this.formatTime(message.timestamp);
    const content = this.escapeHtml(message.content);

    return `
      <div class="message-enter flex ${alignment} w-full mb-1">
        <div class="max-w-[65%] ${bubbleColor} ${borderRadius} px-3 py-2 shadow-sm">
          <p class="text-sm leading-relaxed mb-1">${content}</p>
          <p class="text-[10px] ${timeColor} text-right">${time}</p>
        </div>
      </div>
    `;
  }

  static formatTime(timestamp) {
    const date = new Date(timestamp);
    const now = new Date();
    const diffInHours = (now - date) / (1000 * 60 * 60);

    if (diffInHours < 24) {
      return date.toLocaleTimeString([], {
        hour: "2-digit",
        minute: "2-digit",
      });
    } else if (diffInHours < 168) {
      return date.toLocaleDateString([], {
        weekday: "short",
        hour: "2-digit",
        minute: "2-digit",
      });
    } else {
      return date.toLocaleDateString([], {
        month: "short",
        day: "numeric",
      });
    }
  }

  static escapeHtml(text) {
    const div = document.createElement("div");
    div.textContent = text;
    return div.innerHTML;
  }
}

// Initialize components
let conversationListComponent;
let chatWindowComponent;

document.addEventListener("DOMContentLoaded", function() {
  // Initialize ConversationList
  const container = document.getElementById("conversationListContainer");
  if (container) {
    conversationListComponent = new ConversationList("conversationListContainer");
    conversationListComponent.render([]);
  }

  // Initialize ChatWindow
  const chatContainer = document.getElementById("chatWindowContainer");
  if (chatContainer) {
    chatWindowComponent = new ChatWindow("chatWindowContainer");
    chatWindowComponent.render();
    
    // Initialize menu after ChatWindow renders
    if (typeof initializeMessagesMenu === 'function') {
      setTimeout(() => {
        console.log("Initializing messages menu after ChatWindow render...");
        initializeMessagesMenu();
      }, 200);
    }
  }
});

