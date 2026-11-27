# Klavye Testi Merkezi v4 - tam WinForms uygulamasi
# onceki surum: rehberli-tus-testi-v3.ps1 (artik gerekli degil, klasore tasinmadi).
# Kaynak: kbdlayout.info/KBDTUQ + Microsoft GetAsyncKeyState/GetKeyState dokumanlari.
# Cift tiklama icin: klavye-testi.vbs (ayni klasorde)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class KBApp4 {
    [DllImport("user32.dll")] public static extern short GetAsyncKeyState(int vKey);
    [DllImport("user32.dll")] public static extern short GetKeyState(int nVirtKey);
    [DllImport("kernel32.dll")] public static extern bool FlushConsoleInputBuffer(IntPtr h);
    [DllImport("kernel32.dll")] public static extern IntPtr GetStdHandle(int n);
}
"@

$appDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$configPath = Join-Path $appDir "klavye-testi-ayarlar.json"

# --- Varsayilan ayarlar --------------------------------------------------------
function Get-DefaultConfig {
    $defaultResult = Join-Path (Join-Path ([Environment]::GetFolderPath("Desktop")) "Klavye Testi") "klavye-testi-sonucu.txt"
    [ordered]@{
        KeyTimeoutSec   = 10
        LockConfirmMs   = 900
        PollMs          = 2
        HintX           = 60
        HintY           = 60
        HintWidth       = 560
        HintHeight      = 170
        HintTopMost     = $true
        ResultPath      = $defaultResult
        SoundOn         = $false
        LogMismatch     = $true
        DarkTheme       = $true
        AutoSave        = $true
        OpenResultAfter = $false
        AutoStart       = $false
        AcceptNumNav    = $true
        EnabledSteps    = @()
    }
}

function Load-Config {
    $cfg = Get-DefaultConfig
    if (Test-Path -LiteralPath $configPath) {
        try {
            $j = Get-Content -Raw -Encoding UTF8 -LiteralPath $configPath | ConvertFrom-Json
            foreach ($p in @($cfg.Keys)) {
                if ($j.PSObject.Properties.Name -contains $p) { $cfg[$p] = $j.$p }
            }
        } catch { }
    }
    if (-not $cfg.ResultPath) { $cfg.ResultPath = $defaultResult }
    $cfg
}

function Save-Config($cfg) {
    $cfg | ConvertTo-Json -Depth 4 | Set-Content -Encoding UTF8 -LiteralPath $configPath
}

function Clear-InputBuffer {
    try { [KBApp4]::FlushConsoleInputBuffer([KBApp4]::GetStdHandle(-10)) | Out-Null } catch { }
}

function Get-Lock([int]$vk) {
    $s = [int][KBApp4]::GetKeyState($vk)
    if (($s -band 1) -ne 0) { "ON" } else { "OFF" }
}

# --- Turkce Q ozel tuslar ------------------------------------------------------
$special = @{
    0xC0 = '" / é'      # OEM 3      (1'in solu)
    0xDF = '* / ?'      # OEM 8      (0'in sagi)
    0xBD = '- / _'      # OEM MINUS  (*'in sagi)
    0xDB = 'ğ / Ğ'      # OEM 4      (P'nin sagi)
    0xDD = 'ü / Ü'      # OEM 6      (ğ'nin sagi)
    0xBA = 'ş / Ş'      # OEM 1      (L'nin sagi)
    0xDE = 'i / İ'      # OEM 7      (ş'nin sagi)
    0xBC = ', / ;'      # OEM COMMA  (i'nin sagi)
    0xE2 = '< / >'      # OEM 102    (Sol Shift'in sagi)
    0xBF = 'ö / Ö'      # OEM 2      (M'nin sagi)
    0xDC = 'ç / Ç'      # OEM 5      (ö'nin sagi)
    0xBE = '. / :'      # OEM PERIOD (ç'nin sagi)
}
$specialVks = [int[]]$special.Keys

# --- Adim listesi: klavyedeki fiziksel sira ------------------------------------
function New-Steps($cfg) {
    $list = New-Object 'System.Collections.Generic.List[object]'
    function AddOne([int]$vk,[string]$name,[string]$group,[string]$hint="",[bool]$optional=$false,[int]$altVk=0,[string]$action="") {
        $list.Add([pscustomobject]@{ Name=$name; Vk=$vk; Group=$group; Hint=$hint;
            Optional=$optional; Action=$action; AltVk=$altVk })
    }

    # 1) Fonksiyon satiri
    AddOne 0x1B "Esc" "Fonksiyon" "Sol ust"
    for ($n=0x70; $n -le 0x7B; $n++) { AddOne $n ("F"+[string]($n-0x70+1)) "Fonksiyon" "Esc'nin saginda" }
    AddOne 0x2C "PrintScreen" "Fonksiyon"
    AddOne 0x90 "NumLock" "Fonksiyon" "LED'e bakma, TOGGLE kaydina bak"
    AddOne 0x91 "ScrollLock" "Fonksiyon"
    AddOne 0 "Pause / Break" "Fonksiyon" "Olmazsa Fn+Pause dene (Fn gorunmez)" $false 0 "Pause"

    # 2) Rakam satiri
    AddOne 0xC0 '" / é (OEM 3)' "Rakam satiri" "1'in solu"
    for ($n=0x31; $n -le 0x39; $n++) { AddOne $n ([string][char]$n) "Rakam satiri" }
    AddOne 0x30 "0" "Rakam satiri"
    AddOne 0xDF '* / ? (OEM 8)' "Rakam satiri" "0'in sagi"
    AddOne 0xBD '- / _ (OEM Minus)' "Rakam satiri" "*'in sagi"
    AddOne 0x08 "Backspace" "Rakam satiri"
    AddOne 0x2D "Insert" "Rakam satiri"
    AddOne 0x24 "Home" "Rakam satiri"
    AddOne 0x21 "PageUp" "Rakam satiri"

    # 3) Q satiri
    AddOne 0x09 "Tab" "Q satiri"
    AddOne 0x51 "Q" "Q satiri"; AddOne 0x57 "W" "Q satiri"
    AddOne 0x45 "E" "Q satiri"; AddOne 0x52 "R" "Q satiri"
    AddOne 0x54 "T" "Q satiri"; AddOne 0x59 "Y" "Q satiri"
    AddOne 0x55 "U" "Q satiri"; AddOne 0x49 "I / ı" "Q satiri"
    AddOne 0x4F "O" "Q satiri"; AddOne 0x50 "P" "Q satiri"
    AddOne 0xDB 'ğ / Ğ (OEM 4)' "Q satiri" "P'nin sagi"
    AddOne 0xDD 'ü / Ü (OEM 6)' "Q satiri" "ğ'nin sagi"
    AddOne 0x0D "Enter" "Q satiri"
    AddOne 0x2E "Delete" "Q satiri"; AddOne 0x23 "End" "Q satiri"
    AddOne 0x22 "PageDown" "Q satiri"

    # 4) A satiri
    AddOne 0x14 "CapsLock" "A satiri" "Tab'in alti"
    AddOne 0x41 "A" "A satiri"; AddOne 0x53 "S" "A satiri"
    AddOne 0x44 "D" "A satiri"; AddOne 0x46 "F" "A satiri"
    AddOne 0x47 "G" "A satiri"; AddOne 0x48 "H" "A satiri"
    AddOne 0x4A "J" "A satiri"; AddOne 0x4B "K" "A satiri"
    AddOne 0x4C "L" "A satiri"
    AddOne 0xBA 'ş / Ş (OEM 1)' "A satiri" "L'nin sagi"
    AddOne 0xDE 'i / İ (OEM 7)' "A satiri" "ş'nin sagi"
    AddOne 0xBC ', / ; (OEM Comma)' "A satiri" "i'nin sagi, Enter'in solu"

    # 5) Z satiri
    AddOne 0xA0 "Sol Shift" "Z satiri"
    AddOne 0xE2 '< / > (OEM 102)' "Z satiri" "Sol Shift'in sagi"
    AddOne 0x5A "Z" "Z satiri"; AddOne 0x58 "X" "Z satiri"
    AddOne 0x43 "C" "Z satiri"; AddOne 0x56 "V" "Z satiri"
    AddOne 0x42 "B" "Z satiri"; AddOne 0x4E "N" "Z satiri"
    AddOne 0x4D "M" "Z satiri"
    AddOne 0xBF 'ö / Ö (OEM 2)' "Z satiri" "M'nin sagi"
    AddOne 0xDC 'ç / Ç (OEM 5)' "Z satiri" "ö'nin sagi"
    AddOne 0xBE '. / : (OEM Period)' "Z satiri" "ç'nin sagi"
    AddOne 0xA1 "Sağ Shift" "Z satiri"
    AddOne 0x26 "Yukarı ok" "Z satiri"

    # 6) Alt satir
    AddOne 0xA2 "Sol Ctrl" "Alt satir"
    AddOne 0x5B "Sol Win" "Alt satir"
    AddOne 0xA4 "Sol Alt" "Alt satir"
    AddOne 0x20 "Space" "Alt satir"
    AddOne 0xA5 "AltGr (Sağ Alt)" "Alt satir"
    AddOne 0x5D "Menü tuşu" "Alt satir" "Varsa" $true
    AddOne 0xA3 "Sağ Ctrl" "Alt satir"
    AddOne 0x25 "Sola ok" "Alt satir"
    AddOne 0x28 "Aşağı ok" "Alt satir"
    AddOne 0x27 "Sağa ok" "Alt satir"
    AddOne 0x5C "Sağ Win (varsa; Fn değil)" "Alt satir" "Fn Windows'a bildirilmez" $true

    # 7) Sayisal takim
    $numAlt = @{ 0=0x2D; 1=0x23; 2=0x28; 3=0x22; 4=0x25; 5=0x0C; 6=0x27; 7=0x24; 8=0x26; 9=0x21 }
    for ($n=0x60; $n -le 0x69; $n++) {
        $d = $n - 0x60
        AddOne $n ("Num"+[string]$d) "Sayisal takim" "" $false $numAlt[$d]
    }
    AddOne 0x6E "NumDecimal (.)" "Sayisal takim" "" $false 0x2E
    AddOne 0x6B "NumAdd (+)" "Sayisal takim"
    AddOne 0x6D "NumSubtract (-)" "Sayisal takim"
    AddOne 0x6A "NumMultiply (*)" "Sayisal takim"
    AddOne 0x6F "NumDivide (/)" "Sayisal takim"

    $enabled = @($cfg.EnabledSteps)
    # Bos dizi = "hic ayar yapilmadi -> tumu etkin" anlamina gelir.
    # Kullanici butun isaretleri kaldirdiysa __NONE__ sentinel'i yazilir;
    # yoksa hic tus secilmemisken tum tuslar geri geliyordu (bug).
    $noneSelected = ($enabled -contains "__NONE__")
    foreach ($s in $list) {
        if ($noneSelected) { $en = $false }
        elseif ($enabled.Count -eq 0) { $en = $true }
        else { $en = ($enabled -contains $s.Name) }
        $s | Add-Member -MemberType NoteProperty -Name Enabled -Value $en -Force
    }
    $list
}

# --- Tus algilama --------------------------------------------------------------
function Wait-Key([int]$vk, [double]$seconds) {
    # Microsoft: dusuk bit guvenilmez (baska uygulama tuketebilir).
    # Asil tespit yuksek bitin 0->1 gecisidir; dusuk bit yalnizca yedek.
    $first = [int][KBApp4]::GetAsyncKeyState($vk)
    $prev = (($first -band 0x8000) -ne 0)
    $script:specialPrev = @{}
    foreach ($k in $specialVks) {
        $sv = [int][KBApp4]::GetAsyncKeyState($k)
        $script:specialPrev[$k] = (($sv -band 0x8000) -ne 0)
    }
    $expectSpecial = ($specialVks -contains $vk)
    $end = [DateTime]::UtcNow.AddSeconds($seconds)

    while ([DateTime]::UtcNow -lt $end) {
        # Iptal kisayolu: Ctrl + Shift + Q
        $ctrl = [int][KBApp4]::GetAsyncKeyState(0x11)
        $shift = [int][KBApp4]::GetAsyncKeyState(0x10)
        $q = [int][KBApp4]::GetAsyncKeyState(0x51)
        if ((($ctrl -band 0x8000) -ne 0) -and (($shift -band 0x8000) -ne 0) -and (($q -band 0x8000) -ne 0)) {
            $script:abort = $true
            return $false
        }

        $s = [int][KBApp4]::GetAsyncKeyState($vk)
        $down = (($s -band 0x8000) -ne 0)
        if (($down -and -not $prev) -or (($s -band 1) -ne 0)) { return $true }
        $prev = $down

        if ($script:cfg.LogMismatch -and $expectSpecial) {
            foreach ($k in $specialVks) {
                if ($k -eq $vk) { continue }
                $sv = [int][KBApp4]::GetAsyncKeyState($k)
                $sd = (($sv -band 0x8000) -ne 0)
                if ($sd -and -not $script:specialPrev[$k]) {
                    $script:mismatch.Add(("'{0}' beklenirken '{1}' algılandı" -f $special[$vk], $special[$k]))
                }
                $script:specialPrev[$k] = $sd
            }
        }
        [System.Windows.Forms.Application]::DoEvents()
        Start-Sleep -Milliseconds $script:cfg.PollMs
    }
    $false
}

function Play-Sound([bool]$ok) {
    if (-not $script:cfg.SoundOn) { return }
    try {
        if ($ok) { [System.Media.SystemSounds]::Beep.Play() }
        else { [System.Media.SystemSounds]::Exclamation.Play() }
    } catch { }
}

