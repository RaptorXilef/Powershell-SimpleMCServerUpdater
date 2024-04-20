<#
.SYNOPSIS
Dieses Skript dient zum Updaten von Minecraft-Servern (Paper, Spigot, Bukkit) und dessen Plugins.
Es bereitet die im Verzeichnis enthaltenen .jar-Dateien für den Upload vor und prüft Dateiabhängigkeiten.
Es sortiert veraltete Plugins und Serverversionen aus und lädt nur die jeweils neuste Verstion auf den Server hoch.
Im Anschluss startet es den Server Automatisch neu.

.DESCRIPTION
Dieses Skript wurde von Felix Maywald aka RaptorXilef erstellt.
Es ist freie Software: Du kannst es frei nutzen und weitergeben unter den Bedingungen der MIT-Lizenz.
Das Skript darf kostenfrei genutzt werden, darf jedoch nicht für kommerzielle Zwecke verwendet oder weiterverarbeitet werden.
Solltest du es Komerziell nutzen wollen oder es in einer Kommerzielen Software einbinden wollen, brauchst du vorher meine Schriftliche Erlaubnis.

.NOTES
Skriptname: SimpleMCServerUpdater
Skriptalias: MCServerAutoJarFileUploadAndRestart
Autor: Felix Maywald; RaptorXilef
GitHub: https://github.com/RaptorXilef/
Erstelldatum: 07.04.2024
Letzte Änderung: 20.04.2024
Version: 1.0.0
#>


<#
#################################################################################################

In diesem Abschnitt können alle nötigen Variablen und Logindaten festgelegt werden.

#################################################################################################
#>
# INFO: Alle Zeilen die mit einem # beginnen, werden nicht geladen und werden für Kommentare und Erklärungen genutzt.
# Öffne diese Datei am bessten mit Notepad++ oder einem anderen Codeeditor um besser zu sehen, was du bearbeiten sollst.

<# ALLGEMEIN #>
# Setze den Wert von $debug nach dem ersten erfolgreichen Start auf $false um das Skript normal zu nutzen.
#  Standartmäßig ist er auf $true gesetzt, damit beim erststart deine Anmeldedaten für 
#  FTP, MCRcon und Server-Ping geprüft
#  und damit alle nötigen Ordner erstellt werden.
# Wenn ein Fehler im Skript auftritt, setze den Wert wieder auf $true
#   so werden die zusätzlichen Fehlerprüfungen im Hintergrund aktiviert, 
#   welche zumeist genau ausgeben, bei welchen Angaben im Config-Teil 
#   ein Fehler ist.
# Standart: $debug = $false
# Mögliche Werte: $true / $false
$debug = $false



# Arbeitsverzeichnisse und Dateien / FOLDERS
# Der Ort an dem das Skript arbeiten soll:
# Standart: $currentPath = Get-Location      <- ruft das Verzeichnis auf, in welchem sich das Skript selbst befindet
# Alternativ: $currentPath = ".\"
    $currentPath = Get-Location

# Ordnernamen:
# Hier kannst du individuelle Namen oder Pfade für die einzelnen Ordner anlegen
# Möchtest du z.B. die verarbeiteten Plugins unter Dokumente\MinecraftPlugins ablegen, könntest du z.B folgendes eintragen:
# $destinationPathForPluginJars = "%USERPROFILE%\Documents\MinecraftPlugins" <---- Neuen Pfad angeben
# Standart v1.: VARIABLE = Join-Path -Path $currentPath -ChildPath "<OrdnerName>" <---- Ordnernamen ändern
# Standart v2.: VARIABLE = .\<OrdnerName> 
    $sourcePathUpdatePluginFiles = Join-Path -Path $currentPath -ChildPath "update_Plugins"
    $sourcePathInstallPluginFiles = Join-Path -Path $currentPath -ChildPath "install_Plugins"
    $destinationPathForPluginJars = Join-Path -Path $currentPath -ChildPath "HistoryPluginJars"
    $sourcePathUpdateMcServerFiles = Join-Path -Path $currentPath -ChildPath "update_McServerVersion"
    $destinationPathForMcServerJars = Join-Path -Path $currentPath -ChildPath "HistoryMCServerJars"



<# Prüfung ob Minecraftserver .jar Dateien existieren #>
# Die Reihenfolge bestimmt die Priorität: 
#   Heißt im Standartbeispiel: paper*.jar wird immer behalten auch wenn eine neuere 
#   spigot oder craftbukkit Version vorhanden ist. Ist keine paper Version vorhanden, 
#   hat spigot Vorrang vor craftbukkit.
# Standart: $mcServerFileNamePatterns = @("paper*.jar", "spigot*.jar", "craftbukkit*.jar")
    $mcServerFileNamePatterns = @("paper*.jar", "spigot*.jar", "craftbukkit*.jar")

# Nitrado: https://server.nitrado.net/deu
# Zielname der Minecraftserver .jar
# Standart bei Nitrado: $mcServerFileNameDestination = "craftbukkit.jar"
# Standart bei localhost: $mcServerFileNameDestination = "mcserver.jar"
    $mcServerFileNameDestination = "craftbukkit.jar"



<# FTP #>
# Logindaten
<# Standart:
    $ftpHostname = "hostname"
    $ftpUsername = "username"
    $ftpPassword = "password"
#>
# HIER FTP DATEN EINTRAGEN!
    $ftpHostname = "hostname"
    $ftpUsername = "username"
    $ftpPassword = "password"
# FTP-Pfade
<# Standart bei Nitrado:
    $ftpDirectoryCraftbukkitJarPath = "/minecraftbukkit"
    $ftpDirectoryPlugins = "/minecraftbukkit/plugins"
    $ftpDirectoryPluginUpdate = "/minecraftbukkit/plugins/update"
#>
    $ftpDirectoryCraftbukkitJarPath = "/minecraftbukkit"
    $ftpDirectoryPlugins = "/minecraftbukkit/plugins"
    $ftpDirectoryPluginUpdate = "/minecraftbukkit/plugins/update"

# Das Passwort in einem SecureString verschlüsseln, damit es nicht von externer Software abgefangen werden kann (Nicht verändern!)
    $ftpSecurePassword = ConvertTo-SecureString $ftpPassword -AsPlainText -Force



<# MCRcon #>
<# Wie? Rcon muss erst in der "server.properties" aktiviert werden!
    server.properties:
        rcon.port=<DEIN WUNSCHPORT>  # <--- Empfohlen Gameport + 5
        broadcast-rcon-to-ops=true
        enable-rcon=true
        rcon.password=<Dein Passwort>
#>
# Logindaten: 
<# Standart:
    $mcRconSourcePath = $currentPath + "\MCRcon.exe" # <--- Pfad zur MCRcon.exe
alternativ:     $mcRconSourcePath = ".\" + "MCRcon.exe" # <--- Pfad zur MCRcon.exe
    $mcRconServerIP = "ServerIP" # <--- Identisch mit der Gameserver IP
    $mcRconPort = "GamePort + 5"
    $mcRconPassword = "<Dein Passwort>"
