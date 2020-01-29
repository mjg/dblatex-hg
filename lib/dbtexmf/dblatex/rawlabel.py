from .texcodec import TexCodec
from .texcodec import tex_handler_counter
from .rawparse import RawLatexParser, utf8


def label_char_replace(exc, pre, post, errors):
    global tex_handler_counter
    if not isinstance(exc, UnicodeEncodeError):
        raise TypeError("don't know how to handle %r" % exc)
    l = []
    n = tex_handler_counter[errors]
    for c in exc.object[exc.start:exc.end]:
        if pre: l.append(pre)
        # in labels, just replace char by a supported string
        l.append("u%x" % ord(c))
        if post: l.append(post)
        n = n + 1
    tex_handler_counter[errors] = n
    return ("".join(l), exc.end)


class LabelCodec(TexCodec):
    """
    For label identifiers, this class just tries to convert to
    <output_encoding> characters without escaping anything. For unsupported
    chars, it just replace them by a string to have a valid label string.
    """
    charmap = {}

    def __init__(self, input_encoding="utf8", output_encoding="latin-1"):
        TexCodec.__init__(self, input_encoding, output_encoding,
                          errors="labelcharreplace")

    def build_error_func(self, pre="", post="", errors="charrep"):
        return lambda exc: label_char_replace(exc, pre, post, errors)

    def decode(self, text):
        global tex_handler_counter
        ntext = TexCodec.decode(self, text)
        if self.output_encoding == "utf8":
            return ntext

        # Enforce to pure ASCII identifier, because some latin1 char can give
        # weird results too.
        text = ""
        n = tex_handler_counter[self._errors]
        for c in ntext:
            if ord(c) > 127:
                c = self.pre + "u%x" % ord(c) + self.post
                n += 1
            text += c
        tex_handler_counter[self._errors] = n
        return text


class RawLabelParser(RawLatexParser):
    """
    Just encode from UTF-8 with a dedicated label char handling to ensure
    it works in commands handling labels
    """
    def __init__(self, codec=None, output_encoding="latin-1"):
        texcodec = codec or LabelCodec(output_encoding=output_encoding)
        RawLatexParser.__init__(self, utf8("\u0370l"), utf8("\u0371l"),
                                texcodec)

    def translate(self, text):
        # no hyphenation stuff, just encode
        text = self.codec.decode(text)
        return self.codec.encode(text)


if __name__ == "__main__":
    import sys
    v = RawLabelParser()
    f = open(sys.argv[1])
    for line in f:
        text = v.parse(line)
        if text:
            sys.stdout.write(text)

