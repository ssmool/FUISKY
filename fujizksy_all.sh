#!/bin/bash
# ==============================================================
# Fujizksy Security & Network Console (Cross-Platform)
# Author: ChatGPT (GPT-5)
# Description: Interactive tool for monitoring, firewall, and security control
# ==============================================================

REFRESH_INTERVAL=10

# Detect Platform (Linux, FreeBSD, macOS, WSL)
PLATFORM=$(uname -s)
echo "Detected Platform: $PLATFORM"

# Set platform-specific variables and tools
if [[ "$PLATFORM" == "Linux" ]]; then
    FIREWALL_TOOL="iptables"
    NETWORK_MONITOR="netstat"
    SYSTEM_MONITOR="top"
elif [[ "$PLATFORM" == "FreeBSD" ]]; then
    FIREWALL_TOOL="pfctl"
    NETWORK_MONITOR="netstat"
    SYSTEM_MONITOR="top"
elif [[ "$PLATFORM" == "Darwin" ]]; then
    FIREWALL_TOOL="pfctl"
    NETWORK_MONITOR="netstat"
    SYSTEM_MONITOR="top"
elif [[ "$PLATFORM" == "MINGW32_NT"* || "$PLATFORM" == "MINGW64_NT"* ]]; then
    # WSL - Windows Subsystem for Linux
    FIREWALL_TOOL="netsh advfirewall firewall"
    NETWORK_MONITOR="netstat"
    SYSTEM_MONITOR="tasklist"
else
    echo "Unsupported platform: $PLATFORM"
    exit 1
fi

# Helper functions
pause() { read -rp "Press [Enter] to continue..."; }
clear_screen() { clear; }

# -----------------------------
# 1. Verify Network Connections
# -----------------------------
verify_network_connections() {
    while true; do
        clear_screen
        echo "=== Network Connections ==="
        if [[ "$PLATFORM" == "Linux" || "$PLATFORM" == "FreeBSD" || "$PLATFORM" == "Darwin" ]]; then
            $NETWORK_MONITOR -tulpen
        elif [[ "$PLATFORM" == "MINGW32_NT"* || "$PLATFORM" == "MINGW64_NT"* ]]; then
            netstat -an
        fi
        echo
        echo "1) Kill process"
        echo "2) Block by IP"
        echo "3) Refresh"
        echo "4) Back"
        read -rp "Choose: " opt
        case $opt in
            1) read -rp "Enter PID to kill: " pid; sudo kill -9 "$pid";;
            2) read -rp "Enter IP to block: " ip; sudo $FIREWALL_TOOL add rule name="block-ip" protocol=TCP dir=in remoteip="$ip" action=block;;
            3) sleep $REFRESH_INTERVAL;;
            4) break;;
            *) echo "Invalid option"; sleep 1;;
        esac
    done
}

# ---------------------------------------
# 2. Verify Process Forks / CPU / RAM Use
# ---------------------------------------
verify_process_usage() {
    while true; do
        clear_screen
        echo "=== Process Forks / Usage ==="
        ps aux --sort=-%cpu | head -20
        echo
        echo "1) Kill PID"
        echo "2) Verify connections by PID"
        echo "3) CPU Usage (top)"
        echo "4) Back"
        read -rp "Choose: " opt
        case $opt in
            1) read -rp "Enter PID: " pid; sudo kill -9 "$pid";;
            2) read -rp "Enter PID: " pid; sudo netstat -tpn | grep "$pid"; pause;;
            3) top -b -n 1 | head -20; pause;;
            4) break;;
            *) echo "Invalid"; sleep 1;;
        esac
    done
}

