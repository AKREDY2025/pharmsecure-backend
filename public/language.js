// PharmSecure Bilingual Support (EN/FR)
// Centralized i18n utility for all modules

class PharmSecureI18n {
    constructor() {
        this.currentLanguage = localStorage.getItem('language') || 'en';
        this.translations = {};
        this.apiUrl = 'https://pharmsecure-api.onrender.com/api';
    }

    // Get current language
    getLanguage() {
        return this.currentLanguage;
    }

    // Set language and update UI
    setLanguage(lang) {
        if (lang !== 'en' && lang !== 'fr') return;
        this.currentLanguage = lang;
        localStorage.setItem('language', lang);
        this.updateAllUI();
        return lang;
    }

    // Get available languages
    getAvailableLanguages() {
        return ['en', 'fr'];
    }

    // Translate a key
    t(key, defaultValue = '') {
        const keys = key.split('.');
        let value = this.translations[this.currentLanguage] || {};
        for (let k of keys) {
            value = value[k];
            if (!value) return defaultValue || key;
        }
        return value || defaultValue || key;
    }

    // Load translations from backend
    async loadTranslations() {
        try {
            const response = await fetch(`${this.apiUrl}/auth/languages`);
            const data = await response.json();
            if (data.success) {
                this.translations[this.currentLanguage] = data.data.labels || {};
                return true;
            }
        } catch (e) {
            console.warn('Could not load translations from backend:', e.message);
        }
        return false;
    }

    // Update all UI elements with data-i18n attributes
    updateAllUI() {
        document.querySelectorAll('[data-i18n]').forEach(el => {
            const key = el.getAttribute('data-i18n');
            const translated = this.t(key);
            if (el.tagName === 'INPUT') {
                el.placeholder = translated;
            } else if (el.tagName === 'BUTTON' || el.tagName === 'A') {
                el.textContent = translated;
            } else {
                el.textContent = translated;
            }
        });
    }

    // Create language toggle button
    createLanguageToggle() {
        const toggle = document.createElement('div');
        toggle.className = 'language-toggle';
        toggle.innerHTML = `
            <button class="lang-btn active" onclick="i18n.setLanguage('en'); i18n.updateAllUI();" data-lang="en">EN</button>
            <button class="lang-btn" onclick="i18n.setLanguage('fr'); i18n.updateAllUI();" data-lang="fr">FR</button>
        `;
        return toggle;
    }

    // Update language toggle button states
    updateLanguageToggle() {
        document.querySelectorAll('.lang-btn').forEach(btn => {
            btn.classList.toggle('active', btn.dataset.lang === this.currentLanguage);
        });
    }

    // Get user's stored language preference from backend
    async getUserLanguage() {
        try {
            const token = localStorage.getItem('token');
            if (!token) return this.currentLanguage;
            
            const response = await fetch(`${this.apiUrl}/user/language`, {
                headers: { 'Authorization': `Bearer ${token}` }
            });
            const data = await response.json();
            if (data.success) {
                this.currentLanguage = data.data.language;
                localStorage.setItem('language', this.currentLanguage);
                return this.currentLanguage;
            }
        } catch (e) {
            console.warn('Could not fetch user language:', e.message);
        }
        return this.currentLanguage;
    }

    // Set user's language preference on backend
    async setUserLanguage(lang) {
        try {
            const token = localStorage.getItem('token');
            if (!token) return false;

            const response = await fetch(`${this.apiUrl}/user/language`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                },
                body: JSON.stringify({ language: lang })
            });
            const data = await response.json();
            return data.success;
        } catch (e) {
            console.warn('Could not set user language:', e.message);
        }
        return false;
    }

    // Initialize i18n system
    async init() {
        const user = JSON.parse(localStorage.getItem('user') || '{}');
        if (user.language) {
            this.currentLanguage = user.language;
        }
        await this.loadTranslations();
        this.updateAllUI();
        this.updateLanguageToggle();
    }
}

// Global instance
const i18n = new PharmSecureI18n();

// Auto-initialize on DOMContentLoaded
document.addEventListener('DOMContentLoaded', () => {
    i18n.init();
});
