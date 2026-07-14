@echo off
cd /d "C:\Users\banja\Desktop\AI\CLAUDE\banja-vrujci"

echo Brisem sve lock fajlove...
del /f /q .git\index.lock 2>nul
del /f /q .git\HEAD.lock 2>nul
del /f /q .git\config.lock 2>nul

echo Ucitavam bundle sa svim promenama...
git fetch stefan-push.bundle main:bundle-main

echo Mergeujem u main...
git merge bundle-main --no-edit

echo Push na GitHub...
git push origin main

echo.
echo GOTOVO! Vercel ce za ~2 min deploovati.
pause
