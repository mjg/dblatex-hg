#
# Basic wrapper for xsltproc. Maybe we should directly use the lixslt Python
# API.
#
import os

class XsltProc:
    def __init__(self):
        self.verbose = 0
        self.catalogs = os.getenv("SGML_CATALOG_FILES")
        self.use_catalogs = 1

    def run(self, xslfile, xmlfile, outfile, opts=None, params=None):
        cmd = "xsltproc --xinclude -o %s " % outfile
        if self.use_catalogs and self.catalogs:
            cmd += " --catalogs "
        for param in params:
            cmd += "--param %s \"'%s'\" " % (param[0], param[1])
        if opts:
            cmd += " ".join(opts) + " "
        cmd += "%s %s" % (xslfile, xmlfile)
        self.system(cmd)

    def system(self, cmd):
        if self.verbose: print cmd
        rc = os.system(cmd)
        if rc != 0:
            raise ValueError("xsltproc failed")

