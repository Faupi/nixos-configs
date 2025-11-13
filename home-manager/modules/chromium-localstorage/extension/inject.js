// Loads config.json from the extension package and applies defaults.

(async () => {
  try {
    const url = chrome.runtime.getURL("config.json");
    const res = await fetch(url, { cache: "no-cache" });
    if (!res.ok) return;
    const conf = await res.json();

    // Get config of the current site
    const cfg = conf[location.origin];
    if (!cfg) return;

    // Apply each configured value into the localStorage
    for (const [k, v] of Object.entries(cfg)) {
      const str = typeof v === "string" ? v : JSON.stringify(v);
      if (localStorage.getItem(k) === null) {
        localStorage.setItem(k, str);
      }
    }

    // Just in case
    window.dispatchEvent(new Event("storage"));
  } catch (e) {
    console.error("localstorage-defaults error", e);
  }
})();
