"""Run pytest without hiding its exit status; retain actual console output."""
import os
from pathlib import Path
import subprocess
import sys
import time

root = Path(__file__).resolve().parent
name, *targets = sys.argv[1:]
command = [sys.executable, '-m', 'pytest', '--hypothesis-show-statistics', *targets]
env = dict(os.environ, PYTHONDONTWRITEBYTECODE='1')
started = time.monotonic()
result = subprocess.run(command, cwd=root, env=env, text=True,
                        stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
output = ('$ ' + ' '.join(command) + '\n' + result.stdout
          + f'\nExit code: {result.returncode}\nElapsed: {time.monotonic() - started:.3f} s\n')
(root / 'logs' / name).write_text(output)
print(output)
sys.exit(result.returncode)
