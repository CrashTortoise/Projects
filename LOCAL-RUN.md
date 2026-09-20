# Run Project TAB locally

Project TAB can run entirely on one computer. Docker, a cloud account and an internet connection are not required during operation.

## Windows

1. Install Node.js 24 or later once.
2. Extract the Project TAB ZIP to a normal folder such as `Documents\Project-TAB`.
3. Double-click `Start-Project-TAB.cmd`.
4. Your browser opens `http://127.0.0.1:8080`.
5. Keep the command window open. Press `Ctrl+C` to stop the platform.

First-launch credentials are `admin` / `TAB-Admin-2026!`. Project TAB immediately requires a replacement password.

All operational data is stored beside the application in `data\project-tab.db`. No exercise data is sent to an external service.

### Allow participants on the local network

From PowerShell, run:

```powershell
.\Start-Project-TAB.ps1 -AllowLAN
```

The launcher prints participant URLs based on the computer's local IPv4 addresses. Windows Firewall may ask whether Node.js can accept connections. Only permit this on a trusted private network.

To select another port:

```powershell
.\Start-Project-TAB.ps1 -Port 8090 -AllowLAN
```

## macOS or Linux

Run:

```bash
chmod +x start-project-tab.sh
./start-project-tab.sh
```

To allow other devices on a trusted LAN:

```bash
TAB_ALLOW_LAN=1 ./start-project-tab.sh
```

## Backup or move the platform

1. Stop Project TAB with `Ctrl+C`.
2. Copy the complete Project TAB folder, or at minimum the complete `data` folder.
3. Keep the backup encrypted because it contains participant details, exercise decisions and facilitator notes.

Restoring is simply a matter of putting the backed-up `data` folder into the same location in another Project TAB copy and starting it.
