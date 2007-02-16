import sys
import os
import re

from texcodec import LatexCodec, TexCodec
from rawverb import VerbParser
from dbtexmf.core.imagedata import *


class RawKey:
    def __init__(self, key, incr):
        self.key = key
        self.depth = incr
        self.pos = -1
        self.len = len(key)

class RawLatexParser:
    def __init__(self, key_in="<t>", key_out="</t>", codec=None):
        self.key_in = RawKey(key_in, 1)
        self.key_out = RawKey(key_out, -1)
        self.depth = 0
        self.hyphenate = 0
        self.codec = codec or LatexCodec()
        
        # hyphenation patterns
        self.hypon = re.compile(r"<h>")
        self.hypof = re.compile(r"</h>")

    def parse(self, line):
        lout = ""
        while (line):
            self.key_in.pos = line.find(self.key_in.key)
            self.key_out.pos = line.find(self.key_out.key)

            if (self.key_out.pos == -1 or
                (self.key_in.pos >= 0 and (self.key_in.pos < self.key_out.pos))):
                key = self.key_in
            else:
                key = self.key_out

            if key.pos != -1:
                text = line[:key.pos]
                line = line[key.pos + key.len:]
            else:
                text = line
                line = ""

            if (text):
                if self.depth > 0:
                    lout += self.translate(text)
                else:
                    text, hon = self.hypon.subn("", text)
                    text, hof = self.hypof.subn("", text)
                    self.hyphenate += (hon - hof)
                    lout += text

            if key.pos != -1:
                self.depth += key.depth

        return lout

    def translate(self, text):
        text = self.codec.decode(text)
        if self.hyphenate:
            text = "\1".join(text)
            text = text.replace("\1 ", " ")
            text = text.replace(" \1", " ")

        text = self.codec.encode(text)

        # Now hyphenate if needed
        if self.hyphenate:
            text = text.replace("\1", r"\-")
        return text


class RawUtfParser(RawLatexParser):
    "Just encode to UTF-8 without latex escaping"

    def __init__(self):
        RawLatexParser.__init__(self, "<u>", "</u>", TexCodec())

    def translate(self, text):
        # Currently no hyphenation stuff, just encode
        text = self.codec.decode(text)
        return self.codec.encode(text)


class RawLatex:
    def __init__(self):
        self.figre = \
            re.compile(r"(\\includegraphics[\[]?|"\
                       r"\\begin{overpic}|"\
                       r"\\imgexits)[^{]*{([^}]*)}")
        self.image = Imagedata()
        self.parsers = [VerbParser(),
                        RawLatexParser(),
                        RawUtfParser()]
        self.format = None

    def set_fig_paths(self, paths):
        self.image.paths = paths

    def set_format(self, format, backend=None):
        figformats = {"pdf":"pdf", "dvi":"eps", "ps":"eps"}
        # Adjust the actual format from backend
        if (format == "pdf" and backend == "dvips"):
            format = "ps"
        if figformats.has_key(format):
            self.image.output_format = figformats[format]
            self.format = format

    def fig_format(self, format):
        # TODO: consistency check?
        self.image.input_format = format

    def parse(self, input, output):
        f = file(input)
        o = file(output, "w")
        for line in f:
            if self.format:
                line = self.figconvert(line)
            for p in self.parsers:
                line = p.parse(line)
                if not(line):
                    break
            if line:
                o.write(line)
        o.close()
        f.close()

    def figconvert(self, line):
        # Is there an image included here
        m = self.figre.search(line)
        if not(m):
            return line

        # Try to convert the image
        fig = m.group(2)
        newfig = self.image.convert(fig)

        # If something done, replace the figure in the tex file
        if newfig != fig:
            line = re.sub(r"{%s}" % fig, r"{%s}" % newfig, line)

        return line
            

def main():
    c = RawLatex()
    c.set_fig_paths([os.getcwd()])
    c.parse(sys.argv[1], sys.argv[2])

if __name__ == "__main__":
    main()
