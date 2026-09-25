// olympiaweekend.app — tiny bit of vanilla JS.
// No frameworks, no build step.

(() => {
  'use strict';

  // ---- 1. Hide the "LIVE NOW" chip after the event closes ----
  // Chip is only relevant through 2026-09-28 (Sunday, day after finals).
  const chip = document.querySelector('[data-live-chip]');
  if (chip) {
    const cutoff = new Date('2026-09-29T00:00:00-07:00'); // Vegas midnight after finals
    if (Date.now() >= cutoff.getTime()) {
      chip.hidden = true;
    }
  }

  // ---- 2. Sticky nav fades in AFTER the user scrolls past ~80% of viewport ----
  const nav = document.querySelector('[data-nav]');
  if (nav) {
    const threshold = () => window.innerHeight * 0.8;
    const onScroll = () => {
      if (window.scrollY > threshold()) nav.classList.add('is-visible');
      else nav.classList.remove('is-visible');
    };
    onScroll();
    window.addEventListener('scroll', onScroll, { passive: true });
    window.addEventListener('resize', onScroll, { passive: true });
  }

  // ---- 3. Reveal-on-scroll for anything with [data-reveal] ----
  const reveals = document.querySelectorAll('[data-reveal]');
  if ('IntersectionObserver' in window && reveals.length) {
    const io = new IntersectionObserver((entries) => {
      for (const e of entries) {
        if (e.isIntersecting) {
          e.target.classList.add('is-in');
          io.unobserve(e.target);
        }
      }
    }, { rootMargin: '0px 0px -8% 0px', threshold: 0.05 });
    reveals.forEach((el) => io.observe(el));
  } else {
    reveals.forEach((el) => el.classList.add('is-in'));
  }
})();
