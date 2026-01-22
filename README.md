<p align="center">
  <img src="https://github.com/user-attachments/assets/xxxx-xxxx-xxxx-xxxx" width="128" alt="RDP → Telegram">
  <br><br>
  <h1>RDP Monitoring to Telegram</h1>
  <p>Мгновенные уведомления о входах и переподключениях по RDP прямо в Telegram</p>
</p>

<p align="center">
  <a href="https://github.com/ваш-username/rdp-telegram-monitor/stargazers">
    <img src="https://img.shields.io/github/stars/ваш-username/rdp-telegram-monitor?style=for-the-badge&color=4285F4" alt="Stars">
  </a>
  <a href="https://github.com/ваш-username/rdp-telegram-monitor/forks">
    <img src="https://img.shields.io/github/forks/ваш-username/rdp-telegram-monitor?style=for-the-badge&color=34A853" alt="Forks">
  </a>
  <a href="https://github.com/ваш-username/rdp-telegram-monitor/issues">
    <img src="https://img.shields.io/github/issues/ваш-username/rdp-telegram-monitor?style=for-the-badge&color=EA4335" alt="Issues">
  </a>
  <br>
  <img src="https://img.shields.io/badge/PowerShell-5.1%2B-blue?style=for-the-badge&logo=powershell&logoColor=white" alt="PowerShell">
  <img src="https://img.shields.io/badge/Telegram-Bot%20API-0088cc?style=for-the-badge&logo=telegram" alt="Telegram">
  <img src="https://img.shields.io/badge/Windows-10%20%7C%2011-blue?style=for-the-badge&logo=windows" alt="Windows">
</p>

<p align="center">
  <img src="[image:1]" width="520" alt="Пример уведомления в Telegram">
  <br><br>
  <i>Пример красивого и информативного сообщения в Telegram</i>
</p>

## ✨ Возможности

- Отслеживание **входов** (Event ID 21) и **переподключений** (Event ID 25) по RDP  
- Красивое форматированное сообщение в Telegram с эмодзи  
- Полезная информация в одном уведомлении:

  - 🖥️ Полное имя хоста (FQDN)  
  - 🌐 Все IPv4-адреса сервера  
  - 👤 Пользователь, который подключился  
  - 📍 IP-адрес клиента  
  - 🔍 DNS-имя клиента (если удалось разрешить)  
  - ⏰ Точное время события  
  - 🏷️ Тип события (Logon / Reconnect)  
  - #️⃣ Event ID  
  - 📜 Полный текст события  

- Автоматическая установка в виде **Scheduled Task** → запускается при каждом входе в систему  
- Один файл для установки — максимально просто развернуть  
- Логирование в файл для отладки

## 🚀 Быстрый старт (3 минуты)

1. Создай бота через **@BotFather** → получи **токен**  
2. Узнай **Chat ID** через **@myidbot** или **@RawDataBot**  
3. Скачай и открой файл `install-monitoring.template.ps1`  
4. Вставь свои значения:

```powershell
$BotToken = "7415623891:AAHxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$ChatID   = "-1001987654321"           # или "123456789" для личного чата
