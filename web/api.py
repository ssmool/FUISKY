# FILE: web/api.py

from flask import Flask, jsonify, send_file
import os
import subprocess
import requests

app = Flask(__name__)

# -------------------------
# DEBUG GLOBAL (MOSTRA ERRO NO NAVEGADOR)
# -------------------------
app.config["PROPAGATE_EXCEPTIONS"] = True

# -------------------------
# ROTA PRINCIPAL
# -------------------------
@app.route("/")
def index():
    try:
        return send_file("../web/dashboard.html")
    except Exception as e:
        return f"Erro ao carregar dashboard: {e}"

# -------------------------
# EVENTOS
# -------------------------
@app.route("/api/events")
def events():
    try:
        if os.path.exists("data/events.log"):
            with open("data/events.log") as f:
                return jsonify(f.readlines()[-50:])
        return jsonify([])
    except Exception as e:
        return jsonify({"error": str(e)})

# -------------------------
# BANIDOS
# -------------------------
@app.route("/api/banned")
def banned():
    try:
        if os.path.exists("data/banned.txt"):
            with open("data/banned.txt") as f:
                return jsonify(f.read().splitlines())
        return jsonify([])
    except Exception as e:
        return jsonify({"error": str(e)})

# -------------------------
# MÉTRICAS (ULTRA SEGURO)
# -------------------------
@app.route("/api/metrics")
def metrics():
    try:
        cpu = subprocess.getoutput("top -bn1 | grep 'Cpu' | awk '{print $2}' | cut -d. -f1") or "0"
        conn = subprocess.getoutput("ss -ant | wc -l") or "0"
        proc = subprocess.getoutput("ps aux | wc -l") or "0"

        return jsonify({
            "cpu": cpu,
            "conn": conn,
            "proc": proc
        })

    except Exception as e:
        return jsonify({"cpu": 0, "conn": 0, "proc": 0, "error": str(e)})

# -------------------------
# GEO (SUPER PROTEGIDO)
# -------------------------
def geo(ip):
    try:
        r = requests.get(f"http://ip-api.com/json/{ip}", timeout=2)

        if r.status_code != 200:
            return None

        data = r.json()

        if data.get("status") != "success":
            return None

        return {
            "ip": ip,
            "lat": data.get("lat", 0),
            "lon": data.get("lon", 0)
        }

    except Exception as e:
        print("Geo error:", e)
        return None

# -------------------------
# ATAQUES (NÃO QUEBRA NUNCA)
# -------------------------
@app.route("/api/attacks")
def attacks():
    result = []

    try:
        if not os.path.exists("data/events.log"):
            return jsonify(result)

        with open("data/events.log") as f:
            lines = f.readlines()[-20:]

        for line in lines:
            try:
                if "|" not in line:
                    continue

                parts = line.split("|")

                if len(parts) < 3:
                    continue

                ip = parts[2].strip()

                if not ip or ip == "None":
                    continue

                g = geo(ip)
                if g:
                    result.append(g)

            except Exception as e:
                print("Parse error:", e)

    except Exception as e:
        print("Attacks error:", e)

    return jsonify(result)

# -------------------------
# START COM DEBUG
# -------------------------
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5002, debug=True)
