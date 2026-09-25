// olympiaweekend.app — Mixpanel init for the static marketing pages
// (landing + privacy). The Flutter web app at /app uses its own
// MixpanelService and does not touch this file.
//
// Callers invoke `olympiaAnalytics.init({token, page})` from an inline
// <script> at the bottom of each page. `token` is substituted by
// deploy.sh (`__MP_TOKEN__` -> real token). In local preview the
// placeholder is left intact and init() no-ops so nothing hits the
// wire when serving via `python3 -m http.server`.

(function () {
  'use strict';

  function loadMixpanelSnippet() {
    // Standard Mixpanel Web SDK loader (from mixpanel.com/docs/quickstart/install-mixpanel).
    // Queues calls on window.mixpanel, then fetches the real SDK from CDN.
    // prettier-ignore
    (function(f,b){if(!b.__SV){var e,g,i,h;window.mixpanel=b;b._i=[];b.init=function(e,f,c){function g(a,d){var b=d.split(".");2==b.length&&(a=a[b[0]],d=b[1]);a[d]=function(){a.push([d].concat(Array.prototype.slice.call(arguments,0)))}}var a=b;"undefined"!==typeof c?a=b[c]=[]:c="mixpanel";a.people=a.people||[];a.toString=function(a){var d="mixpanel";"mixpanel"!==c&&(d+="."+c);a||(d+=" (stub)");return d};a.people.toString=function(){return a.toString(1)+".people (stub)"};i="disable time_event track track_pageview track_links track_forms track_with_groups add_group set_group remove_group register register_once alias unregister identify name_tag set_config reset opt_in_tracking opt_out_tracking has_opted_in_tracking has_opted_out_tracking clear_opt_in_out_tracking start_batch_senders people.set people.set_once people.unset people.increment people.append people.union people.track_charge people.clear_charges people.delete_user people.remove".split(" ");for(h=0;h<i.length;h++)g(a,i[h]);var j="set set_once union unset remove delete".split(" ");a.get_group=function(){function b(c){d[c]=function(){call2_args=arguments;call2=[c].concat(Array.prototype.slice.call(call2_args,0));a.push([e,call2])}}for(var d={},e=["get_group"].concat(Array.prototype.slice.call(arguments,0)),c=0;c<j.length;c++)b(j[c]);return d};b._i.push([e,f,c])};b.__SV=1.2;e=f.createElement("script");e.type="text/javascript";e.async=!0;e.src="undefined"!==typeof MIXPANEL_CUSTOM_LIB_URL?MIXPANEL_CUSTOM_LIB_URL:"//cdn.mxpnl.com/libs/mixpanel-2-latest.min.js";g=f.getElementsByTagName("script")[0];g.parentNode.insertBefore(e,g)}})(document,window.mixpanel||[]);
  }

  function readSourceHost() {
    var r = document.referrer;
    if (!r) return '';
    try {
      return new URL(r).hostname;
    } catch (_) {
      return '';
    }
  }

  function collectClickProps(el) {
    var props = {};
    for (var i = 0; i < el.attributes.length; i++) {
      var a = el.attributes[i];
      if (a.name.indexOf('data-prop-') === 0) {
        props[a.name.substring('data-prop-'.length)] = a.value;
      }
    }
    if (el.href) props.href = el.href;
    // For anchor CTAs that go off-domain, name the destination.
    if (el.hostname && el.hostname !== location.hostname) {
      props.outbound_host = el.hostname;
    }
    return props;
  }

  function attachClickTracking() {
    document.addEventListener(
      'click',
      function (e) {
        var el = e.target.closest('[data-track]');
        if (!el) return;
        var name = el.getAttribute('data-track');
        if (!name) return;
        try {
          window.mixpanel.track(name, collectClickProps(el));
        } catch (_) {
          // Never break navigation on analytics failure.
        }
      },
      // Capture so links with target=_blank and rel=noopener still see
      // the event before the browser tears down the current context.
      true
    );
  }

  function init(config) {
    var token = config && config.token;
    // Local preview / unsubstituted placeholder / missing config → no-op.
    if (!token || token.indexOf('__MP_TOKEN') === 0) return;

    var page = (config && config.page) || 'unknown';
    var params = new URLSearchParams(location.search);

    loadMixpanelSnippet();

    window.mixpanel.init(token, {
      persistence: 'localStorage',
      ignore_dnt: false,
      // We fire our own page_view below so we can attach super props first.
      track_pageview: false,
      // Anonymous — no identify() call, no email/PII.
      loaded: function () {
        try {
          window.mixpanel.track('page_view');
        } catch (_) {}
      },
    });

    window.mixpanel.register({
      platform: 'marketing_web',
      installed: false,
      page: page,
      referrer: document.referrer || '(direct)',
      referrer_host: readSourceHost() || '(direct)',
      utm_source: params.get('utm_source') || 'direct',
      utm_medium: params.get('utm_medium') || '',
      utm_campaign: params.get('utm_campaign') || '',
    });

    attachClickTracking();
  }

  window.olympiaAnalytics = { init: init };
})();
