# Değişiklik kaydı

## v5.3 — Ekran görüntüleri düzeltildi

- `ekran-goruntusu.png` ve `klavye-haritasi.png` yanlışlıkla uygulama yerine
  masaüstünü gösteriyordu: eski üretim scripti `CopyFromScreen` kullanıyor ve
  form öne geçmeden kare alıyordu.
- Görüntüler yeniden üretildi: form öne alınıyor, `PrintWindow` ile pencere
  içeriği doğrudan okunuyor ve koyu piksel oranıyla doğrulanıyor.
- Doğrulama: her iki görselde uygulamanın tam turkuaz `(0,166,166)`, koyu zemin
  `(32,32,32)` ve klavye tuşu `(45,45,45)` renkleri mevcut. `demo.gif` kontrol
  edildi; masaüstü değil uygulama karelerini içeriyor, değiştirilmedi.

## v5.2 — GitHub Releases ve demo GIF

- `demo.gif` eklendi: boş durum, sonuç tablosu, renkli klavye haritası ve
  tamamlanmış test akışını gösteren 7 karelik kısa animasyon.
- README'ye demo görseli ve son sürümü indirme bağlantısı eklendi.
- GitHub Releases'da `v5.2` sürümü oluşturuldu; `Klavye Testi.exe` sürüm
  varlığı olarak yüklendi.

## v5.1 — Yeni UI için ortak bug turu (OpenCode + Copilot)

v5'te eklenen görsel öğeler hedef alındı. Copilot statik/UI, OpenCode dinamik
harness ve piksel testi yürüttü; bulgular karşılıklı doğrulandı.

- **z-order hatası (OpenCode):** WinForms'ta `Controls[0]` üstte olduğu için
  eklenen yüzde etiketi ProgressBar'ın, boş durum etiketi de sonuç tablosunun
  **arkasında** kalıyordu; yani hiç görünmüyorlardı. İkisine de
  `BringToFront()` eklendi. Kanıt: görünürlük açılıp kapatıldığında piksel farkı
  **0 → 228** ve **0 → 5359**. Copilot bulguyu bağımsız olarak **REAL** onayladı.
- **Yüzde/bar çakışması (OpenCode, önceki maddenin yan etkisi):** Şeffaf Label,
  barın dolgusunu kendi arka planıyla kapatıyordu. Yüzde ve ProgressBar iki ayrı
  sütuna alındı; satır yüksekliği 20 px'e sabitlendi, kenar boşlukları sıfırlandı
  (ölçüm: panel 980×20, yüzde 46×20, bar 934×20).
- **Türkçe yazım (Copilot):** İpucu metinlerindeki `Sol ust`, `saginda`,
  `gorunmez`, `sagi`, `alti`, `kaydina`, `0'in` gibi ASCII transliterasyonları
  düzeltildi (`Sol üst`, `sağında`, `görünmez`, `sağı`, `altı`, `kaydına`,
  `0'ın`). Ayarlar etiketindeki `varsayilan kapali` → `varsayılan kapalı`.
- **Doküman (OpenCode):** README'de tekrar eden "Sonuçlar Sonuçlar" ifadesi
  düzeltildi. EXE ve ekran görüntüleri güncel kaynaktan yeniden üretildi.

Doğrulama: 104 tuş / 104 harita, yinelenen ad 0, boş yazı 0, hücre taşması 0
(57 px hücre), durum geçişleri, devre dışı tuş renkleri, kısayoldan açılış
(1 EXE / 0 conhost), README görselleri ve tüm eski harness'lar `exit=0`.
Gerçek sonuç dosyası korundu.

## v5 — Görsel klavye haritası, EXE ve GitHub sunumu

- **Klavye sekmesi:** 104 tuşun tamamı fiziksel satırlara göre 7 × 17 ızgarada
  gösteriliyor. Beklenen tuş turkuaz, geçen tuş yeşil, kaçırılan tuş kırmızı,
  devre dışı tuş gri; `Reset-KeyMap` tema değişiminde ve temizlemede çalışıyor.
- **Hızlı rötuş:** `Segoe UI` yazı tipi, turkuaz vurgu rengi, kalın **Başlat**
  düğmesi, yüzdeli ilerleme çubuğu ve test öncesi boş durum mesajı eklendi.
- **Simge:** 32 × 32 `klavye-testi.ico` üretildi; forma ve masaüstü kısayoluna
  bağlandı.
