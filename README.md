# RDP Monitoring to Telegram

This repository contains a PowerShell script to monitor RDP login/reconnect events on Windows machines and send detailed notifications to a Telegram chat or group.

## Features

*   Monitors RDP logon (Event ID 21) and reconnect (Event ID 25) events.
*   Sends detailed notifications to a specified Telegram chat/group.
*   Notifications include:
    *   **Host FQDN:** Full Qualified Domain Name of the machine where the RDP session occurred.
    *   **Host IPs:** All IPv4 addresses of the host machine.
    *   **Logged-in User:** The user account that initiated the RDP session.
    *   **Client Source IP:** The IP address from which the client connected.
    *   **Client Source DNS:** The resolved DNS name of the client's source IP (if available).
    *   Event type (Logon/Reconnect).
    *   Event ID.
    *   Timestamp.
    *   Full event message.
*   Installs itself as a scheduled task to run at system logon.
*   Self-contained in a single PowerShell script for easy deployment.

## How to Use

1.  **Get your Telegram Bot Token:**
    *   Talk to [@BotFather](https://t.me/BotFather) on Telegram.
    *   Send `/newbot` to create a new bot.
    *   Follow the instructions, choose a name and a username for your bot.
    *   BotFather will give you an API token (e.g., `123456789:ABC-DEF1234ghy`). Keep this token secure.

2.  **Get your Telegram Chat ID:**
    *   **For a private chat:** Send any message to your new bot. Then, talk to [@RawDataBot](https://t.me/RawDataBot) or [@myidbot](https://t.me/myidbot) and forward a message from your bot to it. It will show you the chat ID.
    *   **For a group chat:** Add your new bot to a group. Send any message to the group. Then, add [@RawDataBot](https://t.me/RawDataBot) or [@myidbot](https://t.me/myidbot) to the *same group* and it will display the group's chat ID (it will be a negative number, e.g., `-123456789`).

3.  **Edit the Script (`install-monitoring.template.ps1`):**
    *   Open the `install-monitoring.template.ps1` file in a text editor (like Notepad or VS Code).
    *   Find the following lines within the script:
        ```powershell
        $BotToken = "ВАШ_ТЕЛЕГРАМ_БОТ_ТОКЕН"
        $ChatID = "ВАШ_ID_ЧАТА_ИЛИ_ГРУППЫ"
        ```
    *   Replace `"ВАШ_ТЕЛЕГРАМ_БОТ_ТОКЕН"` with the actual Bot Token you obtained from BotFather.
    *   Replace `"ВАШ_ID_ЧАТА_ИЛИ_ГРУППЫ"` with your actual Chat ID.

4.  **Run the Script on Target Machines:**
    *   Copy the modified `install-monitoring.template.ps1` script to each Windows machine where you want to monitor RDP connections.
    *   On the target machine, simply run the script (e.g., by double-clicking it or from a PowerShell prompt). **The script will automatically request Administrator privileges if needed.**
    *   Navigate to the directory where you copied the script.
    *   Run the script using the following command:
        ```powershell
        powershell.exe -ExecutionPolicy Bypass -File .\install-monitoring.template.ps1
        ```
    *   The script sets the console output encoding to UTF-8 to ensure proper display of all characters.
    *   The script will create the necessary files (`monitor-rdp.ps1`, `send-telegram.ps1`, `log.txt`) in `C:\ProgramData\TelegramNotifications` and set up a scheduled task named `TelegramRDPAlert` to run `monitor-rdp.ps1` at system logon.

## How it Works

The main script (`install-monitoring.template.ps1`) embeds two helper scripts:
*   `monitor-rdp.ps1`: This script actively monitors the Windows Security event log for RDP logon (Event ID 21) and reconnect (Event ID 25) events. It extracts relevant information like username, source IP, and host details.
*   `send-telegram.ps1`: This script takes a message as input and uses the Telegram Bot API (`Invoke-RestMethod`) to send the message to the configured chat ID.

The `monitor-rdp.ps1` script is configured to run as a scheduled task at every system logon, ensuring continuous monitoring. It also includes logging to `C:\ProgramData\TelegramNotifications\log.txt` for troubleshooting.
