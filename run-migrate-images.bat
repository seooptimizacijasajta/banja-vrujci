@echo off
echo Starting image migration...
echo This will download ~176 images from banjavrujci.info and upload to Supabase.
echo Takes about 3-5 minutes. Do NOT close this window.
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0migrate-images.ps1"
