(() => {

  function init() {

    const AD_URL = "https://pixelhide.net/ads/advertisements.json";
    const MAX_ADS = 3;

    // ---------- STYLE ----------
    const style = document.createElement("style");
    style.innerHTML = `
    .ph-inline-ad {
      width: min(100%, 950px);
      margin: 40px auto;
      border-radius: 18px;
      overflow: hidden;
      position: relative;
      font-family: Arial, sans-serif;
      box-shadow: 0 15px 50px rgba(0,0,0,0.18);
      background: #111;
    }

    .ph-inline-ad img {
      width: 100%;
      height: auto;
      display: block;
      object-fit: cover;
      max-height: 420px;
    }

    .ph-overlay {
      position: absolute;
      inset: 0;

      display: flex;
      flex-direction: column;
      justify-content: space-between;

      padding: 18px;

      background: linear-gradient(
        to top,
        rgba(0,0,0,0.72),
        rgba(0,0,0,0.25),
        rgba(0,0,0,0.08)
      );

      color: white;
    }

    .ph-close {
      position: absolute;
      top: 12px;
      right: 12px;

      width: 36px;
      height: 36px;

      border: none;
      border-radius: 50%;

      background: rgba(0,0,0,0.55);
      backdrop-filter: blur(8px);

      color: white;
      cursor: pointer;

      font-size: 15px;
    }

    .ph-content {
      margin-top: auto;
    }

    .ph-title {
      margin: 0;
      font-size: 26px;
      font-weight: bold;
    }

    .ph-desc {
      margin-top: 6px;
      font-size: 15px;
      opacity: 0.92;
      max-width: 700px;
      line-height: 1.4;
    }

    .ph-btn {
      margin-top: 16px;
      display: inline-block;

      padding: 11px 18px;

      border-radius: 12px;

      background: linear-gradient(135deg,#00c853,#00b0ff);

      color: white;
      text-decoration: none;
      font-weight: bold;
      font-size: 14px;
    }

    @media (max-width: 700px) {

      .ph-inline-ad {
        margin: 24px 12px;
      }

      .ph-title {
        font-size: 20px;
      }

      .ph-desc {
        font-size: 13px;
      }

      .ph-btn {
        width: fit-content;
      }
    }
    `;
    document.head.appendChild(style);

    // ---------- WEIGHTED PICK ----------
    function pickAd(ads) {
      let total = ads.reduce((a, b) => a + b.chance, 0);
      let r = Math.random() * total;

      for (let ad of ads) {
        if (r < ad.chance) return ad;
        r -= ad.chance;
      }

      return ads[0];
    }

    // ---------- CREATE AD ----------
    function createAd(adData) {

      const ad = document.createElement("div");
      ad.className = "ph-inline-ad";

      ad.innerHTML = `
        <img src="${adData.banner}" alt="Advertisement">

        <div class="ph-overlay">

          <button class="ph-close">✕</button>

          <div class="ph-content">
            <h2 class="ph-title">${adData.title}</h2>
            <div class="ph-desc">${adData.description}</div>

            <a class="ph-btn"
               href="${adData.button_link}"
               target="_blank">
              ${adData.button_text}
            </a>
          </div>

        </div>
      `;

      ad.querySelector(".ph-close").onclick = () => {
        ad.remove();
      };

      return ad;
    }

    // ---------- INSERT INTO LAYOUT ----------
    async function loadAds() {

      try {

        const res = await fetch(AD_URL);
        const ads = await res.json();

        // mögliche Sektionen suchen
        let sections = [
          ...document.querySelectorAll("section"),
          ...document.querySelectorAll("main > div"),
          ...document.querySelectorAll("article"),
          ...document.querySelectorAll(".section"),
          ...document.querySelectorAll(".container")
        ];

        // fallback
        if (sections.length === 0) {
          sections = [...document.body.children];
        }

        // nicht zu wenig
        if (sections.length < 2) return;

        // existierende ads löschen
        document.querySelectorAll(".ph-inline-ad").forEach(e => e.remove());

        // max ads berechnen
        const amount = Math.min(
          MAX_ADS,
          Math.max(1, Math.floor(sections.length / 4))
        );

        const usedIndexes = [];

        for (let i = 0; i < amount; i++) {

          let randomIndex;

          do {
            randomIndex = Math.floor(Math.random() * (sections.length - 1));
          }
          while (usedIndexes.includes(randomIndex));

          usedIndexes.push(randomIndex);

          const selectedAd = pickAd(ads);

          const adElement = createAd(selectedAd);

          sections[randomIndex].after(adElement);
        }

      } catch (e) {
        console.error("PixelHide Ads Error:", e);
      }
    }

    // ---------- START ----------
    loadAds();

    // reload alle 5 min
    setInterval(loadAds, 5 * 60 * 1000);

  }

  // ---------- SAFE INIT ----------
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }

})();
