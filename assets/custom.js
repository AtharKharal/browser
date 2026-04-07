document.addEventListener("DOMContentLoaded", function() {
    function customizeUI() {
        // 1. Make GitHub link open in new tab
        const repoLinks = document.querySelectorAll('header .md-source, .md-footer-meta .md-source');
        repoLinks.forEach(link => {
            if (!link.hasAttribute('target')) {
                link.setAttribute('target', '_blank');
            }
        });

        // 2. Inject "Created by Athar Kharal, PhD" into the header
        const headerInner = document.querySelector('.md-header__inner.md-grid');
        if (headerInner && !document.querySelector('.custom-branding-header')) {
            const branding = document.createElement('div');
            branding.className = 'custom-branding-header';
            branding.innerHTML = 'Created by <a href="https://www.linkedin.com/in/atharkharal/" target="_blank">Athar Kharal, PhD</a>';
            
            // Try to insert before the search bar
            const search = headerInner.querySelector('.md-search');
            if (search) {
                headerInner.insertBefore(branding, search);
            } else {
                // Fallback: append if search isn't found for some reason
                headerInner.appendChild(branding);
            }
        }
    }

    // Run on initial load
    customizeUI();

    // Re-run on navigation for SPA-like transitions in Zensical/MkDocs
    const observer = new MutationObserver(customizeUI);
    observer.observe(document.body, { childList: true, subtree: true });
});
