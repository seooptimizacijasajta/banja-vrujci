@echo off
cd /d "C:\Users\banja\Desktop\AI\CLAUDE\banja-vrujci"
del /f /q .git\HEAD.lock 2>nul
del /f /q .git\index.lock 2>nul
git commit -m "SEO fixes: 301 redirects Vila Iva/Ana, fix sitemap hub slugs + blog posts + info-servis"
git push origin main
echo.
echo GOTOVO! Vercel ce za ~2 min deploovati.
pause
