(() => {

  function init() {

    const AD_URL = "https://pixelhide.net/ads/advertisements.json";

    // max 2 ads
    const MAX_ADS = 2;

    // langsamer start
    const INITIAL_DELAY = 5000;

    // reload
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
      from{
        opacity:0;
        transform:translateY(20px);
      }
      to{
        opacity:1;
        transform:translateY(0);
      }
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

      backdrop-filter:blur(6px);

      letter-spacing:1px;
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

      background:linear-gradient(
        135deg,
        #00c853,
        #00b0ff
      );

      color:white;
      text-decoration:none;

      font-weight:bold;
      font-size:14px;
    }
    `;

    document.head.appendChild(style);

    // ---------- PICK ----------
    function pickAd(ads){

      let total =
        ads.reduce((a,b)=>a+b.chance,0);

      let r =
        Math.random() * total;

      for(const ad of ads){

        if(r < ad.chance)
          return ad;

        r -= ad.chance;
      }

      return ads[0];
    }

    // ---------- CREATE ----------
    function createAd(data){

      const ad =
        document.createElement("div");

      ad.className =
        "ph-inline-ad";

      ad.innerHTML = `
        <img src="${data.banner}">

        <div class="ph-overlay">

          <div class="ph-ad-label">
            ANZEIGE
          </div>

          <button class="ph-close">
            ✕
          </button>

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

      ad.querySelector(".ph-close")
        .onclick = () => ad.remove();

      return ad;
    }

    // ---------- TARGETS ----------
    function getTargets(){

      return [...document.body.children]
        .filter((el,index)=>{

          // keine ads
          if(
            el.classList.contains(
              "ph-inline-ad"
            )
          )
            return false;

          // keine scripts/styles
          if(
            el.tagName === "SCRIPT" ||
            el.tagName === "STYLE"
          )
            return false;

          // nicht ganz oben
          if(index < 3)
            return false;

          // kleine elemente ignorieren
          if(el.offsetHeight < 100)
            return false;

          const cls =
            (
              el.className || ""
            )
            .toString()
            .toLowerCase();

          const id =
            (
              el.id || ""
            )
            .toLowerCase();

          // KEINE header/banner/navbar
          if(
            cls.includes("header") ||
            cls.includes("banner") ||
            cls.includes("hero") ||
            cls.includes("navbar") ||
            cls.includes("topbar") ||
            cls.includes("nav") ||
            cls.includes("menu") ||
            id.includes("header") ||
            id.includes("banner") ||
            id.includes("hero") ||
            id.includes("nav")
          )
            return false;

          return true;
        });
    }

    // ---------- LOAD ----------
    async function loadAds(){

      try{

        const res =
          await fetch(AD_URL);

        const ads =
          await res.json();

        // alte ads entfernen
        document
          .querySelectorAll(".ph-inline-ad")
          .forEach(el => el.remove());

        const targets =
          getTargets();

        if(targets.length < 3)
          return;

        // manchmal 1 manchmal 2
        const amount =
          Math.random() < 0.55
            ? 1
            : 2;

        const used = [];

        for(
          let i = 0;
          i < amount;
          i++
        ){

          let index;

          let tries = 0;

          do{

            index =
              Math.floor(
                Math.random() *
                targets.length
              );

            tries++;

          }
          while(
            (
              used.some(
                u =>
                  Math.abs(u - index) < 3
              )
            ) &&
            tries < 50
          );

          used.push(index);

          const target =
            targets[index];

          const ad =
            createAd(
              pickAd(ads)
            );

          target.insertAdjacentElement(
            "afterend",
            ad
          );
        }

      }catch(e){

        console.error(
          "PixelHide Ads:",
          e
        );
      }
    }

    // ---------- START ----------
    setTimeout(() => {

      loadAds();

      setInterval(
        loadAds,
        RELOAD_TIME
      );

    }, INITIAL_DELAY);

  }

  // ---------- INIT ----------
  if(
    document.readyState ===
    "loading"
  ){

    document.addEventListener(
      "DOMContentLoaded",
      init
    );

  }else{

    init();
  }

})();
