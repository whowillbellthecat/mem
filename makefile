PREFIX?=/usr/local/
BIN?=$(PREFIX)/bin/
INSTALL?=install
GPLC_FLAGS?=--no-top-level

mem: *.pl
	gplc mem.pl ${GPLC_FLAGS}

clean:
	rm -f mem

install:
	$(INSTALL) -csm 0755 mem "$(BIN)"
