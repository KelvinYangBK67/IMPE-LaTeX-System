"""Run a build command with a file log and a deadline for its process tree."""
import argparse
import os
from pathlib import Path
import signal
import subprocess
import sys
import time


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--timeout', type=float, required=True)
    parser.add_argument('--log', type=Path, required=True)
    parser.add_argument('command', nargs=argparse.REMAINDER)
    args = parser.parse_args()
    command = args.command[1:] if args.command[:1] == ['--'] else args.command
    if args.timeout <= 0 or not command:
        parser.error('a positive timeout and a command are required')
    args.log.parent.mkdir(parents=True, exist_ok=True)
    started = time.perf_counter()
    with args.log.open('wb') as output:
        # File output avoids a full stdout/stderr pipe blocking TeX or its
        # converter. Batch builds cannot answer an interactive input prompt.
        proc = subprocess.Popen(command, stdin=subprocess.DEVNULL,
                                stdout=output, stderr=subprocess.STDOUT,
                                start_new_session=os.name != 'nt')
        try:
            code = proc.wait(timeout=args.timeout)
        except subprocess.TimeoutExpired:
            if os.name == 'nt':
                cleanup = subprocess.run(['taskkill', '/PID', str(proc.pid), '/T', '/F'],
                                         capture_output=True, timeout=15)
                if cleanup.returncode and proc.poll() is None:
                    print(cleanup.stderr.decode(errors='replace'), file=sys.stderr)
                    proc.kill()
            else:
                os.killpg(proc.pid, signal.SIGKILL)
            proc.wait(timeout=15)
            code = 124
            print(f'Timeout after {args.timeout:g}s: {command[0]}', file=sys.stderr)
    print(f'{command[0]}: exit={code}, elapsed={time.perf_counter()-started:.2f}s, log={args.log}')
    if code:
        print('\n'.join(args.log.read_text(encoding='utf-8', errors='replace').splitlines()[-40:]),
              file=sys.stderr)
    return code


if __name__ == '__main__':
    sys.exit(main())
