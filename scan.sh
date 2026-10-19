#!/bin/bash
# Quick HTB recon: full TCP + top 100 UDP, then detailed scans on open ports.
# Usage: sudo ./scan.sh 10.10.11.x [-s]
#   -s : slow/thorough mode for laggy or filtered hosts (more retries, lower rate)

ip="$1"
mode="$2"

if [ -z "$ip" ]; then
    echo "Usage: sudo $0 <target_ip> [-s]"
    exit 1
fi

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (sudo), UDP scanning requires it."
    exit 1
fi

# Timing profile: default is fast, -s is slow-and-stubborn
if [ "$mode" == "-s" ]; then
    timing="-T3 --max-retries 5 --min-rate 300"
    echo "[*] Slow/thorough mode enabled."
else
    timing="-T4 --max-retries 3 --min-rate 500"
fi

mkdir -p "$ip"

echo "[*] Scanning all TCP ports on $ip..."
tcp=$(nmap -Pn -p- $timing "$ip" | grep '^[0-9]' | cut -d '/' -f 1 | tr '\n' ',' | sed 's/,$//')

echo "[*] Scanning top 100 UDP ports on $ip..."
udp=$(nmap -Pn -sU --top-ports 100 $timing "$ip" | grep '^[0-9].* open ' | cut -d '/' -f 1 | tr '\n' ',' | sed 's/,$//')

echo
echo "[+] Open TCP ports: ${tcp:-none}"
echo "[+] Open UDP ports: ${udp:-none}"
echo

if [ -n "$tcp" ]; then
    echo "[*] Running detailed TCP scan..."
    nmap -Pn -p"$tcp" -sC -sV -oN "$ip/tcp.txt" "$ip"
else
    echo "[-] No open TCP ports found. If the box should be up, re-run with -s (slow mode)."
fi

if [ -n "$udp" ]; then
    echo "[*] Running detailed UDP scan..."
    nmap -Pn -sU -p"$udp" -sC -sV -oN "$ip/udp.txt" "$ip"
fi

echo
echo "[+] Done. Results saved in ./$ip/"
