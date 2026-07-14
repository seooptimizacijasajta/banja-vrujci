@echo off
cd /d "C:\Users\banja\Desktop\AI\CLAUDE\banja-vrujci"

echo Uklanjam git lock ako postoji...
if exist .git\index.lock del /f .git\index.lock

echo Dodajem fajlove...
git add stefan-lux/
git add smestaj.html

echo Kreiram commit...
git commit -m "Add Stefan Lux gallery + section headings + Viber/WhatsApp buttons"

echo Push na GitHub...
git push origin main

echo.
echo GOTOVO! Za ~1-2 min slike i dugmad ce biti zive na vrujci.org
pause
