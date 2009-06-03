#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Time-stamp: <2008-06-23 22:21:26 ah>

"""
Provide an encoder for a font specification configuration: the encoder is fed
with Unicode characters one by one and determines the needed font switches
between the preceding and the current character.
"""

import re
import xml.dom.minidom

def _indent(string, width=2):
    """Indent the <string> lines by <width> blank characters."""
    istr = ' ' * width
    s = istr + istr.join(string.splitlines(1))
    return s

class UnicodeInterval:
    """Unicode codepoint interval, including all codepoints between its minimum
    and maximum boundary.
    For any Unicode codepoint it can be queried if it belongs to the interval.
    """

    # Internal data attributes:
    # _min_boundary: Minimum boundary of the codepoint interval (ordinal)
    # _max_boundary: Maximum boundary of the codepoint interval (ordinal)

    _re_codepoint = re.compile(r'^[Uu]\+?([0-9A-Fa-f]+)$')

    def __init__(self):
        self._min_boundary = 0
        self._max_boundary = 0

    def __str__(self):
        """Dump the instance's data attributes."""
        string = '[' + str(self._min_boundary)
        if self._max_boundary != self._min_boundary:
            string += ',' + str(self._max_boundary)
        string += ']'
        return string

    def _unicode_to_ordinal(self, codepoint):
        """Return the ordinal of the specified codepoint."""
        match = self._re_codepoint.match(codepoint)
        if match:
            return int(match.group(1), 16)
        else:
            raise RuntimeError, 'Not a unicode codepoint: ' + codepoint

    def from_char(self, char):
        """Interval for a single character"""
        self._min_boundary = ord(char)
        self._max_boundary = self._min_boundary
        return self

    def from_codepoint(self, codepoint):
        """Interval for a single character defined as unicode string."""
        self._min_boundary = self._unicode_to_ordinal(codepoint)
        self._max_boundary = self._min_boundary
        return self

    def from_interval(self, codepoint1, codepoint2):
        """Interval from a unicode range."""
        self._min_boundary = self._unicode_to_ordinal(codepoint1)
        self._max_boundary = self._unicode_to_ordinal(codepoint2)
        if self._min_boundary > self._max_boundary:
            self._min_boundary, self._max_boundary = \
                self._max_boundary, self._min_boundary
        return self

    def match(self, char):
        """
        Determine whether the specified character is contained in this
        instance's interval.
        """
        #print "%d in [%d - %d]?" % (ord(char), self._min_boundary,self._max_boundary)
        return (ord(char) >= self._min_boundary
                and ord(char) <= self._max_boundary)


