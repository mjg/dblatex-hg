TABLES = $(wildcard table-eg*)
EQUATIONS = $(addprefix lst., $(wildcard equation-*))
FIGURES = $(addsuffix .eps, $(basename $(wildcard *.fig)))
PWD = $(shell pwd)
TEXIN = $(shell echo ${TEXINPUTS})
SPECS = specmanual.sgml
CHANGES = $(notdir $(wildcard change*.sgml))

all: manual.pdf $(FIGURES) $(EQUATIONS)

clean:
	-rm manual.pdf $(EQUATIONS) $(FIGURES)

%.pdf: %.sgml $(TABLES) $(FIGURES) $(EQUATIONS) $(SPECS) $(CHANGES)
	TEXINPUTS=:$(PWD)/../latex//:$(TEXIN) ../scripts/dblatex -S manual.specs -f fig -o $@ $<

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
