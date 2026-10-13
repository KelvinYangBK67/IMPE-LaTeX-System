"""Exercise real child trees on both deadline expiry and supervisor cancellation."""
import ctypes
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('bounded', ROOT / 'scripts/run_bounded_command.py')
bounded = importlib.util.module_from_spec(spec)
spec.loader.exec_module(bounded)


def running(pid):
    if os.name == 'nt':
        kernel = ctypes.WinDLL('kernel32', use_last_error=True)
        kernel.OpenProcess.restype = ctypes.c_void_p
        kernel.GetExitCodeProcess.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_ulong)]
        kernel.CloseHandle.argtypes = [ctypes.c_void_p]
        handle = kernel.OpenProcess(0x1000, False, pid)
        if not handle:
            return False
        code = ctypes.c_ulong()
        try:
            assert kernel.GetExitCodeProcess(handle, ctypes.byref(code))
            return code.value == 259
        finally:
            kernel.CloseHandle(handle)
    try:
        os.kill(pid, 0)
    except ProcessLookupError:
        return False
    stat = Path(f'/proc/{pid}/stat')
    return not (stat.exists() and stat.read_text().split(') ')[1].startswith('Z'))


class BoundedCommandTest(unittest.TestCase):
    def exercise_tree(self, cancel):
        build = ROOT / 'tests/build'
        build.mkdir(exist_ok=True)
        with tempfile.TemporaryDirectory(prefix='bounded-', dir=build) as directory:
            pidfile = Path(directory) / 'pids.json'
            code = ('import json,os,subprocess,sys,time; from pathlib import Path; '
                    "c=subprocess.Popen([sys.executable,'-c','import time; time.sleep(30)']); "
                    'Path(sys.argv[1]).write_text(json.dumps([os.getpid(),c.pid])); time.sleep(30)')
            argv = ['bounded', '--timeout', '2', '--log', str(Path(directory) / 'command.log'),
                    '--', sys.executable, '-c', code, str(pidfile)]
            wait = subprocess.Popen.wait
            injected = False

            def interrupt(process, *args, **kwargs):
                nonlocal injected
                if not injected:
                    injected = True
                    deadline = time.monotonic() + 2
                    while not pidfile.exists() and time.monotonic() < deadline:
                        time.sleep(.02)
                    raise KeyboardInterrupt
                return wait(process, *args, **kwargs)

            try:
                with patch.object(sys, 'argv', argv):
                    if cancel:
                        # Inject only the interruption; Popen and cleanup remain real.
                        with patch.object(subprocess.Popen, 'wait', interrupt):
                            result = bounded.main()
                    else:
                        result = bounded.main()
                self.assertEqual(result, 130 if cancel else 124)
                self.assertTrue(pidfile.exists())
                pids = json.loads(pidfile.read_text())
                deadline = time.monotonic() + 3
                while any(running(pid) for pid in pids) and time.monotonic() < deadline:
                    time.sleep(.02)
                self.assertFalse(any(running(pid) for pid in pids), pids)
            finally:
                # Cleanup is restricted to processes created by this fixture.
                if pidfile.exists():
                    for pid in json.loads(pidfile.read_text()):
                        if running(pid):
                            if os.name == 'nt':
                                subprocess.run(['taskkill', '/PID', str(pid), '/T', '/F'],
                                               capture_output=True, timeout=10)
                            else:
                                os.kill(pid, 9)

    def test_timeout_cleans_tree(self):
        self.exercise_tree(False)

    def test_cancel_cleans_tree(self):
        self.exercise_tree(True)


if __name__ == '__main__':
    unittest.main()
