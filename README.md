# scan.sh

A simple nmap wrapper for the initial recon on Hack The Box style challenges.

It runs two quick scans to find open ports, then runs detailed scans only on the ports it found.

1. Scans **all 65,535 TCP ports**
2. Scans the **top 100 UDP ports**
3. Runs `-sC` (default scripts) and `-sV` (version detection) on the open TCP ports
4. Runs the same detailed scan on any open UDP ports

All scans use `-Pn` to skip the ping check, since challenge boxes are expected to be up.

## Installation

Download `scan.sh`, then move it somewhere on your PATH so you can run it from any folder:

```bash
sudo mv scan.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/scan.sh
```

Can also add it as an alias:

```bash
echo "alias scan='sudo /usr/local/bin/scan.sh'" >> ~/.zshrc
source ~/.zshrc
```
I use Kali so using zsh.

## Usage

```bash
sudo scan.sh <target_ip>
```

Example:

```bash
mkdir mybox && cd mybox
sudo scan.sh 10.10.11.123
```

## Output

Open ports are printed to the terminal, and the detailed results are saved in a folder named after the IP, inside whatever folder you ran the script from:

```
10.10.11.123/
├── tcp.txt
└── udp.txt
```

`udp.txt` is only created if open UDP ports are found.

## Notes

- If no TCP ports are found, check that your VPN is connected and the box is running.
- `--min-rate=1000` speeds up scanning but can occasionally miss UDP ports. If nothing interesting turns up, try rerunning the UDP scan without it.
- Only the top 100 UDP ports are scanned, because a full UDP scan can take hours.
