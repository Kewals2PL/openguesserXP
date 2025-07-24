# OpenGuesserXP.ps1
Add-Type -AssemblyName System.Windows.Forms,System.Drawing

# --- Funkcje P/Invoke dla myszy i klawiszy ---
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinApi {
    [DllImport("user32.dll")]
    public static extern bool GetCursorPos(out System.Drawing.Point lpPoint);
    [DllImport("user32.dll")]
    public static extern void mouse_event(uint dwFlags, uint dx, uint dy, uint dwData, UIntPtr dwExtraInfo);
    [DllImport("user32.dll")]
    public static extern short GetAsyncKeyState(int vKey);
}
"@

# Flagi do mouse_event
$MOUSEEVENTF_LEFTDOWN  = 0x0002
$MOUSEEVENTF_LEFTUP    = 0x0004

function Get-MousePosition {
    [System.Drawing.Point]$pt = New-Object System.Drawing.Point
    [WinApi]::GetCursorPos([ref]$pt) | Out-Null
    return "$($pt.X), $($pt.Y)"
}

function Do-Click([int]$x, [int]$y) {
    [WinApi]::mouse_event($MOUSEEVENTF_LEFTDOWN, $x, $y, 0, [UIntPtr]::Zero)
    Start-Sleep -Milliseconds 50
    [WinApi]::mouse_event($MOUSEEVENTF_LEFTUP, $x, $y, 0, [UIntPtr]::Zero)
}

# --- Wczytaj lub utwórz config.json ---
$configPath = Join-Path (Get-Location) 'config.json'
if (-Not (Test-Path $configPath)) {
    $default = @{
        MAP_POS              = "0, 0"
        PLACE_FLAG_POS       = "0, 0"
        GUESS_BUTTON_POS     = "0, 0"
        CONTINUE_BUTTON_POS  = "0, 0"
        ERROR_BUTTON_CLOSE_POS = "0, 0"
    }
    $default | ConvertTo-Json | Set-Content $configPath
}

# --- GUI ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "OpenGuesserXP - Ustawienia"
$form.Size = New-Object System.Drawing.Size(350,300)
$form.StartPosition = "CenterScreen"

$fields = @("MAP_POS","PLACE_FLAG_POS","GUESS_BUTTON_POS","CONTINUE_BUTTON_POS","ERROR_BUTTON_CLOSE_POS")
$entries = @{}

for ($i=0; $i -lt $fields.Count; $i++) {
    $y = 10 + $i* thirty
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = $fields[$i]
    $lbl.Location = New-Object System.Drawing.Point(10,$y)
    $lbl.AutoSize = $true
    $form.Controls.Add($lbl)

    $tb = New-Object System.Windows.Forms.TextBox
    $tb.Location = New-Object System.Drawing.Point(130,$y)
    $tb.Size = New-Object System.Drawing.Size(100,20)
    $form.Controls.Add($tb)

    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = "Pobierz"
    $btn.Location = New-Object System.Drawing.Point(240,$y-2)
    $btn.Size = New-Object System.Drawing.Size(75,23)
    $btn.Add_Click({ $tb.Text = Get-MousePosition })
    $form.Controls.Add($btn)

    $entries[$fields[$i]] = $tb
}

# Załaduj istniejące wartości do textboxów
$json = Get-Content $configPath | ConvertFrom-Json
foreach ($f in $fields) { $entries[$f].Text = $json.$f }

# Przycisk Zapisz
$saveBtn = New-Object System.Windows.Forms.Button
$saveBtn.Text = "Zapisz"
$saveBtn.Location = New-Object System.Drawing.Point(130, 10 + $fields.Count* thirty)
$saveBtn.Size = New-Object System.Drawing.Size(75,23)
$saveBtn.Add_Click({
    $h = @{}
    foreach ($f in $fields) { $h[$f] = $entries[$f].Text }
    $h | ConvertTo-Json | Set-Content $configPath
    [System.Windows.Forms.MessageBox]::Show("Zapisano konfigurację","Sukces",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information)
})
$form.Controls.Add($saveBtn)

# Pokaż GUI
[void]$form.ShowDialog()

# --- Główna pętla klikacza ---
# Wczytaj ponownie po zamknięciu GUI
$config = Get-Content $configPath | ConvertFrom-Json

function Parse-XY($s) {
    $a = $s -split ',' | ForEach-Object { $_.Trim() }
    return [int]$a[0], [int]$a[1]
}

$map = Parse-XY $config.MAP_POS
$place = Parse-XY $config.PLACE_FLAG_POS
$guess = Parse-XY $config.GUESS_BUTTON_POS
$cont = Parse-XY $config.CONTINUE_BUTTON_POS
$err  = Parse-XY $config.ERROR_BUTTON_CLOSE_POS

Write-Host "Trwa rozruch... (wciśnij ESC, aby przerwać)" -ForegroundColor Cyan
Start-Sleep -Seconds 3

$logFile = 'log.txt'
"Log start" | Out-File $logFile -Encoding utf8

$attempt = 1
while ($true) {
    # Sprawdź ESC (kod 27)
    if ([WinApi]::GetAsyncKeyState(0x1B) -band 0x8000) {
        Write-Host "Przerwano przez użytkownika." -ForegroundColor Yellow
        break
    }

    $now = (Get-Date).ToString("HH:mm:ss")
    $entry = "cycle $attempt at $now"
    Write-Host $entry
    $entry | Out-File $logFile -Append -Encoding utf8
    $attempt++

    # Kliknięcia
    Do-Click $map[0] $map[1]
    Do-Click $place[0] $place[1]
    Do-Click $guess[0] $guess[1]
    Do-Click $cont[0] $cont[1]
    Do-Click $err[0]  $err[1]

    Start-Sleep -Milliseconds 500
}
