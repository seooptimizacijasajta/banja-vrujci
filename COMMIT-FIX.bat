@echo off
cd /d "C:\Users\banja\Desktop\AI\CLAUDE\banja-vrujci"
echo Brisanje svih git lock fajlova...
del /f /q .git\HEAD.lock 2>nul
del /f /q .git\index.lock 2>nul
del /f /q .git\COMMIT_EDITMSG.lock 2>nul
del /f /q .git\MERGE_HEAD.lock 2>nul
del /f /q .git\refs\heads\main.lock 2>nul
del /f /q .git\packed-refs.lock 2>nul

echo.
echo Status:
git status

echo.
echo Committing sve izmene...
git add -A
git commit -m "SEO fixes: redirects Vila Iva/Ana, sitemap, blog posts; admin panel; featured listings; Ana images"
git push origin main

echo.
echo GOTOVO! Vercel ce deploovati za ~2 minuta.
pause
