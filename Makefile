PREFIX := $(HOME)

.PHONY: all install

COMPONENTS = emacs

all: $(patsubst %,all-%,$(COMPONENTS))
install: $(patsubst %,install-%,$(COMPONENTS))

%.el: %.org
	emacs --quick --batch --eval "(require 'org)" --eval "(apply 'org-babel-tangle-file (cdr command-line-args-left))" -- '$<' '$@'

%.elc: %.el
	emacs --quick --batch --eval "(byte-compile-file (cadr command-line-args-left))" -- '$<'

.PHONY: all-emacs install-emacs

EMACS_DEPENDENCIES = emacs.el

all-emacs: $(EMACS_DEPENDENCIES)

install-emacs: $(EMACS_DEPENDENCIES)
	install -D --no-target-directory emacs.el '$(PREFIX)/.var/app/org.gnu.emacs/config/emacs/init.el'
