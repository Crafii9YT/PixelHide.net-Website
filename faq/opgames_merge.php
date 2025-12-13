<?php
// Ultra-moderne Docs-Seite mit animierten Effekten, Glasmorphismus und Dark/Light-Mode
// favicon.png wird als Logo und Favicon verwendet
?>
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OPGAMES Merge - PixelHide</title>
    <link rel="icon" type="image/png" href="favicon.png">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap');

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Poppins', sans-serif;
        }
        :root {
            --bg-dark: #0d0d0f;
            --bg-glass: rgba(255, 255, 255, 0.05);
            --text-light: #f9f9f9;
            --accent: #00e0ff;
            --accent2: #0072ff;
        }
        body {
            background: radial-gradient(circle at top left, #0f0f15, #050506);
            color: var(--text-light);
            display: grid;
            grid-template-columns: 270px 1fr;
            grid-template-rows: 80px 1fr 60px;
            grid-template-areas:
                'sidebar header'
                'sidebar content'
                'sidebar footer';
            height: 100vh;
            overflow: hidden;
        }
        header {
            grid-area: header;
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: var(--bg-glass);
            backdrop-filter: blur(20px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            padding: 0 2rem;
            animation: fadeInDown 0.8s ease;
        }
        aside {
            grid-area: sidebar;
            background: var(--bg-glass);
            backdrop-filter: blur(25px);
            padding: 2rem 1rem;
            border-right: 1px solid rgba(255, 255, 255, 0.1);
            overflow-y: auto;
            animation: slideInLeft 0.8s ease;
        }
        main {
            grid-area: content;
            padding: 3rem 4rem;
            overflow-y: auto;
            scroll-behavior: smooth;
            animation: fadeIn 1s ease;
        }
        footer {
            grid-area: footer;
            background: var(--bg-glass);
            backdrop-filter: blur(20px);
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.9rem;
            color: #bbb;
            animation: fadeInUp 0.8s ease;
        }
        .logo {
            display: flex;
            align-items: center;
            gap: 0.8rem;
            font-weight: 600;
            font-size: 1.3rem;
            color: var(--text-light);
        }
        .logo img {
            height: 40px;
            width: 40px;
            border-radius: 10px;
            box-shadow: 0 0 15px rgba(0, 224, 255, 0.3);
        }
        .search-box {
            background: rgba(255, 255, 255, 0.1);
            border-radius: 12px;
            padding: 0.6rem 1rem;
            width: 260px;
            border: none;
            color: #fff;
            outline: none;
            transition: 0.2s;
        }
        .search-box:focus {
            background: rgba(255, 255, 255, 0.2);
            box-shadow: 0 0 10px var(--accent);
        }
        .nav-link {
            display: block;
            padding: 0.8rem 1rem;
            border-radius: 12px;
            margin-bottom: 0.5rem;
            color: #ddd;
            text-decoration: none;
            font-weight: 500;
            position: relative;
            overflow: hidden;
            transition: all 0.3s;
        }
        .nav-link::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, var(--accent), var(--accent2));
            transition: all 0.4s;
            z-index: -1;
        }
        .nav-link:hover::before {
            left: 0;
        }
        .nav-link:hover {
            color: #fff;
            transform: translateX(6px);
        }
        section {
            margin-bottom: 3rem;
            line-height: 1.6;
        }
        h1 {
            font-size: 2.3rem;
            margin-bottom: 1rem;
            background: linear-gradient(90deg, var(--accent), var(--accent2));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .theme-toggle {
            background: rgba(255, 255, 255, 0.1);
            border: none;
            border-radius: 12px;
            padding: 0.5rem 1rem;
            color: #fff;
            cursor: pointer;
            transition: 0.3s;
        }
        .theme-toggle:hover {
            background: rgba(255, 255, 255, 0.2);
        }
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }
        @keyframes fadeInDown {
            from { opacity: 0; transform: translateY(-20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        @keyframes slideInLeft {
            from { opacity: 0; transform: translateX(-40px); }
            to { opacity: 1; transform: translateX(0); }
        }
    </style>
</head>
<body>
    <aside>
        <div class="logo" style="margin-bottom: 2.5rem;">
            <img src="favicon.png" alt="Logo">
            <span>FaQ</span>
        </div>
        <a href="#" class="nav-link">Offizieller OPGAMES Merge</a>
    </aside>

    <header>
        <div class="logo">
            <img src="favicon.png" alt="Logo">
            <span>PixelHide.net</span>
        </div>
        <div style="display: flex; align-items: center; gap: 1rem;">
        </div>
    </header>

    <main>
        <section>
            <h1>Offizieller OPGames Merge</h1>
            <p>Es ist soweit. OPGames wurde offiziell in PixelHide integriert. Nun sind viele Features, die auf OPGames existierten,</p>
            <p>nun auch auf PixelHide verfügbar! Unten seht ihr nun das FaQ.</p> 
        </section>

        <section>
            <h2>Was ist mit OPGames?</h2>
            <p>OPGames existiert so nicht mehr. Fast alle Funktionen wurden von OPGames auf PixelHide gebracht.</p>
        </section>
        <section>
            <h2>Warum wurde OPGames in PixelHide gemerged?</h2>
            <p>OPGames wurde in PixelHide germerged, da OPGames so gut wie unbekannt war, und das Management für den Server einfach nicht mehr reichte.</p>
            <p>Wir wollten unseren Fokus nun voll auf PixelHide setzen, um PixelHide so gut wie möglich an den Neustart zu bringen.</p>
        </section>                                

        <section>
            <h3>Du hast auch eine Frage?</h3>
            <p>Joine unserem Discord Server unter discord.PixelHide.net!</p>
        </section>
    </main>

    <footer>
        © 2025 PixelHide.net
    </footer>

    <script>
        const toggle = document.querySelector('.theme-toggle');
        toggle.addEventListener('click', () => {
            document.body.classList.toggle('light');
            if (document.body.classList.contains('light')) {
                document.documentElement.style.setProperty('--bg-dark', '#f0f0f0');
                document.documentElement.style.setProperty('--bg-glass', 'rgba(255,255,255,0.6)');
                document.documentElement.style.setProperty('--text-light', '#111');
            } else {
                document.documentElement.style.setProperty('--bg-dark', '#0d0d0f');
                document.documentElement.style.setProperty('--bg-glass', 'rgba(255,255,255,0.05)');
                document.documentElement.style.setProperty('--text-light', '#f9f9f9');
            }
        });
    </script>
</body>
</html>
