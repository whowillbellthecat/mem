PREFIX=/usr/local/
BIN=$(PREFIX)/bin/
INSTALL=install

mem: mem.pl
	gplc mem.pl --no-top-level

clean:
	rm -f mem

install:
	$(INSTALL) -csm 0755 mem "$(BIN)"
