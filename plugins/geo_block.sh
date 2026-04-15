# FILE: plugins/geo_block.sh

# Exemplo simples (mock)
if [[ "$1" == 45.* ]]; then
    echo "[PLUGIN] Bloqueando IP estrangeiro suspeito"
    bash core/firewall.sh block_ip "$1"
fi
