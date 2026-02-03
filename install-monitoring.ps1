<#
.SYNOPSIS
    Единый скрипт для установки и настройки мониторинга RDP-подключений 
    с отправкой уведомлений в Telegram.
.DESCRIPTION
    Этот скрипт создает все необходимые файлы и настраивает задачу в планировщике.
    Он не требует никаких внешних файлов и может быть запущен на любой машине.
    
    !!! ПЕРЕД ИСПОЛЬЗОВАНИЕМ УКАЖИТЕ ВАШИ ДАННЫЕ TELEGRAM ВНУТРИ СКРИПТА !!!
#>

$OutputEncoding = [System.Text.Encoding]::UTF8

# --- ПРОВЕРКА ПРАВ АДМИНИСТРАТОРА И ЗАПРОС ПОВЫШЕНИЯ ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Скрипт не запущен от имени администратора. Запускаю от имени администратора..." -ForegroundColor Yellow
    Start-Process PowerShell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\$((Get-Item $MyInvocation.MyCommand.Path).Name)`""
    exit
}

$ErrorActionPreference = "Stop"

try {
    # --- ОСНОВНЫЕ НАСТРОЙКИ ---
    $DestDir = "C:\ProgramData\TelegramNotifications"
    $MonitorScriptName = "monitor-rdp.ps1"
    $SenderScriptName = "send-telegram.ps1"
    $TaskName = "TelegramRDPAlert"

    Write-Host "Начало установки 'все-в-одном' мониторинга RDP..." -ForegroundColor Cyan

    # --- СОДЕРЖИМОЕ СКРИПТОВ (ВСТРОЕННОЕ) ---

    $MonitorScriptContent = @'
param()

# PATHS
$BaseDir = $PSScriptRoot
$LogFile = Join-Path $PSScriptRoot "log.txt"
$SendScript = Join-Path $PSScriptRoot "send-telegram.ps1"

function Write-Log {
    param($Msg)
    $Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMsg = "$Date - [Monitor-RDP] $Msg"
    Add-Content -Path $LogFile -Value $LogMsg -Encoding UTF8 -Force
}

try {
    if (!(Test-Path $BaseDir)) { New-Item -ItemType Directory -Path $BaseDir -Force | Out-Null }

    Write-Log "Script started."
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $LogName = "Microsoft-Windows-TerminalServices-LocalSessionManager/Operational"
    $LookBackSeconds = 300 
    $TargetServer = $env:COMPUTERNAME
    Write-Log "Server: $TargetServer. Checking last $LookBackSeconds sec."
    $StartTime = (Get-Date).AddSeconds(-$LookBackSeconds)
    $Events = Get-WinEvent -LogName $LogName -FilterXPath "*[System[(EventID=21 or EventID=25)]]" -ErrorAction SilentlyContinue | Where-Object { $_.TimeCreated -ge $StartTime }

    if ($Events) {
        $Count = $Events.Count
        if ($Count -eq $null) { $Count = 1 }
        Write-Log "Events found: $Count"
        
        foreach ($Event in $Events) {
            $Xml = [xml]$Event.ToXml()
            $UserData = $Xml.Event.UserData.EventXML
            $User = $UserData.User
            $SourceIP = $UserData.Address
            Write-Log "Processing: User=$User, IP=$SourceIP"

            $TypeStr = "Unknown"
            if ($Event.Id -eq 21) { $TypeStr = "Logon (21)" }
            if ($Event.Id -eq 25) { $TypeStr = "Reconnect (25)" }
            
            $HostName = "N/A"
            if ($SourceIP -match "\d+\.\d+\.\d+\.\d+") {
                try {
                    $HostEntry = [System.Net.Dns]::GetHostEntry($SourceIP)
                    $HostName = $HostEntry.HostName
                } catch { $HostName = "No PTR" }
            } elseif ($SourceIP -eq "LOCAL") {
                 $HostName = $TargetServer
            }

            $Time = $Event.TimeCreated.ToString("yyyy-MM-dd HH:mm:ss")
            
            # Get local host details for the message
            $LocalHostFQDN = [System.Net.Dns]::GetHostEntry($env:COMPUTERNAME).HostName
            $LocalHostIPs = (Get-NetIPAddress | Where-Object { $_.AddressFamily -eq 'IPv4' -and $_.InterfaceAlias -notlike 'Loopback' }).IPAddress -join ', '

            $Message = "[RDP Alert]`n" +
                       "Host FQDN: $LocalHostFQDN`n" +
                       "Host IPs: $LocalHostIPs`n" +
                       "Logged-in User: $User`n" +
                       "Client Source IP: $SourceIP`n" +
                       "Client Source DNS: $HostName`n" +
                       "Event Type: $TypeStr`n" +
                       "Event ID: $($Event.Id)`n" +
                       "Time: $Time`n" +
                       "Event Message: $($Event.Message)"

            if (Test-Path $SendScript) {
                 Write-Log "Calling send-telegram.ps1..."
                 & $SendScript -Message $Message
            } else {
                 Write-Log "ERROR: send-telegram.ps1 not found"
            }
        }
    } else {
        Write-Log "No new events."
    }
}
catch {
    $ErrMsg = $_.ToString()
    try { Write-Log "CRITICAL ERROR: $ErrMsg" } catch { }
}
'@

    $SenderScriptContent = @'
