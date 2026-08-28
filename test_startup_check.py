#!/usr/bin/env python3
import importlib.util, pathlib, tempfile
from importlib.machinery import SourceFileLoader
source = pathlib.Path('/home/ubuntu/np300e5x-win10/updater/package/usr/local/bin/np300e5x-updater')
loader = SourceFileLoader('zenith_updater', str(source))
spec = importlib.util.spec_from_loader('zenith_updater', loader)
mod = importlib.util.module_from_spec(spec); spec.loader.exec_module(mod)
with tempfile.TemporaryDirectory(prefix='zenith-startup-test-') as td:
    root = pathlib.Path(td); mod.LOCAL = root/'version'; mod.LOCAL.write_text('0.1.4\n'); mod.BACKUP = root/'backups'; mod.CACHE = root/'cache'
    launched = []; mod.subprocess.Popen = lambda args, **kwargs: launched.append(args)
    mod.startup_check()
    assert len(launched) == 2, launched
    assert launched[1][-1] == str(source), launched
    print('startup-check=ok')
    print('notification-and-update-window=triggered')