- **EXE:** `ps2exe` ile `Klavye Testi.exe` derlendi. Konsol açmıyor, gizli
  başlatıcıya gerek duymuyor. Uygulama klasörü artık EXE içinde de doğru
  çözülüyor (`GetCommandLineArgs()[0]` yedeği). Masaüstü kısayolu artık EXE'yi
  doğrudan açıyor; aradaki VBS/PowerShell zinciri kaldırıldı.
- **GitHub:** `README.md` görsellerle yeniden yazıldı; `ekran-goruntusu.png` ve
  `klavye-haritasi.png` eklendi. Türkçe büyük/küçük harf ve Fn/Sağ Win notu
  düzeltildi; repo herkese açık hale getirildi.
- Kaynak dosya hâlâ **doğruluk kaynağıdır**; EXE onun derlenmiş kopyasıdır.

Doğrulama: 104 tuşluk harita ve renk durumları harness ile, EXE açılışı
(konsol yok, stderr/stdout boş) gerçek çalıştırma ile, görseller 980 × 640
olarak kaydedildi. v4.4 testleri tekrar geçti.

## v4.4 — Ortak bug avı (OpenCode + Copilot)

Copilot yalnızca tuş motorunu, OpenCode yalnızca UI/ayar/sonuç katmanını
inceledi; bulgular karşılıklı gönderilip çapraz doğrulandı. Tekrar eden kök
neden bulunmadı.

- **NumLock yarışı (Copilot):** `Wait-Key` artık ana tuş koduyla birlikte
  numpad alternatif kodunu da izliyor. NumLock bekleme sırasında ON↔OFF
  değişirse geçerli basış artık kaçmıyor (mock testi: eski `False`, yeni `True`).
- **Ayarlar güvenliği (OpenCode):** test sürerken Ayarlar / Sıfırla / Temizle
  kontrolleri kilitleniyor ve ikinci bir `Test-SettingsAllowed` koruması var.
  Modal pencere artık `DoEvents` döngüsünü durdurup tuşları kaçıramıyor.
- **Farklı kaydet (OpenCode):** geçersiz/kilitli yolda hata artık try/catch ile
  gösteriliyor; WinForms olay handler'ında fırlayıp uygulamayı düşürmüyor.
- **Sonuç yolu (OpenCode):** yeni `Resolve-ResultPath` hem boş yolu varsayılana
  çeviriyor hem görece yolu uygulama klasörüne çözümlüyor. Aynı fonksiyon
  `Load-Config` ve ayarlar penceresi tarafından kullanılıyor (tek çözüm).

Doğrulama: 104/104 uçtan uca, 2/2 alt küme, iptal, abort (5 sn → 0 ms),
düşük-bit yedek, toggle kurtarma, uyuşmazlık kaydı, bozuk ayar dosyası,
UI geometrisi, gizli launcher, gerçek GUI (stderr/stdout boş). Gerçek sonuç
dosyası korundu.

## v4.3 — İmza güncellemesi

- Sağ alt köşedeki ikinci imza satırı artık **"With help of Opencode and
  Copilot ;)"**; birinci satır **"Made by jaNNberk"** aynen kaldı.
- Hakkında penceresi ve `README.txt` aynı metinle güncellendi.
- Doğrulama: 7 pt font, panel genişliği 210 px, metin ölçümü 161.9 px (taşma
  yok), syntax/BOM, abort ve 104/104 simülasyon geçti.

## v4.2 — Copilot bağımsız denetimi ve durdurma gecikmesi düzeltmesi

- GitHub Copilot CLI (ücretsiz GitHub hesabıyla) bağımsız kod denetimcisi olarak
  bağlandı; Claude Handoff dosyası kaldırıldı.
- **Düzeltilen gerçek bug:** `Wait-Key`-polling döngüsü `$script:abort` bayrağını
  kontrol etmiyordu. Test sırasında **Durdur**'a basmak veya pencereyi kapatmak,
  o tuşun 60 saniyeye varan timeout'u bitene kadar etkisiz kalıyordu. Artık döngü
  her adımda abort'u kontrol ediyor ve anında çıkıyor (ölçüm: 5 sn → 0 ms).
- Doğrulama: abort senaryosu, syntax/BOM, 104/104 uçtan uca simülasyon, alt
  küme/iptal senaryoları, bozuk ayar dosyası, UI geometrisi ve gizli launcher —
  hepsi geçti.

## v4.1 — Ayar dosyası sağlamlaştırma ve derin bug testi

- Bozuk / elle düzenlenmiş `klavye-testi-ayarlar.json` dosyasındaki sayısal
  değerler artık geçerli aralığa sıkıştırılıyor (ör. `PollMs = -1` artık
  `Start-Sleep` hatasına yol açmıyor).
- `"false"` / `"0"` gibi metin boolean'lar doğru şekilde `false` yorumlanıyor;
  PowerShell'de boş olmayan her string `true` sayıldığı için ses istenmeden
  açılabiliyordu.
- `ResultPath` boşsa varsayılan yol artık ortak `Get-DefaultResultPath`
  fonksiyonundan alınıyor. Önceden `Load-Config`, başka fonksiyonun yerel
  değişkenine erişmeye çalışıyor ve yolu boş bırakıyordu.

### Ek doğrulama senaryoları

- Düşük bit yedek algılama (yüksek bit hiç set edilmezse): geçti.
- Toggle kurtarma (tuş algılanmasa da kilit durumu değiştiyse OK): geçti.
- Yanlış özel tuş uyuşmazlık kaydı: geçti.
- Bozuk ayar dosyası (negatif/değer dışı/string boolean/boş yol): geçti.
- Statik bütünlük: 104 adım, yinelenen ad veya VK yok, 12/12 özel tuş kapsanıyor.
- Gerçek GUI açılışı: stderr/stdout boş.

## v4 — Klavye Testi Merkezi (ilk yayın)

- Tam WinForms arayüz: menü çubuğu (Dosya / Test / Ayarlar / Yardım), araç çubuğu,
  canlı sonuç tablosu, olay kaydı, ilerleme çubuğu ve istatistik paneli.
- 104 adımlık test sırası **klavyedeki fiziksel sıraya** göre; Türkçe Q (KBDTUQ)
  özel tuş eşlemeleri kbdlayout.info kaynaklı.
- `GetAsyncKeyState` ile yüksek bit kenar algılama + düşük bit yedek; 2 ms polling.
- Toggle tuşları için `DoEvents + 120 ms + DoEvents` sonrası `GetKeyState` okuması.
- NumLock kapalıyken numpad gezinme kodları kabul edilir.
- Fn ve Numpad Enter Windows'a ayrı kod göndermediği için test edilmez;
  "Sağ Win (varsa; Fn değil)" isteğe bağlı olarak işaretlenir.
- İptal kısayolu: **Ctrl + Shift + Q**.
- Ayarlar: bekleme süresi, kilit onay süresi, örnekleme aralığı, ipucu penceresi
  konumu/boyutu/her zaman üstte, sonuç yolu, ses, tema, otomatik kaydet,
  otomatik başlatma, NumLock davranışı ve düzenlenebilir 104 tuş listesi.
- Masaüstünde tek kısayol: `Klavye Testi.lnk` → gizli VBS → gizli PowerShell;
  cmd/shell penceresi görünmez.
- Sağ alt köşede imza: **Made by jaNNberk** / *With help of Opencode*.
- Sesli geri bildirim varsayılan olarak kapalı.

### Bu sürümde düzeltilen hatalar

- `ToolStripMenuItem` alt menüleri `Items` yerine `DropDownItems` ile ekleniyordu.
- `PSCustomObject`'a sonradan özellik atanamıyordu; `Add-Member` kullanıldı.
- Kısayol tuşu string olarak verilmişti; `System.Windows.Forms.Keys` enum'una çevrildi.
- İmza panelinde Dock sırası yanlıştı; istatistik yazısı imzayı kapatıyordu.
- Ayarlar formu 620 px idi; Tamam/İptal butonları görünmüyordu (850 px + AutoScroll).
- Tuş listesi tamamen boş bırakılırsa bütün tuşlar geri geliyordu; `__NONE__` eklendi.
- Devre dışı tuşlar sonuç dosyasında listelenmiyordu.
- Test sürerken uygulama kapatılırsa dispose edilmiş kontrollere yazılıyordu.
- İptal sonrası test edilmeyen tuşlar "algılanmadı" sanılıyordu; ayrı başlık eklendi.
- Geçersiz ayar değerleri `NumericUpDown` değer aralığını aşabiliyordu.
- `Temizle` sonrası eski sonuç "farklı kaydet"te kalabiliyordu.

## Doğrulama

- PowerShell sözdizimi ve UTF-8 BOM kontrolü: geçti.
- 104 adım, tekrar eden sanal tuş kodu yok.
- Sahte tuş simülasyonu: 104/104 satır; alt küme senaryosu: 2/2;
  iptal senaryosu ve ayarlar kaydetme senaryosu: geçti.
- Gerçek GUI açılışı: stderr/stdout boş.
