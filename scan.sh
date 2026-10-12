#!/bin/bash
# Quick HTB recon: full TCP + top 100 UDP, then detailed scans on open ports.
# Usage: sudo ./scan.sh 10.10.11.x

ip="$1"

if [ -z "$ip" ]; then
    echo "Usage: sudo $0 <target_ip>"
    exit 1
fi

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (sudo), UDP scanning requires it."
    exit 1
fi

# Save results in a folder named after the IP
mkdir -p "$ip"

echo "[*] Scanning all TCP ports on $ip..."
tcp=$(nmap -Pn -p- --min-rate=1000 -T4 "$ip" | grep '^[0-9]' | cut -d '/' -f 1 | tr '\n' ',' | sed 's/,$//')

echo "[*] Scanning top 100 UDP ports on $ip..."
udp=$(nmap -Pn -sU --top-ports 100 --min-rate=1000 "$ip" | grep '^[0-9].* open ' | cut -d '/' -f 1 | tr '\n' ',' | sed 's/,$//')

echo
echo "[+] Open TCP ports: ${tcp:-none}"
echo "[+] Open UDP ports: ${udp:-none}"
echo

if [ -n "$tcp" ]; then
    echo "[*] Running detailed TCP scan..."
    nmap -Pn -p"$tcp" -sC -sV -oN "$ip/tcp.txt" "$ip"
else
    echo "[-] No open TCP ports found. Check your VPN connection and that the box is running."
fi

if [ -n "$udp" ]; then
    echo "[*] Running detailed UDP scan..."
    nmap -Pn -sU -p"$udp" -sC -sV -oN "$ip/udp.txt" "$ip"
fi

echo
echo "[+] Done. Results saved in ./$ip/"
