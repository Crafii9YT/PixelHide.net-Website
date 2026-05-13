(() => {

  function init() {

    const AD_URL = "https://pixelhide.net/ads/advertisements.json";

    // ---------- STYLE ----------
    const style = document.createElement("style");
    style.innerHTML = `
    .ph-ad {
      position: fixed;
      bottom: 24px;
      left: 50%;
      transform: translateX(-50%);

      width: min(720px, 88vw);
      max-width: 720px;

      max-height: 260px;

      border-radius: 16px;
      overflow: hidden;

      z-index: 999999;

      font-family: Arial, sans-serif;

      box-shadow: 0 18px 50px rgba(0,0,0,0.45);

      transition: transform 0.3s ease, opacity 0.3s ease;
    }

    .ph-ad.hidden {
      display: none;
    }

    .ph-bg {
      width: 100%;
      height: 100%;
    }

    .ph-bg img {
      width: 100%;
      height: 100%;
      max-height: 260px;
      object-fit: cover;
      display: block;
      filter: brightness(0.55) saturate(1.1);
    }

    .ph-overlay {
      position: absolute;
      inset: 0;

      display: flex;
      flex-direction: column;
      justify-content: space-between;

      padding: 14px;

      background: linear-gradient(
        to top,
        rgba(0,0,0,0.65),
        rgba(0,0,0,0.2),
        rgba(0,0,0,0.1)
      );

      color: white;
    }

    .ph-close {
      position: absolute;
      top: 10px;
      right: 10px;

      width: 34px;
      height: 34px;

      border-radius: 50%;
      border: none;

      background: rgba(0,0,0,0.6);
      color: white;
      cursor: pointer;
    }

    .ph-text h2 {
      margin: 0;
      font-size: 18px;
    }

    .ph-text p {
      margin: 4px 0 0;
      font-size: 13px;
      opacity: 0.9;
      max-width: 70%;
    }

    .ph-btn {
      align-self: flex-start;

      padding: 9px 14px;

      background: linear-gradient(135deg,#00c853,#00b0ff);
      color: white;

      border-radius: 10px;

      text-decoration: none;
      font-weight: bold;
      font-size: 13px;
    }
    `;
    document.head.appendChild(style);

    // ---------- CREATE ELEMENT ----------
    const ad = document.createElement("div");
    ad.className = "ph-ad hidden";

    ad.innerHTML = `
      <div class="ph-bg">
        <img id="ph-img">
      </div>

      <div class="ph-overlay">
        <button class="ph-close">✕</button>

        <div class="ph-text">
          <h2 id="ph-title"></h2>
          <p id="ph-desc"></p>
        </div>

        <a class="ph-btn" id="ph-btn" target="_blank"></a>
      </div>
    `;

    document.body.appendChild(ad);

    const img = ad.querySelector("#ph-img");
    const title = ad.querySelector("#ph-title");
    const desc = ad.querySelector("#ph-desc");
    const btn = ad.querySelector("#ph-btn");
    const close = ad.querySelector(".ph-close");

    let timer = null;

    // ---------- WEIGHTED PICK ----------
    function pick(ads) {
      let total = ads.reduce((a, b) => a + b.chance, 0);
      let r = Math.random() * total;

      for (let a of ads) {
        if (r < a.chance) return a;
        r -= a.chance;
      }
      return ads[0];
    }

    // ---------- LOAD ----------
    async function load() {
      try {
        const res = await fetch(AD_URL);
        const ads = await res.json();

        const a = pick(ads);

        img.src = a.banner;
        title.textContent = a.title;
        desc.textContent = a.description;
        btn.textContent = a.button_text;
        btn.href = a.button_link;

        ad.classList.remove("hidden");

        clearTimeout(timer);
        timer = setTimeout(load, 5 * 60 * 1000);

      } catch (e) {
        console.error("Ad load failed", e);
      }
    }

    // ---------- CLOSE ----------
    close.onclick = () => {
      ad.classList.add("hidden");
      clearTimeout(timer);
      setTimeout(load, 5 * 60 * 1000);
    };

    // ---------- OPTIONAL SCROLL FLOAT ----------
    window.addEventListener("scroll", () => {
      if (ad.classList.contains("hidden")) return;
      const offset = window.scrollY * 0.015;
      ad.style.transform = `translateX(-50%) translateY(${offset}px)`;
    });

    load();
  }

  // ---------- SAFE INIT ----------
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }

})();
