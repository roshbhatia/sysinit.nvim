import os
from pathlib import Path
import subprocess
import sys
import tempfile


with tempfile.TemporaryDirectory() as temporary:
    root = Path(temporary)
    ssh = root / "ssh"
    ssh.write_text(
        f"#!{sys.executable}\n"
        "import os, pathlib, sys\n"
        "command = sys.argv[-1]\n"
        "if command.startswith('printf'):\n"
        "    print('/remote home')\n"
        "elif command.startswith('bash -s -- '):\n"
        "    pathlib.Path(os.environ['CAPTURE']).write_text(command)\n"
        "    sys.stdin.read()\n"
    )
    ssh.chmod(0o700)
    nvim = root / "nvim"
    nvim.write_text("#!/bin/sh\nexit 0\n")
    nvim.chmod(0o700)
    env = {
        **os.environ,
        "PATH": f"{root}:{os.environ['PATH']}",
        "CAPTURE": str(root / "command"),
    }
    directory = "dir with 'quotes' $(touch PWNED); and spaces"
    subprocess.run(
        ["bash", sys.argv[1], f"fixture:{directory}"], env=env, cwd=root, check=True
    )
    command = (root / "command").read_text()
    quoted = command.removeprefix("bash -s -- ")
    result = subprocess.run(
        ["bash", "-c", "set -- " + quoted + "; printf '%s\\0' \"$@\""],
        cwd=root,
        check=True,
        capture_output=True,
    )
    arguments = result.stdout.decode().split("\0")
    assert arguments[0] == directory, arguments
    assert arguments[1].startswith("/remote home/.cache/rnvim/"), arguments
    assert len(arguments) == 3, arguments
    assert not (root / "PWNED").exists()
    print("rnvim remote arguments survived the shell boundary")
