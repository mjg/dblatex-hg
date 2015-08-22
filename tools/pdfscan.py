#
# This tool is provided by dblatex (http://dblatex.sourceforge.net) and has
# the same copyright.
#
# It was initially developped to find out the fonts used and their size because
# as strange as it may seem, no obvious tool gives the font sizes used (pdffonts
# just lists the font objects of the PDF). The script can be improved to give
# more informations in a next release.
#
# To understand the PDF format, read:
#   * The reference:
#     http://www.adobe.com/content/dam/Adobe/en/devnet/acrobat/pdfs/
#                                                      pdf_reference_1-7.pdf
#
#   * A usefull introduction:
#     http://www.adobe.com/content/dam/Adobe/en/technology/pdfs/
#                                                      PDF_Day_A_Look_Inside.pdf
#
#
import os
import sys
import traceback
import zlib
import re
import logging
import tempfile
import shutil

class ErrorHandler:
    def __init__(self):
        self._dump_stack = False
        self.rc = 0

    def dump_stack(self, dump=True):
        self._dump_stack = dump

    def failure_track(self, msg, rc=1):
        self.rc = rc
        print >>sys.stderr, (msg)
        if self._dump_stack:
            traceback.print_exc()

    def failed_exit(self, rc=1):
        self.failure_track(msg, rc)
        sys.exit(self.rc)


def pdfstring_is_list(data):
    return (data and data[0] == "[" and data[-1] == "]")


