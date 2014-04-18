#!/usr/bin/make
# WARN: gmake syntax
########################################################
# Makefile for python-pagerduty
#
# useful targets:
#   make sdist ---------------- produce a tarball
#   make deb ------------------ produce a DEB
#   make tests ---------------- run the tests
#   make pyflakes, make pep8 -- source code checks

########################################################
# variable section

NAME = "python-pagerduty"
OS = $(shell uname -s)

PYTHON=python
SITELIB = $(shell $(PYTHON) -c "from distutils.sysconfig import get_python_lib; print get_python_lib()")

# Get the branch information from git
ifneq ($(shell which git),)
GIT_DATE := $(shell git log -n 1 --format="%ai")
endif

ifeq ($(shell echo $(OS) | egrep -c 'Darwin|FreeBSD|OpenBSD'),1)
DATE := $(shell date -j -r $(shell git log -n 1 --format="%at") +%Y%m%d%H%M)
else
DATE := $(shell date --utc --date="$(GIT_DATE)" +%Y%m%d%H%M)
endif
NOSETESTS ?= nosetests
SRC := pygerduty/*.py

########################################################

all: clean python

tests:
	PYTHONPATH=./lib  $(NOSETESTS) -d -w test/units -v

authors:
	sh hacking/authors.sh

loc:
	sloccount lib library bin

pep8:
	@echo "#############################################"
	@echo "# Running PEP8 Compliance Tests"
	@echo "#############################################"
	-pep8 -r bin/* $(SRC)

pyflakes:
	pyflakes bin/* $(SRC)

clean:
	@echo "Cleaning up distutils stuff"
	rm -rf build
	rm -rf dist
	@echo "Cleaning up byte compiled python stuff"
	find . -type f -regex ".*\.py[co]$$" -delete
	@echo "Cleaning up editor backup files"
	find . -type f \( -name "*~" -or -name "#*" \) -delete
	find . -type f \( -name "*.swp" \) -delete
	@echo "Cleaning up output from test runs"
	rm -rf test/test_data
	@echo "Cleaning up Debian building stuff"
	rm -rf debian
	rm -rf deb-build
	@echo "Cleaning up authors file"
	rm -f AUTHORS.TXT

python:
	$(PYTHON) setup.py build

install:
	$(PYTHON) setup.py install

sdist: clean
	$(PYTHON) setup.py sdist -t MANIFEST.in

debian: sdist
deb: debian
	cp -r packaging/debian ./
	chmod 755 debian/rules
	fakeroot debian/rules clean
	fakeroot dh_install
	fakeroot debian/rules binary
