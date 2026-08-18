PREFIX ?= /usr/local
DESTDIR ?=
UNITS = $(PREFIX)/lib/systemd/user

.PHONY: install uninstall

install:
	install -Dm755 omarchy-auto-theme $(DESTDIR)$(PREFIX)/bin/omarchy-auto-theme
	install -Dm644 systemd/omarchy-auto-theme.service $(DESTDIR)$(UNITS)/omarchy-auto-theme.service
	install -Dm644 systemd/omarchy-auto-theme.timer $(DESTDIR)$(UNITS)/omarchy-auto-theme.timer
	install -Dm644 omarchy-auto-theme.json.example $(DESTDIR)/etc/omarchy-auto-theme.json.example

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/omarchy-auto-theme
	rm -f $(DESTDIR)$(UNITS)/omarchy-auto-theme.service
	rm -f $(DESTDIR)$(UNITS)/omarchy-auto-theme.timer
	rm -f $(DESTDIR)/etc/omarchy-auto-theme.json.example
