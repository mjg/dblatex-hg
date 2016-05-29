import sys
import os
import re
import shutil
import logging
import urllib
from dbtexmf.core.error import signal_error
from commander import CommandRunner

class PoolManager:
    def __init__(self): 
        self._used_pool = None
        self._pending_pools = []
    
    def set_pool(self, pool):
        self._used_pool = pool
        for p in self._pending_pools:
            pool.preprend(p)
        self._pending_pools = []
    
    def prepend_pool(self, pool):
        if self._used_pool:
            self._used_pool.prepend(pool)
        else:
            self._pending_pools.append(pool)

_pool_manager = PoolManager()
    
def set_config(data):
    global _pool_manager
    _pool_manager.prepend_pool(data)

def set_pool(pool):
    global _pool_manager
    _pool_manager.set_pool(pool)

#
# Objects to convert an image format to another. Actually use the underlying
# tools.
#
class ImageConverter:
    _log = logging.getLogger("dblatex")

    def __init__(self, imgsrc, imgdst="", docformat="", backend=""):
        self.imgsrc = imgsrc
        self.imgdst = imgdst or "*"
        self.docformat = docformat or "*"
        self.backend = backend or "*"
        self.command = CommandRunner(log=self._log)

    def add_command(self, *args, **kwargs):
        self.command.add_command(*args, **kwargs)

    def convert(self, input, output, format, doexec=1):
        rc = self.command.run(kw={"input": input, "output": output,
                                  "dst": format})
        if rc != 0: signal_error(self, "")

class ImageConverterPool:
    def __init__(self):
        self.converters = []

    def add_converter(self, converter):
        self.converters.append(converter)

    def extend(self, other):
        self.converters.extend(other.converters)

    def prepend(self, other):
        self.converters = other.converters + self.converters

    def _re_multi_or_star(self, searched):
        if not(searched):
            searched = r"\w*"
        else:
            s = searched.split()
            #searched = "|".join(["(?<=[/ ])%s" % p for p in s])
            searched = "|".join(["%s" % p for p in s])
        searched += r"|\*"
        return "("+searched+")"

    def get_converters(self, imgsrc="", imgdst="", docformat="", backend=""):
        converters = self.converters
        imgsrc = self._re_multi_or_star(imgsrc)
        imgdst = self._re_multi_or_star(imgdst)
        docfmt = self._re_multi_or_star(docformat)
        backend = self._re_multi_or_star(backend)
        founds = []
        for converter in converters:
            lookup = {imgsrc: converter.imgsrc,
                      imgdst: converter.imgdst,
                      docfmt: converter.docformat,
                      backend: converter.backend}

            for re_expr, data in lookup.items():
                m = re.search(re_expr, data)
                if not(m): break
            if m: founds.append(converter)
        return founds


class ImageConverters(ImageConverterPool):
    def __init__(self):
        ImageConverterPool.__init__(self)
        # Default setup
        self.add_converter(GifConverter("gif"))
        self.add_converter(EpsConverter("eps", "pdf"))
        self.add_converter(EpsConverter("eps", "png"))
        self.add_converter(FigConverter("fig", "pdf"))
        self.add_converter(FigConverter("fig", "png"))
        self.add_converter(SvgConverter("svg"))

        # Register as main pool
        set_pool(self)


class GifConverter(ImageConverter):
    def __init__(self, imgsrc, imgdst="", docformat="", backend=""):
        ImageConverter.__init__(self, imgsrc="gif bmp", imgdst="*")
        self.add_command(["convert", "%(input)s", "%(output)s"])

class EpsConverter(ImageConverter):
    def __init__(self, imgsrc, imgdst="", docformat="", backend=""):
        ImageConverter.__init__(self, imgsrc="eps", imgdst=imgdst)
        if imgdst == "pdf":
            self.add_command(["epstopdf", "--outfile=%(output)s", "%(input)s"],
                             shell=True)
        elif imgdst == "png":
            self.add_command(["convert", "%(input)s", "%(output)s"])

class FigConverter(ImageConverter):
    def __init__(self, imgsrc, imgdst="", docformat="", backend=""):
        ImageConverter.__init__(self, imgsrc="fig", imgdst=imgdst)
        self.add_command(["fig2dev", "-L", "eps", "%(input)s"],
                         stdout="%(output)s")
        if imgdst != "eps":
            self.conv_next = EpsConverter("eps", imgdst=imgdst)
        else:
            self.conv_next = None

    def convert(self, input, output, format):
        if self.conv_next:
            epsfile = "tmp_fig.eps"
        else:
            epsfile = output
        ImageConverter.convert(self, input, epsfile, "eps")
        if self.conv_next:
            self.conv_next.convert(epsfile, output, format)

class SvgConverter(ImageConverter):
    def __init__(self, imgsrc, imgdst="", docformat="", backend=""):
        ImageConverter.__init__(self, imgsrc="svg", imgdst=imgdst)
        self.add_command(["inkscape", "-z", "-D", "--export-%(dst)s=%(output)s",
                          "%(input)s"])


#
# The Imagedata class handles all the image transformation
# process, from the discovery of the actual image involved to
# the conversion process.
#
class Imagedata:
    def __init__(self):
        self.paths = []
        self.input_format = "png"
        self.output_format = "pdf"
        self.converters = ImageConverters()
        self.converted = {}
        self.log = logging.getLogger("dblatex")
        self.output_encoding = ""

    def set_encoding(self, output_encoding):
        self.output_encoding = output_encoding

    def convert(self, fig):
        # Translate the URL to an actual local path
        fig = urllib.url2pathname(fig)

        # Always use '/' in path: work even on windows and is required by tex
        if os.path.sep != '/': fig = fig.replace(os.path.sep, '/')

        # First, scan the available formats
        (realfig, ext) = self.scanformat(fig)

        # No real file found, give up
        if not(realfig):
            self.log.warning("Image '%s' not found" % fig)
            return fig

        # Check if this image has been already converted
        if self.converted.has_key(realfig):
            self.log.info("Image '%s' already converted as %s" % \
                  (fig, self.converted[realfig]))
            return self.converted[realfig]

        # No format found, take the default one
        if not(ext):
            ext = self.input_format

        # Natively supported format?
        if (ext == self.output_format):
            return self._safe_file(fig, realfig, ext)

        # Try to convert
        count = len(self.converted)
        newfig = "fig%d.%s" % (count, self.output_format)

        conv = self.converters.get_converters(ext, self.output_format)
        if not(conv):
            self.log.debug("Cannot convert '%s' to %s" % (fig,
                             self.output_format))
            # Unknown conversion to do, or nothing to do
            return self._safe_file(fig, realfig, ext)
        else:
            # Take the first converter that does the trick
            conv = conv[0]

        # Convert the image and put it in the cache
        conv.log = self.log
        conv.convert(realfig, newfig, self.output_format)
        self.converted[realfig] = newfig
        return newfig

    def _safe_file(self, fig, realfig, ext):
        """
        Copy the file in the working directory if its path contains characters
        unsupported by latex, like spaces.
        """
        # Encode to expected output format. If encoding is OK and 
        # supported by tex, just return the encoded path
        newfig = self._path_encode(fig)
        if newfig and newfig.find(" ") == -1:
            return newfig

        # Added to the converted list
        count = len(self.converted)
        newfig = "figcopy%d.%s" % (count, ext)
        self.converted[realfig] = newfig

        # Do the copy
        shutil.copyfile(realfig, newfig)
        return newfig

    def _path_encode(self, fig):
        # Actually, only ASCII characters are sure to match filesystem encoding
        # so let's be conservative
        if self.output_encoding == "utf8":
            return fig
        try:
            newfig = fig.decode("utf8").encode("ascii")
        except:
            newfig = ""
        return newfig

    def scanformat(self, fig):
        (root, ext) = os.path.splitext(fig)

        if (ext):
            realfig = self.find(fig)
            return (realfig, ext[1:])
        
        # Lookup for the best suited available figure
        if (self.output_format == "pdf"):
            formats = ("png", "pdf", "jpg", "eps", "gif", "fig", "svg")
        else:
            formats = ("eps", "fig", "pdf", "png", "svg")

        for format in formats:
            realfig = self.find("%s.%s" % (fig, format))
            if realfig:
                self.log.info("Found %s for '%s'" % (format, fig))
                break

        # Maybe a figure with no extension
        if not(realfig):
            realfig = self.find(fig)
            format = ""

        return (realfig, format)
        
    def find(self, fig):
        # First, the obvious absolute path case
        if os.path.isabs(fig):
            if os.path.isfile(fig):
                return fig
            else:
                return None

        # Then, look for the file in known paths
        for path in self.paths:
            realfig = os.path.join(path, fig)
            if os.path.isfile(realfig):
                return realfig

        return None
 