#>
# HIER RCON DATEN EINTRAGEN!
$mcRconServerIP = "gameServerIP"
$mcRconPort = "rconPort"
$mcRconPassword = "rconPassword"
# Pfad zu MCRcon:
$mcRconSourcePath = Join-Path -Path $currentPath -ChildPath "MCRcon.exe"
# Lasse den Wert auf 5 und 60 für 5 Minuten auf Restart prüfen (alle 5 Sek einen Verbindungsversuch + 60x Wiederhohlen vor Abbruch)
$mcRconTimeWaitBetweenTests = 5
$mcRconMaxPingAttempts = 60
$mcRconCommandSave = "save-all"
$mcRconCommandRestart = "restart"
$mcRconCommandTestOnline = "bukkit:version"
$mcRconCommandTestPlugins = "plugins"
# Downloadseite von MCRcon.exe
$urlMCRcon = "https://github.com/Tiiffi/mcrcon/releases/latest"



<# Anderes #>
$urlGitHubIssues = "https://github.com/RaptorXilef/Powershell-SimpleMCServerUpdater/issues"


# DIESER TEIL WIRD IN EINEM KOMMENDEN UPDATE ENTFERNT!
<# MC Ping Server #>
# Logindaten:
<# Standart:
    $pingServerIP = "ServerIpOhnePort"
    $pingServerPort = "GameServerPort"   # <--- Der Port über den man auch mit dem Minecraftclienten online geht. Minecraft Standart ist 25565
#>
#$pingServerIP = "ServerIpOhnePort"
#$pingServerPort = "GameServerPort"
# Lasse den Wert auf 5 und 60 für 5 Minuten auf Restart prüfen (alle 5 Sek einen Verbindungsversuch + 60x Wiederhohlen vor Abbruch)
#$pingServerTimeWaitBetweenTests = 5
#$pingServerMaxAttempts = 60


























<#
#################################################################################################

In diesem Abschnitt werden alle Funktionen definiert.

#################################################################################################
#>

# Funktions https://learn.microsoft.com/de-de/powershell/scripting/learn/ps101/09-functions?view=powershell-7.4

function New-CheckFileExistenceAndCreateIfNot {
    param (
        [string]$filePath,
        [string[]]$Content
    )

    # Check if the file exists
    if (-not (Test-Path -Path $filePath)) {
        # If not, create the file with content
        $Content | Out-File -filePath $filePath -Force
        if ($debug -eq $true) {Write-Host "    DEBUG: Datei erstellt: $filePath" -ForegroundColor Gray; Write-Host ""; Write-Host ""} else {Clear-Host}
    } else {
        if ($debug -eq $true) {Write-Host "    DEBUG: Datei vorhanden: $filePath" -ForegroundColor Gray}
    }
}

function New-CheckFolderExistenceAndCreateIfNot {
    param (
        [string]$FolderPath
    )

    # Check if the folder exists
    if (-not (Test-Path -Path $FolderPath)) {
        # If not, create the folder
        New-Item -ItemType Directory -Path $FolderPath -Force
        if ($debug -eq $true) {Write-Host "    DEBUG: Ordner erstellt: $FolderPath" -ForegroundColor Gray; Write-Host ""; Write-Host ""} else {Clear-Host}
    } else {
        if ($debug -eq $true) {Write-Host "    DEBUG: Ordner vorhanden: $FolderPath" -ForegroundColor Gray}
    }
}

function Test-FileExistence {
    param (
        [string]$filePath
    )

    # Check if the file exists
    if (Test-Path -Path $filePath) {
        if ($debug -eq $true) {Write-Host "    DEBUG: Datei vorhanden: $filePath" -ForegroundColor Gray}
    } else {
        if ($debug -eq $true) {Write-Host "    DEBUG: Datei fehlt: $filePath" -ForegroundColor Red}
    }
}

function Test-FtpConnectionDebug {
    param (
        [string]$ftpHostname,
        [string]$ftpDirectoryCraftbukkitJarPath,
        [string]$ftpUsername,
        [SecureString]$ftpSecurePassword
    )

    try {
        # Erstellen des FtpWebRequest-Objekts
        $ftpSession = [System.Net.FtpWebRequest]::Create("ftp://${ftpHostname}:${ftpDirectoryCraftbukkitJarPath}")
        $ftpSession.Credentials = New-Object System.Net.NetworkCredential($ftpUsername, $ftpSecurePassword)
        $ftpSession.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectory
        
        # Ausführen des FTP-Requests
        $ftpResponse = $ftpSession.GetResponse()

        Start-Sleep 1
        Write-Host "    DEBUG: FTP-Anmeldedaten sind korrekt!" -ForegroundColor White
        return $ftpResponse

    } catch {
        # Fehlermeldung ausgeben, dass die Verbindung zum FTP-Server fehlgeschlagen ist
        Write-Host "    DEBUG: Fehler: Verbindung zum FTP-Server konnte nicht hergestellt werden. Überprüfen Sie die Anmeldedaten und die Netzwerkverbindung." -ForegroundColor Red
    } finally {
        # Zerstören des FtpWebRequest-Objekts und Freigeben von Ressourcen
        if ($ftpSession) {
            $ftpSession = $null
        }
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
    }
}

# Funktion zum Prüfen der Serververfügbarkeit per Ping
function Ping-Server {
    param(
        [string]$ip,
        [int]$port
    )
    $pingResult = Test-NetConnection -ComputerName $ip -port $port -InformationLevel Quiet
    return $pingResult
}

# Funktion zum Prüfen der Serververfügbarkeit per Ping
function Test-PingServerDebug {
    param(
        [string]$ip,
        [int]$port
    )
    $pingResult = Ping-Server -ip $ip -port $port
    Start-Sleep 1
    if ($debug -eq $true) {   
        if ($pingResult -eq $true) {
            Write-Host "DEBUG: Die eingetragenen Daten für den Ping sind korrekt. Und der Server ist Online." -ForegroundColor White
        } elseif ($pingResult -eq $false) {
            Write-Host "DEBUG: Die eingetragenen Daten für den Ping sind falsch oder der Server ist Offline." -ForegroundColor Red
        } else {
            Write-Host "DEBUG: Beim Ping ist ein unbekannter Fehler aufgetreten!" -ForegroundColor Red
        }
    }
    return $pingResult
}

