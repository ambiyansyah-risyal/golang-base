// Global JavaScript functions for GoFiber App

// Utility functions
const Utils = {
    // Format date to local string
    formatDate: (dateString) => {
        return new Date(dateString).toLocaleDateString();
    },
    
    // Format date and time
    formatDateTime: (dateString) => {
        return new Date(dateString).toLocaleString();
    },
    
    // Show loading state on element
    showLoading: (element) => {
        element.classList.add('loading');
    },
    
    // Hide loading state
    hideLoading: (element) => {
        element.classList.remove('loading');
    },
    
    // Show toast notification
    showToast: (message, type = 'info') => {
        const toastContainer = document.getElementById('toast-container') || createToastContainer();
        const toast = createToast(message, type);
        toastContainer.appendChild(toast);
        
        // Auto remove after 5 seconds
        setTimeout(() => {
            toast.remove();
        }, 5000);
    },
    
    // Validate email format
    isValidEmail: (email) => {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    },
    
    // Get auth token from localStorage
    getAuthToken: () => {
        return localStorage.getItem('auth_token');
    },
    
    // Set auth token
    setAuthToken: (token) => {
        localStorage.setItem('auth_token', token);
    },
    
    // Remove auth token
    removeAuthToken: () => {
        localStorage.removeItem('auth_token');
    },
    
    // Check if user is authenticated
    isAuthenticated: () => {
        return !!Utils.getAuthToken();
    }
};

// API helper functions
const API = {
    baseURL: '/api/v1',
    
    // Make authenticated request
    request: async (endpoint, options = {}) => {
        const token = Utils.getAuthToken();
        const headers = {
            'Content-Type': 'application/json',
            ...options.headers
        };
        
        if (token) {
            headers.Authorization = `Bearer ${token}`;
        }
        
        const config = {
            ...options,
            headers
        };
        
        try {
            const response = await fetch(`${API.baseURL}${endpoint}`, config);
            
            // Handle unauthorized responses
            if (response.status === 401) {
                Utils.removeAuthToken();
                window.location.href = '/login';
                return;
            }
            
            return response;
        } catch (error) {
            console.error('API request failed:', error);
            throw error;
        }
    },
    
    // GET request
    get: (endpoint) => {
        return API.request(endpoint);
    },
    
    // POST request
    post: (endpoint, data) => {
        return API.request(endpoint, {
            method: 'POST',
            body: JSON.stringify(data)
        });
    },
    
    // PUT request
    put: (endpoint, data) => {
        return API.request(endpoint, {
            method: 'PUT',
            body: JSON.stringify(data)
        });
    },
    
    // DELETE request
    delete: (endpoint) => {
        return API.request(endpoint, {
            method: 'DELETE'
        });
    }
};

// Form validation helpers
const Validation = {
    // Add error message to form field
    showFieldError: (fieldId, message) => {
        const field = document.getElementById(fieldId);
        const errorElement = document.getElementById(`${fieldId}-error`) || createErrorElement(fieldId);
        
        field.classList.add('is-invalid');
        errorElement.textContent = message;
        errorElement.style.display = 'block';
    },
    
    // Clear error message from form field
    clearFieldError: (fieldId) => {
        const field = document.getElementById(fieldId);
        const errorElement = document.getElementById(`${fieldId}-error`);
        
        field.classList.remove('is-invalid');
        if (errorElement) {
            errorElement.style.display = 'none';
        }
    },
    
    // Clear all form errors
    clearFormErrors: (formId) => {
        const form = document.getElementById(formId);
        const errorElements = form.querySelectorAll('.invalid-feedback');
        const invalidFields = form.querySelectorAll('.is-invalid');
        
        errorElements.forEach(el => el.style.display = 'none');
        invalidFields.forEach(field => field.classList.remove('is-invalid'));
    },
    
    // Validate required fields
    validateRequired: (formId) => {
        const form = document.getElementById(formId);
        const requiredFields = form.querySelectorAll('[required]');
        let isValid = true;
        
        requiredFields.forEach(field => {
            if (!field.value.trim()) {
                Validation.showFieldError(field.id, 'This field is required');
                isValid = false;
            } else {
                Validation.clearFieldError(field.id);
            }
        });
        
        return isValid;
    }
};

// Helper functions for DOM manipulation
function createToastContainer() {
    const container = document.createElement('div');
    container.id = 'toast-container';
    container.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        z-index: 9999;
    `;
    document.body.appendChild(container);
    return container;
}

function createToast(message, type) {
    const toast = document.createElement('div');
    const bgColor = {
        success: '#28a745',
        error: '#dc3545',
        warning: '#ffc107',
        info: '#17a2b8'
    }[type] || '#17a2b8';
    
    toast.style.cssText = `
        background-color: ${bgColor};
        color: white;
        padding: 12px 16px;
        margin-bottom: 10px;
        border-radius: 4px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.2);
        animation: slideInRight 0.3s ease-out;
        cursor: pointer;
    `;
    toast.textContent = message;
    toast.onclick = () => toast.remove();
    
    return toast;
}

function createErrorElement(fieldId) {
    const errorElement = document.createElement('div');
    errorElement.id = `${fieldId}-error`;
    errorElement.className = 'invalid-feedback';
    errorElement.style.display = 'none';
    
    const field = document.getElementById(fieldId);
    field.parentNode.appendChild(errorElement);
    
    return errorElement;
}

// Add CSS animations
const style = document.createElement('style');
style.textContent = `
    @keyframes slideInRight {
        from { transform: translateX(100%); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
    }
`;
document.head.appendChild(style);

// Initialize app when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    // Add fade-in animation to main content
    const main = document.querySelector('main');
    if (main) {
        main.classList.add('fade-in-up');
    }
    
    // Add click handlers to navigation
    updateNavigation();
});

// Update navigation based on authentication status
function updateNavigation() {
    const isAuth = Utils.isAuthenticated();
    const navItems = document.querySelectorAll('.navbar-nav .nav-item');
    
    navItems.forEach(item => {
        const link = item.querySelector('.nav-link');
        if (link) {
            const href = link.getAttribute('href');
            
            // Show/hide navigation items based on auth status
            if ((href === '/login' || href === '/register') && isAuth) {
                item.style.display = 'none';
            } else if (href === '/dashboard' && !isAuth) {
                item.style.display = 'none';
            }
        }
    });
}

// Export for use in other scripts
window.Utils = Utils;
window.API = API;
window.Validation = Validation;