function Write-ResultFile($text) {
    $script:lastResultText = $text
    if ($script:cfg.AutoSave) {
        try {
            $dir = Split-Path -Parent $script:cfg.ResultPath
            if ($dir -and -not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
            [System.IO.File]::WriteAllText($script:cfg.ResultPath, ($text -join "`r`n"), (New-Object System.Text.UTF8Encoding($true)))
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Sonuç dosyası yazılamadı:`n" + $_.Exception.Message, "Klavye Testi", "OK", "Warning")
        }
    }
}

# === HARNESS CUT: bundan sonrasi UI olusturma ==================================

[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Windows.Forms.Application]::SetCompatibleTextRenderingDefault($false)

$script:cfg = Load-Config
$script:steps = New-Steps $script:cfg
$script:running = $false
$script:abort = $false
$script:closeAfterTest = $false
$script:lastResultText = ""
$script:mismatch = New-Object 'System.Collections.Generic.List[string]'
$script:toggleNotes = New-Object 'System.Collections.Generic.List[string]'

# --- Tema ----------------------------------------------------------------------
function Set-ControlColors($ctrl, $bg, $fg) {
    try { $ctrl.BackColor = $bg } catch { }
    try { $ctrl.ForeColor = $fg } catch { }
    if ($ctrl.Controls) { foreach ($c in $ctrl.Controls) { Set-ControlColors $c $bg $fg } }
}
function Get-ThemeColors {
    if ($script:cfg.DarkTheme) {
        @([System.Drawing.Color]::FromArgb(32,32,32), [System.Drawing.Color]::White)
    } else {
        @([System.Drawing.Color]::FromArgb(245,245,245), [System.Drawing.Color]::FromArgb(20,20,20))
    }
}
function Apply-Theme {
    $c = Get-ThemeColors
    Set-ControlColors $mainForm $c[0] $c[1]
    Set-ControlColors $hintForm $c[0] $c[1]
    foreach ($tp in $tabMain.TabPages) { Set-ControlColors $tp $c[0] $c[1] }
    $dgv.BackgroundColor = $c[0]
    $dgv.GridColor = if ($script:cfg.DarkTheme) { [System.Drawing.Color]::FromArgb(70,70,70) } else { [System.Drawing.Color]::FromArgb(200,200,200) }
    $dgv.DefaultCellStyle.BackColor = $c[0]
    $dgv.DefaultCellStyle.ForeColor = $c[1]
    $txtLog.BackColor = $c[0]
    $txtLog.ForeColor = $c[1]
    try { $mainMenu.BackColor = $c[0]; $mainMenu.ForeColor = $c[1] } catch { }
}

# --- Ana pencere ----------------------------------------------------------------
$mainForm = New-Object System.Windows.Forms.Form
$mainForm.Text = "Klavye Testi Merkezi v4"
$mainForm.ClientSize = New-Object System.Drawing.Size(980, 640)
$mainForm.StartPosition = "CenterScreen"
$mainForm.MinimumSize = New-Object System.Drawing.Size(760, 480)

$mainMenu = New-Object System.Windows.Forms.MenuStrip
$miFile = New-Object System.Windows.Forms.ToolStripMenuItem("Dosya")
$miTest = New-Object System.Windows.Forms.ToolStripMenuItem("Test")
$miSettings = New-Object System.Windows.Forms.ToolStripMenuItem("Ayarlar")
$miHelp = New-Object System.Windows.Forms.ToolStripMenuItem("Yardım")
$mainMenu.Items.AddRange(@($miFile, $miTest, $miSettings, $miHelp))
$mainForm.MainMenuStrip = $mainMenu
$mainForm.Controls.Add($mainMenu)

$tool = New-Object System.Windows.Forms.ToolStrip
$tool.Dock = "Top"
$btnStart = New-Object System.Windows.Forms.ToolStripButton("▶ Başlat")
$btnStop = New-Object System.Windows.Forms.ToolStripButton("■ Durdur")
$btnSettings = New-Object System.Windows.Forms.ToolStripButton("⚙ Ayarlar")
$btnClear = New-Object System.Windows.Forms.ToolStripButton("Temizle")
$btnStop.Enabled = $false
$tool.Items.AddRange(@($btnStart, $btnStop, $btnSettings, $btnClear))
$mainForm.Controls.Add($tool)

$bar = New-Object System.Windows.Forms.ProgressBar
$bar.Dock = "Top"
$bar.Height = 20
$bar.Minimum = 0
$bar.Maximum = 100
$mainForm.Controls.Add($bar)

$tabMain = New-Object System.Windows.Forms.TabControl
$tabMain.Dock = "Fill"
$tabResults = New-Object System.Windows.Forms.TabPage("Sonuçlar")
$tabLog = New-Object System.Windows.Forms.TabPage("Olay Kaydı")
$tabMain.TabPages.AddRange(@($tabResults, $tabLog))
$mainForm.Controls.Add($tabMain)

$dgv = New-Object System.Windows.Forms.DataGridView
$dgv.Dock = "Fill"
$dgv.AllowUserToAddRows = $false
$dgv.ReadOnly = $true
$dgv.SelectionMode = "FullRowSelect"
$dgv.RowHeadersVisible = $false
$dgv.AutoSizeRowsMode = "AllCells"
[void]$dgv.Columns.Add("No", "#")
[void]$dgv.Columns.Add("Key", "Tuş")
[void]$dgv.Columns.Add("Result", "Sonuç")
[void]$dgv.Columns.Add("Detail", "Detay")
$dgv.Columns[0].Width = 48
$dgv.Columns[1].Width = 260
$dgv.Columns[2].Width = 90
$dgv.Columns[3].Width = 520
$tabResults.Controls.Add($dgv)

$txtLog = New-Object System.Windows.Forms.TextBox
$txtLog.Multiline = $true
$txtLog.Dock = "Fill"
$txtLog.ReadOnly = $true
$txtLog.ScrollBars = "Vertical"
$txtLog.Font = New-Object System.Drawing.Font("Consolas", 10)
$tabLog.Controls.Add($txtLog)

$status = New-Object System.Windows.Forms.StatusStrip
$lblStatus = New-Object System.Windows.Forms.ToolStripStatusLabel("Hazır — Başlat'a basın veya Test menüsünü kullanın.")
[void]$status.Items.Add($lblStatus)
$mainForm.Controls.Add($status)

$statPanel = New-Object System.Windows.Forms.Panel
$statPanel.Dock = "Bottom"
$statPanel.Height = 34

# Imza: sag altta iki satir, ikinci satir daha kucuk font.
$creditPanel = New-Object System.Windows.Forms.Panel
$creditPanel.Dock = "Right"
$creditPanel.Width = 210
$lblCredit2 = New-Object System.Windows.Forms.Label
$lblCredit2.Dock = "Fill"
$lblCredit2.TextAlign = [System.Drawing.ContentAlignment]::TopRight
$lblCredit2.Text = "With help of Opencode"
$lblCredit2.Font = New-Object System.Drawing.Font("Segoe UI", 7)
$creditPanel.Controls.Add($lblCredit2)
$lblCredit1 = New-Object System.Windows.Forms.Label
$lblCredit1.Dock = "Top"
$lblCredit1.Height = 17
$lblCredit1.TextAlign = [System.Drawing.ContentAlignment]::BottomRight
$lblCredit1.Text = "Made by jaNNberk"
$lblCredit1.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$creditPanel.Controls.Add($lblCredit1)

# Dock sirasi onemli: Fill ilk eklenir, Right sonra eklenir; aksi halde
# Fill tum genisligi kapar ve imza satiri ustune biner (gorunmez olur).
$lblStats = New-Object System.Windows.Forms.Label
$lblStats.Dock = "Fill"
$lblStats.TextAlign = "MiddleLeft"
$lblStats.Text = "Toplam: 0   OK: 0   YOK: 0   Opsiyonel: 0"
$statPanel.Controls.Add($lblStats)
$statPanel.Controls.Add($creditPanel)
$mainForm.Controls.Add($statPanel)

# --- Ipucu penceresi ------------------------------------------------------------
$hintForm = New-Object System.Windows.Forms.Form
$hintForm.Text = "Klavye Testi — Tuş İpucu"
$hintForm.StartPosition = "Manual"
$hintForm.FormBorderStyle = "FixedToolWindow"
$hintForm.ControlBox = $false
$hintForm.ShowInTaskbar = $false
$hintForm.ClientSize = New-Object System.Drawing.Size($script:cfg.HintWidth, $script:cfg.HintHeight)
$hintForm.Location = New-Object System.Drawing.Point($script:cfg.HintX, $script:cfg.HintY)
$hintForm.TopMost = [bool]$script:cfg.HintTopMost
$hintLabel = New-Object System.Windows.Forms.Label
$hintLabel.Dock = "Fill"
$hintLabel.TextAlign = "MiddleCenter"
$hintLabel.Font = New-Object System.Drawing.Font("Segoe UI", 15, [System.Drawing.FontStyle]::Bold)
$hintLabel.Text = "Hazır"
$hintForm.Controls.Add($hintLabel)

function Add-Log([string]$line) {
    $txtLog.AppendText($line + "`r`n")
}

function Add-Row([string]$no,[string]$key,[string]$result,[string]$detail,[bool]$ok) {
    $idx = $dgv.Rows.Add($no, $key, $result, $detail)
    $cell = $dgv.Rows[$idx].Cells[2]
    if ($ok) { $cell.Style.ForeColor = [System.Drawing.Color]::FromArgb(40,180,90) }
    else { $cell.Style.ForeColor = [System.Drawing.Color]::FromArgb(230,90,90) }
    $dgv.FirstDisplayedScrollingRowIndex = $idx
}

# --- Test motoru ----------------------------------------------------------------
function Start-Test {
    if ($script:running) { return }
    Clear-InputBuffer
    $script:running = $true
    $script:abort = $false
    $script:mismatch.Clear()
    $script:toggleNotes.Clear()
    $dgv.Rows.Clear()
    $txtLog.Clear()
    $lblStats.Text = "Toplam: 0   OK: 0   YOK: 0   Opsiyonel: 0"
    $btnStart.Enabled = $false
    $btnStop.Enabled = $true
    $tabMain.SelectedTab = $tabResults

    $hintForm.TopMost = [bool]$script:cfg.HintTopMost
    $hintForm.ClientSize = New-Object System.Drawing.Size($script:cfg.HintWidth, $script:cfg.HintHeight)
    $hintForm.Location = New-Object System.Drawing.Point($script:cfg.HintX, $script:cfg.HintY)
    $hintForm.Show()
    [System.Windows.Forms.Application]::DoEvents()

    $skipped = New-Object 'System.Collections.Generic.List[string]'
    # Devre disi birakilan tuslar artik sonuc dosyasinda da gorunsun.
    foreach ($sk in ($script:steps | Where-Object { -not $_.Enabled })) { $skipped.Add($sk.Name) }
    $active = @($script:steps | Where-Object { $_.Enabled })
    $total = $active.Count
    $bar.Maximum = [Math]::Max(1, $total)
    $bar.Value = 0
    $passed = 0
    $failed = New-Object 'System.Collections.Generic.List[string]'
    $optionalMissed = New-Object 'System.Collections.Generic.List[string]'
    $tested = New-Object 'System.Collections.Generic.List[string]'
    $done = 0
    $aborted = $false

    Add-Log ("==== TEST BAŞLADI — " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " ====")
    Add-Log ("Başlangıç kilitleri: CapsLock={0} NumLock={1} ScrollLock={2}" -f (Get-Lock 0x14), (Get-Lock 0x90), (Get-Lock 0x91))

    foreach ($s in $active) {
        if ($script:abort) { $aborted = $true; break }
        $done++
        $hintText = if ($s.Hint) { "İpucu: " + $s.Hint } else { "Sadece bu tuşa bas." }
        $hintLabel.Text = ("[{0}/{1}]  BAS: {2}`n`n{3}" -f $done, $total, $s.Name, $hintText)
        $hintLabel.Refresh()
        $lblStatus.Text = ("[{0}/{1}]  {2}" -f $done, $total, $s.Name)
        $bar.Value = $done
        [System.Windows.Forms.Application]::DoEvents()

        $ok = $false
        $detail = ""

        if ($s.Action -eq "Pause") {
            $ok = Wait-Key 0x13 $script:cfg.KeyTimeoutSec
            if (-not $ok -and -not $script:abort) {
                $hintLabel.Text = ("[{0}/{1}]  Fn + Pause dene`n`nFn'in kendisi görünmez." -f $done, $total)
                $hintLabel.Refresh()
                [System.Windows.Forms.Application]::DoEvents()
                $ok = Wait-Key 0x13 $script:cfg.KeyTimeoutSec
            }
        }
        else {
            $before = ""
            if ($s.Vk -in @(0x14,0x90,0x91)) { $before = Get-Lock $s.Vk }
            $targetVk = $s.Vk
            if ($script:cfg.AcceptNumNav -and $s.AltVk -ne 0 -and (Get-Lock 0x90) -ne "ON") {
                $targetVk = $s.AltVk
                $detail = "NumLock kapalı → gezinme kodu"
            }
            $ok = Wait-Key $targetVk $script:cfg.KeyTimeoutSec

            if ($s.Vk -in @(0x14,0x90,0x91)) {
                [System.Windows.Forms.Application]::DoEvents()
                Start-Sleep -Milliseconds 120
                [System.Windows.Forms.Application]::DoEvents()
                $after = Get-Lock $s.Vk
                $detail = "TOGGLE=$after"
                $script:toggleNotes.Add(("$($s.Name): $before -> $after"))
                if (-not $ok -and $after -ne $before) { $ok = $true }
                if ($ok) {
                    $hintLabel.Text = ("[{0}/{1}]  {2}  ->  {3}`n`nSonraki tuşa geçiliyor..." -f $done, $total, $s.Name, $after)
                    $hintLabel.Refresh()
                    [System.Windows.Forms.Application]::DoEvents()
                    Start-Sleep -Milliseconds $script:cfg.LockConfirmMs
                }
            }
        }

        if ($script:abort) { $aborted = $true; break }
        $tested.Add($s.Name)

        if ($ok) {
            $passed++
            Add-Row ([string]$done) $s.Name "OK" $detail $true
            Add-Log ("[{0,3}/{1}] OK   {2} {3}" -f $done, $total, $s.Name, $detail)
        } else {
            Add-Row ([string]$done) $s.Name "YOK" $detail $false
            Add-Log ("[{0,3}/{1}] YOK  {2} {3}" -f $done, $total, $s.Name, $detail)
            if ($s.Optional) { $optionalMissed.Add($s.Name) } else { $failed.Add($s.Name) }
        }
        $lblStats.Text = ("Toplam: {0}   OK: {1}   YOK: {2}   Opsiyonel: {3}" -f $total, $passed, ($done-$passed), $optionalMissed.Count)
        Play-Sound $ok
        [System.Windows.Forms.Application]::DoEvents()
    }

    $hintForm.Hide()
    $passedCount = $passed
    $lines = @()
    $lines += "==== KLAVYE TESTİ v4 — SONUÇ ===="
    $lines += ("Tarih: " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss"))
    $lines += ("Algılanan: {0} / {1}" -f $passedCount, $total)
    if ($total -eq 0) { $lines += "UYARI: Test edilecek tuş seçilmedi (Ayarlar > tuş listesini kontrol et)." }
    if ($aborted) { $lines += "DURUM: Kullanıcı tarafından iptal edildi (Ctrl+Shift+Q)." }
    $lines += ("Kilitler (son): CapsLock={0}  NumLock={1}  ScrollLock={2}" -f (Get-Lock 0x14), (Get-Lock 0x90), (Get-Lock 0x91))
    $lines += "Not: Fn ve Numpad Enter Windows'a ayrı kod göndermez; test edilemez."
    $lines += "Not: NumLock kapalıysa numpad gezinme kodları da kabul edilir."
    $lines += ""
    if ($skipped.Count -gt 0) {
        $lines += "Ayarlarla devre dışı bırakılan tuşlar:"
        foreach ($f in $skipped) { $lines += "  - $f" }
        $lines += ""
    }
    if ($failed.Count -eq 0) { $lines += "Algılanmayan zorunlu tuş: yok." }
    else {
        $lines += "Algılanmayan / basılmayan tuşlar:"
        foreach ($f in $failed) { $lines += "  - $f" }
    }
    if ($optionalMissed.Count -gt 0) {
        $lines += ""
        $lines += "İsteğe bağlı (klavyende olmayabilir / Fn):"
        foreach ($f in $optionalMissed) { $lines += "  - $f" }
    }
    if ($aborted) {
        $untested = @($active | Where-Object { $tested -notcontains $_.Name })
        if ($untested.Count -gt 0) {
            $lines += ""
            $lines += "Test edilmeyen tuşlar (iptal nedeniyle, arıza değil):"
            foreach ($f in $untested) { $lines += "  - $($f.Name)" }
        }
    }
    if ($script:toggleNotes.Count -gt 0) {
        $lines += ""
        $lines += "Kilit toggle kayıtları:"
        foreach ($t in $script:toggleNotes) { $lines += "  - $t" }
    }
    if ($script:cfg.LogMismatch -and $script:mismatch.Count -gt 0) {
        $lines += ""
        $lines += "Tuş kimliği uyuşmazlığı:"
        foreach ($m in ($script:mismatch | Sort-Object -Unique)) { $lines += "  ? $m" }
    }

    foreach ($l in $lines) { Add-Log $l }
    Write-ResultFile $lines
    $lblStatus.Text = if ($aborted) { "İptal edildi." } else { ("Bitti: {0}/{1} algılandı." -f $passedCount, $total) }
    $btnStart.Enabled = $true
    $btnStop.Enabled = $false
    $script:running = $false
    if ($script:cfg.OpenResultAfter -and (Test-Path -LiteralPath $script:cfg.ResultPath)) {
        try { Start-Process notepad.exe $script:cfg.ResultPath } catch { }
    }
    # Kapanis istegi test sirasinda geldiyse, form ancak motor tamamen bittikten
    # sonra kapanir; aksi halde dispose edilmis kontroller uzerine yazilir.
    if ($script:closeAfterTest) {
        $script:closeAfterTest = $false
        $mainForm.Close()
    }
}

function Stop-Test {
    if (-not $script:running) { return }
    $script:abort = $true
    $lblStatus.Text = "İptal isteği gönderildi..."
}

function Clear-Results {
    $dgv.Rows.Clear()
    $txtLog.Clear()
    $script:lastResultText = ""
    $bar.Value = 0
    $lblStats.Text = "Toplam: 0   OK: 0   YOK: 0   Opsiyonel: 0"
    $lblStatus.Text = "Hazır — Başlat'a basın veya Test menüsünü kullanın."
}

# --- Ayarlar penceresi ----------------------------------------------------------
function Show-Settings {
    $f = New-Object System.Windows.Forms.Form
    $f.Text = "Ayarlar"
    # Icerik yaklasik 810 px: 620 yukseklikte Tamam/IPTAL tuslari form disinda kaliyordu.
    $f.ClientSize = New-Object System.Drawing.Size(700, 850)
    $f.StartPosition = "CenterParent"
    $f.FormBorderStyle = "FixedDialog"
    $f.MaximizeBox = $false
    $f.AutoScroll = $true
    $y = 12

    function Numeric($labelText,[int]$x,[int]$yPos,[int]$min,[int]$max,[int]$val,[string]$name) {
        $l = New-Object System.Windows.Forms.Label
        $l.Text = $labelText; $l.Location = "$x,$($yPos+3)"; $l.AutoSize = $true
        $val = [int]$val
        if ($val -lt $min) { $val = $min }
        if ($val -gt $max) { $val = $max }
        $n = New-Object System.Windows.Forms.NumericUpDown
        $n.Name = $name; $n.Location = "$($x+270),$yPos"; $n.Minimum = $min; $n.Maximum = $max; $n.Value = $val; $n.Width = 90
        $f.Controls.Add($l); $f.Controls.Add($n)
    }
    function Check($labelText,[int]$x,[int]$yPos,[bool]$checked,[string]$name) {
        $c = New-Object System.Windows.Forms.CheckBox
        $c.Text = $labelText; $c.Name = $name; $c.Location = "$x,$yPos"; $c.AutoSize = $true; $c.Checked = $checked
        $f.Controls.Add($c)
    }

    Numeric "Her tuş için bekleme süresi (sn)" 16 $y 1 60 $script:cfg.KeyTimeoutSec "nudTimeout"; $y += 30
    Numeric "Kilit onay ekranı (ms)" 16 $y 0 5000 $script:cfg.LockConfirmMs "nudLock"; $y += 30
    Numeric "Algılama örnekleme aralığı (ms)" 16 $y 1 20 $script:cfg.PollMs "nudPoll"; $y += 32

    Numeric "İpucu penceresi X" 16 $y 0 3000 $script:cfg.HintX "nudX"; $y += 26
    Numeric "İpucu penceresi Y" 16 $y 0 3000 $script:cfg.HintY "nudY"; $y += 26
    Numeric "İpucu penceresi genişlik" 16 $y 300 1600 $script:cfg.HintWidth "nudW"; $y += 26
    Numeric "İpucu penceresi yükseklik" 16 $y 100 800 $script:cfg.HintHeight "nudH"; $y += 28

    Check "İpucu penceresi her zaman üstte" 16 $y ([bool]$script:cfg.HintTopMost) "chkTop"; $y += 24
    Check "Sesli geri bildirim (OK / YOK) - varsayilan kapali" 16 $y ([bool]$script:cfg.SoundOn) "chkSound"; $y += 24
    Check "Yanlış tuş uyuşmazlıklarını kaydet" 16 $y ([bool]$script:cfg.LogMismatch) "chkMismatch"; $y += 24
    Check "Koyu tema" 16 $y ([bool]$script:cfg.DarkTheme) "chkDark"; $y += 24
    Check "Sonucu otomatik kaydet" 16 $y ([bool]$script:cfg.AutoSave) "chkAutoSave"; $y += 24
    Check "Test bitince sonucu Notepad'te aç" 16 $y ([bool]$script:cfg.OpenResultAfter) "chkOpen"; $y += 24
    Check "Program açılınca testi başlat" 16 $y ([bool]$script:cfg.AutoStart) "chkAutoStart"; $y += 24
    Check "NumLock kapalıyken gezinme kodlarını kabul et" 16 $y ([bool]$script:cfg.AcceptNumNav) "chkNumNav"; $y += 30

    $lblPath = New-Object System.Windows.Forms.Label
    $lblPath.Text = "Sonuç dosyası:"; $lblPath.Location = "16,$($y+3)"; $lblPath.AutoSize = $true
    $txtPath = New-Object System.Windows.Forms.TextBox
    $txtPath.Name = "txtPath"; $txtPath.Location = "170,$y"; $txtPath.Width = 400; $txtPath.Text = $script:cfg.ResultPath
    $btnBrowse = New-Object System.Windows.Forms.Button
    $btnBrowse.Text = "Gözat..."; $btnBrowse.Location = "580,$($y-2)"; $btnBrowse.Width = 90
    $f.Controls.Add($lblPath); $f.Controls.Add($txtPath); $f.Controls.Add($btnBrowse)
    $btnBrowse.Add_Click({
        $sd = New-Object System.Windows.Forms.SaveFileDialog
        $sd.Filter = "Metin dosyası|*.txt"
        $sd.FileName = $txtPath.Text
        if ($sd.ShowDialog($f) -eq "OK") { $txtPath.Text = $sd.FileName }
    })
    $y += 34

    $lblKeys = New-Object System.Windows.Forms.Label
    $lblKeys.Text = "Test edilecek tuşlar (işaretini kaldırırsan atlanır):"
    $lblKeys.Location = "16,$($y+2)"; $lblKeys.AutoSize = $true
    $f.Controls.Add($lblKeys); $y += 22

    $clb = New-Object System.Windows.Forms.CheckedListBox
    $clb.Name = "clbSteps"
    $clb.Location = "16,$y"; $clb.Width = 654; $clb.Height = 250
    $clb.CheckOnClick = $true
    $clb.ScrollAlwaysVisible = $true
    foreach ($s in $script:steps) {
        [void]$clb.Items.Add($s.Name, [bool]$s.Enabled)
    }
    $f.Controls.Add($clb)
    $y += 258

    $btnAll = New-Object System.Windows.Forms.Button
    $btnAll.Text = "Tümünü seç"; $btnAll.Location = "16,$y"; $btnAll.Width = 110
    $btnAll.Add_Click({ for ($i=0; $i -lt $clb.Items.Count; $i++) { $clb.SetItemChecked($i, $true) } })
    $btnReq = New-Object System.Windows.Forms.Button
    $btnReq.Text = "Sadece zorunlular"; $btnReq.Location = "136,$y"; $btnReq.Width = 130
    $btnReq.Add_Click({
        for ($i=0; $i -lt $clb.Items.Count; $i++) {
            $name = $clb.Items[$i]
            $st = $script:steps | Where-Object { $_.Name -eq $name } | Select-Object -First 1
            $clb.SetItemChecked($i, (-not $st.Optional))
        }
    })
    $btnDef = New-Object System.Windows.Forms.Button
    $btnDef.Text = "Varsayılan"; $btnDef.Location = "276,$y"; $btnDef.Width = 100
    $btnDef.Add_Click({ for ($i=0; $i -lt $clb.Items.Count; $i++) { $clb.SetItemChecked($i, $true) } })
    $f.Controls.Add($btnAll); $f.Controls.Add($btnReq); $f.Controls.Add($btnDef)
    $y += 40

    $btnOK = New-Object System.Windows.Forms.Button
    $btnOK.Text = "Tamam"; $btnOK.Location = "430,$y"; $btnOK.Width = 90; $btnOK.DialogResult = "OK"
    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text = "İptal"; $btnCancel.Location = "530,$y"; $btnCancel.Width = 90; $btnCancel.DialogResult = "Cancel"
    $f.Controls.Add($btnOK); $f.Controls.Add($btnCancel)
    $f.AcceptButton = $btnOK; $f.CancelButton = $btnCancel

    $c = Get-ThemeColors
    Set-ControlColors $f $c[0] $c[1]

    if ($f.ShowDialog($mainForm) -eq "OK") {
        $script:cfg.KeyTimeoutSec = [int]$f.Controls["nudTimeout"].Value
        $script:cfg.LockConfirmMs = [int]$f.Controls["nudLock"].Value
        $script:cfg.PollMs = [int]$f.Controls["nudPoll"].Value
        $script:cfg.HintX = [int]$f.Controls["nudX"].Value
        $script:cfg.HintY = [int]$f.Controls["nudY"].Value
        $script:cfg.HintWidth = [int]$f.Controls["nudW"].Value
        $script:cfg.HintHeight = [int]$f.Controls["nudH"].Value
        $script:cfg.HintTopMost = $f.Controls["chkTop"].Checked
        $script:cfg.SoundOn = $f.Controls["chkSound"].Checked
        $script:cfg.LogMismatch = $f.Controls["chkMismatch"].Checked
        $script:cfg.DarkTheme = $f.Controls["chkDark"].Checked
        $script:cfg.AutoSave = $f.Controls["chkAutoSave"].Checked
        $script:cfg.OpenResultAfter = $f.Controls["chkOpen"].Checked
        $script:cfg.AutoStart = $f.Controls["chkAutoStart"].Checked
        $script:cfg.AcceptNumNav = $f.Controls["chkNumNav"].Checked
        $script:cfg.ResultPath = $f.Controls["txtPath"].Text
        $checkedNames = @()
        for ($i = 0; $i -lt $clb.Items.Count; $i++) {
            if ($clb.GetItemChecked($i)) { $checkedNames += [string]$clb.Items[$i] }
        }
        if ($checkedNames.Count -eq 0) { $checkedNames = @("__NONE__") }
        $script:cfg.EnabledSteps = $checkedNames
        Save-Config $script:cfg
        $script:steps = New-Steps $script:cfg
        Apply-Theme
        $hintForm.TopMost = [bool]$script:cfg.HintTopMost
        $lblStatus.Text = "Ayarlar kaydedildi."
    }
    $f.Dispose()
}

# --- Menü olaylari --------------------------------------------------------------
$miStart = New-Object System.Windows.Forms.ToolStripMenuItem("Başlat")
$miStart.ShortcutKeys = [System.Windows.Forms.Keys]::Control -bor [System.Windows.Forms.Keys]::B
$miStop = New-Object System.Windows.Forms.ToolStripMenuItem("Durdur")
$miClear = New-Object System.Windows.Forms.ToolStripMenuItem("Sonuçları temizle")
$miTest.DropDownItems.AddRange(@($miStart, $miStop, $miClear))
$miOpen = New-Object System.Windows.Forms.ToolStripMenuItem("Sonucu Notepad'te aç")
$miSaveAs = New-Object System.Windows.Forms.ToolStripMenuItem("Sonucu farklı kaydet...")
$miExit = New-Object System.Windows.Forms.ToolStripMenuItem("Çıkış")
$miFile.DropDownItems.AddRange(@($miOpen, $miSaveAs, $miExit))
$miSettingsOpen = New-Object System.Windows.Forms.ToolStripMenuItem("Ayarlar...")
$miReset = New-Object System.Windows.Forms.ToolStripMenuItem("Ayarları varsayılana döndür")
$miSettings.DropDownItems.AddRange(@($miSettingsOpen, $miReset))
$miUsage = New-Object System.Windows.Forms.ToolStripMenuItem("Kullanım")
$miAbout = New-Object System.Windows.Forms.ToolStripMenuItem("Hakkında")
$miHelp.DropDownItems.AddRange(@($miUsage, $miAbout))

$btnStart.Add_Click({ Start-Test })
$miStart.Add_Click({ Start-Test })
$btnStop.Add_Click({ Stop-Test })
$miStop.Add_Click({ Stop-Test })
$btnClear.Add_Click({ Clear-Results })
$miClear.Add_Click({ Clear-Results })
$btnSettings.Add_Click({ Show-Settings })
$miSettingsOpen.Add_Click({ Show-Settings })
$miReset.Add_Click({
    $script:cfg = Get-DefaultConfig
    Save-Config $script:cfg
    $script:steps = New-Steps $script:cfg
    Apply-Theme
    $lblStatus.Text = "Ayarlar varsayılana döndürüldü."
})
$miOpen.Add_Click({
    if (Test-Path -LiteralPath $script:cfg.ResultPath) { Start-Process notepad.exe $script:cfg.ResultPath }
    else { [System.Windows.Forms.MessageBox]::Show("Sonuç dosyası bulunamadı.", "Klavye Testi", "OK", "Information") }
})
$miSaveAs.Add_Click({
    if (-not $script:lastResultText) { [System.Windows.Forms.MessageBox]::Show("Kaydedilecek sonuç yok.", "Klavye Testi", "OK", "Information"); return }
    $sd = New-Object System.Windows.Forms.SaveFileDialog
    $sd.Filter = "Metin dosyası|*.txt"; $sd.FileName = $script:cfg.ResultPath
    if ($sd.ShowDialog($mainForm) -eq "OK") {
        [System.IO.File]::WriteAllText($sd.FileName, ($script:lastResultText -join "`r`n"), (New-Object System.Text.UTF8Encoding($true)))
        $lblStatus.Text = ("Sonuç kaydedildi: " + $sd.FileName)
    }
})
$miExit.Add_Click({ $mainForm.Close() })
$miUsage.Add_Click({
    [System.Windows.Forms.MessageBox]::Show(
        "1) Başlat'a basın.`n2) Açılan küçük pencerede sadece 'BAS:' yazan tuşa basın.`n3) CapsLock/NumLock/ScrollLock için LED'e değil TOGGLE kaydına bakın.`n4) İptal için Ctrl+Shift+Q.`n5) Ayarlar menüsünden süre, ses, tema, sonuç yolu ve tuş listesini değiştirebilirsiniz.",
        "Kullanım", "OK", "Information")
})
$miAbout.Add_Click({
    [System.Windows.Forms.MessageBox]::Show(
        "Klavye Testi Merkezi v4`n`nMade by jaNNberk`nWith help of Opencode`n`nTürkçe Q (KBDTUQ) VK eşlemesi.`nGetAsyncKeyState: yüksek bit kenar algılama + düşük bit yedek.`nAyar dosyası: $configPath",
        "Hakkında", "OK", "Information")
})

$mainForm.Add_FormClosing({
    param($sender, $e)
    if ($script:running) {
        $r = [System.Windows.Forms.MessageBox]::Show(
            "Test sürüyor. İptal edip uygulamadan çıkmak istiyor musun?",
            "Klavye Testi", "YesNo", "Warning")
        if ($r -ne "Yes") { $e.Cancel = $true; return }
        $script:abort = $true
        $script:closeAfterTest = $true
        $e.Cancel = $true
        $lblStatus.Text = "İptal ediliyor, test kapatılıyor..."
        return
    }
    $hintForm.Hide()
})

Apply-Theme
Clear-InputBuffer
if ($script:cfg.AutoStart) {
    $mainForm.Add_Shown({ Start-Test })
}
[System.Windows.Forms.Application]::Run($mainForm)
Clear-InputBuffer
