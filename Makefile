PREFIX := $(HOME)

ALL_COMPONENTS = emacs git
COMPONENTS = $(ALL_COMPONENTS)

CONFIG_EMACS_PLATFORM = native
CONFIG_TOOLBOX =

include platform.mk


CONFIG_ENV = env \
  'CONFIG_EMACS_PLATFORM=$(CONFIG_EMACS_PLATFORM)' \
  'CONFIG_TOOLBOX=$(CONFIG_TOOLBOX)'

.PHONY: all install clean

all: $(patsubst %,all-%,$(COMPONENTS))
install: $(patsubst %,install-%,$(COMPONENTS))
clean: $(patsubst %,clean-%,$(ALL_COMPONENTS))

%.el: %.org
	$(CONFIG_ENV) emacs --quick --batch --eval "(require 'org)" --eval \
	  "(let ((org-file (cadr command-line-args-left))) (org-babel-tangle-file org-file (concat (file-name-base org-file) \".el\")))" -- '$<'

%.elc: %.el
	emacs --quick --batch --eval "(byte-compile-file (cadr command-line-args-left))" -- '$<'


.PHONY: all-emacs install-emacs clean-emacs

EMACS_DEPENDENCIES = emacs/emacs.el

.PHONY: install-git-emacs-link
ifeq ($(CONFIG_EMACS_PLATFORM), flatpak)
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
	install -D --no-target-directory emacs/emacs.el '$(EMACS_PREFIX)/init.el'

clean-emacs:
	-rm -f $(EMACS_DEPENDENCIES)


.PHONY: all-git install-git

git/gitconfig: git/make-gitconfig.sh
	./'$<' '$@'

all-git: git/gitconfig git/gitignore

install-git: git/gitconfig git/gitignore
	install -D --no-target-directory git/gitconfig '$(PREFIX)/.config/git/config'
	install -D --no-target-directory git/gitignore '$(PREFIX)/.config/git/ignore'

clean-git:
	-rm -f git/gitconfig
