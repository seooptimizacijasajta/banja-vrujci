@echo off
cd /d "C:\Users\banja\Desktop\AI\CLAUDE\banja-vrujci"
echo Downloading Apartmani Ana images...
mkdir ana 2>nul

powershell -Command "Invoke-WebRequest -Uri 'https://www.banjavrujci.info/wp-content/uploads/2025/07/apartman-ana-velika-nova.jpg' -OutFile 'ana\apartman-ana-velika-nova.jpg' -UserAgent 'Mozilla/5.0'"
powershell -Command "Invoke-WebRequest -Uri 'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanana/ana2.1.jpg' -OutFile 'ana\ana2.1.jpg' -UserAgent 'Mozilla/5.0'"
powershell -Command "Invoke-WebRequest -Uri 'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanana/ana1.5.jpg' -OutFile 'ana\ana1.5.jpg' -UserAgent 'Mozilla/5.0'"
powershell -Command "Invoke-WebRequest -Uri 'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanana/ana1.4.jpg' -OutFile 'ana\ana1.4.jpg' -UserAgent 'Mozilla/5.0'"

echo.
echo Checking downloaded files:
dir ana\

echo.
del /f /q .git\HEAD.lock 2>nul
del /f /q .git\index.lock 2>nul
git add ana\
git commit -m "Add Apartmani Ana images locally (fix hotlink protection)"
git push origin main

echo.
echo GOTOVO! Vercel ce za ~2 min deploovati slike.
echo Zatim pokrenite UPDATE-ANA-SUPABASE.bat da azurirate Supabase.
pause
