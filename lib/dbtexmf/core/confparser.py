import os
import sys
from xml.etree.ElementTree import ParseError
from xmlparser import XmlConfig
from txtparser import TextConfig
from imagedata import ImageConverterPool, ImageConverter
from imagedata import set_config


class ConfigFactory:
    """
    Build the actual objects that configure the other modules from the XML
    parsed configuration, and publish them to the related modules
    """
    def __init__(self, xmlconfig):
        self.xmlconfig = xmlconfig

    def publish(self):
        pool = self.imagedata_config()
        if pool: set_config(pool)

    def imagedata_config(self):
        converters = self.xmlconfig.get("imagedata").get("converter")
        if not(converters):
            return None
        pool = ImageConverterPool()
        for cv in converters:
            imc = ImageConverter(cv.imgsrc, cv.imgdst, cv.docformat, cv.backend)
            for cmd in cv.commands:
                imc.add_command(cmd.args, stdin=cmd.stdin, stdout=cmd.stdout,
                                shell=cmd.shell)
            pool.add_converter(imc)
        return pool


class DbtexConfig:
    """
    Main configuration object, in charge to parse the configuration files
    and populate the setup.
    """
    def __init__(self):
        self.options = []
        self.paths = []
        self.style_exts = ["", ".xml", ".specs", ".conf"]

    def warn(self, text):
        print >>sys.stderr, text

    def fromfile(self, filename):
        try:
            self.fromxmlfile(filename)
        except ParseError, e:
            self.warn("Text configuration files are deprecated. "\
                      "Use the XML format instead")
            self.fromtxtfile(filename)
        except Exception, e:
            raise e

    def fromxmlfile(self, filename):
        xmlconfig = XmlConfig()
        xmlconfig.fromfile(filename)
        self.options += xmlconfig.options()
        factory = ConfigFactory(xmlconfig)
        factory.publish()

    def fromtxtfile(self, filename):
        txtconfig = TextConfig()
        txtconfig.fromfile(filename)
        self.options += txtconfig.options()

    def fromstyle(self, style, paths=None):
        # First, find the related config file
        if not paths:
            paths = self.paths

        for p in paths:
            for e in self.style_exts:
                file = os.path.join(p, style + e)
                if os.path.isfile(file):
                    self.fromfile(file)
                    return

        # If we are here nothing found
        raise ValueError("'%s': style not found" % style)