class PDFFile:
    """
    Main object that parses the PDF file and extract the objects used for
    scanning.
    """
    SHOW_DETAILS = 2
    SHOW_SUMMARY = 1

    def __init__(self, stream_manager=None):
        self.filename = ""
        self.pdfobjects = None
        self.page_objects = []
        self.stream_manager = stream_manager or StreamManager()
        self._log = logging.getLogger("pdfscan.pdffile")

        # Detect the beginning of a PDF Object
        self.re_objstart = re.compile("(\d+) (\d+) obj(.*$)", re.DOTALL)

    def debug(self, text):
        self._log.debug(text)
    def error(self, text):
        self._log.error(text)
    def info(self, text):
        self._log.info(text)

    def cleanup(self):
        self.stream_manager.cleanup()

    def parse_file(self, file_read):
        pdfobj = None
        self.pdfobjects = PDFObjectGroup()

        for line in file_read:
            while line:
                if pdfobj:
                    fields = line.split("endobj", 1)
                    if len(fields) > 1:
                        if fields[0]:
                            pdfobj.append_string(fields[0])
                        pdfobj.compute()
                        self.pdfobjects.add_object(pdfobj)
                        pdfobj = None
                        line = fields[1]
                    else:
                        pdfobj.append_string(line)
                        line = ""
                else:
                    m = self.re_objstart.search(line)
                    if m:
                        number, revision = m.group(1), m.group(2)
                        pdfobj = PDFObject(number, revision,
                                       stream_manager=self.stream_manager)
                        line = m.group(3)
                    else:
                        # drop the line
                        line = ""

    def populate_object_streams(self):
        pdfobjects = self.pdfobjects.get_objects_by_type("/ObjStm")
        if not(pdfobjects):
            return
        for pdfobject in pdfobjects:
            objstm = PDFObjectStream(pdfobject)
            for pdfobj in objstm.pdfobjects():
                self.pdfobjects.add_object(pdfobj)

    def load(self, filename):
        self.filename = filename
        file_pdf = open(filename, 'rb')
        self.parse_file(file_pdf)
        file_pdf.close()
        self.populate_object_streams()
        self.pdfobjects.link_objects()

    def _expand_pages(self, page_kids):
        # Iterations to make a list of unitary pages (/Page) from a list
        # containing group of pages (/Pages). The iterations stop when all
        # The objects in the list are replaced by unit pages and not
        # intermediate page groups
        page_list = page_kids
        has_kid = len(page_list)
        while has_kid:
            newlist = []
            has_kid = 0
            for kid in page_list:
                if kid.get_type() == "/Pages":
                    kids = kid.descriptor.get("/Kids")
                    self.debug("Expand page list: %s -> %s" % (kid, kids))
                    has_kid += len(kids)
                elif kid.get_type() == "/Page":
                    kids = [kid]
                else:
                    self.error("What's wrong? '%s'" % kid.get_type())
                    kids = []
                newlist = newlist + kids
            page_list = newlist
        return page_list

    def arrange_pages(self):
        # From the PDF objects tree, make a flat list of the pages contained
        # by the the document
        if self.page_objects:
            return
        catalog = self.pdfobjects.get_objects_by_type("/Catalog")[0]
        pages = catalog.descriptor.get("/Pages")
        page_count = int(pages.descriptor.get("/Count"))
        page_kids = pages.descriptor.get("/Kids")
        self.page_objects = self._expand_pages(page_kids)
        if len(self.page_objects) != page_count:
            self.error("Unconsistent pages found: %d vs %d" % \
                  (len(self.page_objects), page_count))

    def _page_range(self, page_range):
        if not(page_range): page_range = [1, len(self.page_objects)]
        if page_range[0] == 0: page_range[0] = 1
        if page_range[1] == 0 or page_range[1] > len(self.page_objects):
            page_range[1] = len(self.page_objects)
        return page_range

    def details(self, text):
        self._print(self.SHOW_DETAILS, text)

    def _print(self, level, text):
        if self.print_level >= level:
            print text

    def show_fonts(self, page_range=None, print_level=SHOW_SUMMARY):
        self.print_level = print_level

        self.arrange_pages()

        page_first, page_last = self._page_range(page_range)

        page_objects = self.page_objects[page_first-1:page_last]

        header_fmt = "%4s %-40s %s"
        self.details(header_fmt % ("PAGE", "FONT", "SIZE"))
        self.details(header_fmt % (4*"-", 40*"-", 10*"-"))

        fonts_used = []
        for i, page in enumerate(page_objects):
            page_num = i+page_first
            contents = page.descriptor.get("/Contents")
            resources = page.descriptor.get("/Resources")
            self.debug("Page %d %s: contents: %s, resources: %s" % \
                         (page_num, page, contents, resources))

            if (isinstance(resources, PDFDescriptor)):
                rsc_descriptor = resources
            else:
                rsc_descriptor = resources.descriptor

            font = rsc_descriptor.get("/Font")
            if font:
                fontdict = font.infos()
            else:
                fontdict = {}

            if not(isinstance(contents, list)):
                contents = [contents]

            for content in contents:
                b = PDFContentStream(content, fontdict)
                used_fonts = b.used_fonts()
                for f in used_fonts:
                    font_used = "%-40s %fpt" % \
                          (f.fontobject.descriptor.get("/BaseFont"),
                           f.fontsize)
                    self.details("%4d %s" % (page_num, font_used))
                    if not(font_used in fonts_used):
                        fonts_used.append(font_used)

            self.details(header_fmt % (4*"-", 40*"-", 10*"-"))

        print "\nFonts used in pages %d-%d:" % (page_first, page_last)
        for font in fonts_used:
            print font


class PDFObjectGroup:
    """
    Group of the PDF Objects contained in a file. This wrapper is a dictionnary
    of the objects, and consolidates the links between the objects.
    """
    def __init__(self):
        self.pdfobjects = {}
        self.objtypes = {}

    def count(self):
        return len(self.pdfobjects.values())

    def types(self):
        return self.objtypes.keys()

    def add_object(self, pdfobject):
        self.pdfobjects[pdfobject.ident()] = pdfobject
        objtype = pdfobject.get_type()
        if not(objtype):
            objtype = "misc"
        lst = self.objtypes.get(objtype, [])
        lst.append(pdfobject)
        self.objtypes[objtype] = lst

    def get_objects_by_type(self, objtype):
        return self.objtypes.get(objtype, [])

    def get_object(self, ident):
        return self.pdfobjects.get(ident, None)

    def link_objects(self):
        for pdfobj in self.pdfobjects.values():
            pdfobj.link_to(self.pdfobjects)


