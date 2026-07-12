# migrate-images.ps1
# Downloads all banjavrujci.info images and uploads them to Supabase Storage.
# Outputs: migrate-images-sql.txt with SQL UPDATE statements to run afterwards.

$SUPABASE_URL = 'https://eckotcmqbpoftcseqzsa.supabase.co'
$ANON_KEY    = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVja290Y21xYnBvZnRjc2VxenNhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE4MTIwMDUsImV4cCI6MjA5NzM4ODAwNX0.76nDrh5iLcqbK9Xdxfg6lidWeaFVBg_o3Oue1aHfT5U'
$BUCKET      = 'site-images'

# All unique banjavrujci.info image URLs to migrate
$ALL_URLS = @(
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/frontpage/Banja_Vrujci1.jpg',
  'https://www.banjavrujci.info/wp-content/uploads/2025/07/apartmani-stefan-lux-spa-centar.jpg',
  'https://www.banjavrujci.info/wp-content/uploads/2025/07/apartman-mira-nove-velika.jpg',
  'https://www.banjavrujci.info/wp-content/uploads/2023/01/apartman-tamara-velika.jpg',
  'https://www.banjavrujci.info/wp-content/uploads/2023/03/apartman-tri-delfina-velika.jpg',
  'https://www.banjavrujci.info/wp-content/uploads/2023/05/apartman-vorteks-velika.jpg',
  'https://www.banjavrujci.info/wp-content/uploads/2026/05/apartman-pakic-velika.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanialfa/apartman-alfa2.6.jpg',
  'https://www.banjavrujci.info/wp-content/uploads/2025/07/apartman-ana-velika-nova.jpg',
  'https://www.banjavrujci.info/wp-content/uploads/2024/06/apartmani-bella-velika.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanblanusa/apartman-blanusa1.jpg',
  'https://www.banjavrujci.info/wp-content/uploads/2023/04/apartmani-jasminka-velika.jpg',
  'https://www.banjavrujci.info/wp-content/uploads/2022/11/Apartmani-Komazec-velika.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/frontpage/Banja-Vrujci1.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanipink/apartman1/apartman-pink1.1.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/frontpage/Banjavrujci-1.jpg',
  'https://www.banjavrujci.info/wp-content/uploads/2023/06/apartman-vesna-izdvojena.jpg',
  'https://www.banjavrujci.info/wp-content/uploads/2022/06/apartman-visnja-velika.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanimaja/majamala.jpg',
  'https://www.banjavrujci.info/wp-content/uploads/2022/07/apartmani-nikolic-dvoriste-velika.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilasuncanibreg/smestaj/apartmani-suncani-breg4.1.jpg',
  'https://www.banjavrujci.info/wp-content/uploads/2023/03/vila-ana-apartmani-velika.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilapetra/petra/vila-petra-nove10.jpg',
  'https://www.banjavrujci.info/wp-content/uploads/2021/07/sobe-desa-filipovic-velika1.jpg',
  'https://www.banjavrujci.info/wp-content/uploads/2023/07/sobe-cica-vulovic-velika.jpg',
  'https://www.banjavrujci.info/wp-content/uploads/2023/03/smestaj-nikita-sprat-velika.jpg',
  'https://www.banjavrujci.info/wp-content/uploads/2021/07/sobe-goca-velika.jpg',
  'https://www.banjavrujci.info/wp-content/uploads/2023/07/brvnara-oaza-mira-velika.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/ivicaimarica/vajati-apartmani/ivica-i-marica-dvoriste-nove1.jpg',
  'https://www.banjavrujci.info/wp-content/uploads/2022/06/vikendica-bane-velika.jpg',
  'https://www.banjavrujci.info/wp-content/uploads/2025/06/vila-amante-apartmani-velika.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilapetra/petra/vila-petra-nove1.jpg',
  'https://www.banjavrujci.info/wp-content/uploads/2023/02/vila-aqua-casa-velika.jpg',
  'https://www.banjavrujci.info/wp-content/uploads/2021/07/vila-elipsa-velika.jpg',
  'https://www.banjavrujci.info/wp-content/uploads/2024/05/vila-ema-apartmani-velika.jpg',
  'https://www.banjavrujci.info/wp-content/uploads/2023/06/vila-iva-izdvojena.jpg',
  'https://www.banjavrujci.info/wp-content/uploads/2022/05/vila-jelena-velika.jpg',
  'https://www.banjavrujci.info/wp-content/uploads/2024/06/vila-sofija-velika.jpg',
  'https://www.banjavrujci.info/wp-content/uploads/2022/07/vila-vila-velika.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanistefanlux/spacentar/apartmani-stefan-lux-spa-centar2.7.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanistefanlux/spacentar/apartmani-stefan-lux-spa-centar1.2.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanistefanlux/spacentar/apartmani-stefan-lux-spa-centar1.5.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanistefanlux/spacentar/apartmani-stefan-lux-spa-centar1.3.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanmira/apartman-mira-novi2.3.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanmira/apartman-mira-novi1.7.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanmira/apartman-mira-novi2.8.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanmira/apartman-mira-novi2.4.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmantamara/apartman-tamara9.5.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmantamara/apartman-tamara2.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmantamara/apartman-tamara9.3.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmantamara/apartman-tamara7.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmantridelfina/apartman-tri-delfina8.1.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmantridelfina/apartman-tri-delfina9.5.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmantridelfina/apartman-tri-delfina9.4.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmantridelfina/apartman-tri-delfina8.4.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanvorteks/apartman-vorteks2.5.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanvorteks/apartman-vorteks2.7.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanvorteks/apartman-vorteks2.4.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanvorteks/apartman-vorteks2.2.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanialfa/apartman-alfa1.7.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanialfa/apartman-alfa1.9.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanialfa/apartman-alfa3.5.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanialfa/apartman-alfa2.8.jpg',
  'https://www.banjavrujci.info/wp-content/uploads/2019/06/apartman-ana-mapa.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanana/apartman-ana-banja-vrujci2.1.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanana/apartman-ana-banja-vrujci1.5.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanana/apartman-ana-banja-vrujci1.4.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanibella/bella1/apartman-bella1-1.7.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanibella/bella1/apartman-bella1-1.2.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanibella/bella1/apartman-bella1-1.4.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanibella/bella1/apartman-bella1-1.8.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanblanusa/apartman-blanusa8.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanblanusa/apartman-blanusa6.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanblanusa/apartman-blanusa5.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanblanusa/apartman-blanusa7.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanblanusa/apartman-blanusa4.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanijasminka/apartman1/apartmani-jasminka1.8.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanijasminka/apartman1/apartmani-jasminka1.9.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanijasminka/apartman1/apartmani-jasminka1.2.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanijasminka/apartman1/apartmani-jasminka1.4.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanikomazec/apartman1/zeleni-apartman5.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanikomazec/apartman1/zeleni-apartman8.1.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanikomazec/apartman1/zeleni-apartman8.3.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanikomazec/apartman1/zeleni-apartman9.1.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanipakic/apartman1/apartmani-pakic1.8.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanipakic/apartman1/apartmani-pakic-novi1.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanipakic/apartman1/apartmani-pakic-novi2.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanipakic/apartman1/apartmani-pakic-novi3.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanipink/apartman1/apartman-pink1.2.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanipink/apartman1/apartman-pink1.4.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanipink/apartman1/apartman-pink1.5.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanipink/apartman1/apartman-pink1.3.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanvesna/apartman-vesna1.8.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanvesna/apartman-vesna2.2.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanvesna/apartman-vesna2.7.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanvesna/apartman-vesna2.3.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanvisnja/apartman1/apartman-visnja-2.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanvisnja/apartman1/apartman-visnja-5.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanvisnja/apartman1/apartman-visnja-4.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmanvisnja/apartman1/apartman-visnja-3.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/oazamira/brvnaraoazamira/oaza-mira-brvnara1.3.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/oazamira/brvnaraoazamira/oaza-mira-brvnara1.7.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/oazamira/brvnaraoazamira/oaza-mira-brvnara2.2.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/oazamira/brvnaraoazamira/oaza-mira-brvnara3.7.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/filipovic/filipovicsobe/sobe-desa-filipovic1.2.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/filipovic/filipovicsobe/sobe-desa-filipovic1.6.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/filipovic/filipovicsobe/sobe-desa-filipovic1.5.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/filipovic/filipovicsobe/sobe-desa-filipovic1.7.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmaninikolic/crveni/crveninikolic4.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmaninikolic/crveni/crveninikolic11.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmaninikolic/crveni/crveninikolic8.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/apartmaninikolic/crveni/apartmani-nikolic-dvoriste2.6.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/smestajnikita/prizemlje/smestaj-nikita-prizemlje2.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/smestajnikita/prizemlje/smestaj-nikita-prizemlje7.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/smestajnikita/prizemlje/smestaj-nikita-prizemlje3.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/smestajnikita/prizemlje/smestaj-nikita-prizemlje5.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/sobegoca/sobe-goca2.2.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/sobegoca/sobe-goca3.1.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/sobegoca/sobe-goca3.2.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/sobegoca/sobe-goca1.9.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/sobecica/kuca/sobe-cica-vulovic-nove-dvoriste1.3.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/sobecica/kuca/sobecica9.1.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/sobecica/kuca/sobe-cica-vulovic-nove-dvoriste1.1.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/sobecica/kuca/sobe-cica-vulovic-nove-dvoriste1.2.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilasuncanibreg/smestaj/apartmani-suncani-breg4.6.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilasuncanibreg/smestaj/apartmani-suncani-breg5.1.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilasuncanibreg/smestaj/apartmani-suncani-breg5.3.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilasuncanibreg/smestaj/apartmani-suncani-breg5.2.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/ivicaimarica/apartmani/ivica-i-marica-nove8.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/ivicaimarica/apartmani/ivica-i-marica-nove9.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/ivicaimarica/apartmani/ivica-i-marica-nove4.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/ivicaimarica/apartmani/ivica-i-marica-nove2.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/ivicaimarica/apartmani/ivica-i-marica-nove1.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vikendicabane/smestaj/vikendica-bane-smestaj8.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vikendicabane/smestaj/vikendica-bane-nova7.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vikendicabane/smestaj/vikendica-bane-smestaj7.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vikendicabane/smestaj/vikendica-bane-smestaj-nova5.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilaamante/apartmani/Slika-7.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilaamante/apartmani/Slika-2.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilaamante/apartmani/vila-amante-apartmani1.4.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilaamante/apartmani/Slika-13.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilaana/vilaana2.3.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilaana/vilaana1.9.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilaana/vilaana2.4.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilaana/vilaana2.1.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilaaquacasa/apartman/vila-aqua-casa-apartman3.5.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilaaquacasa/apartman/vila-aqua-casa-apartman3.93.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilaaquacasa/apartman/vila-aqua-casa-apartman3.6.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilaaquacasa/apartman/vila-aqua-casa-apartman3.7.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilaelipsa/vila-elipsa-nove-2.9.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilaelipsa/vila-elipsa-nove-3.2.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilaelipsa/vila-elipsa-nove-4.5.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilaelipsa/vila-elipsa-nove-2.2.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilaema/vila/vila-ema3.7.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilaema/vila/vila-ema1.1.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilaema/vila/vila-ema2.9.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilaema/vila/vila-ema3.2.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilaiva/banja-vrujci-vila-iva-nove-1.4.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilaiva/banja-vrujci-vila-iva-nove-2.5.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilaiva/banja-vrujci-vila-iva-nove-1.1.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilaiva/banja-vrujci-vila-iva23.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilajelena/vila-jelena-banja-vrujci7.1.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilajelena/vila-jelena-banja-vrujci1.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilajelena/vila-jelena-banja-vrujci8.2.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilajelena/vila-jelena-banja-vrujci9.5.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilapetra/petra/vila-petra-nove11.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilapetra/petra/vila-petra-nove4.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilapetra/petra/vila-petra-nove6.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilasofija/vila/vila-sofija1.4.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilasofija/vila/vila-sofija1.6.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilasofija/vila/vila-sofija1.2.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilasofija/vila/vila-sofija2.7.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilavila/vila-vila-dvoriste6.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilavila/vila-vila-nove6.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilavila/vila-vila-nove1.jpg',
  'https://www.banjavrujci.info/wp-content/rockettheme/rt_panacea_wp/smestaj/vilavila/vilavila3.5.jpg'
)

