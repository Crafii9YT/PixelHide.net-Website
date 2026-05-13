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

      max-height: 420px;

      object-fit: cover;
    }

    .ph-overlay {
      position: absolute;
      inset: 0;

      display: flex;
      flex-direction: column;
      justify-content: flex-end;

      padding: 18px;

      background: linear-gradient(
        to top,
        rgba(0,0,0,0.75),
        rgba(0,0,0,0.2),
        rgba(0,0,0,0.05)
      );

      color: white;
    }

    .ph-ad-label {
      position: absolute;

      top: 10px;
      right: 14px;

      font-size: 10px;
      font-weight: bold;

      opacity: 0.75;

      background: rgba(0,0,0,0.35);

      padding: 4px 8px;

      border-radius: 999px;

      backdrop-filter: blur(6px);
    }

    .ph-close {
      position: absolute;

      top: 34px;
      right: 12px;

      width: 32px;
      height: 32px;

      border-radius: 50%;
      border: none;

      background: rgba(0,0,0,0.55);

      color: white;

      cursor: pointer;
    }

    .ph-title {
      margin: 0;

      font-size: 26px;
      font-weight: bold;
    }

    .ph-desc {
      margin-top: 7px;

      font-size: 15px;

      opacity: 0.92;

      line-height: 1.45;

      max-width: 700px;
    }

    .ph-btn {
      margin-top: 16px;

      width: fit-content;

      padding: 11px 18px;

      border-radius: 12px;

      background: linear-gradient(135deg,#00c853,#00b0ff);

      color: white;
      text-decoration: none;

      font-weight: bold;
      font-size: 14px;
    }
    `;

    document.head.appendChild(style);

    // ---------- PICK ----------
    function pickAd(ads) {

      let total = ads.reduce((a, b) => a + b.chance, 0);

      let r = Math.random() * total;

      for (let ad of ads) {

        if (r < ad.chance) return ad;

        r -= ad.chance;
      }

      return ads[0];
    }

    // ---------- CREATE ----------
    function createAd(data) {

      const ad = document.createElement("div");

      ad.className = "ph-inline-ad";

      ad.innerHTML = `
        <img src="${data.banner}" alt="Advertisement">

        <div class="ph-overlay">

          <div class="ph-ad-label">
            ANZEIGE
          </div>

          <button class="ph-close">✕</button>

          <h2 class="ph-title">
            ${data.title}
          </h2>

          <div class="ph-desc">
            ${data.description}
          </div>

          <a
            class="ph-btn"
            href="${data.button_link}"
            target="_blank"
          >
            ${data.button_text}
          </a>

        </div>
      `;

      ad.querySelector(".ph-close").onclick = () => {
        ad.remove();
      };

      return ad;
    }

    // ---------- GET CONTENT ----------
    function getBlocks() {

      let blocks = [
        ...document.body.querySelectorAll("div")
      ];

      // nur größere sichtbare content-boxen
      blocks = blocks.filter(el => {

        if (el.classList.contains("ph-inline-ad")) return false;

        if (!el.offsetParent) return false;

        if (el.offsetHeight < 120) return false;

        if (el.innerText.trim().length < 40) return false;

        return true;
      });

      return blocks;
    }

    // ---------- INSERT ----------
    async function loadAds() {

      try {

        const res = await fetch(AD_URL);

        const ads = await res.json();

        // alte entfernen
        document.querySelectorAll(".ph-inline-ad").forEach(a => a.remove());

        const blocks = getBlocks();

        if (blocks.length === 0) return;

        const used = [];

        const amount = Math.min(
          MAX_ADS,
          Math.max(1, Math.floor(blocks.length / 8))
        );

        for (let i = 0; i < amount; i++) {

          let random;

          do {

            random = Math.floor(Math.random() * blocks.length);

          } while (used.includes(random));

          used.push(random);

          const block = blocks[random];

          const adData = pickAd(ads);

          const ad = createAd(adData);

          // direkt zwischen content
          block.insertAdjacentElement("afterend", ad);
        }

      } catch (e) {

        console.error("PixelHide Ads:", e);
      }
    }

    // ---------- START ----------
    loadAds();

    setInterval(loadAds, 5 * 60 * 1000);

  }

  // ---------- INIT ----------
  if (document.readyState === "loading") {

    document.addEventListener("DOMContentLoaded", init);

  } else {

    init();
  }

})();
