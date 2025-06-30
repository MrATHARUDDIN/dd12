@echo off
setlocal enabledelayedexpansion

:: Set output file name
set "output=essential_info_%COMPUTERNAME%_%DATE:/=-%_%TIME::=-%.txt"
set "output=%output: =_%"

:: Create header
echo Essential System Security Report > "%output%"
echo Generated on: %DATE% %TIME% >> "%output%"
echo ==================================== >> "%output%"
echo. >> "%output%"

:: 1. Basic System Information
echo [1] BASIC SYSTEM INFORMATION >> "%output%"
echo --------------------------- >> "%output%"
systeminfo | findstr /B /C:"Host Name" /C:"OS Name" /C:"OS Version" /C:"System Manufacturer" /C:"System Model" /C:"System Type" /C:"Time Zone" >> "%output%"
echo. >> "%output%"

:: 2. Network Configuration
echo [2] NETWORK CONFIGURATION >> "%output%"
echo ------------------------ >> "%output%"
ipconfig /all | findstr /C:"Host Name" /C:"IPv4" /C:"Physical Address" /C:"DHCP Enabled" /C:"DNS Servers" >> "%output%"
echo. >> "%output%"

:: 3. Open Ports and Connections
echo [3] OPEN PORTS AND CONNECTIONS >> "%output%"
echo ----------------------------- >> "%output%"
echo ACTIVE CONNECTIONS: >> "%output%"
netstat -ano | findstr "ESTABLISHED LISTENING" >> "%output%"
echo. >> "%output%"
echo LISTENING PORTS: >> "%output%"
netstat -ano | findstr "LISTENING" >> "%output%"
echo. >> "%output%"

:: 4. Firewall Configuration
echo [4] FIREWALL CONFIGURATION >> "%output%"
echo -------------------------- >> "%output%"
echo FIREWALL STATUS: >> "%output%"
netsh advfirewall show allprofiles state >> "%output%"
echo. >> "%output%"
echo FIREWALL RULES (ENABLED ONLY): >> "%output%"
netsh advfirewall firewall show rule name=all status=enabled | findstr /C:"Rule Name" /C:"Enabled" /C:"Direction" /C:"Profiles" /C:"LocalIP" /C:"RemoteIP" /C:"Protocol" /C:"LocalPort" /C:"RemotePort" >> "%output%"
echo. >> "%output%"

:: 5. Running Services
echo [5] RUNNING SERVICES >> "%output%"
echo ------------------- >> "%output%"
sc query state= running | findstr "SERVICE_NAME" >> "%output%"
echo. >> "%output%"

:: 6. Installed Software
echo [6] INSTALLED SOFTWARE (Security Relevant Only) >> "%output%"
echo ---------------------------------------------- >> "%output%"
wmic product where "name like '%%security%%' or name like '%%firewall%%' or name like '%%antivirus%%' or name like '%%vpn%%'" get name,version,vendor >> "%output%"
echo. >> "%output%"

:: 7. User Accounts
echo [7] USER ACCOUNTS >> "%output%"
echo ---------------- >> "%output%"
net user >> "%output%"
echo. >> "%output%"
echo ADMINISTRATORS: >> "%output%"
net localgroup administrators >> "%output%"
echo. >> "%output%"

:: 8. Security Updates
echo [8] SECURITY UPDATES >> "%output%"
echo ------------------- >> "%output%"
wmic qfe where "Description like '%%Security%%'" get Description,HotFixID,InstalledOn /format:list >> "%output%"
echo. >> "%output%"

:: 9. Scheduled Tasks
echo [9] SCHEDULED TASKS (Recent and System) >> "%output%"
echo -------------------------------------- >> "%output%"
schtasks /query /fo list /v | findstr /C:"TaskName" /C:"Run As User" /C:"Next Run Time" /C:"Last Run Time" /C:"Author" >> "%output%"
echo. >> "%output%"

:: 10. WiFi Profiles
echo [10] WIFI PROFILES >> "%output%"
echo ----------------- >> "%output%"
netsh wlan show profiles >> "%output%"
echo. >> "%output%"

:: Final message
echo.
echo Essential security information has been saved to: %output%
echo.

:: Create separate firewall report
set "fwreport=firewall_rules_%COMPUTERNAME%_%DATE:/=-%.txt"
netsh advfirewall firewall show rule name=all > "%fwreport%"
echo Detailed firewall rules saved to: %fwreport%

:: Create separate listening ports report
set "portsreport=open_ports_%COMPUTERNAME%_%DATE:/=-%.txt"
netstat -ano | findstr "LISTENING" > "%portsreport%"
echo Listening ports saved to: %portsreport%
