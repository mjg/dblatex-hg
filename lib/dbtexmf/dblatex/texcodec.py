#
# The Latex Codec handles the encoding from UFT-8 text to latin1 latex compatible
# text.
#
import re
import codecs
import unient

tex_handler_installed = 0

def latex_char_replace(exc):
    if not isinstance(exc, UnicodeEncodeError):
        raise TypeError("don't know how to handle %r" % exc)
    l = []
    for c in exc.object[exc.start:exc.end]:
        try:
            l.append(unient.unicode_map[ord(c)])
        except KeyError:
            l.append(u"\&\#x%x;" % ord(c))
    return (u"".join(l), exc.end)


class LatexCodec:
    # This mapping for characters < 256 seems enough for latin1 output
    charmap = {
              "~"   : r"\textasciitilde{}",
              "\xa0": r"~",
              # "\xa2": r"\textcent{}",
              # "\xa4": r"\textcurrency{}",
              "\xa5": r"$\yen$",
              # "\xa6": r"\textbrokenbar{}",
              "\xac": r"\ensuremath{\lnot}",
              "\xb0": "\\ensuremath{\xb0}",
              "\xb1": r"\ensuremath{\pm}",
              "\xb2": r"$^2$",
              "\xb3": r"$^3$",
              "\xb5": r"$\mathrm{\mu}$",
              "\xb9": r"$^1$",
              "\xd7": r"$\times$",
              "\xf7": r"$\div$"
              }

    def __init__(self, input_encoding="utf8", output_encoding="latin-1"):
        self._errors = "latexcharreplace"
        self._decode = codecs.getdecoder(input_encoding)
        self._encode = codecs.getencoder(output_encoding)
        if not(tex_handler_installed):
            codecs.register_error(self._errors, latex_char_replace)

        self.texres = (
            # Kind of normalize
            (re.compile("^[\s\n]*$"), r" "),
            # TeX escapes
            (re.compile(r"([{}%_^$&#])"), r"\\\1"),
            (re.compile(r"([-^])"), r"\1{}"))

    def decode(self, text):
        return self._decode(text)[0]
    
    def encode(self, text):
        # Preliminary backslash substitution
        text = text.replace("\\", r"\textbackslash")

        # Basic TeX escape
        for r, s in self.texres:
            text = r.sub(s, text)

        # Encode UTF-8 -> Latin-1 + latex specific
        text = self._encode(text, self._errors)[0]

        # Special Character Mapping
        for c, v in self.charmap.items():
            text = text.replace(c, v)

        # Things are done, complete with {}
        text = text.replace(r"\textbackslash", r"\textbackslash{}")
        return text


def main():
    import sys
    c = LatexCodec()
    f = open(sys.argv[1])
    for line in f:
        c.encode(c.decode(line))
        
if __name__ == "__main__":
    main()
