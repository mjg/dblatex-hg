#
# DbLatex main class handling the compilation of a DocBook file via
# XSL Transformation and LaTeX compilation.
#
import sys
import os
import re
import tempfile
from optparse import OptionParser

from dbtexmf.core.xsltproc import XsltProc
from dbtexmf.core.sgmlxml import Osx
from dbtexmf.core.dbtex import DbTex, DbTexCommand

from rawtex import RawLatex
from runtex import RunLatex


class DbLatex(DbTex):

    def __init__(self, base=""):
        DbTex.__init__(self, base=base)
        self.name = "dblatex"

        # Engines to use
        self.runtex = RunLatex()
        self.runtex.index_style = "%s/latex/scripts/doc.ist" % self.topdir
        self.rawtex = RawLatex()
        self.xsltproc = XsltProc()
        self.sgmlxml = Osx()

    def set_base(self, topdir):
        DbTex.set_base(self, topdir)
        self.xslmain = "%s/xsl/latex_book_fast.xsl" % self.topdir
        self.xsllist = "%s/xsl/common/mklistings.xsl" % self.topdir
        self.texdir = "%s/latex" % self.topdir
        self.confdir = "%s/latex/specs" % self.topdir


#
# Command entry point
#
def main(base=""):
    command = DbTexCommand(base)
    command.run = DbLatex(base=base)
    command.main()

if __name__ == "__main__":
    main()