class PDFObjectStream:
    """
    A PDF Object Stream contains in its stream some compressed PDF objects.
    This class works on a PDF object stream to build the containded PDF objects.
    """
    def __init__(self, pdfobject):
        self.stream_object = pdfobject
        self._pdfobjects = []

    def debug(self, text):
        self.stream_object.debug(text)
    def error(self, text):
        self.stream_object.error(text)
    def info(self, text):
        self.stream_object.info(text)

    def pdfobjects(self):
        if not(self._pdfobjects):
            self.compute()
        return self._pdfobjects

    def _getinfo(self, what):
        return self.stream_object.descriptor.get(what)

    def parse_object_list(self, data):
        values = data.split()
        objlist = []

        for i in range(0, len(values), 2):
            # The pair is ('object number', byte_offset)
            objlist.append((values[i], int(values[i+1])))
        return objlist

    def compute(self):
        _type = self._getinfo("/Type")
        if  _type != "/ObjStm":
            self.error("Cannot read object stream: Invalid type '%s'" % _type)
            return

        nb_objects = int(self._getinfo("/N"))
        objlist_b = int(self._getinfo("/First"))
        stream = self.stream_object.stream_cache

        objlist = self.parse_object_list(stream.read(objlist_b))

        if len(objlist) != nb_objects:
            self.warning("Error in parsing the Stream Object: found %d"\
                         "objects instead of %d" % (len(objlist), nb_object))

        # List Terminator
        objlist.append(("",-1))

        bytes_read = 0
        for i in range(len(objlist)-1):
            # In ObjectStream, a PDF object revision is always '0'
            number, revision = objlist[i][0], "0"

            # The size of the object data is given by the position of the next
            objsize = objlist[i+1][1] - bytes_read
            if objsize >= 0:
                data = stream.read(objsize)
            else:
                data = stream.read()
            bytes_read += len(data)
            self.debug("Object[%d] in stream: '%s' has %d bytes" % \
                       (i, number, objsize))

            # Build the PDF Object from stream data
            pdfobj = PDFObject(number, revision)
            pdfobj.append_string(data)
            pdfobj.compute()
            self._pdfobjects.append(pdfobj)


