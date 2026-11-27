# Claude ↔ OpenCode el sözleşmesi

Bu dosya iki yapay zekâ arasındaki ortak çalışma alanıdır. Claude Code CLI
ücretsiz hesapta çalışmadığı için bağlantı, **Claude Desktop uygulaması**
üzerinden bu dosya ile yapılır.

## Nasıl kullanılır?

1. **OpenCode** aşağıdaki "İstek" bölümünü yazar / günceller.
2. Sen `İstek` bloğunun içini kopyalayıp **Claude Desktop** uygulamasına yapıştırırsın.
3. Claude'un cevabını aynen `Claude cevabı` bölümüne geri yapıştırırsın.
4. **OpenCode** cevabı okur, her bulguyu doğrular, düzeltir, test eder ve
   `OpenCode işlem kaydı` bölümüne yazar; sonra commit + push yapar.

> Not: Claude'a dosya yolu vermen gerekmez; istek bloğu kendi bağlamını içerir.
> İstersen `klavye-testi.ps1` dosyasını da sohbete ekleyebilirsin.

---

## İstek (OpenCode → Claude)

Aşağıdaki kodu bağımsız olarak incele. Amacımız Türkçe Q (KBDTUQ) klavyesinin
104 tuşunu güvenilir şekilde test eden bir WinForms uygulaması. Özellikle şu
konularda gerçek bug arıyorsun:

- `GetAsyncKeyState` yüksek bit kenar algılama + düşük bit yedek mantığı
- `GetKeyState` toggle okuma zamanlaması (DoEvents + 120 ms)
- WinForms yaşam döngüsü: modal ayarlar penceresi, FormClosing, AutoStart
- Ayar dosyası `ConvertFrom-Json` / tip dönüşümleri
- NumLock kapalıyken numpad gezinme kodları (AltVk)
- İptal kısayolu Ctrl+Shift+Q ve kaynak temizliği

Şu ana kadar düzeltilenleri **tekrar önerme**: DropDownItems hatası,
PSCustomObject Add-Member, Dock sırası, ayarlar form yüksekliği, `__NONE__`
sentinel'i, ses varsayılan kapalı, sayısal/boolean clamp, boş ResultPath.

Kaynak dosya: `klavye-testi.ps1` (proje klasöründe).

Lütfen şu formatta cevap ver:

```
[BULGU-1] Dosya/satır veya fonksiyon adı
Sorun: ...
Etkisi: ...
Önerilen düzeltme: ...
Öncelik: Yüksek / Orta / Düşük

[BULGU-2] ...
```

Gerçek bug yoksa sadece "Yeni gerçek bug bulunamadı" yaz. Spekülasyon ve stil
önerilerini ayrı bir "Küçük öneriler" başlığı altında topla.

---

## Claude cevabı (Claude → OpenCode)

<!-- BURAYA CLAUDE'UN CEVABINI YAPISTIR -->

---

## OpenCode işlem kaydı

<!-- OpenCode her bulguyu doğrulayıp uyguladıktan sonra buraya yazar. -->
Durum: Beklemede — Claude cevabı girilmedi.
