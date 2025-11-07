// Tabbar hover stability helper (moving mouse from tabs to web content would not get caught)

(function () {
  const init = () => {
    const bar = document.querySelector(".tabbar-wrapper");
    if (!bar) {
      setTimeout(init, 500);
      return;
    }

    const COLLAPSED = "42px"; // Keep aligned with CSS
    const curtain = document.createElement("div");
    curtain.id = "js-sidebar-curtain";
    Object.assign(curtain.style, {
      position: "fixed",
      top: "0",
      left: COLLAPSED,
      right: "0",
      bottom: "0",
      zIndex: "199", // Keep right under the bar (it's 200)
      background: "transparent",
      pointerEvents: "none"
    });
    document.body.appendChild(curtain);

    function arm() {
      curtain.style.pointerEvents = "auto";
      // console.log('curtain armed');
    }

    function disarm() {
      curtain.style.pointerEvents = "none";
      // console.log('curtain disarmed');
    }

    bar.addEventListener("pointerenter", arm);
    curtain.addEventListener("pointerover", disarm);
  };

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
