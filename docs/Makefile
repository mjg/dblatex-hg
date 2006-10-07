TABLES = $(wildcard table-eg*)
PWD = $(shell pwd)
CHANGES = $(wildcard changes/*.xml)
VERSION = devel
OPTS =
XSLTPROC = xsltproc
XSLPROF = /usr/local/share/xsl/docbook/profiling/profile.xsl

all: profile manual.pdf

allstyle: all native db2latex simple

profile:
	@gmake -C manpage -f ../Makefile dblatex-doc.xml

dblatex-doc.xml: dblatex.1.xml
	$(XSLTPROC) -o $@ --param profile.attribute "'output'" \
                          --param profile.value "'manual'" $(XSLPROF) $<

clean:
	$(RM) manual.pdf $(FIGURES)

native db2latex simple: version.xml
	../scripts/dblatex -T $@ -o manual-$@.pdf manual.xml

%.pdf: %.xml version.xml $(TABLES) $(CHANGES)
	../scripts/dblatex -c manual.specs $(OPTS) -o $@ $<

# Actual version of the release
version.xml: FORCE
	echo "<emphasis>$(VERSION)</emphasis>" > $@

FORCE:
