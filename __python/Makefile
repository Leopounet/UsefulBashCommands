define SQ
y
imaplaceholder
De Castro Pinto Theo
0.1
y

endef
export SQ

SHELL=/bin/bash

all:
	@echo "usage: make [CMD]"
	@echo ""
	@echo "build: \t\tbuild the package"
	@echo "install: \tbuild(after building) installs the package"
	@echo "uninstall: \tbuildremoves the package from the system"

build:
	mypy imaplaceholder
	rm -rf build/
	rm -rf dist/
	rm -rf imaplaceholder.egg-info/
	python3 setup.py sdist
	python3 setup.py bdist_wheel
	python3 setup.py build

ubuild:
	rm -rf build/
	rm -rf dist/
	rm -rf imaplaceholder.egg-info/
	python3 setup.py sdist
	python3 setup.py bdist_wheel
	python3 setup.py build

install:
	pip install .

uninstall:
	pip uninstall imaplaceholder

typecheck:
	mypy imaplaceholder

docs:
	rm -rf docs/
	sphinx-quickstart docs <<< "$$SQ"
	cp docs_conf.py docs/source/conf.py
	cd docs/ && sphinx-apidoc -f -o source ../imaplaceholder/
	sed -i 's/   :caption: Contents:/   :caption: Contents:\n\n   modules/' docs/source/index.rst

.PHONY: all build install uninstall docs