<p align="center">
  <br><br>
  <h1>RDP Monitoring to Telegram</h1>
  <p>Мгновенные уведомления о входах и переподключениях по RDP прямо в Telegram</p>
</p>

<p align="center">
  <a href="https://github.com/gami78rus/rdp-telegram-notifier/stargazers">
    <img src="https://img.shields.io/github/stars/gami78rus/rdp-telegram-notifier?style=for-the-badge&color=4285F4" alt="Stars">
  </a>
  <a href="https://github.com/gami78rus/rdp-telegram-notifier/forks">
    <img src="https://img.shields.io/github/forks/gami78rus/rdp-telegram-notifier?style=for-the-badge&color=34A853" alt="Forks">
  </a>
  <a href="https://github.com/gami78rus/rdp-telegram-notifier/issues">
    <img src="https://img.shields.io/github/issues/gami78rus/rdp-telegram-notifier?style=for-the-badge&color=EA4335" alt="Issues">
  </a>
  <br>
  <img src="https://img.shields.io/badge/PowerShell-5.1%2B-blue?style=for-the-badge&logo=powershell&logoColor=white" alt="PowerShell">
  <img src="https://img.shields.io/badge/Telegram-Bot%20API-0088cc?style=for-the-badge&logo=telegram" alt="Telegram">
  <img src="https://img.shields.io/badge/Windows-10%20%7C%2011-blue?style=for-the-badge&logo=windows" alt="Windows">
</p>

## Возможности

- Отслеживание **входов** (Event ID 21) и **переподключений** (Event ID 25) по RDP
- Красивое форматированное сообщение в Telegram с эмодзи
- Полезная информация в одном уведомлении:
  - Полное имя хоста (FQDN)
  - Все IPv4-адреса сервера
  - Пользователь, который подключился
  - IP-адрес клиента
  - DNS-имя клиента (если удалось разрешить)
  - Точное время события
  - Тип события (Logon / Reconnect)
  - Event ID
  - Полный текст события
- Автоматическая установка в виде **Scheduled Task** — запускается при каждом входе в систему
- Один файл для установки — максимально просто развернуть
- Логирование в файл для отладки

## Быстрый старт

### 1. Создай Telegram-бота

1. Открой **@BotFather** в Telegram
2. Отправь `/newbot` и следуй инструкциям
3. Сохрани полученный **токен** (формат: `7415623891:AAHxxxxxxxxxxxxxxxxxxxxxxxxxxxx`)

### 2. Узнай Chat ID

- Напиши **@myidbot** или **@RawDataBot** в Telegram
- Для личного чата используй числовой ID (например `123456789`)
- Для группы используй отрицательный ID (например `-1001987654321`)

### 3. Скачай и настрой скрипт

Скачай файл `install-monitoring.ps1` и открой его в текстовом редакторе. Найди строки с настройками Telegram и вставь свои значения:

```powershell
$BotToken = "7415623891:AAHxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$ChatID   = "-1001987654321"           # или "123456789" для личного чата
```

### 4. Запусти установку

Кликни правой кнопкой на скрипт и выбери **Запустить с помощью PowerShell** (или запусти от имени администратора). Скрипт автоматически:

- Запросит права администратора (если нужно)
- Создаст папку `C:\ProgramData\TelegramNotifications`
- Сгенерирует скрипты мониторинга и отправки
- Зарегистрирует задачу в планировщике Windows

## Структура файлов

```
C:\ProgramData\TelegramNotifications\
  monitor-rdp.ps1        # Скрипт мониторинга событий RDP
  send-telegram.ps1      # Скрипт отправки сообщений в Telegram
  log.txt                # Лог-файл для отладки
```

## Как это работает

1. Задача **TelegramRDPAlert** запускается при каждом входе в систему
2. Скрипт `monitor-rdp.ps1` проверяет Windows Event Viewer на наличие новых событий RDP за последние 5 минут
3. При обнаружении события (вход или переподключение) скрипт собирает информацию и вызывает `send-telegram.ps1`
4. Уведомление отправляется в указанный Telegram-чат через Bot API

## Устранение неполадок

### Проверка задачи в планировщике

```powershell
Get-ScheduledTask -TaskName "TelegramRDPAlert" | Format-List
```

### Ручной запуск мониторинга

```powershell
powershell -ExecutionPolicy Bypass -File "C:\ProgramData\TelegramNotifications\monitor-rdp.ps1"
```

### Просмотр лога

```powershell
Get-Content "C:\ProgramData\TelegramNotifications\log.txt" -Tail 20
```

### Проверка событий RDP в Event Viewer

```powershell
Get-WinEvent -LogName "Microsoft-Windows-TerminalServices-LocalSessionManager/Operational" -MaxEvents 10
```

## Удаление

Для полного удаления выполните в PowerShell от имени администратора:

```powershell
# Удалить задачу из планировщика
Unregister-ScheduledTask -TaskName "TelegramRDPAlert" -Confirm:$false

# Удалить файлы
Remove-Item -Path "C:\ProgramData\TelegramNotifications" -Recurse -Force
```

## Требования

- Windows 10 / Windows 11
- PowerShell 5.1+
- Права администратора (для установки)
- Доступ к Telegram Bot API (порт 443)

## Лицензия

MIT License
