TABLES = $(wildcard table-eg*)
PWD = $(shell pwd)
CHANGES = $(wildcard changes/*.xml)
VERSION = devel
OPTS =
XSLTPROC = xsltproc
XSLDBK = /usr/local/share/xsl/docbook
XSLPROF = $(XSLDBK)/profiling/profile.xsl
XSLMAN = $(XSLDBK)/manpages/docbook.xsl

all: profile manual.pdf manpagegz

allstyle: all native db2latex simple

profile:
	@gmake -C manpage -f ../Makefile dblatex-doc.xml

dblatex-doc.xml: dblatex.1.xml
	$(XSLTPROC) -o $@ --param profile.attribute "'output'" \
                          --param profile.value "'manual'" $(XSLPROF) $<

manpagegz:
	@gmake -C manpage -f ../Makefile dblatex.1.gz

clean:
	$(RM) manual.pdf $(FIGURES)

native db2latex simple: version.xml
	../scripts/dblatex -T $@ -o manual-$@.pdf manual.xml

%.pdf: %.xml version.xml $(TABLES) $(CHANGES)
	../scripts/dblatex -c manual.specs $(OPTS) -o $@ $<

# Build the manpage
%.1.gz: %.1
	gzip $<

%.1: %.1.xml
	$(XSLTPROC) --param profile.attribute "'output'" \
                    --param profile.value "'manpage'" $(XSLPROF) $< | \
        $(XSLTPROC) $(XSLMAN) - 

# Actual version of the release
version.xml: FORCE
	echo "<emphasis>$(VERSION)</emphasis>" > $@

FORCE:
