# Değişiklik kaydı

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