class FontSpec:
    """
    Font specification, consisting of one or several unicode character
    intervals and of fonts to select for those characters. The object
    fully defines the fonts to switch to.
    """

    # Internal data attributes:
    # _intervals: UnicodeInterval list

    transition_types = ['enter', 'inter', 'exit']
    _re_interval = re.compile(r'^([Uu][0-9A-Fa-f]+)-([Uu][0-9A-Fa-f]+)$')
    _re_codepoint = re.compile(r'^([Uu][0-9A-Fa-f]+)$')

    def __init__(self, intervals=None, subfont_first=False):
        """Create a font specification from the specified codepoint intervals.
        The other data attributes will be set by the caller later.
        """
        self.type = ""
        self.id = None
        self.refmode = None
        self.transitions = {}
        self.fontspecs = [self]
        self.subfont_first = subfont_first
        self._ignored = []

        for type in self.transition_types:
            self.transitions[type] = {}

        if not(intervals):
            self._intervals = []
            return

        try:
            self._intervals = list(intervals)
        except TypeError:
            self._intervals = [intervals]

    def fromnode(self, node):
        range = node.getAttribute('range')
        charset = node.getAttribute('charset')
        id = node.getAttribute('id')
        refmode = node.getAttribute('refmode')
        self.type = node.getAttribute('type')

        if (range):
            self._intervals = self._parse_range(range)
        elif (charset):
            intervals = []
            for char in charset:
                intervals.append(UnicodeInterval().from_char(char))
            self._intervals = intervals

        # Unique identifier
        if (id):
            self.id = id
        if (refmode):
            self.refmode = refmode

        for transition_type in self.transition_types:
            self._parse_transitions(node, transition_type)

    def _parse_range(self, range):
        """Parse the specified /fonts/fontspec@range attribute to a
        UnicodeInterval list.
        """
        print range
        intervals = []
        chunks = range.split()
        for chunk in chunks:
            match = self._re_interval.match(chunk)
            #print match
            if match:
                urange = UnicodeInterval().from_interval(match.group(1),
                                                          match.group(2))
                intervals.append(urange)
            else:
                match = self._re_codepoint.match(chunk)
                if match:
                    intervals.append(
                        UnicodeInterval().from_codepoint(match.group(1)))
                else:
                    raise RuntimeError, 'Unable to parse range: "' + range + '"'
        return intervals

    def _parse_transitions(self, node, transition_type):
        """Evaluate the font elements of the specified fontspec element for the
        specified transition type (enter, inter or exit).
        """
        fontlist = self.transitions[transition_type]

        for dom_transition in node.getElementsByTagName(transition_type):
            for dom_font in dom_transition.getElementsByTagName('font'):
                font = ''
                types = dom_font.getAttribute("type")
                types = types.split()
                for dom_child in dom_font.childNodes:
                    if dom_child.nodeType == dom_child.TEXT_NODE:
                        font += dom_child.nodeValue
                if (font):
                    for type in types:
                        fontlist[type] = font

    def _switch_to(self, fonts):
        """
        Return a string with the XeTeX font switching commands for the
        specified font types.
        """
        s = ''
        for type, font in fonts.items():
            s += '\switch%sfont{%s}' % (type, font)
        if s:
            s = r"\savefamily" + s + r"\loadfamily{}"
        return s

    def enter(self):
        print "enter in %s" % self.id
        s = self._switch_to(self.transitions["enter"])
        return s

    def exit(self):
        print "exit from %s" % self.id
        s = self._switch_to(self.transitions["exit"])
        return s

    def interchar(self):
        s = self._switch_to(self.transitions["inter"])
        return s

    def __str__(self):
        """Dump the instance's data attributes."""
        string = 'FontSpec:'
        string += '\n  Id: %s' % self.id
        string += '\n  Refmode: %s' % self.refmode
        for interval in self._intervals:
            string += '\n' + _indent(str(interval))
        return string

    def add_subfont(self, fontspec):
        print "%s -> %s" % (self.id, fontspec.id)
        if self.subfont_first:
            self.fontspecs.insert(-1, fontspec)
        else:
            self.fontspecs.append(fontspec)

    def add_uranges(self, ranges, depth=1):
        # Recursively extend the supported character range
        if depth:
            for f in self.fontspecs:
                if f != self:
                    f.add_uranges(ranges)
        self._intervals.extend(ranges)

    def add_ignored(self, ranges, depth=1):
        if depth:
            for f in self.fontspecs:
                if f != self:
                    f.add_ignored(ranges)
        self._ignored.extend(ranges)

    def get_uranges(self):
        return self._intervals

    def contains(self, char):
        #print "%s: %s" % (self.id, self._intervals)
        for interval in self._intervals:
            if interval.match(char):
                return True
        else:
            return False

    def isignored(self, char):
        #print "%s: %s" % (self.id, [ str(a) for a in self._ignored ])
        for interval in self._ignored:
            if interval.match(char):
                return True
        else:
            return False

    def _loghas(self, id, char):
        try:
            print "%s has '%s'" % (id, str(char))
        except:
            print "%s has '%s'" % (id, ord(char))

    def match(self, char):
        """Determine whether the font specification matches the specified
        object, thereby considering refmode.
        """
        fontspec = None
        #print "Lookup in ", self.id
        if self.isignored(char):
            self._loghas(self.id, char)
            return self

        for fontspec in self.fontspecs:
            #print " Look in %s" % fontspec.id
            if fontspec.contains(char):
                self._loghas(fontspec.id, char)
                return fontspec
        return None


class DefaultFontSpec(FontSpec):
    """
    The default fontspec gives priority to its children, and 
    contains any character.
    """
    def __init__(self):
        FontSpec.__init__(self, subfont_first=True)
    
    def contains(self, char):
        return True


class FontSpecConfig:
    """
    This object parses an XML fontspec configuration file and build the
    resulting fontspec tree, the root fontspec being the default font
    to apply.
    
    The fontspec configuration file defines the fonts to apply in order
    of precedence (and for some Unicode ranges) and the font levels (or
    subfonts) thanks to the 'refmode' attribute that links a font to its
    parent.
    """

    def __init__(self, conf_file):
        """Create a font specification configuration from the specified file
        (file name or file-like object).
        """
        self.fontspecs = []
        self.fontnames = {}

        self.default_fontspec = DefaultFontSpec()

        dom_document = xml.dom.minidom.parse(conf_file)
        for dom_fontspec in dom_document.getElementsByTagName('fontspec'):
            default = dom_fontspec.getAttribute('default')
            if default:
                print "has default"
                fontspec = self.default_fontspec
            else:
                fontspec = FontSpec()

            fontspec.fromnode(dom_fontspec)

            if fontspec != self.default_fontspec:
                self.fontspecs.append(fontspec)
            if fontspec.id:
                self.fontnames[fontspec.id] = fontspec

        dom_document.unlink()

        self.build_tree()

    def build_tree(self):
        """
        Build the fontspec tree, the root node being the default font
        to apply. The fontspecs without a refmode (i.e. not being
        explicitely a subfont) are direct children of the default font.
        """
        to_ignore = []
        for fontspec in self.fontspecs:
            if fontspec.type == "ignore":
                to_ignore.append(fontspec)
                continue

            if not(fontspec.refmode):
                f = self.default_fontspec
            else:
                f = self.fontnames.get(fontspec.refmode, None)

            if (f):
                f.add_subfont(fontspec)
            else:
                raise ValueError("wrong fontspec tree")

        # Insert the characters to ignore in fontspecs
        for f in to_ignore:
            self.default_fontspec.add_ignored(f.get_uranges())

    def __str__(self):
        """Dump the instance's data attributes."""
        string = 'FontSpecConfig:'
        string += '\n  Fontspec list:'
        for fontspec in self.fontspecs:
            string += '\n' + _indent(str(fontspec), 4)
        return string


class FontSpecEncoder:
    """
    Encoder working with font specifications: it is fed
    with Unicode characters one by one and it inserts the needed font switches
    between the preceding and the current character.
    """

    def __init__(self, configuration):
        """
        Create a font specification encoder from the specified configuration
        file (file name or file-like object).
        """
        self._conf = FontSpecConfig(configuration)
        self._cur_fontspec = None
        self._ref_stack = [self._conf.default_fontspec]

    def reset(self):
        # Restart from the default fontspec to avoid a useless 'enter' from None
        self._cur_fontspec = self._conf.default_fontspec
        self._ref_stack = [self._conf.default_fontspec]

    def _switch_to(self, fontspec):
        """
        Insert the transition string, according to the newly selected
        fontspec and the previously selected fontspec
        """
        s = ""
        # If the font hasn't changed, just insert optional inter-char material
        if fontspec == self._cur_fontspec:
            return fontspec.interchar()

        # A new font is selected, so exit from current font stream
        if self._cur_fontspec:
            s += self._cur_fontspec.exit()

        # Enter into the current font stream
        self._cur_fontspec = fontspec
        s += fontspec.enter()
        return s

    def _encode(self, char):
        """
        Select the fontspec matching the specified <char>, and switch to
        this font as current font.

        The principle to find out the fontspec is to:
        - find from the current font level a matching font
          (the current font leaf or the direct font children)
        - if no font is found try with the parent font, and so on,
          up to the default root font (that must exist).
        """
        fontspec = self._cur_fontspec or self._conf.default_fontspec

        fontspec = fontspec.match(char)
        while not(fontspec):
            self._ref_stack.pop()
            fontspec = self._ref_stack[-1].match(char)

        if fontspec != self._ref_stack[-1]:
            self._ref_stack.append(fontspec)

        return self._switch_to(fontspec)

    def ignorechars(self, charset):
        "Characters to ignore in font selection (maintain the current one)"
        intervals = [ UnicodeInterval().from_char(c) for c in charset ]
        self._conf.default_fontspec.add_ignored(intervals)

    def encode(self, char):
        """
        Return a string consisting of the specified character prepended by
        all necessary font switching commands.
        """
        return (self._encode(char), char)

    def stop(self):
        """
        Cleanly exit from the current fontspec
        """
        if self._cur_fontspec:
            s = self._cur_fontspec.exit()
            self._cur_fontspec = None
            return s
