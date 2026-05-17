(() => {

  // 🔥 verhindert doppelte Initialisierung
  if (window.__pixelhide_ads_loaded) return;
  window.__pixelhide_ads_loaded = true;

  function init() {

    const AD_URL = "https://www.pixelhide.net/ads/advertisements.json";

    const MAX_ADS = 2;

    const INITIAL_DELAY = 1000;
    const RELOAD_TIME = 5 * 60 * 1000;

    // ---------- STYLE ----------
    const style = document.createElement("style");

    style.innerHTML = `
    .ph-inline-ad{
      width:min(100%,950px);
      margin:56px auto;

      border-radius:18px;
      overflow:hidden;

      position:relative;

      font-family:Arial,sans-serif;

      box-shadow:0 15px 50px rgba(0,0,0,.18);

      background:#111;

      animation:phFade .45s ease;
    }

    @keyframes phFade{
      from{opacity:0;transform:translateY(18px);}
      to{opacity:1;transform:translateY(0);}
    }

    .ph-inline-ad img{
      width:100%;
      display:block;
      max-height:420px;
      object-fit:cover;
    }

    .ph-overlay{
      position:absolute;
      inset:0;

      display:flex;
      flex-direction:column;
      justify-content:flex-end;

      padding:18px;

      background:linear-gradient(
        to top,
        rgba(0,0,0,.78),
        rgba(0,0,0,.22),
        rgba(0,0,0,.05)
      );

      color:white;
    }

    .ph-ad-label{
      position:absolute;
      top:10px;
      right:14px;

      font-size:10px;
      font-weight:bold;

      opacity:.75;

      background:rgba(0,0,0,.35);

      padding:4px 8px;

      border-radius:999px;

      letter-spacing:1px;

      backdrop-filter:blur(6px);
    }

    .ph-close{
      position:absolute;
      top:34px;
      right:12px;

      width:32px;
      height:32px;

      border:none;
      border-radius:50%;

      background:rgba(0,0,0,.55);

      color:white;

      cursor:pointer;
    }

    .ph-title{
      margin:0;
      font-size:26px;
      font-weight:bold;
    }

    .ph-desc{
      margin-top:7px;
      font-size:15px;
      line-height:1.45;
      opacity:.92;
      max-width:700px;
    }

    .ph-btn{
      margin-top:16px;

      width:fit-content;

      padding:11px 18px;

      border-radius:12px;

      background:linear-gradient(135deg,#00c853,#00b0ff);

      color:white;
      text-decoration:none;

      font-weight:bold;
      font-size:14px;
    }
    `;

    document.head.appendChild(style);

    // ---------- PICK ----------
    function pickAd(ads){

      let total = ads.reduce((a,b)=>a+b.chance,0);
      let r = Math.random() * total;

      for(const ad of ads){
        if(r < ad.chance) return ad;
        r -= ad.chance;
      }

      return ads[0];
    }

    // ---------- CREATE ----------
    function createAd(data){

      const ad = document.createElement("div");
      ad.className = "ph-inline-ad";

      ad.innerHTML = `
        <img src="${data.banner}">

        <div class="ph-overlay">

          <div class="ph-ad-label">ANZEIGE</div>

          <button class="ph-close">✕</button>

          <h2 class="ph-title">${data.title}</h2>

          <div class="ph-desc">${data.description}</div>

          <a class="ph-btn" href="${data.button_link}" target="_blank">
            ${data.button_text}
          </a>

        </div>
      `;

      ad.querySelector(".ph-close").onclick = () => ad.remove();

      return ad;
    }

    // ---------- VALID TARGETS ----------
    function getTargets(){

      return [...document.body.children].filter((el,index)=>{

        if(el.classList.contains("ph-inline-ad"))
          return false;

        if(el.tagName === "SCRIPT" || el.tagName === "STYLE")
          return false;

        if(index < 3)
          return false;

        if(el.offsetHeight < 120)
          return false;

        const cls = (el.className || "").toLowerCase();

        if(
          cls.includes("header") ||
          cls.includes("navbar") ||
          cls.includes("nav") ||
          cls.includes("top") ||
          cls.includes("banner") ||
          cls.includes("hero") ||
          cls.includes("menu")
        )
          return false;

        return true;
      });
    }

    // ---------- RANDOM COUNT ----------
    function randomAmount(){
      return Math.random() < 0.6 ? 1 : 2;
    }

    // ---------- LOAD ----------
    async function loadAds(){

      try{

        const res = await fetch(AD_URL);
        const ads = await res.json();

        // 💀 HARD RESET: NIE mehr als 2 möglich
        document
          .querySelectorAll(".ph-inline-ad")
          .forEach(el => el.remove());

        const targets = getTargets();

        if(targets.length < 3) return;

        const amount = Math.min(MAX_ADS, randomAmount());

        const used = [];

        for(let i = 0; i < amount; i++){

          let index;
          let tries = 0;

          do{
            index = Math.floor(Math.random() * targets.length);
            tries++;
          }
          while(used.includes(index) && tries < 30);

          used.push(index);

          const ad = createAd(pickAd(ads));

          targets[index].insertAdjacentElement("afterend", ad);
        }

      }catch(e){
        console.error("PixelHide Ads:", e);
      }
    }

    // ---------- START ----------
    setTimeout(() => {
      loadAds();
      setInterval(loadAds, RELOAD_TIME);
    }, INITIAL_DELAY);

  }

  if(document.readyState === "loading"){
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }

})();
