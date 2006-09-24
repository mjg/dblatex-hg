# This file is part of Rubber and thus covered by the GPL
# (c) Emmanuel Beffara, 2002--2006
"""
pdfLaTeX support for Rubber.

When this module loaded with the otion 'dvi', the document is compiled to DVI
using pdfTeX.
"""

from plugins import TexModule

class Module (TexModule):
    def __init__ (self, doc, dict):
        doc.program = "pdflatex"
        doc.engine = "pdfTeX"
        # FIXME: how to handle opt=dvi with file.tex passed?
        # FIXME: can we add commands after the file?
        doc.set_format("pdf")

