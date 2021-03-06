# 
#    Copyright (C) 2009 Modelon AB
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the Common Public License as published by
#    IBM, version 1.0 of the License.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY. See the Common Public License for more details.
#
#    You should have received a copy of the Common Public License
#    along with this program.  If not, see
#     <http://www.ibm.com/developerworks/library/os-cpl.html/>.


AUTOMAKE_OPTIONS = foreign

# EXTRA_DIST =

SUBDIRS = ThirdParty/Sundials ThirdParty/CasADi JMI/src ThirdParty/Blas ThirdParty/Lapack

assimulo_install_dir=$(abs_builddir)/Assimulo_install
jmodelica_install_dir=$(abs_builddir)/JModelica_install
pyfmi_install_dir=$(abs_builddir)/PyFMI_install
pyjmi_install_dir=$(abs_builddir)/PyJMI_install

bindistdir=JModelica.org-$(VERSION)-bin

build-python-packages:
if WITH_SUNDIALS
if WITH_SUPERLU
	cd $(abs_top_srcdir)/Assimulo; \
	python setup.py install --sundials-home=$(SUNDIALS_HOME) --superlu-home=$(SUPERLU_HOME) --blas-home=$(abs_builddir)/ThirdParty/Blas/ --prefix=$(assimulo_install_dir)
endif
endif
if WITH_SUNDIALS
if !WITH_SUPERLU
	cd $(abs_top_srcdir)/Assimulo; \
	python setup.py install --sundials-home=$(SUNDIALS_HOME) --prefix=$(assimulo_install_dir)
endif
endif
	cd $(abs_top_srcdir)/Python/src; \
	python setup_jmodelica.py install --prefix=$(jmodelica_install_dir); \
	rm -rf build

	cd $(abs_top_srcdir)/Python/src; \
	python setup_pyfmi.py install --prefix=$(pyfmi_install_dir); \
	rm -rf build

	cd $(abs_top_srcdir)/Python/src; \
	python setup_pyjmi.py install --prefix=$(pyjmi_install_dir); \
	rm -rf build

install-python-packages: build-python-packages
	mkdir -p $(DESTDIR)$(prefix)/Python
	cp $(abs_top_srcdir)/Python/src/startup.py $(DESTDIR)$(prefix)/
	[ $(abs_top_srcdir) == $(DESTDIR)$(prefix) ] && echo "Installing in dist directory, don't copy LICENSE file" || cp $(abs_top_srcdir)/Python/LICENSE $(DESTDIR)$(prefix)/Python
if WITH_SUNDIALS
	for pkgdir in lib/python2.5 lib/python2.6 lib/python2.7 lib64/python2.5 lib64/python2.6 lib64/python2.7 Lib; do \
	if [ -e $(assimulo_install_dir)/$${pkgdir}/site-packages/ ]; \
	then \
	cd $(assimulo_install_dir)/$${pkgdir}/site-packages/; \
	find assimulo -type f |grep -v /.svn | grep -v .pyc | grep -v ~ |tar c -T - -f - | tar x -C $(DESTDIR)$(prefix)/Python; \
	fi; \
	done
endif 
	for pkgdir in lib/python2.5 lib/python2.6 lib/python2.7 lib64/python2.5 lib64/python2.6 lib64/python2.7 Lib; do \
	if [ -e $(jmodelica_install_dir)/$${pkgdir}/site-packages/ ]; \
	then \
	cd $(jmodelica_install_dir)/$${pkgdir}/site-packages/; \
	find jmodelica -type f |grep -v /.svn | grep -v .pyc | grep -v ~ |tar c -T - -f - | tar x -C $(DESTDIR)$(prefix)/Python; \
	fi; \
	done
	for pkgdir in lib/python2.5 lib/python2.6 lib/python2.7 lib64/python2.5 lib64/python2.6 lib64/python2.7 Lib; do \
	if [ -e $(pyjmi_install_dir)/$${pkgdir}/site-packages/ ]; \
	then \
	cd $(pyjmi_install_dir)/$${pkgdir}/site-packages/; \
	find pyjmi -type f |grep -v /.svn | grep -v .pyc | grep -v ~ |tar c -T - -f - | tar x -C $(DESTDIR)$(prefix)/Python; \
	fi; \
	done
	for pkgdir in lib/python2.5 lib/python2.6 lib/python2.7 lib64/python2.5 lib64/python2.6 lib64/python2.7 Lib; do \
	if [ -e $(pyfmi_install_dir)/$${pkgdir}/site-packages/ ]; \
	then \
	cd $(pyfmi_install_dir)/$${pkgdir}/site-packages/; \
	find pyfmi -type f |grep -v /.svn | grep -v .pyc | grep -v ~ |tar c -T - -f - | tar x -C $(DESTDIR)$(prefix)/Python; \
	fi; \
	done
	cd $(abs_top_srcdir)/Python/src/tests_jmodelica/; \
	mkdir -p $(DESTDIR)$(prefix)/Python/tests_jmodelica; \
	find . -type f |grep -v /.svn | grep -v .pyc | grep -v ~ |tar c -T - -f - | tar x -C $(DESTDIR)$(prefix)/Python/tests_jmodelica
	cd $(abs_builddir)/casadi_build/swig/python/; \
	find . -type f |grep -v /.svn | grep -v .pyc | grep -v ~ |tar c -T - -f - | tar x -C $(DESTDIR)$(prefix)/Python/
	mkdir -p $(DESTDIR)$(prefix)/bin
	[ -e $(DESTDIR)$(prefix)/bin/jm_python.sh ] && echo "File exists, don't copy jm_python.sh" || cp Python/jm_python.sh $(DESTDIR)$(prefix)/bin/jm_python.sh
	[ -e $(DESTDIR)$(prefix)/bin/jm_ipython.sh  ] && echo "File exists, don't jm_ipython.sh" || cp Python/jm_ipython.sh $(DESTDIR)$(prefix)/bin/jm_ipython.sh
	chmod ugo+x $(DESTDIR)$(prefix)/bin/jm_*.sh

all-local: build-python-packages
if HAVE_ANT
	cd $(abs_top_srcdir)/Compiler/ModelicaCompiler; \
	$(ANT_OPTS) $(ANT)
	cd $(abs_top_srcdir)/Compiler/OptimicaCompiler; \
	$(ANT_OPTS) $(ANT)
endif
	$(abs_top_srcdir)/get_version.sh $(abs_top_srcdir) > $(abs_builddir)/version.txt
	mkdir -p $(abs_builddir)/Options
	$(abs_top_srcdir)/run_java.sh org.jmodelica.util.OptionRegistry $(abs_builddir)/Options/options.xml

install-exec-local: install-python-packages
if HAVE_ANT
	cp $(abs_top_srcdir)/Compiler/ModelicaCompiler/bin/ModelicaCompiler.jar $(DESTDIR)$(prefix)/lib/
	cp $(abs_top_srcdir)/Compiler/ModelicaCompiler/bin/util.jar $(DESTDIR)$(prefix)/lib/
	cp $(abs_top_srcdir)/Compiler/ModelicaCompiler/bin/graphs.jar $(DESTDIR)$(prefix)/lib/
	cp $(abs_top_srcdir)/Compiler/OptimicaCompiler/bin/OptimicaCompiler.jar $(DESTDIR)$(prefix)/lib/
endif
	[ $(abs_top_srcdir) == $(DESTDIR)$(prefix) ] && echo "Installing in dist directory, don't copy LICENSE file" || cp $(abs_top_srcdir)/LICENSE $(DESTDIR)$(prefix)/ 
	cp $(abs_top_srcdir)/JMI/LICENSE_GPL $(DESTDIR)$(prefix)/lib/
	cp $(abs_top_srcdir)/JMI/LICENSE_CPL $(DESTDIR)$(prefix)/lib/
	cp $(abs_top_srcdir)/JMI/LICENSE_GPL $(DESTDIR)$(prefix)/include/
	cp $(abs_top_srcdir)/JMI/LICENSE_CPL $(DESTDIR)$(prefix)/include/
	mkdir -p $(DESTDIR)$(prefix)/Makefiles
	cp $(abs_top_srcdir)/JMI/LICENSE_GPL $(DESTDIR)$(prefix)/Makefiles/LICENSE
	case $(build) in \
	*-cygwin*) \
	cp $(abs_top_srcdir)/JMI/Makefiles/Makefile.windows $(DESTDIR)$(prefix)/Makefiles/Makefile ;; \
  	*-mingw*) \
	cp $(abs_top_srcdir)/JMI/Makefiles/Makefile.windows $(DESTDIR)$(prefix)/Makefiles/MakeFile ;; \
  	*-apple*) \
	cp $(abs_top_srcdir)/JMI/Makefiles/Makefile.macosx $(DESTDIR)$(prefix)/Makefiles/MakeFile ;; \
  	*) \
	cp $(abs_top_srcdir)/JMI/Makefiles/Makefile.linux $(DESTDIR)$(prefix)/Makefiles/MakeFile ;; \
	esac
	mkdir -p $(DESTDIR)$(prefix)/Options
	cp $(abs_builddir)/Options/options.xml $(DESTDIR)$(prefix)/Options/options.xml
	mkdir -p $(DESTDIR)$(prefix)/ThirdParty
	mkdir -p $(DESTDIR)$(prefix)/ThirdParty/Beaver
	cp $(abs_top_srcdir)/ThirdParty/Beaver/beaver-0.9.6.1/LICENSE $(DESTDIR)$(prefix)/ThirdParty/Beaver/
	mkdir -p $(DESTDIR)$(prefix)/ThirdParty/Beaver/lib
	cp $(abs_top_srcdir)/ThirdParty/Beaver/beaver-0.9.6.1/lib/beaver.jar $(DESTDIR)$(prefix)/ThirdParty/Beaver/lib/ 
	mkdir -p $(DESTDIR)$(prefix)/ThirdParty/Sundials	
	cp -r $(SUNDIALS_HOME)/* $(DESTDIR)$(prefix)/ThirdParty/Sundials
	mkdir -p $(DESTDIR)$(prefix)/ThirdParty/CppAD
	cp $(CPPAD_HOME)/COPYING $(DESTDIR)$(prefix)/ThirdParty/CppAD
	mkdir -p $(DESTDIR)$(prefix)/ThirdParty/CppAD/cppad	
	cp $(CPPAD_HOME)/cppad/*.h $(DESTDIR)$(prefix)/ThirdParty/CppAD/cppad
	cp $(CPPAD_HOME)/cppad/*.hpp $(DESTDIR)$(prefix)/ThirdParty/CppAD/cppad
	mkdir -p $(DESTDIR)$(prefix)/ThirdParty/CppAD/cppad/local	
	cp $(CPPAD_HOME)/cppad/local/*.hpp $(DESTDIR)$(prefix)/ThirdParty/CppAD/cppad/local
	[ $(abs_top_srcdir) == $(DESTDIR)$(prefix) ] && echo "Installing in dist directory, don't copy MSL" || cd $(abs_top_srcdir)/ThirdParty; find MSL -type f |grep -v /.svn | grep -v ~ |tar c -T - -f - | tar x -C $(DESTDIR)$(prefix)/ThirdParty
	mkdir -p $(DESTDIR)$(prefix)/CodeGenTemplates
	cp $(abs_top_srcdir)/JMI/LICENSE_GPL $(DESTDIR)$(prefix)/CodeGenTemplates/LICENSE
	cp  $(abs_top_srcdir)/Compiler/ModelicaCBackEnd/templates/jmi_modelica_template.c $(DESTDIR)$(prefix)/CodeGenTemplates
	cp  $(abs_top_srcdir)/Compiler/ModelicaCBackEnd/templates/fmi_me_modelica_template.c $(DESTDIR)$(prefix)/CodeGenTemplates
	cp  $(abs_top_srcdir)/Compiler/ModelicaCBackEnd/templates/fmi_cs_modelica_template.c $(DESTDIR)$(prefix)/CodeGenTemplates
	cp  $(abs_top_srcdir)/Compiler/OptimicaCBackEnd/templates/jmi_optimica_template.c $(DESTDIR)$(prefix)/CodeGenTemplates
	cp  $(abs_top_srcdir)/Compiler/ModelicaXMLBackEnd/templates/fmi_model_description.tpl $(DESTDIR)$(prefix)/CodeGenTemplates
	cp  $(abs_top_srcdir)/Compiler/ModelicaXMLBackEnd/templates/fmi_extended_model_description.tpl $(DESTDIR)$(prefix)/CodeGenTemplates
	cp  $(abs_top_srcdir)/Compiler/ModelicaXMLBackEnd/templates/jmodelica_model_description.tpl $(DESTDIR)$(prefix)/CodeGenTemplates
	cp  $(abs_top_srcdir)/Compiler/ModelicaXMLBackEnd/templates/jmodelica_model_values.tpl $(DESTDIR)$(prefix)/CodeGenTemplates
	mkdir -p $(DESTDIR)$(prefix)/XML
	[ $(abs_top_srcdir) == $(DESTDIR)$(prefix) ] && echo "Installing in dist directory, don't copy XML schemas"  || cp  $(abs_top_srcdir)/XML/*.xsd $(DESTDIR)$(prefix)/XML
	[ $(abs_top_srcdir) == $(DESTDIR)$(prefix) ] && echo "Installing in dist directory, don't copy XML LICENSE"  || cp  $(abs_top_srcdir)/XML/LICENSE $(DESTDIR)$(prefix)/XML
	cp  $(abs_builddir)/version.txt $(DESTDIR)$(prefix)
	cp jm_tests $(DESTDIR)$(prefix)/jm_tests
	chmod ugo+x $(DESTDIR)$(prefix)/jm_tests

bindistdir: install
	rm -rf $(bindistdir)
	mkdir -p $(bindistdir)
	cp $(DESTDIR)$(prefix)/LICENSE $(bindistdir)
	cp $(DESTDIR)$(prefix)/startup.py $(bindistdir)
	cp $(DESTDIR)$(prefix)/version.txt $(bindistdir)
	cp -r $(DESTDIR)$(prefix)/CodeGenTemplates $(bindistdir)
	cp -r $(DESTDIR)$(prefix)/Makefiles $(bindistdir)
	cp -r $(DESTDIR)$(prefix)/Options $(bindistdir)
	cp -r $(DESTDIR)$(prefix)/Python $(bindistdir)
	cp -r $(DESTDIR)$(prefix)/ThirdParty $(bindistdir)
	cp -r $(DESTDIR)$(prefix)/XML $(bindistdir)
	cp -r $(DESTDIR)$(prefix)/include $(bindistdir)
	cp -r $(DESTDIR)$(prefix)/lib $(bindistdir)
if COMPILE_WITH_IPOPT	
	mkdir -p $(bindistdir)/ThirdParty/Ipopt
# Copy files
	cd $(IPOPT_HOME); find * -type f |grep -v /.svn | grep -v ~ |tar c -T - -f - | tar x -C $(abs_builddir)/$(bindistdir)/ThirdParty/Ipopt
# Copy symbolic links
	cd $(IPOPT_HOME); find * -type l |grep -v /.svn | grep -v ~ |tar c -T - -f - | tar x -C $(abs_builddir)/$(bindistdir)/ThirdParty/Ipopt
endif 

if WITH_MINGW	
	mkdir -p $(bindistdir)/ThirdParty/MinGW
# Copy files
	cd $(MINGW_HOME); find * -type f |grep -v /.svn | grep -v ~ |tar c -T - -f - | tar x -C $(abs_builddir)/$(bindistdir)/ThirdParty/MinGW
# Copy symbolic links
	cd $(MINGW_HOME); find * -type l |grep -v /.svn | grep -v ~ |tar c -T - -f - | tar x -C $(abs_builddir)/$(bindistdir)/ThirdParty/MinGW
endif 

bindist: bindistdir
	tar -cf $(bindistdir).tar $(bindistdir)
	gzip -c $(bindistdir).tar > $(bindistdir).tar.gz
	rm -rf $(bindistdir)
	rm -rf $(bindistdir).tar

test: install
	$(prefix)/jm_tests -i

clean-local: clean-frontends clean-python-packages

clean-python-packages:
if WITH_SUNDIALS
	cd $(abs_top_srcdir)/Assimulo; \
	python setup.py clean --all --sundials-home=$(SUNDIALS_HOME) 
	rm -rf $(assimulo_install_dir)
endif
	cd $(abs_top_srcdir)/Python/src; \
	python setup_jmodelica.py clean --all 
	rm -rf $(jmodelica_install_dir)
	cd $(abs_top_srcdir)/Python/src; \
	python setup_pyfmi.py clean --all 
	rm -rf $(pyfmi_install_dir)
	cd $(abs_top_srcdir)/Python/src; \
	python setup_pyjmi.py clean --all 
	rm -rf $(pyjmi_install_dir)

clean-frontends:
if HAVE_ANT
	cd $(abs_top_srcdir)/Compiler/ModelicaCompiler; \
	$(ANT_OPTS) $(ANT) clean
	cd $(abs_top_srcdir)/Compiler/OptimicaCompiler; \
	$(ANT_OPTS) $(ANT) clean
endif

docs:
	cd $(abs_top_srcdir); doxygen doc/JMI/jmi_doxydoc.conf
	cd $(abs_top_srcdir); doxygen doc/ModelicaCompiler/modelica_compiler_doxydoc.conf
	cd $(abs_top_srcdir); doxygen doc/OptimicaCompiler/optimica_compiler_doxydoc.conf
	make -C $(abs_top_srcdir)/doc/PyJMI html

docbook-docs:
	cd docbook/UsersGuide; $(MAKE) all

