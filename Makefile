PREFIX := $(HOME)

ALL_COMPONENTS = emacs git
COMPONENTS = $(ALL_COMPONENTS)

EMACS_PLATFORM = native

include platform.mk


CONFIG_ENV = env 'EMACS_PLATFORM=$(EMACS_PLATFORM)'

.PHONY: all install clean

all: $(patsubst %,all-%,$(COMPONENTS))
install: $(patsubst %,install-%,$(COMPONENTS))
clean: $(patsubst %,clean-%,$(ALL_COMPONENTS))

%.el: %.org
	$(CONFIG_ENV) emacs --quick --batch --eval "(require 'org)" --eval "(apply 'org-babel-tangle-file (cdr command-line-args-left))" -- '$<' '$@'

%.elc: %.el
	emacs --quick --batch --eval "(byte-compile-file (cadr command-line-args-left))" -- '$<'


.PHONY: all-emacs install-emacs clean-emacs

EMACS_DEPENDENCIES = emacs.el

.PHONY: install-git-emacs-link
ifeq ($(EMACS_PLATFORM), flatpak)
EMACS_PREFIX ?= $(PREFIX)/.var/app/org.gnu.emacs/config/emacs
install-emacs-git-link:
	ln --relative --symbolic --force --no-target-directory -- \
	  '$(PREFIX)/.config/git' '$(EMACS_PREFIX)/../git'
else
EMACS_PREFIX ?= $(PREFIX)/.config/emacs
install-emacs-git-link:
endif

all-emacs: $(EMACS_DEPENDENCIES)

install-emacs: $(EMACS_DEPENDENCIES) install-emacs-git-link
	install -D --no-target-directory emacs.el '$(EMACS_PREFIX)/init.el'

clean-emacs:
	-rm -f $(EMACS_DEPENDENCIES)


.PHONY: all-git install-git

gitconfig: make-gitconfig.sh
	./'$<' '$@'

all-git: gitconfig

install-git: gitconfig
	install -D --no-target-directory gitconfig '$(PREFIX)/.config/git/config'

clean-git:
	-rm -f gitconfig
