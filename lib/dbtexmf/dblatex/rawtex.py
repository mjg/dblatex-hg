import sys
import os
import re

from texcodec import LatexCodec, TexCodec
from rawverb import VerbParser
from dbtexmf.core.imagedata import *

def utf8(u):
    return u.encode("utf8")

class RawKey:
    def __init__(self, key, incr):
        self.key = key
        self.depth = incr
        self.pos = -1
        self.len = len(key)

class RawLatexParser:
    def __init__(self,
                 key_in=utf8(u"\u0370t"), key_out=utf8(u"\u0371t"),
                 codec=None, output_encoding="latin-1"):
        self.key_in = RawKey(key_in, 1)
        self.key_out = RawKey(key_out, -1)
        self.depth = 0
        self.hyphenate = 0
        self.codec = codec or LatexCodec(output_encoding=output_encoding)
        
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
    "Just encode from UTF-8 without latex escaping"

    def __init__(self, output_encoding="latin-1"):
        RawLatexParser.__init__(self, utf8(u"\u0370u"), utf8(u"\u0371u"),
                                TexCodec(output_encoding=output_encoding))

    def translate(self, text):
        # Currently no hyphenation stuff, just encode
        text = self.codec.decode(text)
        return self.codec.encode(text)


class RawLatex:
    "Main latex file parser"
    def __init__(self):
        self.figre = \
            re.compile(r"(\\includegraphics[\[]?|"\
                       r"\\begin{overpic}|"\
                       r"\\imgexits)[^{]*{([^}]*)}")
        self.image = Imagedata()
        self.parsers = []
        self.format = None

    def set_fig_paths(self, paths):
        self.image.paths = paths

    def set_parsers(self, input, output_encoding=""):
        if not(output_encoding):
            f = file(input)
            params = {}
            started = 0
            for line in f:
                if not(started):
                    if line.startswith("%%<params>"): started = 1
                    continue
                if line.startswith("%%</params>"):
                    break
                p = line.split()
                params[p[1]] = p[2]
            output_encoding = params.get("latex.encoding", "latin-1")

        self.parsers = [VerbParser(output_encoding=output_encoding),
                        RawLatexParser(output_encoding=output_encoding),
                        RawUtfParser(output_encoding=output_encoding)]

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
        self.set_parsers(input)
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
