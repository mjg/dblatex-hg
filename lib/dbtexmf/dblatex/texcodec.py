#
# The Latex Codec handles the encoding from UFT-8 text to latin1 latex compatible
# text.
#
import re
import codecs
import unient

# Dictionnary of the handlers installed
tex_handler_installed = {}
tex_handler_counter = {}

def latex_char_replace(exc, pre, post, name):
    global tex_handler_counter
    if not isinstance(exc, UnicodeEncodeError):
        raise TypeError("don't know how to handle %r" % exc)
    l = []
    n = tex_handler_counter[name]
    for c in exc.object[exc.start:exc.end]:
        if pre: l.append(pre)
        try:
            l.append(unient.unicode_map[ord(c)])
        except KeyError:
            print "Missing character &#x%x;" % ord(c)
            l.append(u"\&\#x%x;" % ord(c))
        if post: l.append(post)
        n = n + 1
    tex_handler_counter[name] = n
    return (u"".join(l), exc.end)


class TexCodec:
    # This mapping for characters < 256 seems enough for latin1 output
    charmap = {
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

    def __init__(self, input_encoding="utf8", output_encoding="latin-1",
                 errors="latexcharreplace", pre="", post=""):
        self._errors = errors
        self._decode = codecs.getdecoder(input_encoding)
        self._encode = codecs.getencoder(output_encoding)
        if not(tex_handler_installed.has_key(self._errors)):
            f = self.build_error_func(pre, post, errors)
            codecs.register_error(self._errors, f)
            tex_handler_installed[self._errors] = f
            self.clear_errors()

    def clear_errors(self):
        tex_handler_counter[self._errors] = 0

    def get_errors(self):
        return tex_handler_counter[self._errors]

    def build_error_func(self, pre="", post="", errors="charrep"):
        return lambda exc: latex_char_replace(exc, pre, post, errors)

    def decode(self, text):
        return self._decode(text)[0]

    def encode(self, text):
        text = self._encode(text, self._errors)[0]
        for c, v in self.charmap.items():
            text = text.replace(c, v)
        return text
 

class LatexCodec(TexCodec):
    def __init__(self, input_encoding="utf8", output_encoding="latin-1"):
        TexCodec.__init__(self, input_encoding, output_encoding)

        self.texres = (
            # Kind of normalize
            (re.compile("^[\s\n]*$"), r" "),
            # TeX escapes (the order is important)
            (re.compile(r"([{}%_^$&#])"), r"\\\1"),
            (re.compile(r"([-^])"), r"\1{}"),
            (re.compile(r"~"), r"\\textasciitilde{}"))
   
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
