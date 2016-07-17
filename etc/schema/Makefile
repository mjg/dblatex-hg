#
# Build the other schemas from the Compact Relax-NG source
#
CONFIG_SCHEMA = dblatex-config

all: $(CONFIG_SCHEMA).rng $(CONFIG_SCHEMA).dtd

%.rng: %.rnc
	trang $< $@

%.dtd: %.rnc
	trang $< $@