class PDFObject:
    """
    A PDF Object contains the data between the 'obj ... 'endobj' tags.
    It has a unique identifier given by the (number,revision) pair.
    The data contained by a PDF object can be dictionnaries (descriptors),
    stream contents and other stuff.
    """
    # Extract a dictionnary '<<...>>' leaf (does not contain another dict)
    _re_desc = re.compile("(<<(?:(?<!<)<(?!<)|[^<>]|(?<!>)>(?!>))+>>)",
                          re.MULTILINE)

    def __init__(self, number, revision, stream_manager=None):
        self.string = ""
        self.number = number
        self.revision = revision
        self.descriptors = []
        self.descriptor = None
        self.data = ""
        self.stream = None
        self.outfile = ""
        self.stream_manager = stream_manager or StreamManager()
        self._log = logging.getLogger("pdfscan.pdfobject")
        self.debug("New Object")
        self.re_desc = self._re_desc

    def debug(self, text):
        self._log.debug(self.logstr(text))
    def warning(self, text):
        self._log.warning(self.logstr(text))
    def error(self, text):
        self._log.error(self.logstr(text))
    def info(self, text):
        self._log.info(self.logstr(text))

    def ident(self):
        return "%s %s" % (self.number, self.revision)

    def __repr__(self):
        return "(%s R)" % self.ident()

    def logstr(self, text):
        return "Object [%s %s]: %s" % (self.number,self.revision,text)

    def append_string(self, string):
        self.string = self.string + string

    def compute(self):
        string = self.string

        s = re.split("stream", string, re.MULTILINE)
        if len(s) > 1:
            self.debug("Contains stream")
            self.stream = s[1].strip()

        string = s[0]

        # Iterate to build all the nested dictionnaries/descriptors,
        # from the deepest to the main one
        self.descriptors = []
        while True:
            descs = self.re_desc.findall(string)
            if not(descs):
                break
            for desc_str in descs:
                desc = PDFDescriptor(string=desc_str)
                string = string.replace(desc_str,
                            "{descriptor(%d)}" % len(self.descriptors))
                self.descriptors.append(desc)
            
        self.debug("Found %d descriptors" % len(self.descriptors))

        for descobj in self.descriptors:
            descobj.compute(descriptors=self.descriptors)

        if self.descriptors:
            self.descriptor = self.descriptors[-1]
        else:
            self.descriptor = PDFDescriptor()

        self.data = re.sub("{descriptor\(\d+\)}", "",
                           string, flags=re.MULTILINE).strip()
        self.debug("Data: '%s'" % self.data)

        self.stream_decode()

    def stream_decode(self):
        if not(self.stream):
            return

        # Consolidate stream buffer from the /Length information
        stream_size = int(self.descriptor.get("/Length"))
        self.stream = self.stream[0:stream_size]

        # Put the stream in a cache
        self.stream_cache = self.stream_manager.cache(number=self.number,
                                                      revision=self.revision)

        method = self.descriptor.get("/Filter")
        if method == "/FlateDecode":
            method = "zlib"
        elif method != "":
            self.error("don't know how to decode stream with filter '%s'" \
                     % method)
            return

        self.stream_cache.write(self.stream, compress_type=method)

    def stream_text(self):
        if not(self.stream):
            return ""
        return self.stream_cache.read()

    def get_type(self):
        _type = self.descriptor.get("/Type")
        if _type:
            return _type
        if self.stream:
            return "stream"
        if pdfstring_is_list(self.data):
            return "list"
        if self.descriptor.is_name_tree_node():
            return "name tree"

    def link_to(self, pdfobjects):
        self.debug("Link objects")
        for desc in self.descriptors:
            desc.link_to(pdfobjects)

        if pdfstring_is_list(self.data):
            pass


class PDFDescriptor:
    """
    Contains the data between the << ... >> brackets in PDF objects. It is
    a dictionnary that can contain other descriptors/dictionnaries.
    """
    # Unique identifier for these objects
    _id = 0

    # Detect the dictionnary fields covering these cases:
    # <<
    #  /Type /Page                    : the value is another keyword
    #  /Contents 5 0 R                : the value is a string up next keyword
    #  /Resources 4 0 R                   
    #  /MediaBox [0 0 595.276 841.89] : the value is an array
    #  /Parent 12 0 R
    # >>
    _re_dict = re.compile("/\w+\s*/[^/\s]+|/\w+\s*\[[^\]]*\]|/\w+\s*[^/]+")

    # Extract a dictionnary keyword
    _re_key = re.compile("(/[^ \({/\[<]*)")

    # Extract the substituted descriptors
    _re_descobj = re.compile("{descriptor\((\d+)\)}")

    # Find the PDF object references
    _re_objref = re.compile("(\d+ \d+ R)")

    def __init__(self, string=""):
        self._ident = self._get_ident()
        self.string = string
        self.params = {}
        self._log = logging.getLogger("pdfscan.descriptor")

        self.re_dict = self._re_dict
        self.re_key = self._re_key
        self.re_descobj = self._re_descobj
        self.re_objref = self._re_objref

    def _get_ident(self):
        _id = PDFDescriptor._id
        PDFDescriptor._id += 1
        return _id

    def ident(self):
        return self._ident

    def debug(self, text):
        self._log.debug("Descriptor [%d]: %s" % (self._ident, text))
    def error(self, text):
        self._log.error("Descriptor [%d]: %s" % (self._ident, text))
    def info(self, text):
        self._log.info("Descriptor [%d]: %s" % (self._ident, text))
    def warning(self, text):
        self._log.warning("Descriptor [%d]: %s" % (self._ident, text))

    def __repr__(self):
        return "desc[%d]" % self._ident

    def normalize_fields(self, string):
        string = string.replace(">>", "")
        string = string.replace("<<", "")
        string = string.replace("\n", " ")
        #print string
        fields = self.re_dict.findall(string)
        fields = [ f.strip() for f in fields if (f and f.strip()) ]
        return fields

    def compute(self, descriptors=None):
        lines = self.normalize_fields(self.string)
        for line in lines:
            #print line
            m = self.re_key.match(line)
            if not(m):
                continue
            param = m.group(1)
            value = line.replace(param, "").strip()
            m = self.re_descobj.match(value)
            if m and descriptors:
                value = descriptors[int(m.group(1))]
            self.params[param] = value

        self.debug(self.params)

    def get(self, param):
        return self.params.get(param, "")
    
    def values(self):
        return self.params.values()

    def keys(self):
        return self.params.keys()

    def infos(self):
        return self.params

    def is_name_tree_node(self):
        if self.get("/Limits") or self.get("/Names") or self.get("/Kid"):
            return True
        else:
            return False

    def link_to(self, pdfobjects):
        for param, value in self.params.items():
            # Point to another descriptor? Skip it
            if isinstance(value, PDFDescriptor):
                continue

            objects = []
            objrefs = self.re_objref.findall(value)
            value2 = value
            #print objrefs
            for objref in objrefs:
                o = pdfobjects.get(objref.replace(" R", ""), None)
                objects.append(o)
                value2 = value2.replace(objref, "", 1)

            if not(objects):
                continue

            if pdfstring_is_list(value):
                if (value2[1:-1].strip()):
                    #print value2, objects
                    self.warning("Problem: cannot substitute objects: '%s'" \
                                 % value)
                else:
                    self.params[param] = objects
                    self.debug("Substitute %s: %s" % (param, objects))
            else:
                if value2.strip() or len(objects) > 1:
                    self.warning("Problem: cannot substitute object" % value)
                else:
                    self.params[param] = objects[0]
                    self.debug("Substitute %s: %s" % (param, objects[0]))
 

class StreamManager:
    CACHE_REFRESH = 1
    CACHE_REMANENT = 2
    CACHE_TMPDIR = 4

    def __init__(self, cache_method="file", cache_dirname="", flags=0):
        self.cache_method = cache_method
        self.cache_format = "pdfstream.%(number)s.%(revision)s"
        self.cache_dirname = cache_dirname
        self.cache_files = []
        self.flags = flags
        self._log = logging.getLogger("pdfscan.pdffile")
        # Don't want to remove something in a user directory
        if cache_dirname: self.flags = self.flags | self.CACHE_REMANENT

    def debug(self, text):
        self._log.debug(text)
    def error(self, text):
        self._log.error(text)
    def info(self, text):
        self._log.info(text)

    def cleanup(self):
        if (self.cache_method != "file"):
            return

        if (self.flags & self.CACHE_REMANENT):
            if (self.flags & self.CACHE_TMPDIR):
                print "'%s' not removed" % (self.cache_dirname)
            return

        if (self.flags & self.CACHE_TMPDIR):
            self.info("Remove cache directory '%s'" % (self.cache_dirname))
            shutil.rmtree(self.cache_dirname)
        else:
            for fname in self.cache_files:
                print "shutil.remove(", fname

    def cache(self, **kwargs):
        if self.cache_method == "file":
            return self.cache_file(kwargs)
        else:
            return self.cache_memory(kwargs)
    
    def cache_file(self, kwargs):
        if not(self.cache_dirname):
            self.cache_dirname = tempfile.mkdtemp()
            self.flags = self.flags | self.CACHE_TMPDIR

        if not(os.path.exists(self.cache_dirname)):
            os.mkdir(self.cache_dirname)

        cache_path = os.path.join(self.cache_dirname,
                                  self.cache_format % kwargs)
        stream_cache = StreamCacheFile(cache_path, flags=self.flags)
        self.cache_files.append(cache_path)
        return stream_cache

    def cache_memory(self, kwargs):
        stream_cache = StreamCacheMemory(flags=self.flags)
        return stream_cache