# Funktion zum Prüfen der Serververfügbarkeit per Ping
function Test-PingServerOnline {
    param(
        [string]$ip,
        [int]$port,
        [int]$attempts = 0,
        [int]$maxAttempts = 120,
        [int]$sleepTime = 5
    )
    
    Write-Host ""; Write-Host ""; Write-Host "Warte auf Rückmeldung vom Server. Bitte warten..." -ForegroundColor Yellow
    # Wiederholte Versuche, den Server zu pingen, um seine Verfügbarkeit zu überprüfen
    do {
        $pingAttempts++
        $pingResult = Ping-Server -ip $ip -port $port 2>$null # Unterdrückt die Fehlerausgabe von Ping-Server
        if ($pingResult -eq $true) {
            Write-Host ""; Write-Host ""; Write-Host "Der Server wurde gestartet. Bitte warte noch, bis er alle Plugins geladen hat." -ForegroundColor Green; Write-Host "Warte auf Rückmeldung vom Server. Bitte warten..." -ForegroundColor Yellow
            break
        } else {
            $attempts++
            if ($debug -eq $true) {
                Write-Host "DEBUG: Versuch $($attempts): Server mit Ping nicht erreicht. Bitte warten." -ForegroundColor Gray
                Write-Host "DEBUG: Server ist noch offline. Wiederhole den Ping-Versuch in 5 Sekunden." -ForegroundColor Gray
            }
            Start-Sleep -Seconds $sleepTime
        }
    } while ($true)

    if ($debug -eq $true) {   
        if ($pingResult -eq $true) {
            Write-Host "DEBUG: Die eingetragenen Daten für den Ping sind korrekt. Und der Server ist Online." -ForegroundColor Gray
        } elseif ($pingResult -eq $false) {
            Write-Host "DEBUG: Die eingetragenen Daten für den Ping sind falsch oder der Server ist Offline." -ForegroundColor Red
        } else {
            Write-Host "DEBUG: Beim Ping ist ein unbekannter Fehler aufgetreten!" -ForegroundColor Red
        }
    }
    return $pingResult
}

# Funktion zum Überprüfen, ob MCRcon eine Verbindung aufbauen kann, bzw. ob der Server vollständig gestartet ist
function Test-MCRconConnectionDebug {
    param (
        [string]$filePath,
        [string]$ip,
        [string]$port,
        [string]$pw,
        [int]$attempts = 0,
        [int]$attemptsMax = 2,
        [int]$sleepTime = 5
    )

        while ($attempts -lt $attemptsMax) {
            # $response = & $filePath -H $ip -P $port -p $pw "help"
            # if ($response -like "*Um die Hilfe der Konsole zu sehen,*") {
            # $response = & $filePath -H $ip -P $port -p $pw "ping"
            # if ($response -like "*Pong!*") {
            $response = & $filePath -H $ip -P $port -p $pw "bukkit:version"
            Start-Sleep 1
    
            if ($response -like "*This server is running*") {
                Write-Host "    DEBUG: Die eingetragenen MCRcon Daten sind korrekt und der Server ist Online." -ForegroundColor White
                Write-Host "      DEBUG: Antwort des Servers: " -ForegroundColor Gray
                Write-Host "      $response" -ForegroundColor DarkGray
                return
            } else {
                $attempts++
                Write-Host "$response"
                Write-Host "    DEBUG: Versuch $($attempts): MCRcon Antwortet nicht mehr. Bitte warten." -ForegroundColor Red
                Write-Host "      DEBUG: Starte weiteren Versuch" -ForegroundColor Gray
                Start-Sleep -Seconds $sleepTime
            }
        }
    
        Write-Host "DEBUG: Maximale Anzahl von Versuchen erreicht. Die Verbindung konnte nicht hergestellt werden." -ForegroundColor Red
        Write-Host "DEBUG: Die eingetragenen MCRcon Daten sind falsch oder der Server ist Offline." -ForegroundColor Red
    }

    function Connect-MCRcon {
        param (
            [string]$filePath,
            [string]$ip,
            [string]$port,
            [string]$pw,
            [string]$command = "save-all",
            [int]$sleepTime = 1,
            [int]$attempts = 0,
            [int]$attemptsMax = 120
        )

            #if ($debug -eq $true) {Write-Host "      DEBUG: Übergebe Befehl: $command an MCRcon" -ForegroundColor Gray}

            while ($attempts -lt $attemptsMax) {
                $response = & $filePath -H $ip -P $port -p $pw $command  2>$null # Unterdrückt die Fehlerausgabe von MCRcon
        
                if ($response -like "*This server is running*") {
                    Write-Host ""
                    Write-Host "     $response" -ForegroundColor Cyan
                    return
                } elseif ($response -like "*Checking version, please wait*") {
                    Write-Host ""
                    Write-Host "    Der Server wurde erfolgreich neugestartet und hat alle Plugins wurden geladen." -ForegroundColor Green
                    Write-Host "     Antwort des Servers: " -ForegroundColor Green
                    Write-Host "     $response" -ForegroundColor Cyan
                    return
                } elseif ($response -like "*Saving the game*") {
                    Write-Host ""
                    Write-Host "    Die Daten auf dem GameServer wurde erfolgreich gespeichert." -ForegroundColor Green
                    return
                } elseif ($response -like "*Server Plugins*") {
                    Write-Host ""
                    Write-Host "    Folgende Plugins wurden erfolgreich geladen:" -ForegroundColor DarkYellow
                    Write-Host "     $response" -ForegroundColor Green
                    return
                } elseif ($command -eq "version") {
                    $attempts++
                    if ($debug -eq $true) {
                        Write-Host "      DEBUG: Versuch $($attempts): MCRcon: Server noch nicht erreichbar. Bitte warten..." -ForegroundColor Red
                        Write-Host "      DEBUG:   Starte weiteren Verbindungsversuch" -ForegroundColor Gray
                    }
                } elseif ($command -eq "restart") {
                    Write-Host ""; Write-Host "    Der Server wird nun neu gestartet. Bitte warten..." -ForegroundColor DarkYellow
                    return
                } elseif ([string]::IsNullOrEmpty($command) -and [string]::IsNullOrEmpty($response)) {
                    if ($debug -eq $true) {Write-Host "DEBUG: Der übergebene Parameter der Variablen '$command ist leer oder nicht definiert. Die Variable `$response ist leer oder nicht definiert. Breche Vorgang ab!" -ForegroundColor Red}
                    return
                } elseif ([string]::IsNullOrEmpty($response) -and -not($command -eq "version")) {
                    if ($debug -eq $true) {Write-Host "      DEBUG: Noch keine Antwort vom Server." -ForegroundColor DarkGray; Write-Host "      DEBUG: Warte auf Server..." -ForegroundColor DarkGray}
                    $attempts++
                } elseif (-not($command -eq "version")) {
                    if ($debug -eq $true) {Write-Host "      DEBUG: Die Variable `$response enthält folgenden Inhalt: " -ForegroundColor DarkGray}
                    Write-Host "    $response" -ForegroundColor Cyan
                    return
                } else {
                    if ($debug -eq $true) {Write-Host "      DEBUG: Die Variable `$response ist leer oder nicht definiert." -ForegroundColor Red}
                    $attempts++
                }


                # if ($debug -eq $true) {Write-Host "DEBUG: Warte $sleepTime Sekunden..." -ForegroundColor Gray}
                Start-Sleep $sleepTime
                
            }
        
            Write-Host "      DEBUG: Maximale Anzahl von Versuchen erreicht. Die Verbindung zum Server konnte nicht wiederhergestellt werden." -ForegroundColor Red
        }

    function Disable-ChooseDebugMode {
        param (
            [ref]$debug
        )
    
        # Informiere den Benutzer über die Prüfung der Dateiabhängigkeiten und Anmeldedaten
        Write-Host ""; Write-Host ""
        Write-Host "DEBUG: Alle Dateiabhängigkeiten und Anmeldedaten wurden geprüft." -ForegroundColor DarkYellow
    
        do {
            # Frage den Benutzer, ob er den Vorgang im DEBUG-Modus fortsetzen möchte
            Write-Host ""; Write-Host ""; Write-Host "Möchten Sie den Vorgang im DEBUG-Modus fortsetzen?" -ForegroundColor Cyan
            $continue = Read-Host "    (ja/nein)/(j/n)"
    
            # Überprüfe die Benutzerantwort
            switch ($continue.ToLower()) {
                'ja' {'      Skript wird im DEBUG-Modus fortgesetzt.'}
                'j' {'      Skript wird im DEBUG-Modus fortgesetzt.'}
                'nein' {
                    $debug.Value = $false
                    Write-Host "    DEBUG-Modus wurde deaktiviert!" -ForegroundColor DarkCyan
                }
                'n' {
                    $debug.Value = $false
                    Write-Host "    DEBUG-Modus wurde deaktiviert!" -ForegroundColor DarkCyan
                }
                default {
                    Write-Host "  Ungültige Eingabe. Bitte geben Sie 'ja' oder 'nein' ein." -ForegroundColor Red
                    $continue = $null  # Setze die Eingabe zurück, um die Schleife erneut auszuführen
                }
            }
        } while (-not $continue)
    }
    

# Überprüft, ob sich in den Ordnern .jar Fildes zum hochladen befinden, wenn nicht, wird Skript beendet
function Test-JarFilesExistence {
    param (
        [string]$sourcePathInstallPluginFiles,
        [string]$sourcePathUpdatePluginFiles,
        [string]$sourcePathUpdateMcServerFiles
    )

    # Überprüfe, ob .jar-Dateien in den Verzeichnissen existieren
    $installPluginFiles = Get-ChildItem -Path $sourcePathInstallPluginFiles -Filter "*.jar" -File
    $updatePluginFiles = Get-ChildItem -Path $sourcePathUpdatePluginFiles -Filter "*.jar" -File
    $updateMcServerFiles = Get-ChildItem -Path $sourcePathUpdateMcServerFiles -Filter "*.jar" -File

    if (-not $installPluginFiles -and -not $updatePluginFiles -and -not $updateMcServerFiles) {
        # Keine .jar-Dateien gefunden, Skript beenden
        Write-Host "Keine Plugin- oder MCServer-Updates gefunden." -ForegroundColor Yellow
        Write-Host "Beende Skript!"
        PAUSE
        EXIT
    }

    # Fortsetzung des Skripts
    <# DEBUG #>
    if ($debug -eq $true) {Write-Host ""; Write-Host "    DEBUG: Es wurden .jar-Dateien gefunden. Das Skript wird fortgesetzt." -ForegroundColor White}
}

# Überprüft, ob sich in den Ordnern .jar Fildes zum hochladen befinden, wenn nicht, wird Skript beendet
function Test-JarFilesExistenceInFolder {
    param (
        [string]$sourcePathFolderJarFiles
    )

    if ($debug -eq $true) {Write-Host ""; Write-Host ""; Write-Host "DEBUG: Prüfe ob *.jar in $sourcePathFolderJarFiles existiert." -ForegroundColor DarkYellow}

    # Überprüfe, ob .jar-Dateien in den Verzeichnissen existieren
    $folderWithJarFiles = Get-ChildItem -Path $sourcePathFolderJarFiles -Filter "*.jar" -File

    if (-not $folderWithJarFiles) {
        # Keine .jar-Dateien gefunden
        if ($debug -eq $true) {Write-Host "    DEBUG: Es wurden keine .jar-Dateien in $sourcePathFolderJarFiles gefunden. Überspringe Vorgang." -ForegroundColor DarkGray}
        return $false
    } else {
        if ($debug -eq $true) {Write-Host "    DEBUG: Es wurden .jar-Dateien in $sourcePathFolderJarFiles gefunden. Dateien werden verarbeitet." -ForegroundColor Gray}
        return $true
    }
}

# Gibt aus, weiche .jar Files sind in welchem Ordner befinden
function Write-JarFiles {
    param (
        [string]$destinationPathForMcServerJars,
        [string]$sourcePathUpdateMcServerFiles,
        [string]$destinationPathForPluginJars,
        [string]$sourcePathInstallPluginFiles,
        [string]$sourcePathUpdatePluginFiles
    )

    # Überprüfe, ob .jar-Dateien in den Verzeichnissen existieren
    $historyMcServerFiles = Get-ChildItem -Path $destinationPathForMcServerJars -Filter "*.jar" -File
    $updateMcServerFiles = Get-ChildItem -Path $sourcePathUpdateMcServerFiles -Filter "*.jar" -File
    $historyPluginFiles = Get-ChildItem -Path $destinationPathForPluginJars -Filter "*.jar" -File
    $installPluginFiles = Get-ChildItem -Path $sourcePathInstallPluginFiles -Filter "*.jar" -File
    $updatePluginFiles = Get-ChildItem -Path $sourcePathUpdatePluginFiles -Filter "*.jar" -File
    

    # Liste der gefundenen .jar-Dateien ausgeben
    if ($historyMcServerFiles) {
        Write-Host ""
        Write-Host "DEBUG:  # Folgende .jar-Dateien wurden im Verzeichnis '$destinationPathForMcServerJars' gefunden:" -ForegroundColor White
        $historyMcServerFiles | ForEach-Object { "   - " + $_.Name }
    }

    if ($updateMcServerFiles) {
        Write-Host ""
        Write-Host "DEBUG:  # Folgende .jar-Dateien wurden im Verzeichnis  '$sourcePathUpdateMcServerFiles' gefunden:" -ForegroundColor White
        $updateMcServerFiles | ForEach-Object { "   - " + $_.Name }
    }

    if ($historyPluginFiles) {
        Write-Host ""
        Write-Host "DEBUG:  # Folgende .jar-Dateien wurden im Verzeichnis  '$destinationPathForPluginJars' gefunden:" -ForegroundColor White
        $historyPluginFiles | ForEach-Object { "   - " + $_.Name }
    }

    if ($installPluginFiles) {
        Write-Host ""
        Write-Host "DEBUG:  # Folgende .jar-Dateien wurden im Verzeichnis  '$sourcePathInstallPluginFiles' gefunden:" -ForegroundColor White
        $installPluginFiles | ForEach-Object { "   - " + $_.Name }
    }
    
    if ($updatePluginFiles) {
        Write-Host ""
        Write-Host "DEBUG:  # Folgende .jar-Dateien wurden im Verzeichnis  '$sourcePathUpdatePluginFiles' gefunden:"  -ForegroundColor White
        $updatePluginFiles | ForEach-Object { "   - " + $_.Name }
    }
}

