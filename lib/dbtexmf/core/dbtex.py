#
# DbTex base class handling the compilation of a DocBook file via
# XSL Transformation and some TeX engine compilation.
#
import sys
import os
import re
import tempfile
from optparse import OptionParser

from dbtexmf.core.confparser import DbtexConfig, texinputs_parse


def suffix_replace(path, oldext, newext=""):
    (root, ext) = os.path.splitext(path)
    if ext == oldext:
        return (root+newext)
    else:
        return (path+newext)


class DbTex:
    USE_MKLISTINGS = 1

    def __init__(self, base=""):
        self.name = None
        self.debug = 0
        self.verbose = 0
        if base:
            self.set_base(base)
        self.xslopts = []
        self.xslparams = []
        self.xsluser = ""
        self.flags = self.USE_MKLISTINGS
        self.input = ""
        self.input_format = "xml"
        self.output = ""
        self.format = "pdf"
        self.tmpdir = ""
        self.fig_paths = []
        self.texinputs = []
        self.texbatch = 1
        self.fig_format = ""
        self.backend = ""

        # Temporary files
        self.basefile = ""
        self.rawfile = ""
        self.texfile = ""
        self.binfile = ""

        # Engines to use
        self.runtex = None
        self.rawtex = None
        self.xsltproc = None
        self.sgmlxml = None

    def set_base(self, topdir):
        self.topdir = os.path.realpath(topdir)
        self.xslmain = "%s/xsl/docbook.xsl" % self.topdir
        self.xsllist = "%s/xsl/common/mklistings.xsl" % self.topdir
        self.texdir = "%s/texstyle" % self.topdir
        self.confdir = "%s/confstyle" % self.topdir

    def update_texinputs(self):
        # Systematically put the package style in TEXINPUTS
        texpaths = ":".join(self.texinputs + [self.texdir + "//"])
        texinputs = os.getenv("TEXINPUTS") or ""
        if not(texinputs) or texinputs[0] == ":":
            texinputs = ":%s%s" % (texpaths, texinputs)
        else:
            texinputs = ":%s:%s" % (texpaths, texinputs)
        os.environ["TEXINPUTS"] = texinputs

    def set_format(self, format):
        if not(format in ("rtex", "tex", "dvi", "ps", "pdf")):
            raise ValueError("unknown format '%s'" % format)
        else:
            self.format = format

    def set_verbose(self, verbose):
        self.verbose = verbose
        self.runtex.verbose = verbose
        self.rawtex.verbose = verbose
        self.xsltproc.verbose = verbose

    def unset_flags(self, what):
        self.flags &= ~what

    def get_version(self):
        s = file("%s/xsl/version.xsl" % self.topdir).read()
        versions = re.findall("<xsl:variable[^>]*>([^<]*)<", s)
        if versions:
            return versions[0].strip()
        else:
            return "unknown"

    def build_stylesheet(self, wrapper="custom.xsl"):
        if not(self.xslparams or self.xsluser):
            self.xslbuild = self.xslmain
            return

        f = file(wrapper, "w")
        f.write("""<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:m="http://www.w3.org/1998/Math/MathML"
                version="1.0">
                \n""")
        f.write('<xsl:import href="%s"/>\n' % self.xslmain)
        if self.xsluser:
            f.write('<xsl:import href="%s"/>\n' % self.xsluser)

        for param in self.xslparams:
            v = param.split("=", 1)
            f.write('<xsl:param name="%s">' % v[0])
            if len(v) == 2:
                f.write('%s' % v[1])
            f.write('</xsl:param>\n')

        f.write('</xsl:stylesheet>\n')
        f.close()
        self.xslbuild = wrapper

    def make_xml(self):
        print "Build the XML file..."
        xmlfile = self.basefile + ".xml"
        self.sgmlxml.run(self.input, xmlfile)
        self.input = xmlfile

    def make_listings(self):
        self.listings = "listings.xml"
        if (self.flags & self.USE_MKLISTINGS):
            print "Build the listings..."
            param = ("current.dir", self.inputdir)
            self.xsltproc.use_catalogs = 0
            self.xsltproc.run(self.xsllist, self.input,
                              self.listings, params=[param])
        else:
            print "No external file support"
            f = file(self.listings, "w")
            f.write("<listings/>\n")
            f.close()

    def make_rawtex(self):
        self.rawfile = self.basefile + ".rtex"
        param = ("listings.xml", self.listings)
        self.xsltproc.use_catalogs = 1
        self.xsltproc.run(self.xslbuild, self.input,
                          self.rawfile, opts=self.xslopts, params=[param])

    def make_tex(self):
        self.texfile = self.basefile + ".tex"
        self.rawtex.set_format(self.format)
        if self.fig_format:
            self.rawtex.fig_format(self.fig_format)

        # By default figures are relative to the source file directory
        self.rawtex.set_fig_paths([self.inputdir] + self.fig_paths)
        self.rawtex.parse(self.rawfile, self.texfile)

    def make_bin(self):
        self.binfile = self.basefile + "." + self.format
        if self.backend:
            self.runtex.set_backend(self.backend)
        self.runtex.set_fig_paths([self.inputdir] + self.fig_paths)
        self.runtex.compile(self.texfile, self.binfile, self.format,
                            batch=self.texbatch)

    def compile(self):
        self.cwdir = os.getcwd()
        self.tmpdir = tempfile.mkdtemp()
        self.inputdir = os.path.dirname(self.input)
        os.chdir(self.tmpdir)
        try:
            donefile = self._compile()
            rc = os.system("mv %s %s" % (donefile, self.output))
            if rc == 0:
                print "'%s' successfully built" % os.path.basename(self.output)
        finally:
            os.chdir(self.cwdir)
            if not(self.debug):
                os.system("rm -rf %s" % self.tmpdir)
            else:
                print "%s not removed" % self.tmpdir

    def _compile(self):
        # The temporary output file
        tmpout = os.path.basename(self.input)
        for s in (" ", "\t"):
            tmpout = tmpout.replace(s, "_")
        self.basefile = suffix_replace(tmpout, "." + self.input_format)

        # Convert SGML to XML if needed
        if self.input_format == "sgml":
            self.make_xml()

        # Build the user XSL stylesheet if needed
        self.build_stylesheet()

        # Refresh the TEXINPUTS
        self.update_texinputs()

        # For easy debug
        if self.debug and os.environ.has_key("TEXINPUTS"):
            f = file("env_tex", "w")
            f.write("TEXINPUTS=%s\nexport TEXINPUTS\n" % \
                    os.environ["TEXINPUTS"])
            f.close()

        # Build the tex file, and compile it
        self.make_listings()
        self.make_rawtex()
        if self.format == "rtex":
            return self.rawfile

        self.make_tex()
        if self.format == "tex":
            return self.texfile

        self.make_bin()
        return self.binfile


