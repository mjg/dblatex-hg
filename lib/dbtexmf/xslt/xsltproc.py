#
# Basic wrapper for xsltproc. Maybe we should directly use the lixslt Python
# API.
#
import os
import logging
from subprocess import call

class XsltProc:
    def __init__(self):
        self.catalogs = os.getenv("SGML_CATALOG_FILES")
        self.use_catalogs = 1
        self.log = logging.getLogger("dblatex")

    def get_deplist(self):
        return ["xsltproc"]

    def run(self, xslfile, xmlfile, outfile, opts=None, params=None):
        cmd = ["xsltproc", "--xinclude", "--xincludestyle", "-o", outfile]
        if self.use_catalogs and self.catalogs:
            cmd.append("--catalogs")
        if params:
            for param, value in params.items():
                cmd += ["--param", param, "'%s'" % value]
        if opts:
            cmd += opts
        cmd += [xslfile, xmlfile]
        self.system(cmd)

    def system(self, cmd):
        self.log.debug(" ".join(cmd))
        rc = call(cmd)
        if rc != 0:
            raise ValueError("xsltproc failed")

class Xslt(XsltProc):
    "Plugin Class to load"
