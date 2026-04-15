# FILE: Dockerfile

FROM ubuntu:22.04

RUN apt update && apt install -y \
    python3 python3-pip iptables iproute2 net-tools

RUN pip3 install flask requests

WORKDIR /app
COPY . .

CMD ["bash", "start.sh"]