function Move-SortJarFiles {
    param (
        [string]$sourcePathUpdatePluginFiles,
        [string]$sourcePathInstallPluginFiles,
        [string]$sourcePathUpdateMcServerFiles,
        [string[]]$mcServerFileNamePatterns
    )

    # Schritt 1: Verschiebe passende Dateien nach $sourcePathUpdateMcServerFiles
    $sortSourceDirs = @($sourcePathUpdatePluginFiles, $sourcePathInstallPluginFiles)
    $sortDestinationDir = $sourcePathUpdateMcServerFiles

    foreach ($dir in $sortSourceDirs) {
        $files = Get-ChildItem -Path $dir -Filter "*.jar" -File

        foreach ($file in $files) {
            $matchedPattern = $false

            foreach ($pattern in $mcServerFileNamePatterns) {
                if ($file.Name -like $pattern) {
                    $matchedPattern = $true
                    break
                }
            }

            if ($matchedPattern) {
                # Verschiebe zur $sortDestinationDir
                Move-Item -Path $file.FullName -Destination $sortDestinationDir -Force
                if ($debug -eq $true) {Write-Host "DEBUG: Datei $($file.Name) wurde nach $sortDestinationDir verschoben." -ForegroundColor Gray}
            }
        }
    }

    # Schritt 2: Verschiebe nicht passende Dateien zurück nach $sourcePathUpdatePluginFiles
    $filesInUpdateMcServer = Get-ChildItem -Path $sortDestinationDir -Filter "*.jar" -File

    foreach ($file in $filesInUpdateMcServer) {
        $matchedPattern = $false

        foreach ($pattern in $mcServerFileNamePatterns) {
            if ($file.Name -like $pattern) {
                $matchedPattern = $true
                break
            }
        }

        if (-not $matchedPattern) {
            # Verschiebe zur $sourcePathUpdatePluginFiles
            Move-Item -Path $file.FullName -Destination $sourcePathUpdatePluginFiles -Force
            if ($debug -eq $true) {Write-Host "DEBUG: Datei $($file.Name) wurde nach $sourcePathUpdatePluginFiles verschoben." -ForegroundColor Gray}
        }
    }
}

# Sortiere alle bis auf die neuste Serverversion aus. Dabei hat die Serverversion mit dem Namen aus Array 0 die höchste priorität. Die Priorität fällt mit steigender Arrayzahl.
# Heißt im Standartbeispiel: paper*.jar wird immer behalten auch wenn eine neuere spigot oder craftbukkit Version vorhanden ist. Ist keine paper Version vorhanden, hat spigot Vorrang vor craftbukkit.
function Move-SortMcServerJarsToHistoryFolder {
    param (
        [string]$destinationPathForMcServerJars,
        [string]$sourcePathUpdateMcServerFiles,
        [array]$filePatterns,
        [string]$mcServerFileNameDestination
    )

    # Wenn "MinecraftServerVersionen\"-Ordner nicht vorhanden ist, erstellen
    if (-not (Test-Path $destinationPathForMcServerJars)) {
        New-Item -ItemType Directory -Path $destinationPathForMcServerJars | Out-Null
    }

    $sortedFiles = @()

    foreach ($pattern in $filePatterns) {
        $matchingFiles = Get-ChildItem -Path $sourcePathUpdateMcServerFiles -File | Where-Object { $_.Name -like $pattern } | Sort-Object LastWriteTime -Descending
        $sortedFiles += $matchingFiles
    }

    if ($sortedFiles.Count -gt 0) {
        # Verschieben aller Dateien außer der neuesten nach "MinecraftServerVersionen"
        $filesToMove = $sortedFiles | Select-Object -Skip 1
        foreach ($file in $filesToMove) {
            Move-Item $file.FullName -Destination $destinationPathForMcServerJars -Force
            if ($debug -eq $true) {Write-Host "DEBUG: Datei $($file.Name) wurde nach $destinationPathForMcServerJars verschoben." -ForegroundColor Gray}
        }

        # Kopiere die neueste Datei nach "MinecraftServerVersionen"
        $latestFile = $sortedFiles[0]
        $newFilePath = Join-Path -Path $destinationPathForMcServerJars -ChildPath $latestFile.Name
        Copy-Item $latestFile.FullName -Destination $newFilePath -Force
        if ($debug -eq $true) {Write-Host "DEBUG: $(Split-Path -Leaf $latestFile.FullName) wurde nach $(Split-Path -Leaf $newFilePath) kopiert." -ForegroundColor Gray}

        # Umbenennen der Originaldatei zu "$mcServerFileNameDestination"
        $originalFilePath = Join-Path -Path $sourcePathUpdateMcServerFiles -ChildPath $latestFile.Name
        Rename-Item -Path $originalFilePath -NewName $mcServerFileNameDestination -Force
        if ($debug -eq $true) {Write-Host "DEBUG: $(Split-Path -Leaf $originalFilePath) wurde zu $mcServerFileNameDestination umbenannt." -ForegroundColor Gray}
    }
}

function Connect-UploadJarToFTPServer {
    param (
        [string]$sourcePath,
        [string]$ftpHostname,
        [string]$ftpUsername,
        [SecureString]$ftpSecurePassword,
        [string]$ftpDirectory
    )

    # Erhalte alle .jar-Dateien im angegebenen Pfad
    $jarFiles = Get-ChildItem -Path $sourcePath -File -Filter "*.jar"

    # Überprüfen, ob mindestens eine .jar-Datei vorhanden ist
    if ($jarFiles.Count -gt 0) {
        Write-Host ""; Write-Host ""; Write-Host "Bitte warten! Upload von $($jarFiles.Count) Datei/en läuft..." -ForegroundColor Yellow

        try {
            # Erstellen des WebClient-Objekts
            $webClient = New-Object System.Net.WebClient

            # Anmeldung durchführen
            $credentials = New-Object System.Net.NetworkCredential($ftpUsername, $ftpSecurePassword)
            $webClient.Credentials = $credentials

            foreach ($jarFile in $jarFiles) {
                $ftpUrl = "ftp://$ftpHostname$ftpDirectory/$($jarFile.Name)"
                $webClient.UploadFile($ftpUrl, "STOR", $jarFile.FullName)
                
                Write-Host "  - '$($jarFile.Name)' erfolgreich hochgeladen" -ForegroundColor Green
            }

            # Lösche alle .jar-Dateien im Quellverzeichnis
            foreach ($jarFile in $jarFiles) {
                Remove-Item $jarFile.FullName -Force
            }

        } catch {
            # Fehlermeldung ausgeben, wenn während des Uploads ein Fehler auftritt
            Write-Host "DEBUG: Fehler beim Hochladen der Datei: $_" -ForegroundColor Red
            Pause
            EXIT
        }
    } else {
        Write-Host "DEBUG: Es sind keine *.jar Dateien vorhanden! Unbekannter Fehler! Wenn dieser Fehler auftritt wurde eine Variable falsch gesetzt. Dieser Fehler hätte nie erscheinen dürfen. Bitte melde Ihn mir auf: $urlGitHubIssues Überspringe den Upload." -ForegroundColor DarkRed
    }
}

