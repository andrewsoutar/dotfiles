PREFIX ?= $(HOME)

ALL_COMPONENTS = bash container_shim emacs git ssh xdg

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


.PHONY: all-bash install-bash clean-bash

all-bash: bash/rc.bash bash/profile.bash bash/redirect_rc.bash bash/redirect_profile.bash

install-bash: all-bash
	install -D --target-directory='$(PREFIX)/.config/bash/' bash/rc.bash bash/profile.bash
	install -D --no-target-directory bash/redirect_rc.bash '$(PREFIX)/.bashrc'
	install -D --no-target-directory bash/redirect_profile.bash '$(PREFIX)/.bash_profile'

clean-bash:


.PHONY: all-container_shim install-container_shim clean-container_shim

all-container_shim: container_shim/shim.sh

install-container_shim: all-container_shim
	for shim in $(CONTAINER_SHIMS); do \
	  install -D --no-target-directory --mode=755 container_shim/shim.sh '$(PREFIX)/.local/bin/'"$$shim"; \
	done

clean-container_shim:


.PHONY: all-emacs install-emacs clean-emacs

EMACS_DEPENDENCIES = emacs/emacs.el

.PHONY: install-emacs-flatpak-symlinks
ifeq ($(CONFIG_EMACS_PLATFORM), flatpak)
EMACS_PREFIX ?= $(PREFIX)/.var/app/org.gnu.emacs/config/emacs
install-emacs-flatpak-symlinks:
	ln --relative --symbolic --force --target-directory='$(EMACS_PREFIX)/../' \
	  '$(PREFIX)/.config/bash' '$(PREFIX)/.config/git' '$(PREFIX)/.config/ssh'
else
EMACS_PREFIX ?= $(PREFIX)/.config/emacs
install-emacs-flatpak-symlinks:
endif

all-emacs: $(EMACS_DEPENDENCIES)

install-emacs: $(EMACS_DEPENDENCIES) install-emacs-flatpak-symlinks
	install -D --no-target-directory emacs/emacs.el '$(EMACS_PREFIX)/init.el'

clean-emacs:
	-rm -f $(EMACS_DEPENDENCIES)


.PHONY: all-git install-git clean-git

git/gitconfig: git/make-gitconfig.sh
	./'$<' '$@'

all-git: git/gitconfig git/gitignore

install-git: git/gitconfig git/gitignore
	install -D --no-target-directory git/gitconfig '$(PREFIX)/.config/git/config'
	install -D --no-target-directory git/gitignore '$(PREFIX)/.config/git/ignore'

clean-git:
	-rm -f git/gitconfig


.PHONY: all-ssh install-ssh clean-ssh

all-ssh: ssh/config ssh/stub_config

install-ssh: all-ssh
	install -D --no-target-directory --mode 600 ssh/config '$(PREFIX)/.config/ssh/config'
	install -D --no-target-directory --mode 600 ssh/stub_config '$(PREFIX)/.ssh/config'

clean-ssh:


.PHONY: all-xdg install-xdg clean-xdg

all-xdg: xdg/env.conf

install-xdg: all-xdg
	install -D --no-target-directory xdg/env.conf '$(PREFIX)/.config/environment.d/10-xdg.conf'

clean-xdg:
