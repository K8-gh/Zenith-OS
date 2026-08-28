#!/usr/bin/env python3
import importlib.util, tempfile, pathlib, subprocess
from importlib.machinery import SourceFileLoader

source = pathlib.Path('/home/ubuntu/np300e5x-win10/updater/package/usr/local/bin/np300e5x-updater')
loader = SourceFileLoader('np_updater', str(source))
spec = importlib.util.spec_from_loader('np_updater', loader)
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)
class Dialogs:
    @staticmethod
    def showerror(*args, **kwargs):
        raise AssertionError('unexpected updater error')
mod.messagebox = Dialogs

with tempfile.TemporaryDirectory(prefix='np300e5x-update-test-') as td:
    root = pathlib.Path(td)
    mod.LOCAL = root / 'version'
    mod.LOCAL.write_text('0.1.0\n', encoding='utf-8')
    mod.CACHE = root / 'cache'
    mod.BACKUP = root / 'backups'
    release = mod.get_release()
    latest = release['tag_name']
    assert mod.version_key(latest) > mod.version_key(mod.local_version()), (latest, mod.local_version())
    archive = mod.download_release(release)
    assert archive.exists()
    assert mod.sha256(archive) == (mod.CACHE / (archive.name + '.sha256')).read_text().split()[0]
    calls = []
    original_run = mod.subprocess.run
    original_check_output = mod.subprocess.check_output
    mod.subprocess.run = lambda args, **kwargs: calls.append((args, kwargs)) or subprocess.CompletedProcess(args, 0)
    mod.subprocess.check_output = lambda args, **kwargs: '20990101-000000\n'
    mod.install_archive(archive)
    mod.subprocess.run = original_run
    mod.subprocess.check_output = original_check_output
    assert calls and calls[0][0][:3] == ['sudo', 'bash', calls[0][0][2]]
    print(f'found={latest}')
    print(f'downloaded={archive.name}')
    print('sha256=ok')
    print('install-flow=ok (sudo execution mocked; host unchanged)')
