NAME               = perl5
VERSION            = 22.1
VERSION_MAJOR 	   = $(shell echo $(VERSION) | cut -f1-2 -d.)
VERSION_FULL       = 5.$(VERSION)
VERSION_MAJOR_FULL = 5.$(VERSION_MAJOR)
GARTYPE            = v2
DISTNAME           = perl-$(VERSION_FULL)
DESCRIPTION        = A high-level, general-purpose programming language
define BLURB
  Perl 5 is a high-level, general-purpose programming language that makes easy
  things easy and hard things possible. It is optimized for scanning arbitrary
  text files and system administration. It has built-in extended regular
  expression matching and replacement, a dataflow mechanism to improve security
  with setuid scripts and is extendable via modules that can interface to C
  libraries.
  This package is built with gcc.
endef

#MASTER_SITES = manual://
MASTER_SITES         = http://www.cpan.org/src/5.0/
VENDOR_URL           = http://www.perl.org
DISTFILES            = perl-$(VERSION_FULL).tar.bz2
PACKAGING_PLATFORMS += solaris10-i386 solaris10-sparc
PACKAGES             = CSWperl5
PKG_DESC_CSWperl     = $(DESCRIPTION)
SPKG_DESC_CSWperl    = $(DESCRIPTION)
OBSOLETED_BY_CSWperl = CSWperl CSWperldoc CSWpm-cpan-meta CSWpm-test-use-ok CSWpm-test-tester CSWpm-json-pp CSWpm-parse-cpan-meta CSWpm-cpan-meta-yaml CSWpm-module-metadata CSWpm-experimental CSWpm-cpan-meta-requirements CSWpm-perl-ostype
LICENSE 	     = Copying

# GCC build (Sun Studio build has been fixed)
GARCOMPILER          = GNU
MAKE_OPT_unstable10s = -j 24
MAKE_OPT_unstable10x = -j 4
MAKE_OPT 	     = $(MAKE_OPT_$(shell hostname))
BUILD64              = 1
ISAEXEC              = 1
IGNORE_DESTDIR       = 1
# a .git directory will cause failing upstream author tests (the source will be considered blead)
NOGITPATCH 	      = 1
EXTRA_RUNPATH_DIRS    = $(libdir)/perl/$(VERSION_MAJOR_FULL)/CORE
EXTRA_RUNPATH_ISALIST = $(EXTRA_RUNPATH_DIRS)

# Custom configure
CONFIGURE_SCRIPTS = perl
CONFIGURE_ARGS 	 += -Darchlib=$(libdir)/perl/$(VERSION_MAJOR_FULL)
CONFIGURE_ARGS   += -Dcc=$(CC)
CONFIGURE_ARGS   += -Dcf_email=$(SPKG_EMAIL)
CONFIGURE_ARGS   += -Dman1dir=$(mandir)/man1
CONFIGURE_ARGS   += -Dman1ext=1
CONFIGURE_ARGS   += -Dman3dir=$(mandir)/man3
CONFIGURE_ARGS   += -Dman3ext=3
CONFIGURE_ARGS   += -Dperladmin="root@localhost"
CONFIGURE_ARGS   += -Dprefix=$(prefix)
CONFIGURE_ARGS   += -Dbin=$(bindir)
CONFIGURE_ARGS   += -Dscriptdir=$(bindir)
CONFIGURE_ARGS   += -Dprivlib=$(datadir)/perl/$(VERSION_MAJOR_FULL)
CONFIGURE_ARGS   += -Dsitearch=/opt/csw/local/lib/perl/$(VERSION_MAJOR_FULL)
CONFIGURE_ARGS   += -Dsitelib=/opt/csw/local/share/perl/$(VERSION_MAJOR_FULL)
CONFIGURE_ARGS   += -Dsiteman1dir=/opt/csw/local/share/man/man1
CONFIGURE_ARGS   += -Dsiteman3dir==/opt/csw/local/share/man/man3
CONFIGURE_ARGS   += -Dsiteprefix=/opt/csw/local
CONFIGURE_ARGS   += -Duseshrplib
CONFIGURE_ARGS   += -Dusesitecustomize
CONFIGURE_ARGS   += -Dusethreads
CONFIGURE_ARGS   += -Dusedtrace
CONFIGURE_ARGS   += -Duselargefiles 
CONFIGURE_ARGS   += -Dvendorarch=$(libdir)/perl5/$(VERSION_MAJOR_FULL)
CONFIGURE_ARGS   += -Dvendorlib=$(datadir)/perl5/$(VERSION_MAJOR_FULL)
CONFIGURE_ARGS   += -Dvendorprefix=$(prefix)
CONFIGURE_ARGS   += -Dlibsdirs=" $(abspath /usr/lib/$(MEMORYMODEL)) $(libdir)"
CONFIGURE_ARGS   += -Dsed=/opt/csw/bin/gsed
CONFIGURE_ARGS   += -Dlddlflags=-shared

CONFIGURE_ARGS-64 += -Duse64bitint
CONFIGURE_ARGS-64 += -Duse64bitall

CONFIGURE_ARGS   += $(CONFIGURE_ARGS-$(MEMORYMODEL)) 

# We want 64 bit binaries
MERGE_DIRS_isa-extra = $(bindir) $(sbindir) $(libdir) $(libexecdir)

BUILD_SCRIPTS   = perl
TEST_SCRIPTS    = perl
INSTALL_SCRIPTS = perl

# Get it built
RUNTIME_DEP_PKGS_CSWperl5   += CSWlibgcc-s1
RUNTIME_DEP_PKGS_CSWperl5   += CSWlibssp0
RUNTIME_DEP_PKGS_CSWperl5   += CSWlibgdbm4
CHECKPKG_OVERRIDES_CSWperl5 += file-with-bad-content
# Temporary deps
#RUNTIME_DEP_PKGS_CSWperl5   += CSWperl
CHECKPKG_OVERRIDES_CSWperl5 += missing-dependency|CSWperl
# weird .nfs* file leftover
#CHECKPKG_OVERRIDES_CSWperl5 += pkginfo-opencsw-repository-uncommitted

include gar/category.mk

# Configure

PATH:=/opt/csw/gnu:$(PATH)
configure-perl: CONFIGURE_EXPORTS = PATH LD_OPTIONS
configure-perl:
	(cd $(WORKSRC) ; $(CONFIGURE_ENV) ./Configure $(CONFIGURE_ARGS) -ders)
	@$(MAKECOOKIE)

# Build
build-perl: BUILD_EXPORTS = LD_OPTIONS
build-perl:
	@echo " ==> Running make in $*"
	cd $(WORKSRC) && $(BUILD_ENV) $(MAKE) $(MAKE_OPT)
	@$(MAKECOOKIE)

# Test
# This test fails due the NFS setup of the buildfarm. If only this test fails
# just package it with SKIPTEST=1
# $ SKIPTEST=1 mgar package
# cpan/ExtUtils-Command/t/cp .................................... #   Failed test 'cp updated mtime'
#   at t/cp.t line 26.
#     '2366'
#         <=
#     '1'
# Looks like you failed 1 test of 1.
# FAILED at test 1

test-perl:
	@echo " ==> Running make $(TEST_TARGET) in $*"
	# workaround gar pwd bug (PWD is not changed with cd from Makefile:
	# http://sourceforge.net/apps/trac/gar/ticket/78	
	cd $(WORKSRC) && PWD=`pwd` $(MAKE) $(MAKE_OPT) test
	@$(MAKECOOKIE)


install-perl: INSTALL_EXPORTS = PATH LD_OPTIONS DESTDIR
install-perl:
	(cd $(WORKSRC) ; $(INSTALL_ENV) $(MAKE) $(MAKE_OPT) install)
	@$(MAKECOOKIE)