class StreamCache:
    def __init__(self, outfile, flags=0):
        self.flags = flags

    def decompress(self, data, compress_type):
        if not(compress_type):
            return data
        if compress_type == "zlib":
            return zlib.decompress(data)

class StreamCacheFile(StreamCache):
    def __init__(self, outfile, flags=0):
        self.flags = flags
        self.outfile = outfile
        self._file = None

    def write(self, data, compress_type=""):
        if ((self.flags & StreamManager.CACHE_REFRESH)
            or not(os.path.exists(self.outfile))):
            data = self.decompress(data, compress_type)
            f = open(self.outfile, "w")
            f.write(data)
            f.close()

    def read(self, size=-1):
        if not(self._file):
            self._file = open(self.outfile)
        if size >= 0:
            data = self._file.read(size)
        else:
            data = self._file.read()
        return data

    def _close(self):
        if (self._file):
            self._file.close()

class StreamCacheMemory(StreamCache):
    def __init__(self, outfile, flags=0):
        self.flags = flags
        self._buffer = ""
        self._read_pos = 0

    def write(self, data, compress_type=""):
        self._buffer += self.decompress(data, compress_type)

    def read(self, size=-1):
        remain = len(self._buffer)-self.read_pos
        if size >= 0:
            size = min(size, remain)
        else:
            size = remain
        _buf = self._buffer[self._read_pos:self._read_pos+size]
        self._read_pos += size
        return _buf


class PDFContentStream:
    """
    Data between the 'stream ... endstream' tags in a PDF object used as
    content (and not as image or object storage).
    """
    # Detect a 'Tf', 'Tm', 'Tj', or 'TJ' operator sequence in a text object
    _re_seq = re.compile("(/\w+\s+[^\s]+\s+Tf|"+\
                         6*"[^\s]+\s+"+"Tm"+"|"+\
                         "Tj|TJ)", re.MULTILINE)

    # Find a font setup operator, like '/F10 9.47 Tf'
    _re_font = re.compile("(/\w+\s+[^\s]+\sTf)", re.MULTILINE)

    def __init__(self, pdfobject, fontobjects=None):
        self.stream_object = pdfobject
        self.string = pdfobject.stream_text()
        self.fontobjects = fontobjects or {}
        self.pdffonts = []
        self.allfonts = []
        self.re_seq = self._re_seq
        self.re_font = self._re_font

    def debug(self, text):
        self.stream_object.debug(text)
    def warning(self, text):
        self.stream_object.warning(text)
    def error(self, text):
        self.stream_object.error(text)
    def info(self, text):
        self.stream_object.info(text)

    def record_font(self, fontname, fontsize):
        pdffont = PDFFont(self.fontobjects.get(fontname), fontsize)
        self.pdffonts.append(pdffont)

    def record_font_if_new(self, fontname, fontsize, scale="1"):
        self.debug("Try to add font (%s,%s,%s)" % (fontname, fontsize, scale))
        if ((fontname, fontsize, scale) in self.allfonts):
            return
        self.allfonts.append((fontname, fontsize, scale))
        self.record_font(fontname, float(scale)*float(fontsize))

    def used_fonts(self):
        m = re.search("\sTm", self.string, re.MULTILINE)
        if m:
            self.find_scaled_fonts()
        else:
            self.find_unscaled_fonts()
        return self.pdffonts

    def find_scaled_fonts(self):
        # Search the text objects limited by ' BT ... ET '
        texts = re.findall("(\sBT\s.*\sET\s)", 
                           self.string, re.MULTILINE|re.DOTALL)
        self.debug("Contains %d texts" % len(texts))

        for text in texts:
            self.find_scaled_font_text(text)

    def find_scaled_font_text(self, text):
        # Find the operator sequences
        tf_tm = self.re_seq.findall(text)

        factor = "1"
        font = ""
        last_key = ""

        for tx in tf_tm:
            # print "%s: %s" % (self.objid, tx)
            fields = tx.split()
            key = fields[-1]
            # Found a font setup, memorize the fontname and fontsize base
            if key == "Tf":
                font = fields[0]
                size = fields[1]
            # Found a matrix setup, memorize the fontsize scale factor
            elif key == "Tm":
                if fields[0] != fields[3]:
                    self.warning("Something wrong with Tm matrix: %s" % tx)
                else:
                    factor = fields[0]
            # When text is shown, the current font/size setup applies and is
            # then recorded
            elif key in ("Tj", "TJ"):
                if last_key != "TJ":
                    self.record_font_if_new(font, size, factor)
                key = "TJ"
            last_key = key

    def find_unscaled_fonts(self):
        # Find directly the fonts, because no matrix to check
        fonts = self.re_font.findall(self.string)
        fonts = list(set(fonts))
        for font in fonts:
            rsc, size = font.split()[0:2]
            self.record_font(rsc, float(size))