function Copy-MinecraftPluginsToArchiv {
    param (
        [string]$sourcePath,
        [string]$destinationPath,
        [System.IO.FileInfo[]]$pluginFiles
    )

    if ($debug -eq $true) {Write-Host ""; Write-Host ""; Write-Host "DEBUG: Plugins werden von $sourcePath nach $destinationPath kopiert!" -ForegroundColor DarkYellow}
        
    # Kopiere alle Minecraftplugins in den angegebenen Pfad
    foreach ($pluginFile in $pluginFiles) {
        $baseFileName = $pluginFile.BaseName
        $fileExtension = $pluginFile.Extension

        # Ziel-Pfad festlegen
        $destinationFile = Join-Path -Path $destinationPath -ChildPath $pluginFile.Name

        # Überprüfe, ob die Datei bereits im Zielverzeichnis existiert
        $counter = 0
        while (Test-Path $destinationFile) {
            $counter++
            $destinationFile = Join-Path -Path $destinationPath -ChildPath "$baseFileName`_$('{0:D3}' -f $counter)$fileExtension"
        }

        # Datei kopieren
        Copy-Item -Path $pluginFile.FullName -Destination $destinationFile -Force
    }

    if ($debug -eq $true) {Write-Host "    DEBUG: Dateien erfolgreich von $sourcePath nach $destinationPath kopiert!" -ForegroundColor Gray}
}

function Remove-PreparePluginCsvAndCleanup {
    param (
        [string]$sourcePath,
        [System.IO.FileInfo[]]$pluginFiles
    )

    if ($debug -eq $true) {Write-Host ""; Write-Host ""; Write-Host "DEBUG: Entferne überflüssige und veraltete Plugins aus $sourcePath !" -ForegroundColor DarkYellow}

    # CSV-Datei erstellen und Spaltenköpfe schreiben
    $csvPath = Join-Path -Path $sourcePath -ChildPath "Plugins.csv"
    "Dateiname;PluginName;PluginVersion" | Out-File -filePath $csvPath -Encoding utf8

    # Für jede .jar-Datei die Versionsnummer und den Pluginnamen extrahieren und in die CSV-Datei schreiben
    foreach ($pluginFile in $pluginFiles) {
        # ZipArchive-Objekt erstellen
        $zip = [System.IO.Compression.ZipFile]::OpenRead($pluginFile.FullName)

        # Pfad innerhalb des .jar-Archivs zur plugin.yml-Datei
        $pluginYmlPath = "plugin.yml"

        # Die plugin.yml-Datei aus dem .jar-Archiv extrahieren
        $pluginYmlEntry = $zip.Entries | Where-Object { $_.FullName -eq $pluginYmlPath }
        $stream = $pluginYmlEntry.Open()

        # StreamReader zum Lesen des Inhalts der plugin.yml-Datei erstellen
        $reader = New-Object System.IO.StreamReader($stream)
        $pluginYmlContent = $reader.ReadToEnd()

        # Die Versionsnummer und den Pluginnamen aus der plugin.yml-Datei extrahieren
        $version = ($pluginYmlContent -split "`n" | Where-Object { $_ -match "^version:" }) -replace "version:\s*", ""
        $pluginName = ($pluginYmlContent -split "`n" | Where-Object { $_ -match "^name:" }) -replace "name:\s*", ""
        
        # Den Zeilenumbruch aus dem Pluginnamen entfernen
        $pluginName = $pluginName.Replace("`r","").Replace("`n","")
        
        # Leerzeichen am Ende der Versionsnummer entfernen
        $version = $version.TrimEnd()

        # Ergebnis in die CSV-Datei schreiben, wenn Version nicht leer ist
        if ($version -ne "") {
            "$($pluginFile.Name);$pluginName;$version" | Out-File -filePath $csvPath -Encoding utf8 -Append
        }

        # Ressourcen freigeben
        $reader.Close()
        $stream.Close()
        $zip.Dispose()
    }

    # Inhalt der CSV-Datei lesen
    $csvContent = Import-Csv -Path $csvPath -Delimiter ";" 

    # Für jedes Plugin die neueste Version ermitteln und ältere Versionen löschen
    foreach ($plugin in ($csvContent | Group-Object PluginName)) {
        $latestVersion = $plugin.Group | Sort-Object -Property PluginVersion | Select-Object -Last 1
        $olderVersions = $plugin.Group | Where-Object { $_.PluginVersion -ne $latestVersion.PluginVersion }

        foreach ($oldVersion in $olderVersions) {
            Remove-Item -Path (Join-Path -Path $sourcePath -ChildPath $oldVersion.Dateiname) -Force
        }
    }

    Remove-Item -Path $csvPath -Force
    if ($debug -eq $true) {Write-Host "    DEBUG: Die Plugins wurden für den Upload vorbereitet. Doppelte oder ältere Versionen der Plugins wurden entfernt." -ForegroundColor White}
}




<#
#################################################################################################

In diesem Abschnitt werden alle Funktionen aufgerufen.

#################################################################################################
#>

# Überprüfen, ob einer der Ordner fehlt
if (-not (Test-Path $sourcePathUpdatePluginFiles) -or 
    -not (Test-Path $sourcePathInstallPluginFiles) -or 
    -not (Test-Path $sourcePathUpdateMcServerFiles) -or 
    -not (Test-Path $destinationPathForMcServerJars) -or 
    -not (Test-Path $destinationPathForPluginJars)) {
    # Erster Start des Skripts oder fehlende Ordner, $debug auf $true setzen
    $debug = $true
    Write-Host "debug = on"
}

if (-not (Test-Path $mcRconSourcePath -PathType Leaf)) {
    Write-Host "MCRcon.exe fehlt." -ForegroundColor Red
    Write-Host "Bitte lade MCRcon von Tiiffi herunter und lege die Datei in den selben Ordner wie dieses Skript." -ForegroundColor Cyan
    Write-Host "Speicherort: $mcRconSourcePath" -ForegroundColor Yellow
    Write-Host "Bennene dann die Datei zu 'MCRcon.exe' um. Beachte dabei die Schreibweise." -ForegroundColor Cyan
    Write-Host "Beim Klick auf [Enter] wird die GitHub-Downloadseite von Tiffi's MCRcon geöffnet." -ForegroundColor Cyan
    Write-Host "$urlMCRcon" -ForegroundColor White
    Pause
    Start-Process $urlMCRcon
    Write-Host "Beim nächsten Klick auf [Enter] wird das Skript beendet."  -ForegroundColor DarkYellow
    Pause
    Exit
}

Write-Host ""; Write-Host "Skript gestartet. Bitte warten..." -ForegroundColor Green

if ($debug -eq $true) {Write-Host ""; Write-Host ""; Write-Host "DEBUG: Da der DEBUG-Mode aktiviert ist, wird empfohlen das Consolenfenster zu maximieren um alle Daten einsehen zu können!" -ForegroundColor Cyan; Pause}

