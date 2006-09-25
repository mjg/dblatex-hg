import os
import sys

class Osx:
    def __init__(self):
        self.opts = "-xlower "\
                    "-xno-nl-in-tag "\
                    "-xempty "\
                    "-xid" # To have id() working without a DTD

    def run(self, sgmlfile, xmlfile):
        errfile = "errors.osx"
        rc= os.system("osx %s -f%s %s > %s" % (self.opts, errfile,
                                               sgmlfile, xmlfile))
        if rc != 0:
            for line in open(errfile):
                print >>sys.stderr, line
            raise OSError("osx failed")
