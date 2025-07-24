# Załaduj niezbędne metody z WinAPI do poruszania myszką i klikania
Add-Type -Namespace WinAPI -Name User32 -MemberDefinition @"
    [DllImport("user32.dll")]
    public static extern bool SetProcessDPIAware();
    [DllImport("user32.dll")]
    public static extern bool SetCursorPos(int X, int Y);
    [DllImport("user32.dll")]
    public static extern void mouse_event(int dwFlags, int dx, int dy, int dwData, int dwExtraInfo);
"@

# Flagi do mouse_event
$MOUSEEVENTF_LEFTDOWN = 0x0002
$MOUSEEVENTF_LEFTUP   = 0x0004

# Ustaw DPI-aware (jeżeli możliwe)
[WinAPI.User32]::SetProcessDPIAware() | Out-Null

# Funkcja do uzyskania ścieżki pliku względem skryptu
function Get-ResourcePath {
    param([string]$RelativePath)
    return Join-Path -Path $PSScriptRoot -ChildPath $RelativePath
}

# Funkcja do załadowania konfiguracji JSON lub ustawienia wartości domyślnych
function Load-Config {
    param([string]$Filename)
    $path = Get-ResourcePath $Filename
    if (Test-Path $path) {
        return Get-Content $path -Raw | ConvertFrom-Json
    } else {
        return @{
            MAP_POS               = "0, 0"
            PLACE_FLAG_POS        = "0, 0"
            GUESS_BUTTON_POS      = "0, 0"
            CONTINUE_BUTTON_POS   = "0, 0"
            ERROR_BUTTON_CLOSE_POS= "0, 0"
        }
    }
}

# Funkcja do zamiany "x, y" na liczby
function Parse-Position {
    param([string]$PosString)
    $coords = $PosString -split '\s*,\s*'
    return [int]$coords[0], [int]$coords[1]
}

# Funkcja do ruchu kursorem i kliknięcia
function Move-AndClick {
    param($X, $Y)
    [WinAPI.User32]::SetCursorPos($X, $Y) | Out-Null
    Start-Sleep -Milliseconds 100
    [WinAPI.User32]::mouse_event($MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
    [WinAPI.User32]::mouse_event($MOUSEEVENTF_LEFTUP,   0, 0, 0, 0)
}

# Wyświetlenie i ewentualne ponowne ustawienie współrzędnych
function Prompt-ForCoordinates {
    $choice = Read-Host "Czy chcesz wybrać nowe współrzędne? (y/n)"
    if ($choice.Trim().ToLower() -eq 'y') {
        & python (Get-ResourcePath "find_coordinates.py")
        Write-Host "Restart aplikacji za 2 sekundy..."
        Start-Sleep -Seconds 2
    }
}

# Wyświetl aktualne współrzędne i zwróć konfigurację
function Reload-Coordinates {
    param([string]$Filename)
    $cfg = Load-Config $Filename
    Write-Host "`nAktualne współrzędne:"
    foreach ($k in $cfg.PSObject.Properties.Name) {
        Write-Host "  $k : `"$($cfg.$k)`""
    }
    return $cfg
}

# Główna część skryptu
function Main {
    # Wczytaj i opcjonalnie zmień współrzędne
    $config = Reload-Coordinates "config.json"
    Prompt-ForCoordinates
    $config = Reload-Coordinates "config.json"

    # Parsowanie współrzędnych
    $mapX, $mapY               = Parse-Position $config.MAP_POS
    $placeX, $placeY           = Parse-Position $config.PLACE_FLAG_POS
    $guessX, $guessY           = Parse-Position $config.GUESS_BUTTON_POS
    $continueX, $continueY     = Parse-Position $config.CONTINUE_BUTTON_POS
    $errX, $errY               = Parse-Position $config.ERROR_BUTTON_CLOSE_POS

    Write-Host "`nPrzytrzymaj ESC, aby zakończyć!"
    Start-Sleep -Seconds 2
    3..1 | ForEach-Object {
        Write-Host $_
        Start-Sleep -Seconds 1
    }

    # Przygotuj plik logów
    $logPath = Join-Path $PSScriptRoot "log.txt"
    "Log start" | Out-File -FilePath $logPath -Encoding utf8

    $attempt = 1

    while ($true) {
        # Sprawdź czy wciśnięto ESC
        if ($Host.UI.RawUI.KeyAvailable) {
            $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            if ($key.VirtualKeyCode -eq 27) {
                Write-Host "Program zakończony!"
                break
            }
        }

        # Zapis cyklu
        $timeNow  = Get-Date -Format "HH:mm:ss"
        $entry    = "cycle $attempt at $timeNow"
        Write-Host "`n$entry"
        $entry    | Add-Content -Path $logPath -Encoding utf8
        $attempt++

        # Sekwencja klikania
        Move-AndClick $mapX       $mapY
        Move-AndClick $placeX     $placeY
        Move-AndClick $guessX     $guessY
        Move-AndClick $continueX  $continueY
        Move-AndClick $errX       $errY

        Start-Sleep -Milliseconds 200
    }
}

# Uruchomienie
Main