& { <# Vorbereitung / Prüfung ob alle Komponenten verfügbar und einsatzbereit sind #>
    if ($debug -eq $true) {Write-Host ""; Write-Host ""; Write-Host "DEBUG: Prüfe ob alle Ordner und Dateien Existieren" -ForegroundColor DarkYellow}

    <# Arbeitsordner erstellen wenn sie nicht existieren #>
        New-CheckFolderExistenceAndCreateIfNot -FolderPath $sourcePathUpdatePluginFiles
        New-CheckFolderExistenceAndCreateIfNot -FolderPath $sourcePathInstallPluginFiles
        New-CheckFolderExistenceAndCreateIfNot -FolderPath $sourcePathUpdateMcServerFiles
        New-CheckFolderExistenceAndCreateIfNot -FolderPath $destinationPathForMcServerJars
        New-CheckFolderExistenceAndCreateIfNot -FolderPath $destinationPathForPluginJars

    <# DEBUG / Komponentencheck / Logindaten-Prüfung #>
        if ($debug -eq $true) {
            <# Prüfe ob MCRcon existiert #>
                Test-FileExistence -filePath $mcRconSourcePath
            <# Prüfe ob FTP Daten korrekt sind #>
                Write-Host ""; Write-Host ""
                Write-Host "DEBUG: Prüfe ob alle Anmeldedaten von FTP korrekt sind." -ForegroundColor DarkYellow
                $ftpResponse = Test-FtpConnectionDebug -ftpHostname $ftpHostname -ftpDirectoryCraftbukkitJarPath $ftpDirectoryCraftbukkitJarPath -ftpUsername $ftpUsername -ftpSecurePassword $ftpSecurePassword
                Write-Host "      DEBUG: FTP-Antwort: $($ftpResponse.StatusCode) - $($ftpResponse.StatusDescription)" -ForegroundColor DarkGray
            <# Prüfe ob die Anmeldedaten für den Ping korrekt sind #>
                #Write-Host ""
                #Write-Host "DEBUG: Prüfe ob alle Anmeldedaten für den Ping korrekt sind und ob der Server Online ist." -ForegroundColor DarkYellow
                #$serverPingTestConnection = Test-PingServerDebug -ip $pingServerIP -port $pingServerPort
                #Write-Host "DEBUG: Ping-Antwort: Connection established: $serverPingTestConnection" -ForegroundColor DarkGray 
            <# Prüfe ob MCRcon Anmeldedaten korrekt sind #>
                Write-Host ""
                Write-Host "DEBUG: Prüfe ob alle Anmeldedaten von MCRcon korrekt sind und ob der Server Online ist." -ForegroundColor DarkYellow
                Test-MCRconConnectionDebug -filePath $mcRconSourcePath -ip $mcRconServerIP -port $mcRconPort -pw $mcRconPassword
                # $mcRconTestConnection, $mcRconTestAnswer = Test-MCRconConnection -filePath $mcRconSourcePath -ip $mcRconServerIP -port $mcRconPort -pw $mcRconPassword
            <# DEBUG deaktivieren? #>
                Disable-ChooseDebugMode -debug ([ref]$debug)
        }
}

& { <# Sortiere Plugins und Serverversionen in die Richtigen Ordner ein #>
    <# Prüfe ob Minecraftserver .jar Dateien existieren #>
        if ($debug -eq $true) {
            Write-Host ""
            Write-Host "DEBUG: Prüfe ob MinecraftServer oder Plugin .jar Dateien in folgenden Verzeichnissen existieren:" -ForegroundColor DarkYellow
            Write-Host "    DEBUG:   - $sourcePathInstallPluginFiles" -ForegroundColor DarkGray
            Write-Host "    DEBUG:   - $sourcePathUpdatePluginFiles" -ForegroundColor DarkGray; Write-Host ""
            Write-Host "    DEBUG:   - $sourcePathUpdateMcServerFiles" -ForegroundColor DarkGray
        }
        Test-JarFilesExistence -sourcePathInstallPluginFiles $sourcePathInstallPluginFiles -sourcePathUpdatePluginFiles $sourcePathUpdatePluginFiles -sourcePathUpdateMcServerFiles $sourcePathUpdateMcServerFiles

        if ($debug -eq $true) {
            Write-Host ""; Write-Host ""; Write-Host "DEBUG: Dateien vor der Verarbeitung" -ForegroundColor DarkYellow
            Write-JarFiles -destinationPathForMcServerJars $destinationPathForMcServerJars -sourcePathUpdateMcServerFiles $sourcePathUpdateMcServerFiles -destinationPathForPluginJars $destinationPathForPluginJars -sourcePathInstallPluginFiles $sourcePathInstallPluginFiles -sourcePathUpdatePluginFiles $sourcePathUpdatePluginFiles
            Pause
        }

    <# Sortiere Dateien in die Richtigen Ordner ein #>
        Move-SortJarFiles -sourcePathUpdatePluginFiles $sourcePathUpdatePluginFiles -sourcePathInstallPluginFiles $sourcePathInstallPluginFiles -sourcePathUpdateMcServerFiles $sourcePathUpdateMcServerFiles -mcServerFileNamePatterns $mcServerFileNamePatterns
        if ($debug -eq $true) {
            Write-Host ""; Write-Host ""; Write-Host "DEBUG: Dateien Sortiert" -ForegroundColor DarkYellow
            Write-JarFiles -destinationPathForMcServerJars $destinationPathForMcServerJars -sourcePathUpdateMcServerFiles $sourcePathUpdateMcServerFiles -destinationPathForPluginJars $destinationPathForPluginJars -sourcePathInstallPluginFiles $sourcePathInstallPluginFiles -sourcePathUpdatePluginFiles $sourcePathUpdatePluginFiles
            Pause
        }
}

& { <# Verarbeite Server-Version .jar #>
    <# Verschiebe McServer.jar nach Historyfolder und benenne die neuste McServer.jar in craftbukkit.jar um #>
        Move-SortMcServerJarsToHistoryFolder -destinationPathForMcServerJars $destinationPathForMcServerJars -sourcePathUpdateMcServerFiles $sourcePathUpdateMcServerFiles -filePatterns $mcServerFileNamePatterns -mcServerFileNameDestination $mcServerFileNameDestination
        if ($debug -eq $true) {
            Write-Host ""; Write-Host ""; Write-Host "DEBUG: Server Jar's verschoben" -ForegroundColor DarkYellow
            Write-JarFiles -destinationPathForMcServerJars $destinationPathForMcServerJars -sourcePathUpdateMcServerFiles $sourcePathUpdateMcServerFiles -destinationPathForPluginJars $destinationPathForPluginJars -sourcePathInstallPluginFiles $sourcePathInstallPluginFiles -sourcePathUpdatePluginFiles $sourcePathUpdatePluginFiles
            Pause
        }

    # Erledigt: Bedingung: Nur ausführen wenn *.jar in $sourcePathUpdateMcServerFiles
    <# Lade "craftbukkit.jar" auf FTP-Server hoch, wenn diese vorhanden ist. #>
        $existJarInSourcePathUpdateMcServerFiles = Test-JarFilesExistenceInFolder -sourcePathFolderJarFiles $sourcePathUpdateMcServerFiles
        if ($true -eq $existJarInSourcePathUpdateMcServerFiles) {
            if ($debug -eq $true) {Write-Host ""; Write-Host ""; Write-Host "DEBUG: MCServer.jar erkannt, wird nun hochgeladen!" -ForegroundColor DarkYellow}
            #Connect-UploadCraftbukkitToFTPServer -sourcePathUpdateMcServerFiles $sourcePathUpdateMcServerFiles -mcServerFileNameDestination $mcServerFileNameDestination -ftpHostname $ftpHostname -ftpUsername $ftpUsername -ftpSecurePassword $ftpSecurePassword -ftpDirectoryCraftbukkitJarPath $ftpDirectoryCraftbukkitJarPath
            Connect-UploadJarToFTPServer -sourcePath $sourcePathUpdateMcServerFiles -ftpHostname $ftpHostname -ftpUsername $ftpUsername -ftpSecurePassword $ftpSecurePassword -ftpDirectory $ftpDirectoryCraftbukkitJarPath
        }
}

