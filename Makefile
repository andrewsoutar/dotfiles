PREFIX ?= $(HOME)

ALL_COMPONENTS = bash container_shim emacs git ssh xdg

CONFIG_EMACS_PLATFORM = native
CONFIG_TOOLBOX =

EMACS_PROGRAM ?= emacs

include platform.mk


CONFIG_ENV = env \
  'CONFIG_EMACS_PLATFORM=$(CONFIG_EMACS_PLATFORM)' \
  'CONFIG_TOOLBOX=$(CONFIG_TOOLBOX)'

.PHONY: all install clean

all: $(patsubst %,all-%,$(COMPONENTS))
install: $(patsubst %,install-%,$(COMPONENTS))
clean: $(patsubst %,clean-%,$(ALL_COMPONENTS))

%.el: %.org
	$(CONFIG_ENV) $(EMACS_PROGRAM) --quick --batch --eval "(require 'org)" --eval \
	  "(let ((org-file (cadr command-line-args-left))) (org-babel-tangle-file org-file (concat (file-name-base org-file) \".el\")))" -- '$<'

%.elc: %.el
	$(EMACS_PROGRAM) --quick --batch --eval "(byte-compile-file (cadr command-line-args-left))" -- '$<'


.PHONY: all-bash install-bash clean-bash

all-bash: bash/rc.bash bash/profile.bash bash/redirect_rc.bash bash/redirect_profile.bash

install-bash: all-bash
	mkdir -p '$(PREFIX)/.config/bash'
	install bash/rc.bash bash/profile.bash '$(PREFIX)/.config/bash/'
	install bash/redirect_rc.bash '$(PREFIX)/.bashrc'
	install bash/redirect_profile.bash '$(PREFIX)/.bash_profile'

clean-bash:


.PHONY: all-container_shim install-container_shim clean-container_shim

all-container_shim: container_shim/shim.sh

install-container_shim: all-container_shim
	mkdir -p '$(PREFIX)/.local/bin'
	for shim in $(CONTAINER_SHIMS); do \
	  install -m 755 container_shim/shim.sh '$(PREFIX)/.local/bin/'"$$shim"; \
	done

clean-container_shim:


.PHONY: all-emacs install-emacs clean-emacs

EMACS_DEPENDENCIES = emacs/emacs.el emacs/straight.lock.el

.PHONY: install-emacs-flatpak-symlinks
ifeq ($(CONFIG_EMACS_PLATFORM), flatpak)
EMACS_PREFIX ?= $(PREFIX)/.var/app/org.gnu.emacs/config/emacs
install-emacs-flatpak-symlinks:
	install -l rs '$(PREFIX)/.config/bash' '$(EMACS_PREFIX)/../bash'
	install -l rs '$(PREFIX)/.config/git' '$(EMACS_PREFIX)/../git'
	install -l rs '$(PREFIX)/.config/ssh' '$(EMACS_PREFIX)/../ssh'
else
EMACS_PREFIX ?= $(PREFIX)/.config/emacs
install-emacs-flatpak-symlinks:
endif

all-emacs: $(EMACS_DEPENDENCIES)

install-emacs: $(EMACS_DEPENDENCIES) install-emacs-flatpak-symlinks
	mkdir -p '$(EMACS_PREFIX)'
	install -m 644 emacs/emacs.el '$(EMACS_PREFIX)/init.el'
	install -m 644 emacs/straight.lock.el '$(EMACS_PREFIX)/straight.lock.el'
ifdef EMACS_INIT_PREFIX
	install -l rs '$(EMACS_PREFIX)/init.el' '$(EMACS_INIT_PREFIX)/init.el'
endif

clean-emacs:
	-rm -f $(EMACS_DEPENDENCIES)


.PHONY: all-git install-git clean-git

git/gitconfig: git/make-gitconfig.sh
	./'$<' '$@'

all-git: git/gitconfig git/gitignore

install-git: git/gitconfig git/gitignore
	mkdir -p '$(PREFIX)/.config/git'
	install git/gitconfig '$(PREFIX)/.config/git/config'
	install git/gitignore '$(PREFIX)/.config/git/ignore'

clean-git:
	-rm -f git/gitconfig


.PHONY: all-ssh install-ssh clean-ssh

all-ssh: ssh/config ssh/stub_config

install-ssh: all-ssh
	mkdir -p '$(PREFIX)/.config/ssh'
	install -m 600 ssh/config '$(PREFIX)/.config/ssh/config'
	install -m 600 ssh/stub_config '$(PREFIX)/.ssh/config'

clean-ssh:


.PHONY: all-tmux install-tmux clean-tmux

all-tmux: tmux/config

install-tmux:
	mkdir -p '$(PREFIX)/.config/tmux'
	install -m 644 tmux/config '$(PREFIX)/.config/tmux/tmux.conf'

clean-tmux:


.PHONY: all-xdg install-xdg clean-xdg

all-xdg: xdg/env.conf

install-xdg: all-xdg
	mkdir -p '$(PREFIX)/.config/environment.d'
	install xdg/env.conf '$(PREFIX)/.config/environment.d/10-xdg.conf'

clean-xdg:
