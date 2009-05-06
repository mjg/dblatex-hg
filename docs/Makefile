TABLES = $(wildcard table-eg*)
CHANGES = $(wildcard changes/*.xml)
VERSION = devel
OPTS =
XSLTPROC = xsltproc
XSLDBK = /usr/local/share/xsl/docbook
XSLPROF = $(XSLDBK)/profiling/profile.xsl
XSLMAN = $(XSLDBK)/manpages/docbook.xsl
XSLHTML = $(XSLDBK)/html/chunk.xsl
XSLOLINK = $(XSLDBK)/html/docbook.xsl
HTMLDIR = html/
CP = cp
HERE = $(shell pwd)

# Where to fing the manual and the release notes
vpath %.xml . changes

all: profile olink manual.pdf manpagegz release-notes.pdf

allstyle: all native db2latex simple

olink: manual.db release-notes.db

profile:
	@$(MAKE) -C manpage -f ../Makefile dblatex-doc.xml

dblatex-doc.xml: dblatex.1.xml
	$(XSLTPROC) -o $@ --param profile.attribute "'output'" \
                          --param profile.value "'manual'" $(XSLPROF) $<

manpagegz:
	@$(MAKE) -C manpage -f ../Makefile dblatex.1.gz

htmldir: manual.xml
	$(XSLTPROC) --xinclude --param base.dir "'$(HTMLDIR)'" \
	                  --param graphic.default.extension "'png'" \
			  --param profile.attribute "'output'" \
                          --param profile.value "'manual'" $(XSLHTML) $<
	convert -trim -rotate 90 processus.fig $(HTMLDIR)/processus.png
	$(CP) -r math/figures $(HTMLDIR)/.

clean:
	$(RM) manual.pdf release-notes.pdf *.db
	$(RM) $(FIGURES) manpage/dblatex.1.gz manpage/dblatex-doc.xml
	$(RM) -r $(HTMLDIR)

native db2latex simple: version.xml profile
	../scripts/dblatex -T $@ -o manual-$@.pdf manual.xml

# Build the Olink database
%.db: %.xml
	$(XSLTPROC) --xinclude --stringparam  collect.xref.targets "only" \
	            $(XSLOLINK) $<
	mv target.db $@

# Build the PDF
%.pdf: %.xml version.xml $(TABLES) $(CHANGES)
	../scripts/dblatex -P target.database.document=$(HERE)/olinkdb.xml \
	                   -c manual.specs $(OPTS) -o $@ $<

# Build the manpage
%.1.gz: %.1
	gzip -f $<

%.1: %.1.xml
	$(XSLTPROC) --param profile.attribute "'output'" \
                    --param profile.value "'manpage'" $(XSLPROF) $< | \
        $(XSLTPROC) $(XSLMAN) - 

# Actual version of the release
version.xml: FORCE
	echo "<emphasis>$(VERSION)</emphasis>" > $@

FORCE:
