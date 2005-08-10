TABLES = $(wildcard table-eg*)
EQUATIONS = $(addprefix lst., $(wildcard equation-*))
FIGURES = $(addsuffix .eps, $(basename $(wildcard *.fig)))
PWD = $(shell pwd)
TEXIN = $(shell echo ${TEXINPUTS})
SPECS = specmanual.sgml
CHANGES = $(notdir $(wildcard change*.sgml))
OPT=

all: manual.pdf $(FIGURES) $(EQUATIONS)

clean:
	$(RM) manual.pdf $(EQUATIONS) $(FIGURES)

#        ../scripts/dblatex -T db2latex $(OPT) -o $@ $<

%.pdf: %.sgml $(TABLES) $(FIGURES) $(EQUATIONS) $(SPECS) $(CHANGES)
	TEXINPUTS=:$(PWD)/../latex//:$(TEXIN) \
        ../scripts/dblatex -b pdftex $(OPT) -o $@ $<

$(SPECS): manual.specs
	echo "<programlisting><![CDATA[" > $@
	cat $< >> $@
	echo "]]></programlisting>" >> $@

lst.%: %
	echo "<programlisting><![CDATA[" > $@
	cat $< >> $@
	echo "]]></programlisting>" >> $@

%.eps: %.fig
	fig2dev -L eps $< > $@