def failed_exit(msg, rc=1):
    print >>sys.stderr, (msg)
    sys.exit(rc)


#
# Command entry point
#
class DbTexCommand:
    def __init__(self, base):
        prog = os.path.splitext(os.path.basename(sys.argv[0]))[0]
        usage = "%s [options] file" % prog
        parser = OptionParser(usage=usage)
        parser.add_option("-b", "--backend",
                          help="Backend driver to use. The available drivers are "
                               "'pdftex' and 'dvips'.")
        parser.add_option("-B", "--no-batch", action="store_true",
                          help="All the tex output is printed")
        parser.add_option("-c", "--config",
                          help="Configuration file")
        parser.add_option("-d", "--debug", action="store_true",
                          help="Debug mode. Keep the temporary directory in "
                               "which %s actually works" % prog)
        parser.add_option("-f", "--fig-format",
                          help="Input figure format, used when not deduced from "
                               "figure extension")
        parser.add_option("-F", "--input-format",
                          help="Input file format: sgml, xml. (default=xml)")
        parser.add_option("-i", "--texinputs", action="append",
                          help="Path added to TEXINPUTS")
        parser.add_option("-I", "--fig-path", action="append",
                          dest="fig_paths", metavar="FIG_PATH",
                          help="Additional lookup path of the figures")
        parser.add_option("-o", "--output", dest="output",
                          help="Output filename. When not used, the input filename "
                               "is used, with the suffix of the output format")
        parser.add_option("-p", "--xsl-user",
                          help="XSL user configuration file to use")
        parser.add_option("-P", "--param", dest="xslparams",
                          action="append", metavar="PARAM=VALUE",
                          help="Set an XSL parameter value from command line")
        parser.add_option("-t", "--type", dest="format",
                          help="Output format. Available formats:\n"
                               "tex, dvi, ps, pdf (default=pdf)")
        parser.add_option("--dvi", action="store_true", dest="format_dvi",
                          help="DVI output. Equivalent to -tdvi")
        parser.add_option("--pdf", action="store_true", dest="format_pdf",
                          help="PDF output. Equivalent to -tpdf")
        parser.add_option("--ps", action="store_true", dest="format_ps",
                          help="PostScript output. Equivalent to -tps")
        parser.add_option("-T", "--style",
                          help="Predefined output style")
        parser.add_option("-v", "--version", action="store_true",
                          help="Print the %s version" % prog)
        parser.add_option("-V", "--verbose", action="store_true",
                          help="Verbose mode, showing the running commands")
        parser.add_option("-x", "--xslt", dest="xslopts",
                          action="append", metavar="XSLT_OPTIONS",
                          help="Arguments directly passed to the XSLT engine")
        parser.add_option("-X", "--no-external", action="store_true",
                          help="Disable the external text file support used for "
                               "some callout processing")

        self.parser = parser
        self.base = base
        self.prog = prog
        # The actual engine to use is unknown
        self.run = None

    def run_setup(self, options):
        run = self.run

        if not(options.format):
            if options.format_pdf:
                options.format = "pdf"
            elif options.format_ps:
                options.format = "ps"
            elif options.format_dvi:
                options.format = "dvi"

        if options.format:
            try:
                run.set_format(options.format)
            except Exception, e:
                failed_exit("Error: %s" % e)

        if options.xslopts:
            run.xslopts = options.xslopts

        if options.xslparams:
            run.xslparams = options.xslparams

        if options.debug:
            run.debug = options.debug

        if options.fig_paths:
            run.fig_paths += [os.path.realpath(p) for p in options.fig_paths]

        if options.texinputs:
            for texinputs in options.texinputs:
                run.texinputs += texinputs_parse(texinputs)

        if options.fig_format:
            run.fig_format = options.fig_format

        if options.input_format:
            run.input_format = options.input_format

        if options.no_batch:
            run.texbatch = 0

        if options.backend:
            run.backend = options.backend

        if options.xsl_user:
            xsluser = os.path.realpath(options.xsl_user)
            if not(os.path.isfile(xsluser)):
                failed_exit("Error: '%s' does not exist" % options.xsl_user)
            run.xsluser = xsluser

        if options.no_external:
            run.unset_flags(run.USE_MKLISTINGS)

        if options.verbose:
            run.set_verbose(options.verbose)

    def main(self):
        (options, args) = self.parser.parse_args()

        run = self.run
        parser = self.parser

        if options.version:
            version = run.get_version()
            print "%s version %s" % (self.prog, version)
            if not(args):
                sys.exit(0)

        # At least the input file is expected
        if not(args):
            parser.parse_args(args=["-h"])

        # Load the specified configurations
        conf = DbtexConfig()
        if options.style:
            try:
                conf.fromstyle(options.style, [run.confdir])
            except Exception, e:
                failed_exit("Error: %s" % e)
            
        if options.config:
            try:
                conf.fromfile(options.config)
            except Exception, e:
                failed_exit("Error: %s" % e)

        if conf.options:
            options2, args2 = parser.parse_args(conf.options)
            self.run_setup(options2)
         
        # Now apply the command line setup
        self.run_setup(options)

        input = os.path.realpath(args[0])

        # The output name can be deduced from the input one:
        # /path/to/input.xml -> /path/to/input.{tex|pdf|dvi|ps}
        if not(options.output):
            output = suffix_replace(input, "."+run.input_format, ".%s" % run.format)
        else:
            output = os.path.realpath(options.output)

        run.input = input
        run.output = output

        # Try to buid the file
        try:
            run.compile()
        except Exception, e:
            failed_exit("Error: %s" % e)

