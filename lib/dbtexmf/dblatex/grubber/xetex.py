"""
XeTeX support for Rubber.
"""

from dbtexmf.dblatex.grubber.plugins import TexModule

class Module (TexModule):
    def __init__ (self, doc, dict):
        doc.program = "xelatex"
        doc.engine = "dvipdfmx"
        doc.encoding = "utf8"
        doc.set_format("pdf")

