KLAVYE TESTİ MERKEZİ v4
=======================

Dosyalar
--------
klavye-testi.vbs   :Çift tıklayarak uygulamayı başlatır (konsol penceresi görünmez).
klavye-testi.ps1   :Asıl uygulama (menü, ayarlar, test motoru, sonuç tablosu).
klavye-testi-sonucu.txt : Son testin sonucu (her testte üzerine yazılır).
klavye-testi-ayarlar.json : Ayarlar kaydedildiğinde otomatik oluşur.
README.txt         :Bu dosya.

Kullanım
--------
0) Masaüstündeki "Klavye Testi" kısayoluna çift tıkla (önerilen). Konsol/cmd
   pencereleri tamamen gizli açılır; sadece uygulama görünür.
   Klasör içindeki klavye-testi.vbs de aynı işi yapar.
1) klavye-testi.vbs dosyasına çift tıkla.
2) "▶ Başlat" düğmesine bas veya Test > Başlat seçeneğini kullan.
3) Açılan küçük pencerede sadece "BAS:" yazan tuşa bas.
4) CapsLock / NumLock / ScrollLock için LED'e değil, ekrandaki TOGGLE kaydına bak.
5) Testi iptal etmek için Ctrl + Shift + Q.

Menüler
-------
Dosya  : Sonucu aç, farklı kaydet, çıkış.
Test   : Başlat, Durdur, Sonuçları temizle.
Ayarlar: Süreler, ipucu penceresi konumu/boyutu, sonuç yolu, ses, tema,
         kilit onay süresi, algılama hızı, otomatik başlatma ve tuş listesi.
Yardım : Kullanım ve hakkında.

Ses
---
Sesli geri bildirim varsayılan olarak KAPALIdır; test sırasında Windows uyarı
sesi duyulmaz. İstersen Ayarlar > "Sesli geri bildirim" kutusunu işaretle.

İmza
----
Uygulamanın sağ alt köşesinde: "Made by jaNNberk" / "With help of Opencode and Copilot ;)".

Notlar
------
- Fn tuşu Windows'a bildirilmediği için algılanamaz; "Sağ Win" olarak görünen
  tuş aslında Fn'dir. Bu bir arıza değildir.
- Numpad Enter, ana Enter ile aynı VK kodunu gönderir; ayrı test edilmez.
- NumLock kapalıysa numpad gezinme kodları da geçerli sayılır.
- Kaynak: kbdlayout.info/KBDTUQ ve Microsoft GetAsyncKeyState dokümanı.