class PDFFont:
    def __init__(self, fontobject, fontsize):
        self.fontobject = fontobject
        self.fontsize = fontsize


def logger_setup(log_groups):
    loglevels = { "error":   logging.ERROR,
                  "warning": logging.WARNING,
                  "info":    logging.INFO,
                  "debug":   logging.DEBUG }

    console = logging.StreamHandler()
    fmt = logging.Formatter("%(message)s")
    console.setFormatter(fmt)

    for group, level in log_groups.items():
        log = logging.getLogger("pdfscan.%s" % group)
        log.setLevel(loglevels.get(level, logging.INFO)-1)
        log.addHandler(console)


def option_page_ranges(pages):
    page_ranges = []
    if not(pages):
        page_ranges.append([0, 0])
        return page_ranges

    for page_range in pages:
        p1, p2 = (page_range + "-x").split("-")[0:2]
        if not(p2):
            p2 = 0
        elif (p2 == "x"):
            p2 = p1
        page_ranges.append([int(p1), int(p2)])

    return page_ranges

def option_group_loglevels(verbose):
    log_groups = {"pdffile":   "info",
                 "pdfobject": "info",
                 "descriptor": "error"}

    log_levels = ("debug", "info", "warning", "error")

    if not(verbose):
        return log_groups

    groups = log_groups.keys()
    for verbose_opt in verbose:
        group, level = ("all:" + verbose_opt).split(":")[-2:]
        if not(level in log_levels):
            print "Invalid verbose level: '%s'" % level
            continue
        if group == "all":
            for group in groups:
                log_groups[group] = level
        elif group in groups:
            log_groups[group] = level
        else:
            print "Invalid verbose group: '%s'" % group
            continue

    return log_groups

def option_show_items(show):
    show_items_all = ["objects_summary", "fonts_detail", "fonts_summary"]
    show_items_default = ["objects_summary", "fonts_summary"]

    if not(show):
        return show_items_default

    show_items = []
    errors = 0
    for show in show.split(","):
        if show in show_items_all:
            show_items.append(show)
        else:
            errors += 1
            print "Invalid show item: '%s'" % (show)

    if errors:
        print "Valid show items are: %s" % ", ".join(show_items_all)

    return show_items

