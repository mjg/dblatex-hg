#
# DbTex configuration parser. Maybe we could use or extend ConfigParser.
#
import os
import re


class OptMap:
    def __init__(self, option, isdir=1, ext=""):
        self.option = option
        self.isdir = isdir
        self.ext = ext
        self.paths = []

class DbtexConfig:
    conf_mapping = {
        'TexInputs' : OptMap('--texinputs', ext="//"),
        #'PdfInputs' : OptMap('--pdfinputs'),
        'TexPost'   : OptMap('--texpost'),
        'FigPath'   : OptMap('--fig-path'),
        'XslParam'  : OptMap('--xsl-user'),
        'TexStyle'  : OptMap('--param=latex.style', isdir=0),
        'Options'   : OptMap('', isdir=0)
    }

    def __init__(self):
        self.options = []
        self.reparam = re.compile("^\s*([^:=\s]+)\s*:\s*(.*)")
        self.paths = []
        self.exts = ["", ".specs", ".conf"]

    def clear(self):
        self.options = []

    def fromfile(self, file):
        dir = os.path.dirname(os.path.realpath(file))
        f = open(file)

        for line in f:
            # Remove the comment
            line = line.split("#")[0]
            m = self.reparam.match(line)
            if not(m):
                continue
            key = m.group(1)
            value = m.group(2).strip()
            if not self.conf_mapping.has_key(key):
                continue
            o = self.conf_mapping[key]

            # The paths can be relative to the config file
            if o.isdir and not(os.path.isabs(value)):
                value = os.path.normpath(os.path.join(dir, value)) + o.ext

            if o.option:
                self.options.append("%s=%s" % (o.option, value))
            else:
                self.options += value.split()

    def fromstyle(self, style, paths=None):
        # First, find the related config file
        if not paths:
            paths = self.paths

        for p in paths:
            for e in self.exts:
                file = os.path.join(p, style + e)
                if os.path.isfile(file):
                    self.fromfile(file)
                    return

        # If we are here nothing found
        raise ValueError("'%s': style not found" % style)

