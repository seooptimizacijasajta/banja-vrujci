@echo off
echo Updating Apartmani Ana image URLs in Supabase...

powershell -Command ^
  "$body = '{\"image_url\":\"https://www.vrujci.org/ana/apartman-ana-velika-nova.jpg\",\"gallery_images\":[\"https://www.vrujci.org/ana/apartman-ana-velika-nova.jpg\",\"https://www.vrujci.org/ana/ana2.1.jpg\",\"https://www.vrujci.org/ana/ana1.5.jpg\",\"https://www.vrujci.org/ana/ana1.4.jpg\"]}';" ^
  "$headers = @{apikey='sb_publishable_0NrJlQyn97I7v6IKCLVUdw_uzvKVA4U'; Authorization='Bearer sb_publishable_0NrJlQyn97I7v6IKCLVUdw_uzvKVA4U'; 'Content-Type'='application/json'; Prefer='return=representation'};" ^
  "Invoke-RestMethod -Uri 'https://eckotcmqbpoftcseqzsa.supabase.co/rest/v1/listings?id=eq.20' -Method PATCH -Headers $headers -Body $body | ConvertTo-Json"

echo.
echo Supabase updated! Proveri stranicu:
echo https://www.vrujci.org/apartmani-banja-vrujci/apartmani-ana-banja-vrujci/
pause