def option_cache_setup(cache_in_memory, cache_dirname, cache_flags):
    flags = 0
    if cache_flags:
        cache_flags = cache_flags.split(",")
        for cflag in cache_flags:
            if cflag == "remanent":
                flags = flags | StreamManager.CACHE_REMANENT
            elif cflag == "refresh":
                flags = flags | StreamManager.CACHE_REFRESH

    if cache_in_memory:
        mgr = StreamManager(cache_method="memory")
    elif cache_dirname:
        cache_dirname = os.path.realpath(cache_dirname)
        if not(os.path.exists(cache_dirname)):
            print "Invalid cache dir: '%s'. Temporary dir used instead" % \
                  cache_dirname
            return None
        mgr = StreamManager(cache_method="file",
                            cache_dirname=cache_dirname,
                            flags=flags)
    else:
        mgr = StreamManager(flags=flags)

    return mgr

def pdf_load_and_show(pdf, pdffile, show_items):
    pdf.load(pdffile)
    pdfobjects = pdf.pdfobjects

    if not("objects_summary" in show_items):
        return

    print "Found %s PDFObjects" % pdfobjects.count()
    print "Found the following PDFObject types:"
    types = pdfobjects.types()
    types.sort()

    total = 0
    for typ in types:
        n_type = len(pdfobjects.get_objects_by_type(typ))
        print " %20s: %5d objects" % (typ, n_type)
        total = total + n_type
    print " %20s: %5d objects" % ("TOTAL", total)

def font_scan_and_show(pdf, page_ranges, show_items):
    scope = 0
    if "fonts_summary" in show_items:
        scope = pdf.SHOW_SUMMARY
    if "fonts_detail" in show_items:
        scope = pdf.SHOW_DETAILS
    
    if scope != 0:
        for page_range in page_ranges:
            pdf.show_fonts(page_range=page_range, print_level=scope)


def main():
    from optparse import OptionParser
    parser = OptionParser(usage="%s [options] file.pdf" % sys.argv[0])
    parser.add_option("-p", "--pages", action="append",
          help="Page range in the form '<first>[-[<last>]]'")
    parser.add_option("-v", "--verbose", action="append",
          help="Verbose mode in the form '[group:]level' with level "\
               "in 'debug', 'info', 'warning', 'error' and "\
               "group in 'pdffile', 'pdfobject', 'descriptor'")
    parser.add_option("-s", "--show",
          help="Information to show")
    parser.add_option("-c", "--cache-stream-dir",
          help="Directory where to store the decompressed stream")
    parser.add_option("-m", "--no-cache-stream", action="store_true",
          help="No stream cache on disk used: leave streams in memory")
    parser.add_option("-d", "--cache-remanent", action="store_true",
          help="Equivalent to -fremanent")
    parser.add_option("-f", "--cache-flags",
          help="Comma separated list of stream cache setup options: 'remanent'"\
               " and/or 'refresh'")
    parser.add_option("-D", "--dump-stack", action="store_true",
          help="Dump error stack (debug purpose)")
    
    (options, args) = parser.parse_args()

    if len(args) != 1:
        parser.parse_args(["-h"])
        exit(1)

    show_items = option_show_items(options.show)
    if not(show_items):
        parser.parse_args(["-h"])
        exit(1)

    error = ErrorHandler()
    if options.dump_stack: error.dump_stack()

    if options.cache_remanent:
        if options.cache_flags:
            options.cache_flags += ",remanent"
        else:
            options.cache_flags = "remanent"

    page_ranges = option_page_ranges(options.pages)
    log_groups = option_group_loglevels(options.verbose)
    stream_manager = option_cache_setup(options.no_cache_stream,
                                        options.cache_stream_dir,
                                        options.cache_flags)

    logger_setup(log_groups)

    pdffile = args[0]

    pdf = PDFFile(stream_manager=stream_manager)

    try:
        pdf_load_and_show(pdf, pdffile, show_items)
        font_scan_and_show(pdf, page_ranges, show_items)
    except Exception, e:
        error.failure_track("Error: '%s'" % (e))

    pdf.cleanup()
    sys.exit(error.rc)

    if False:
        misc_objs = pdfobjects.get_objects_by_type("misc")
        for o in misc_objs:
            print o.ident()


if __name__ == "__main__":
    main()