# Deduplicate
$ALL_URLS = $ALL_URLS | Select-Object -Unique

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$logFile   = Join-Path $scriptDir 'migrate-images-log.txt'
$sqlFile   = Join-Path $scriptDir 'migrate-images-sql.txt'
$mapFile   = Join-Path $scriptDir 'migrate-images-map.json'

# Clear old outputs
'' | Set-Content $logFile
'' | Set-Content $sqlFile
$urlMap = @{}
$failed = @()

function Log($msg) {
    Write-Host $msg
    Add-Content $logFile $msg
}

Log "Starting image migration: $($ALL_URLS.Count) unique URLs"
Log "$(Get-Date)"
Log ''

$i = 0
foreach ($url in $ALL_URLS) {
    $i++
    # Storage path = URL minus the domain
    $storagePath = $url -replace 'https://www\.banjavrujci\.info/', ''

    # Download
    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 30 `
            -Headers @{ 'User-Agent' = 'Mozilla/5.0 (migration-bot)' }
        $imageBytes   = $response.Content
        $contentType  = $response.Headers['Content-Type']
        if (-not $contentType) { $contentType = 'image/jpeg' }
        $contentType = ($contentType -split ';')[0].Trim()
    } catch {
        Log "[$i/$($ALL_URLS.Count)] DOWNLOAD FAIL: $url  $_"
        $failed += $url
        continue
    }

    # Upload to Supabase Storage
    $encodedPath = [Uri]::EscapeDataString($storagePath) -replace '%2F', '/'
    $uploadUrl = "$SUPABASE_URL/storage/v1/object/$BUCKET/$encodedPath"
    try {
        $uploadResp = Invoke-RestMethod -Uri $uploadUrl -Method POST `
            -Headers @{
                'Authorization' = "Bearer $ANON_KEY"
                'Content-Type'  = $contentType
                'x-upsert'      = 'true'
            } `
            -Body $imageBytes
        $newUrl = "$SUPABASE_URL/storage/v1/object/public/$BUCKET/$encodedPath"
        $urlMap[$url] = $newUrl
        Log "[$i/$($ALL_URLS.Count)] OK  $($storagePath.Split('/')[-1])"
    } catch {
        Log "[$i/$($ALL_URLS.Count)] UPLOAD FAIL: $storagePath  $_"
        $failed += $url
    }

    Start-Sleep -Milliseconds 100
}

Log ''
Log "Done. Migrated: $($urlMap.Count)  Failed: $($failed.Count)"

# Save URL map as JSON
$urlMap | ConvertTo-Json -Depth 2 | Set-Content $mapFile
Log "URL map saved to: $mapFile"

# Generate SQL UPDATE statements
$sql = @()
$sql += '-- listings.image_url updates'
foreach ($entry in $urlMap.GetEnumerator()) {
    $oldUrl = $entry.Key -replace "'", "''"
    $newUrl = $entry.Value -replace "'", "''"
    $sql += "UPDATE listings SET image_url = '$newUrl' WHERE image_url = '$oldUrl';"
}
$sql += ''
$sql += '-- site_images.url updates'
foreach ($entry in $urlMap.GetEnumerator()) {
    $oldUrl = $entry.Key -replace "'", "''"
    $newUrl = $entry.Value -replace "'", "''"
    $sql += "UPDATE site_images SET url = '$newUrl' WHERE url = '$oldUrl';"
}
$sql | Set-Content $sqlFile
Log "SQL saved to: $sqlFile"

if ($failed.Count -gt 0) {
    Log ''
    Log 'FAILED URLs:'
    $failed | ForEach-Object { Log "  $_" }
}

Write-Host ''
Write-Host 'Press any key to exit...'
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
