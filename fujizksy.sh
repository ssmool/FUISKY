#!/bin/bash
# ==============================================================
# Fujisky Security & Monitoring System (Linux)
# Author: ChatGPT
# ==============================================================

REFRESH_INTERVAL=5
FIREWALL_TOOL="iptables"

# -----------------------------
# Segurança básica
# -----------------------------
if [[ $EUID -ne 0 ]]; then
    echo "[!] Execute como root (sudo)"
    exit 1
fi

# -----------------------------
# Helpers
# -----------------------------
pause() { read -rp "Pressione ENTER para continuar..."; }
clear_screen() { clear; }

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# -----------------------------
# Firewall seguro
# -----------------------------
block_ip() {
    read -rp "IP para bloquear: " ip
    $FIREWALL_TOOL -A INPUT -s "$ip" -j DROP
    echo "[+] IP bloqueado: $ip"
}

kill_process() {
    read -rp "PID: " pid
    if [[ "$pid" == "$$" ]]; then
        echo "[!] Não pode matar o próprio script"
        return
    fi
    kill -9 "$pid" 2>/dev/null && echo "[+] Processo morto"
}

# -----------------------------
# 1. Conexões de rede
# -----------------------------
verify_network_connections() {
    while true; do
        clear_screen
        echo "=== Conexões de Rede ==="

        if command_exists ss; then
            ss -tulnp
        else
            netstat -tulnp
        fi

        echo
        echo "1) Matar processo"
        echo "2) Bloquear IP"
        echo "3) Atualizar"
        echo "4) Voltar"
        read -rp "Escolha: " opt

        case $opt in
            1) kill_process ;;
            2) block_ip ;;
            3) sleep $REFRESH_INTERVAL ;;
            4) break ;;
        esac
    done
}

# -----------------------------
# 2. Processos
# -----------------------------
verify_process_usage() {
    while true; do
        clear_screen
        echo "=== Uso de CPU/RAM ==="
        ps aux --sort=-%cpu | head -20

        echo
        echo "1) Matar PID"
        echo "2) Ver conexões do PID"
        echo "3) Top"
        echo "4) Voltar"
        read -rp "Escolha: " opt

        case $opt in
            1) kill_process ;;
            2)
                read -rp "PID: " pid
                ss -tpn | grep "$pid"
                pause
                ;;
            3)
                top
                ;;
            4) break ;;
        esac
    done
}

# -----------------------------
# 3. Sistema
# -----------------------------
verify_system_usage() {
    while true; do
        clear_screen
        echo "=== Sistema ==="

        echo "--- CPU/RAM ---"
        top -b -n1 | head -15

        echo "--- Disco ---"
        df -h

        echo "--- Rede ---"
        ss -s

        echo
        echo "1) Matar processo"
        echo "2) Bloquear IP"
        echo "3) Atualizar"
        echo "4) Voltar"

        read -rp "Escolha: " opt

        case $opt in
            1) kill_process ;;
            2) block_ip ;;
            3) sleep $REFRESH_INTERVAL ;;
            4) break ;;
        esac
    done
}

# -----------------------------
# 4. Firewall Levels
# -----------------------------
security_level() {
    clear_screen
    echo "=== Níveis de Segurança ==="
    echo "1) Básico"
    echo "2) Médio"
    echo "3) Hardcore"
    read -rp "Escolha: " lvl

    $FIREWALL_TOOL -F

    case $lvl in
        1)
            $FIREWALL_TOOL -A INPUT -p icmp -j DROP
            $FIREWALL_TOOL -A INPUT -p udp -j DROP
            ;;
        2)
            $FIREWALL_TOOL -P INPUT DROP
            for p in 22 80 443; do
                $FIREWALL_TOOL -A INPUT -p tcp --dport $p -j ACCEPT
            done
            ;;
        3)
            $FIREWALL_TOOL -P INPUT DROP
            read -rp "Portas liberadas: " ports
            IFS=',' read -ra p <<< "$ports"
            for port in "${p[@]}"; do
                $FIREWALL_TOOL -A INPUT -p tcp --dport "$port" -j ACCEPT
            done
            ;;
    esac

    echo "[+] Firewall aplicado"
    pause
}

# -----------------------------
# 5. Lockdown (corrigido)
# -----------------------------
lock_security_level() {
    echo "[!] Lockdown ativado"

    $FIREWALL_TOOL -P INPUT DROP
    $FIREWALL_TOOL -P OUTPUT ACCEPT

    echo "[+] Sistema isolado (entrada bloqueada)"
    pause
}

# -----------------------------
# 6. Restaurar rede
# -----------------------------
leave_security_level() {
    echo "[+] Restaurando rede..."
    systemctl restart NetworkManager 2>/dev/null
    pause
}

# -----------------------------
# 7. Hardening seguro
# -----------------------------
system_hardening() {
    echo "[+] Hardening básico..."

    systemctl disable bluetooth 2>/dev/null
    systemctl disable avahi-daemon 2>/dev/null

    echo "[+] Hardening aplicado"
    pause
}

# -----------------------------
# 8. Auto Firewall
# -----------------------------
auto_firewall() {
    echo "[+] Firewall automático (web)"
    $FIREWALL_TOOL -F

    for p in 22 80 443; do
        $FIREWALL_TOOL -A INPUT -p tcp --dport $p -j ACCEPT
    done

    pause
}

# -----------------------------
# MENU PRINCIPAL
# -----------------------------
main_menu() {
    while true; do
        clear_screen
        echo "========= FUJISKY ========="
        echo "1) Conexões de Rede"
        echo "2) Processos"
        echo "3) Sistema"
        echo "4) Firewall"
        echo "5) Lockdown"
        echo "6) Restaurar Rede"
        echo "7) Hardening"
        echo "8) Auto Firewall"
        echo "0) Sair"

        read -rp "Escolha: " opt

        case $opt in
            1) verify_network_connections ;;
            2) verify_process_usage ;;
            3) verify_system_usage ;;
            4) security_level ;;
            5) lock_security_level ;;
            6) leave_security_level ;;
            7) system_hardening ;;
            8) auto_firewall ;;
            0) exit ;;
        esac
    done
}

main_menu
