#
# Very simple plugin loader for Xslt classes
#
import os
import imp

def load(modname):
    try:
        file, path, descr = imp.find_module(modname, [""])
    except ImportError:
        try:
            file, path, descr = imp.find_module(modname, [os.path.dirname(__file__)])
        except ImportError:
            raise ValueError("Xslt '%s' not found" % modname)
    mod = imp.load_module(modname, file, path, descr)
    file.close()
    o = mod.Xslt()
    return o