# --------------------------------------
# 3. Network, CPU, RAM, Disk Monitoring
# --------------------------------------
verify_system_usage() {
    while true; do
        clear_screen
        echo "=== System Resource Monitor ==="
        echo "--- CPU & RAM ---"
        $SYSTEM_MONITOR -b -n 1 | head -15
        echo "--- Network ---"
        if [[ "$PLATFORM" == "Linux" || "$PLATFORM" == "FreeBSD" || "$PLATFORM" == "Darwin" ]]; then
            if command -v iftop &>/dev/null; then
                echo "(iftop installed)"
            else
                netstat -tulpen
            fi
        elif [[ "$PLATFORM" == "MINGW32_NT"* || "$PLATFORM" == "MINGW64_NT"* ]]; then
            netstat -an
        fi
        echo "--- Disk Usage ---"
        df -h | head -10
        echo
        echo "1) Kill process"
        echo "2) Block IP"
        echo "3) Refresh"
        echo "4) Back"
        read -rp "Option: " opt
        case $opt in
            1) read -rp "Enter PID: " pid; sudo kill -9 "$pid";;
            2) read -rp "Enter IP: " ip; sudo $FIREWALL_TOOL add rule name="block-ip" protocol=TCP dir=in remoteip="$ip" action=block;;
            3) sleep $REFRESH_INTERVAL;;
            4) break;;
        esac
    done
}

# -------------------
# 4. Security Levels
# -------------------
security_level() {
    clear_screen
    echo "=== Firewall Security Levels ==="
    echo "1) Basic - block ping, icmp, UDP, >553"
    echo "2) Medium - allow only pop3, smtp, imap, dhcp, http, https, ftp"
    echo "3) Hard - deny all, custom allow"
    read -rp "Choose level: " lvl

    # Flush all existing rules
    sudo $FIREWALL_TOOL -F

    case $lvl in
        1)
            sudo $FIREWALL_TOOL -A INPUT -p icmp -j DROP
            sudo $FIREWALL_TOOL -A INPUT -p udp -j DROP
            sudo $FIREWALL_TOOL -A INPUT -p tcp --dport 554:65535 -j DROP
            ;;
        2)
            sudo $FIREWALL_TOOL -P INPUT DROP
            for p in 25 53 67 68 80 443 110 143 21; do
                sudo $FIREWALL_TOOL -A INPUT -p tcp --dport $p -j ACCEPT
            done
            ;;
        3)
            sudo $FIREWALL_TOOL -P INPUT DROP
            read -rp "Enter allowed port numbers (comma separated): " ports
            IFS=',' read -ra PORT_LIST <<< "$ports"
            for p in "${PORT_LIST[@]}"; do
                sudo $FIREWALL_TOOL -A INPUT -p tcp --dport "$p" -j ACCEPT
            done
            ;;
        *) echo "Invalid";;
    esac
    pause
}

# --------------------------------
# 5. Lock Security Level
# --------------------------------
lock_security_level() {
    echo "Locking down system..."
    sudo $FIREWALL_TOOL -P INPUT DROP
    sudo $FIREWALL_TOOL -P OUTPUT DROP
    sudo pkill -f . # Kill all user processes except this script
    nmcli networking off 2>/dev/null
    pause
}

# --------------------------------
# 6. Leave Security Level
# --------------------------------
leave_security_level() {
    echo "Restoring network..."
    nmcli networking on 2>/dev/null
    sudo systemctl restart NetworkManager 2>/dev/null
    pause
}

# --------------------------------
# 7. Hardening
# --------------------------------
system_hardening() {
    echo "Applying hardening..."
    systemctl disable bluetooth cups avahi-daemon ntp chronyd 2>/dev/null
    sudo timedatectl set-ntp false
    sudo chmod -R o-rwx /etc/systemd/system/
    lock_security_level
    security_level
}

# --------------------------------
# 8. Auto Firewall
# --------------------------------
auto_firewall() {
    echo "Applying auto firewall (web + mail + dns + dhcp only)..."
    sudo $FIREWALL_TOOL -F
    for p in 21 25 53 67 68 80 110 143 443; do
        sudo $FIREWALL_TOOL -A INPUT -p tcp --dport $p -j ACCEPT
    done
    pause
}

# --------------------------------
# 9. First Install Setup
# --------------------------------
first_install() {
    echo "Running first install wizard..."
    security_level
   
