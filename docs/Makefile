TABLES = $(wildcard table-eg*)
FIGURES = $(addsuffix .eps, $(basename $(wildcard *.fig)))
PWD = $(shell pwd)
TEXIN = $(shell echo ${TEXINPUTS})
CHANGES = $(notdir $(wildcard change*.sgml))
VERSION = devel
OPTS=

all: manual.pdf $(FIGURES)

allstyle: all native db2latex simple

clean:
	$(RM) manual.pdf $(FIGURES)

native db2latex simple: version.sgml
	../scripts/dblatex -T $@ -o manual-$@.pdf manual.sgml

%.pdf: %.sgml version.sgml $(TABLES) $(FIGURES) $(CHANGES)
	TEXINPUTS=:$(PWD)/../latex//:$(TEXIN) \
        ../scripts/dblatex -S manual.specs $(OPTS) -o $@ $<

# Actual version of the release
version.sgml: FORCE
	echo $(VERSION) > $@

%.eps: %.fig
	fig2dev -L eps $< > $@

FORCE:
