# This file is part of Rubber and thus covered by the GPL
# (c) Emmanuel Beffara, 2002--2006
"""
LaTeX document building system for Grubber.

This module is specific to Grubber and provides a class that encapsulates some of
the rubber internals.
"""
from msg import _, msg
from maker import Maker
from latex import Latex


class LatexBuilder:
    """
    Main (g)rubber wrapper hiding all the internals and compiling the
    required tex file.
    """
    def __init__(self):
        # The actual workers
        self.maker = Maker()
        self.tex = Latex(self.maker)
        self.maker.dep_append(self.tex)

        # What to do
        self.backend = "pdftex"
        self.format = "pdf"

    def set_format(self, format):
        # Just record it
        self.format = format

    def set_backend(self, backend):
        self.backend = backend

    def compile(self, source):
        self.tex.set_source(source)
        self.tex.prepare()

        # Adapt the modules to load, depending on the output format
        if (self.format == "pdf" and self.backend == "pdftex"):
            self.tex.modules.register("pdftex")
        elif (self.format == "pdf"):
            self.tex.modules.register("dvips")
            self.tex.modules.register("ps2pdf")
        elif (self.format == "ps"):
            self.tex.modules.register("dvips")

        # Let's go...
        rc = self.maker.make()
        if rc != 0:
            raise OSError("%s compilation failed" % self.tex.program)

    def print_errors(self):
        msg.display_all(self.tex.get_errors(), writer=msg.write_stderr)

