APPNAME=net.effjot.stratigraphy
VERSION=0.2.6

MOJOIPK=$(APPNAME)_$(VERSION)_all.ipk


MOJOSRCDIR=mojo

VARIANTS=isc2009_no_base.html isc2009_base_age.html isc2009_base_gssp.html isc2009_base_age+gssp.html
HTML=$(addprefix data/, $(VARIANTS))
MOJOHTML=$(addprefix $(MOJOSRCDIR)/, $(HTML))
JSON=data/stratigraphic-data.js
MOJOJSON=$(addprefix $(MOJOSRCDIR)/, $(JSON))


.PHONY: all clean package launch install


all: package

clean:
	rm -f $(MOJOIPK)
	rm -f $(MOJOHTML)

launch: install
	palm-launch -c $(APPNAME)
	palm-launch $(APPNAME)

install: package
	palm-install -r $(APPNAME) || true 	# ignore error when already uninstalled
	palm-install $(MOJOIPK)

package: $(MOJOIPK)


$(MOJOIPK): $(MOJOHTML) $(MOJOJSON)
	palm-package --exclude-from=.palm-package.exclude $(MOJOSRCDIR)

$(MOJOSRCDIR)/data/%.html: data/%.html
	cp $< $@

$(MOJOSRCDIR)/data/%.js: data/%.js
	cp $< $@

$(HTML): lisp/stratigraphy.lisp
	test -d data || mkdir data
	cd lisp && sbcl --script build-files.lisp

$(JSON): lisp/stratigraphy.lisp
	test -d data || mkdir data
	cd lisp && sbcl --script build-files.lisp