& { <# Verarbeite Plugins #>
    <# Test if Jar-Files in Folder exist #>
    $existJarInSourcePathUpdatePluginFiles = Test-JarFilesExistenceInFolder -sourcePathFolderJarFiles $sourcePathUpdatePluginFiles
    $existJarInSourcePathInstallPluginFiles = Test-JarFilesExistenceInFolder -sourcePathFolderJarFiles $sourcePathInstallPluginFiles
                
        if ($true -eq $existJarInSourcePathUpdatePluginFiles) {
            $existJarInSourcePathUpdatePluginFiles = $null
            $pluginFilesTempVar = Get-ChildItem -Path $sourcePathUpdatePluginFiles -File -Filter "*.jar"
            Copy-MinecraftPluginsToArchiv -sourcePath $sourcePathUpdatePluginFiles -destinationPath $destinationPathForPluginJars -pluginFiles $pluginFilesTempVar
            Remove-PreparePluginCsvAndCleanup -sourcePath $sourcePathUpdatePluginFiles -pluginFiles $pluginFilesTempVar
            $pluginFilesTempVar = $null
            if ($debug -eq $true) {
                Write-Host ""; Write-Host ""; Write-Host "DEBUG: Aktueller Stand:" -ForegroundColor DarkYellow
                Write-JarFiles -destinationPathForMcServerJars $destinationPathForMcServerJars -sourcePathUpdateMcServerFiles $sourcePathUpdateMcServerFiles -destinationPathForPluginJars $destinationPathForPluginJars -sourcePathInstallPluginFiles $sourcePathInstallPluginFiles -sourcePathUpdatePluginFiles $sourcePathUpdatePluginFiles
                Pause
            }

            $existJarInSourcePathUpdatePluginFiles = Test-JarFilesExistenceInFolder -sourcePathFolderJarFiles $sourcePathUpdatePluginFiles
            if ($true -eq $existJarInSourcePathUpdatePluginFiles) {
                Connect-UploadJarToFTPServer -sourcePath $sourcePathUpdatePluginFiles -ftpHostname $ftpHostname -ftpUsername $ftpUsername -ftpSecurePassword $ftpSecurePassword -ftpDirectory $ftpDirectoryPluginUpdate
            }
        }

        if ($true -eq $existJarInSourcePathInstallPluginFiles) {
            $existJarInSourcePathInstallPluginFiles = $null
            # Erhalte alle .jar-Dateien im angegebenen Pfad
            $pluginFilesTempVar = Get-ChildItem -Path $sourcePathInstallPluginFiles -File -Filter "*.jar"
            Copy-MinecraftPluginsToArchiv -sourcePath $sourcePathInstallPluginFiles -destinationPath $destinationPathForPluginJars -pluginFiles $pluginFilesTempVar
            Remove-PreparePluginCsvAndCleanup -sourcePath $sourcePathInstallPluginFiles -pluginFiles $pluginFilesTempVar
            $pluginFilesTempVar = $null
            if ($debug -eq $true) {
                Write-Host ""; Write-Host ""; Write-Host "DEBUG: Aktueller Stand:" -ForegroundColor DarkYellow
                Write-JarFiles -destinationPathForMcServerJars $destinationPathForMcServerJars -sourcePathUpdateMcServerFiles $sourcePathUpdateMcServerFiles -destinationPathForPluginJars $destinationPathForPluginJars -sourcePathInstallPluginFiles $sourcePathInstallPluginFiles -sourcePathUpdatePluginFiles $sourcePathUpdatePluginFiles
                Pause
            }

            $existJarInSourcePathInstallPluginFiles = Test-JarFilesExistenceInFolder -sourcePathFolderJarFiles $sourcePathInstallPluginFiles
            if ($true -eq $existJarInSourcePathInstallPluginFiles) {
                Connect-UploadJarToFTPServer -sourcePath $sourcePathInstallPluginFiles -ftpHostname $ftpHostname -ftpUsername $ftpUsername -ftpSecurePassword $ftpSecurePassword -ftpDirectory $ftpDirectoryPlugins
            }
        }
    if ($debug -eq $true) {Pause}
}

& { <# Server Restart und Prüfung auf erfolgreichen Start #>
    # Restart Server über MCRcon
    Write-Host ""; Write-Host ""; Write-Host "Bitte warte einen Moment, der Server wird gespeichert und neu gestartet um die Updates zu laden!" -ForegroundColor Yellow
        Connect-MCRcon -filePath $mcRconSourcePath -ip $mcRconServerIP -port $mcRconPort -pw $mcRconPassword -attemptsMax 5 -command $mcRconCommandSave
        Start-Sleep 10
        Connect-MCRcon -filePath $mcRconSourcePath -ip $mcRconServerIP -port $mcRconPort -pw $mcRconPassword -attemptsMax 2 -command $mcRconCommandRestart

    # Teste ob Server Online mit PING
#        $pingResult = Test-PingServerOnline -ip $pingServerIP -port $pingServerPort -maxAttempts $pingServerMaxAttempts -sleepTime $pingServerTimeWaitBetweenTests
#        if ($debug -eq $true) {Write-Host "$pingResult"}

    # Teste ob Server neu gestartet mit MCRcon /version
    # Wenn nach 5 Min nicht fertig: Meldung "Server konnte nicht gestartet werden, Serverversion oder Plugin nicht kompertibel"
    # Wenn gestartet Meldung: Serverupdate abgeschlossen!
    # Wiederholte Versuche, bis der Server vollständig gestartet ist
        Connect-MCRcon -filePath $mcRconSourcePath -ip $mcRconServerIP -port $mcRconPort -pw $mcRconPassword -sleepTime $mcRconTimeWaitBetweenTests -attemptsMax $mcRconMaxPingAttempts -command $mcRconCommandTestOnline
        Start-Sleep 10
        Connect-MCRcon -filePath $mcRconSourcePath -ip $mcRconServerIP -port $mcRconPort -pw $mcRconPassword -sleepTime $mcRconTimeWaitBetweenTests -attemptsMax $mcRconMaxPingAttempts -command $mcRconCommandTestOnline
        Connect-MCRcon -filePath $mcRconSourcePath -ip $mcRconServerIP -port $mcRconPort -pw $mcRconPassword -sleepTime $mcRconTimeWaitBetweenTests -attemptsMax $mcRconMaxPingAttempts -command $mcRconCommandTestPlugins
        Write-Host ""; Write-Host ""
}

# Warte nach erfolgreichem Vorgang 15 Sekunden und schließe dann das Konsolenfenster
#Start-Sleep -Seconds 15
if ($debug -eq $true) {pause}
PAUSE
EXIT