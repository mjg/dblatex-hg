#
# Build the entity conversion template from the entity mapping
#
XSLTPROC = xsltproc

entities.xsl: mapmmlent.xml
	$(XSLTPROC) -o $@ ../../tools/map2func.xsl $< 
