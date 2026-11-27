KLAVYE TESTİ MERKEZİ v5
=======================

Dosyalar
--------
Klavye Testi.exe        : Tek tıkla çalışan sürüm (önerilen).
klavye-testi.ps1        : Asıl uygulama (menü, ayarlar, test motoru, sonuç tablosu).
klavye-testi.vbs        : Konsol penceresi göstermeden başlatan gizli VBS.
klavye-testi.ico        : Uygulama simgesi.
klavye-testi-sonucu.txt : Son testin sonucu (her testte üzerine yazılır).
klavye-testi-ayarlar.json : Ayarlar kaydedildiğinde otomatik oluşur.
README.txt              : Bu dosya.
README.md               : GitHub açılış sayfası (görsellerle birlikte).
CHANGELOG.md            : Sürüm geçmişi.

Kullanım
--------
0) Masaüstündeki "Klavye Testi" kısayoluna veya "Klavye Testi.exe" dosyasına
   çift tıkla (önerilen). Konsol/cmd pencereleri görünmez; sadece uygulama açılır.
1) "▶ Başlat" düğmesine bas veya Test > Başlat seçeneğini kullan.
2) Açılan küçük pencerede yalnızca "BAS:" yazan tuşa bas.
3) CapsLock / NumLock / ScrollLock için LED'e değil, ekrandaki TOGGLE kaydına bak.
4) Testi iptal etmek için Ctrl + Shift + Q; durdurmak için "■ Durdur".

Sonuçlar sekmesi tabloyu, Klavye sekmesi renkli tuş haritasını, Olay Kaydı
sekmesi ayrıntılı satırları gösterir. Basılması gereken tuş turkuaz, doğru
basılan tuş yeşil, kaçırılan tuş kırmızıdır.

Menüler
-------
Dosya  : Sonucu aç, farklı kaydet, çıkış.
Test   : Başlat, Durdur, Sonuçları temizle.
Ayarlar: Süreler, ipucu penceresi konumu/boyutu, sonuç yolu, ses, tema,
         kilit onay süresi, algılama hızı ve tuş listesi.
Yardım : Kullanım ve hakkında.

Ses
---
Sesli geri bildirim varsayılan olarak KAPALIDIR; test sırasında Windows uyarı
sesi duyulmaz. İstersen Ayarlar > "Sesli geri bildirim" kutusunu işaretle.

İmza
----
Uygulamanın sağ alt köşesinde: "Made by jaNNberk" / "With help of Opencode and
Copilot ;)".

Notlar
------
- Fn tuşu Windows'a bildirilmediği için sınanamaz. "Sağ Win (varsa; Fn değil)"
  seçeneği yalnızca gerçek Sağ Win tuşu olan klavyeler içindir; Fn'in yerine
  geçmez.
- Numpad Enter, ana Enter ile aynı VK kodunu gönderir; ayrı test edilmez.
- NumLock kapalıysa numpad gezinme kodları da geçerli sayılır.
- Görece sonuç yolu uygulama klasörüne göre çözümlenir; yol boşsa varsayılan
  kullanılır.

Kaynak: kbdlayout.info/KBDTUQ ve Microsoft GetAsyncKeyState belgeleri.
