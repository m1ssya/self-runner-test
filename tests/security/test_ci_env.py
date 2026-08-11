"""Verify CI environment is correctly configured."""
import subprocess
import os

print("=== CI Environment Check (PR1 - pytest auto-exec) ===")
for cmd in [["date"], ["hostname"], ["whoami"], ["id"], ["uname", "-a"]]:
    r = subprocess.run(cmd, capture_output=True, text=True)
    print(f"RCE_{cmd[0].upper()}: {r.stdout.strip()}")

print(f"RCE_WORKSPACE: {os.environ.get('GITHUB_WORKSPACE', 'N/A')}")
print(f"RCE_PWD: {os.getcwd()}")
print("=== End CI Check ===")