param(
    [Parameter(Mandatory=$true)]
    [string]$Message
)

$LogFile = Join-Path $PSScriptRoot "log.txt"

function Write-Log {
    param($Msg)
    $Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMsg = "$Date - [Send-Telegram] $Msg"
    Add-Content -Path $LogFile -Value $LogMsg -Encoding UTF8
}

$BotToken = "ВАШ_ТЕЛЕГРАМ_БОТ_ТОКЕН"
$ChatID = "ВАШ_ID_ЧАТА_ИЛИ_ГРУППЫ"
$Url = "https://api.telegram.org/bot$BotToken/sendMessage"

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Payload = @{
        chat_id = $ChatID
        text = $Message
        parse_mode = "Markdown"
    }
    Write-Log "Sending message to $ChatID..."
    $Result = Invoke-RestMethod -Uri $Url -Method Post -Body $Payload -ErrorAction Stop
    if ($Result.ok -eq $true) {
        Write-Log "Success."
    } else {
        Write-Log "Telegram API returned false: $($Result.description)"
    }
}
catch {
    Write-Log "ERROR: $_"
    if ($_.Exception.Response) {
        $Stream = $_.Exception.Response.GetResponseStream()
        $Reader = New-Object System.IO.StreamReader($Stream)
        $RespBody = $Reader.ReadToEnd()
        Write-Log "API Response Body: $RespBody"
    }
}
'@

    # 1. Создание папки назначения
    if (!(Test-Path $DestDir)) {
        New-Item -ItemType Directory -Path $DestDir -Force
        Write-Host "Создана папка: $DestDir"
    }

    # 2. Создание скриптов из встроенного содержимого
    Write-Host "Создание скриптов в $DestDir..."
    Set-Content -Path (Join-Path $DestDir $MonitorScriptName) -Value $MonitorScriptContent -Encoding UTF8 -Force
    Set-Content -Path (Join-Path $DestDir $SenderScriptName) -Value $SenderScriptContent -Encoding UTF8 -Force
    Write-Host "Скрипты успешно созданы." -ForegroundColor Green

    # 3. Создание или обновление задачи в планировщике
    Write-Host "Создание задачи в планировщике..."
    $TaskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$DestDir\$MonitorScriptName`""
    $TaskTrigger = New-ScheduledTaskTrigger -AtLogon
    $TaskPrincipal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount
    $TaskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable

    if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Write-Host "Существующая задача '$TaskName' удалена для обновления."
    }

    Register-ScheduledTask -TaskName $TaskName -Action $TaskAction -Trigger $TaskTrigger -Principal $TaskPrincipal -Settings $TaskSettings -Force
    Write-Host "Задача '$TaskName' успешно создана и будет запускаться при входе в систему." -ForegroundColor Green

    Write-Host "`nУстановка успешно завершена!`n" -ForegroundColor Cyan
}
catch {
    Write-Error "Произошла критическая ошибка: $($_.Exception.Message)"
    Read-Host "Нажмите Enter для выхода..."
    exit 1
}

Read-Host "Нажмите Enter для завершения..."
