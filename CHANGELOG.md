# Değişiklik kaydı

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
