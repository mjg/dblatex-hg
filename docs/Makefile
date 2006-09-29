TABLES = $(wildcard table-eg*)
PWD = $(shell pwd)
#CHANGES = $(notdir $(wildcard changes/*.xml))
CHANGES = $(wildcard changes/*.xml)
VERSION = devel
OPTS=

all: manual.pdf

allstyle: all native db2latex simple

clean:
	$(RM) manual.pdf $(FIGURES)

native db2latex simple: version.xml
	../scripts/dblatex -T $@ -o manual-$@.pdf manual.xml

%.pdf: %.xml version.xml $(TABLES) $(CHANGES)
	../scripts/dblatex -c manual.specs $(OPTS) -o $@ $<

# Actual version of the release
version.xml: FORCE
	echo $(VERSION) > $@

FORCE:
