(() => {

  function init() {

    const AD_URL = "https://pixelhide.net/ads/advertisements.json";
    const MAX_ADS = 3;

    // ---------- STYLE ----------
    const style = document.createElement("style");
    style.innerHTML = `
    .ph-inline-ad {
      width: min(100%, 950px);

      margin: 42px auto;

      border-radius: 18px;
      overflow: hidden;

      position: relative;

      font-family: Arial, sans-serif;

      box-shadow: 0 15px 50px rgba(0,0,0,0.16);

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
      justify-content: flex-end;

      padding: 18px;

      background: linear-gradient(
        to top,
        rgba(0,0,0,0.78),
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
      letter-spacing: 1px;

      opacity: 0.7;

      background: rgba(0,0,0,0.35);

      padding: 4px 7px;

      border-radius: 999px;

      backdrop-filter: blur(6px);
    }

    .ph-close {
      position: absolute;

      top: 36px;
      right: 12px;

      width: 32px;
      height: 32px;

      border: none;
      border-radius: 50%;

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

      opacity: 0.93;

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

          <div class="ph-ad-label">ANZEIGE</div>

          <button class="ph-close">✕</button>

          <h2 class="ph-title">${data.title}</h2>

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

    // ---------- GET VALID CONTENT BLOCKS ----------
    function getContentBlocks() {

      const selectors = [
        "section",
        "article",
        "main > div",
        ".section",
        ".container",
        ".content",
        ".card",
        ".panel",
        ".box"
      ];

      const blocks = [];

      selectors.forEach(selector => {

        document.querySelectorAll(selector).forEach(el => {

          // ignorieren wenn zu klein
          if (el.offsetHeight < 120) return;

          // keine ads in ads
          if (el.classList.contains("ph-inline-ad")) return;

          // muss sichtbar sein
          if (!el.offsetParent) return;

          blocks.push(el);
        });

      });

      return [...new Set(blocks)];
    }

    // ---------- INSERT ----------
    async function loadAds() {

      try {

        const res = await fetch(AD_URL);

        const ads = await res.json();

        // alte ads entfernen
        document.querySelectorAll(".ph-inline-ad").forEach(a => a.remove());

        const blocks = getContentBlocks();

        if (blocks.length < 3) return;

        // random positions
        const positions = [];

        while (
          positions.length < Math.min(MAX_ADS, Math.floor(blocks.length / 3))
        ) {

          const random = Math.floor(Math.random() * (blocks.length - 1));

          if (!positions.includes(random)) {
            positions.push(random);
          }
        }

        positions.forEach(pos => {

          const block = blocks[pos];

          const adData = pickAd(ads);

          const ad = createAd(adData);

          // BETWEEN CONTENT
          block.insertAdjacentElement("afterend", ad);
        });

      } catch (e) {

        console.error("PixelHide Ads:", e);
      }
    }

    // ---------- START ----------
    loadAds();

    // reload alle 5 minuten
    setInterval(loadAds, 5 * 60 * 1000);

  }

  // ---------- SAFE INIT ----------
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }

})();
