(function () {
  const KEY = 'site-theme'; // 存储键
  const root = document.documentElement;

  function applyTheme(theme) {
    if (theme === 'dark') {
      root.setAttribute('data-theme', 'dark');
    } else if (theme === 'light') {
      root.removeAttribute('data-theme');
    }
    window.dispatchEvent(new CustomEvent('theme:changed', { detail: { theme } }));
  }

  function getStoredTheme() {
    try { return localStorage.getItem(KEY); } catch (e) { return null; }
  }

  function setStoredTheme(value) {
    try { localStorage.setItem(KEY, value); } catch (e) { /* ignore */ }
  }

  function detectInitial() {
    const stored = getStoredTheme();
    if (stored) return stored;
    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) return 'dark';
    return 'light';
  }

  const initial = detectInitial();
  applyTheme(initial);

  window.ThemeToggle = {
    toggle: function () {
      const current = getStoredTheme() || (root.getAttribute('data-theme') ? 'dark' : 'light');
      const next = current === 'dark' ? 'light' : 'dark';
      applyTheme(next);
      setStoredTheme(next);
      return next;
    },
    set: function (t) { applyTheme(t); setStoredTheme(t); },
    get: function () { return getStoredTheme() || (root.getAttribute('data-theme') ? 'dark' : 'light'); }
  };

  document.addEventListener('DOMContentLoaded', function () {
    const btn = document.getElementById('theme-toggle');
    if (!btn) return;
    function refreshIcon() {
      const theme = window.ThemeToggle.get();
      btn.setAttribute('aria-pressed', theme === 'dark' ? 'true' : 'false');
    }
    btn.addEventListener('click', function (ev) {
      ev.preventDefault();
      const next = window.ThemeToggle.toggle();
      refreshIcon();
    });
    window.addEventListener('theme:changed', refreshIcon);
    refreshIcon();
  });
})();
