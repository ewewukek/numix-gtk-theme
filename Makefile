SASS=sassc
SASSFLAGS=-M -t expanded
GLIB_COMPILE_RESOURCES=glib-compile-resources
RES_DIR=src/gtk-3.0
SCSS_DIR=$(RES_DIR)/scss
DIST_DIR=$(RES_DIR)/dist
RES_DIR320=src/gtk-3.20
SCSS_DIR320=$(RES_DIR320)/scss
DIST_DIR320=$(RES_DIR320)/dist
# INSTALL_DIR=$(DESTDIR)/usr/share/themes/Numix-ewew
INSTALL_DIR=~/.themes/Numix-ewew
ROOT_DIR=${PWD}
UTILS=scripts/utils.sh

all: clean gresource

css:
	mkdir $(DIST_DIR)
	$(SASS) $(SASSFLAGS) $(SCSS_DIR)/gtk.scss $(DIST_DIR)/gtk.css
	$(SASS) $(SASSFLAGS) $(SCSS_DIR)/gtk-dark.scss $(DIST_DIR)/gtk-dark.css
	mkdir $(DIST_DIR320)
	$(SASS) $(SASSFLAGS) $(SCSS_DIR320)/gtk.scss $(DIST_DIR320)/gtk.css
	$(SASS) $(SASSFLAGS) $(SCSS_DIR320)/gtk-dark.scss $(DIST_DIR320)/gtk-dark.css

gresource: css
	$(GLIB_COMPILE_RESOURCES) --sourcedir=$(RES_DIR) $(RES_DIR)/gtk.gresource.xml
	$(GLIB_COMPILE_RESOURCES) --sourcedir=$(RES_DIR320) $(RES_DIR320)/gtk.gresource.xml

watch: clean
	while true; do \
		make gresource; \
		inotifywait @gtk.gresource -qr -e modify -e create -e delete $(RES_DIR); \
	done

clean:
	rm -rf $(DIST_DIR)
	rm -f $(RES_DIR)/gtk.gresource
	rm -rf $(DIST_DIR320)
	rm -f $(RES_DIR320)/gtk.gresource
	rm -rf $(ROOT_DIR)/dist

install: all
	$(UTILS) install $(INSTALL_DIR)

uninstall:
	rm -rf $(INSTALL_DIR)

changes:
	$(UTILS) changes

zip: all
	mkdir $(ROOT_DIR)/dist
	$(UTILS) install $(ROOT_DIR)/dist/$$(basename $(INSTALL_DIR))
	cd $(ROOT_DIR)/dist && zip --symlinks -rq $$(basename $(INSTALL_DIR)) $$(basename $(INSTALL_DIR))

xfce-set:
	xfconf-query -c xsettings -p /Net/ThemeName -s "Numix-ewew"
	xfconf-query -c xfwm4 -p /general/theme -s "Numix-ewew"

.PHONY: all
.PHONY: css
.PHONY: watch
.PHONY: gresource
.PHONY: clean
.PHONY: install
.PHONY: uninstall
.PHONY: changes

.DEFAULT_GOAL := all

# vim: set ts=4 sw=4 tw=0 noet :
