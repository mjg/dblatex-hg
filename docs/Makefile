TABLES = $(wildcard table-eg*)
FIGURES = $(addsuffix .eps, $(basename $(wildcard *.fig)))
PWD = $(shell pwd)
TEXIN = $(shell echo ${TEXINPUTS})
SPECS = specmanual.sgml
CHANGES = $(notdir $(wildcard change*.sgml))
VERSION = devel
OPT=

all: manual.pdf $(FIGURES)

allstyle: all native db2latex simple

clean:
	$(RM) manual.pdf $(EQUATIONS) $(FIGURES)

native db2latex simple: version.sgml
	../scripts/dblatex -T $@ -o manual-$@.pdf manual.sgml

%.pdf: %.sgml version.sgml $(TABLES) $(FIGURES) $(EQUATIONS) $(SPECS) $(CHANGES)
	TEXINPUTS=:$(PWD)/../latex//:$(TEXIN) \
        ../scripts/dblatex -S manual.specs $(OPT) -o $@ $<

# Actual version of the release
version.sgml: FORCE
	echo $(VERSION) > $@

$(SPECS): manual.specs
	echo "<programlisting><![CDATA[" > $@
	cat $< >> $@
	echo "]]></programlisting>" >> $@

%.eps: %.fig
	fig2dev -L eps $< > $@

FORCE:
