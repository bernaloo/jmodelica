# ! /bin/bash 
# $Id: build.sh 1670 2010-03-18 04:29:52Z bradbell $
# -----------------------------------------------------------------------------
# CppAD: C++ Algorithmic Differentiation: Copyright (C) 2003-10 Bradley M. Bell
#
# CppAD is distributed under multiple licenses. This distribution is under
# the terms of the 
#                     Common Public License Version 1.0.
#
# A copy of this license is included in the COPYING file of this distribution.
# Please visit http://www.coin-or.org/CppAD/ for information on other licenses.
# -----------------------------------------------------------------------------
#
# Bash script for building the CppAD distribution.
#
# check for multiple options options
option_divider=\
"============================================================================="
if [ "$1" == "all" ] || [ "$2" != "" ]
then
	if [ "$1" == "all" ] && [ "$2" == "" ]
	then
		echo "./build.sh all"
		options="
			version 
			automake 
			configure 
			dist
			omhelp 
			doxygen 
			gpl 
			move
		"
		if ! ./build.sh $options
		then
			echo "Error during \"build.sh all\" command"
			exit 1
		fi
		exit 0
	fi
	if [ "$1" == "all" ] && [ "$2" == "dos" ]
	then
		echo "./build.sh all dos"
		options="
			version 
			automake 
			configure 
			dist
			omhelp 
			doxygen 
			test
			gpl 
			move
		"
		if ! ./build.sh $options
		then
			echo "Error during \"build.sh all dos\" command"
			exit 1
		fi
		exit 0
	fi
	if [ "$1" == "all" ] && [ "$2" == "test" ]
	then
		echo "./build.sh all test"
		options="
			version 
			automake 
			configure 
			dist 
			omhelp 
			doxygen 
			test 
			gpl 
			move
		"
		if ! ./build.sh $options
		then
			echo "Error during \"build.sh all test\" command"
			exit 1
		fi
		exit 0
	fi
	if [ "$1" == "all" ]
	then
		echo "build.sh: \"$2\" is invalid second arg when first is all."
		exit 1
	fi
	list=" version automake configure"
	list="$list omhelp doxygen dist test gpl dos move "
	for option in $*
	do
		if [ "$option" == "all" ]
		then
			echo "build.sh: If present, all must be first option."  
			exit 1
		fi
		if ! echo "$list" | grep " $option " > /dev/null
		then
			# run invalid option for error message
			./build.sh $option
			exit 1
		fi
	done
	for option in $*
	do
		echo "$option_divider"
		echo "./build.sh $option"
		if ! ./build.sh $option
		then
			exit 1
		fi
	done
	echo "$option_divider"
	exit 0
fi
# ============================================================================
# Default values used for arguments to configure during this script.
# These defaults are development system dependent and can be changed.
BOOST_DIR=/usr/include
ADOLC_DIR=$HOME/prefix/adolc
FADBAD_DIR=$HOME/prefix/fadbad
SACADO_DIR=$HOME/prefix/sacado
IPOPT_DIR=$HOME/prefix/ipopt
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$ADOLC_DIR/lib:$IPOPT_DIR/lib"
# -----------------------------------------------------------------------------
#
# get version currently in configure.ac file
# (in a way that works when version is not a date)
configure_ac_version=`grep "^ *AC_INIT(" configure.ac | \
	sed -e 's/[^,]*, *\([^ ,]*\).*/\1/'`
#
# -----------------------------------------------------------------------------
if [ "$1" = "version" ]
then
	echo "build.sh version"
	#
	# Today's date in yy-mm-dd decimal digit format where 
	# yy is year in century, mm is month in year, dd is day in month.
	yyyy_mm_dd=`date +%F`
	yyyymmdd=`echo $yyyy_mm_dd | sed -e 's|-||g'`
	#
	# automatically change version for certain files
	# (the [.0-9]* is for using build.sh in CppAD/stable/* directories)
	#
	# libtool does not seem to support version by date
	# sed < cppad_ipopt/src/makefile.am > cppad_ipopt/src/makefile.am.$$ \
	#	-e "s/\(-version-info\) *[0-9]\{8\}[.0-9]*/\1 $yyyymmdd/"
	#
	sed < AUTHORS > AUTHORS.$$ \
		-e "s/, [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} *,/, $yyyy_mm_dd,/"
	sed < configure.ac > configure.ac.$$\
		-e "s/(CppAD, [0-9]\{8\}[.0-9]* *,/(CppAD, $yyyymmdd,/" 
	#
	sed < configure > configure.$$ \
	-e "s/CppAD [0-9]\{8\}[.0-9]*/CppAD $yyyymmdd/g" \
	-e "s/VERSION='[0-9]\{8\}[.0-9]*'/VERSION='$yyyymmdd'/g" \
	-e "s/configure [0-9]\{8\}[.0-9]*/configure $yyyymmdd/g" \
	-e "s/config.status [0-9]\{8\}[.0-9]*/config.status $yyyymmdd/g" \
	-e "s/\$as_me [0-9]\{8\}[.0-9]*/\$as_me $yyyymmdd/g" \
        -e "s/Generated by GNU Autoconf.*$yyyymmdd/&./"
	#
	chmod +x configure.$$
	sed < cppad/config.h > cppad/config.h.$$ \
		-e "s/CppAD [0-9]\{8\}[.0-9]*/CppAD $yyyymmdd/g" \
		-e "s/VERSION \"[0-9]\{8\}[.0-9]*\"/VERSION \"$yyyymmdd\"/g"
	list="
		AUTHORS
		configure.ac
		configure
		cppad/config.h
	"
	for name in $list
	do
		echo "diff $name $name.$$"
		diff $name $name.$$
		echo "mv   $name.$$ $name"
		mv   $name.$$ $name
	done
	#
	# change Autoconf version to today
	configure_ac_version=$yyyymmdd
	#
	exit 0
fi
version="$configure_ac_version"
#
# -----------------------------------------------------------------------------
if [ "$1" = "automake" ] 
then
	echo "build.sh automake"
	#
	# check that autoconf and automake output are in original version
	#
	makefile_in=`sed configure.ac \
        	-n \
        	-e '/END AC_CONFIG_FILES/,$d' \
        	-e '1,/AC_CONFIG_FILES/d' \
        	-e 's|/makefile$|&.in|' \
        	-e '/\/makefile.in/p'`
	auto_output="
		depcomp 
		install-sh 
		missing 
		configure 
		cppad/config.h 
		cppad/config.h.in 
		$makefile_in
	"
	for name in $auto_output
	do
		if [ ! -e $name ]
		then
			echo "$name"
			echo "is not in subversion repository."
			echo "Check it in after making this change."
			echo "This error won't occur when you re-run build.sh"
			touch $name
			exit 1
		fi
	done
	#
	echo "aclocal"
	if ! aclocal
	then
		exit 1
	fi
	#
	echo "autoheader"
	if ! autoheader
	then
		exit 1
	fi
	#
	echo "skipping libtoolize"
	# echo "libtoolize -c -f -i"
	# if ! libtoolize -c -f -i
	# then
	# 	exit 1
	# fi
	#
	echo "autoconf"
	if ! autoconf
	then
		exit 1
	fi
	#
	echo "automake --add-missing"
	if ! automake --add-missing
	then
		exit 1
	fi
	link_list="missing install-sh depcomp"
	for name in $link_list
	do
		if [ -h "$name" ]
		then
			echo "Converting $name from a link to a regular file"
			cp $name $name.$$
			if ! mv $name.$$ $name
			then
				echo "Cannot convert $name"
				exit 1
			fi
		fi
	done
	#
	exit 0
fi
#
# -----------------------------------------------------------------------------
# configure
if [ "$1" == "configure" ]
then
	options="
		--with-Documentation
		POSTFIX_DIR=coin
	"
	if [ -e $BOOST_DIR/boost ]
	then
		options="$options 
			BOOST_DIR=$BOOST_DIR"
	fi
	if [ -e $ADOLC_DIR/include/adolc ]
	then
		options="$options 
			ADOLC_DIR=$ADOLC_DIR"
	fi
	if [ -e $FADBAD_DIR/FADBAD++ ]
	then
		options="$options 
			FADBAD_DIR=$FADBAD_DIR"
	fi
	if [ -e $SACADO_DIR/include/Sacado.hpp ]
	then
		options="$options 
			SACADO_DIR=$SACADO_DIR"
	fi
	if [ -e $IPOPT_DIR/include/coin/IpIpoptApplication.hpp ]
	then
		options="$options 
		IPOPT_DIR=$IPOPT_DIR"
	fi
	options=`echo $options | sed -e 's|\t\t*| |g'`
	echo "configure \\"
	echo "$options" | sed -e 's| | \\\n\t|g' -e 's|$| \\|' -e 's|^|\t|'
	echo "	CXX_FLAGS=\"-Wall -ansi -pedantic-errors -std=c++98\""
	#
	if ! ./configure $options \
		CXX_FLAGS="-Wall -ansi -pedantic-errors -std=c++98"
	then
		exit 1
	fi
	#
	# Fix makefile for what appears to be a bug in gzip under cygwin
	echo "fix_makefile.sh"
	./fix_makefile.sh
	#
	# make shell scripts created by configure executable
	echo "chmod +x example/test_one.sh"
	chmod +x example/test_one.sh
	echo "chmod +x test_more/test_one.sh"
	chmod +x test_more/test_one.sh
	#
	exit 0
fi
#
# -----------------------------------------------------------------------------
if [ "$1" = "dist" ] 
then
	echo "build.sh dist"
	#
	if [ -e cppad-$version ]
	then
		echo "rm -f -r cppad-$version"
		if ! rm -f -r cppad-$version
		then
			echo "Build: cannot remove old cppad-$version"
			exit 1
		fi
	fi
	for file in cppad-*.tgz cppad-*.zip
	do
		if [ -e $file ]
		then
			echo "rm $file"
			rm $file
		fi
	done
	#
	# only build the *.xml version of the documentation for distribution
	if ! grep < doc.omh > /dev/null \
		'This comment is used to remove the table below' 
	then
		echo "Error: Missing comment expected in doc.omh"
		exit 1
	fi
	mv doc.omh doc.tmp
	sed < doc.tmp > doc.omh \
		-e '/This comment is used to remove the table below/,/$tend/d'
	echo "./run_omhelp.sh doc clean"
	if ! ./run_omhelp.sh doc clean
	then
		echo "./run_omhelp.sh doc clean failed."
		exit 1
	fi
	echo "./run_omhelp.sh doc xml"
	if ! ./run_omhelp.sh doc xml 
	then
		echo "./run_omhelp.sh doc xml failed."
		exit 1
	fi
	mv doc.tmp doc.omh
	#
	echo "make dist"
	if ! make dist
	then
		exit 1
	fi
	#
	if [ ! -e cppad-$version.tar.gz ]
	then
		echo "cppad-$version.tar.gz does not exist"
		echo "perhaps version is out of date"
		#
		exit 1
	fi
	# change *.tgz to *.cpl.tgz
	if ! mv cppad-$version.tar.gz cppad-$version.cpl.tgz
	then
		echo "cannot move cppad-$version.tar.gz to cppad-$version.tgz"
		exit 1
	fi
	#
	#
	exit 0
fi
# -----------------------------------------------------------------------------
if [ "$1" = "omhelp" ] 
then
	for flag in "printable" ""
	do
		for ext in htm xml
		do
			echo "./run_omhelp.sh doc $ext $flag"
			if ! ./run_omhelp.sh doc $ext $flag
			then
				msg="Error: run_omhelp.sh doc $ext $flag"
				echo "$msg" 
				exit 1
			fi
			msg="OK: run_omhelp.sh doc $ext $flag"
			echo "$msg" 
		done
	done
	#
	exit 0
fi
# -----------------------------------------------------------------------------
if [ "$1" = "doxygen" ] 
then
	echo "build.sh doxygen"
	# remove old error or warning file, check_doxygen.sh will make sure 
	# a new one is created.
	list="
		doxygen.err
		doxydoc
	"
	for name in $list 
	do
		if [ -e $name ]
		then
			if ! rm -r $name
			then
				echo "Error: cannot remove old $name"
				exit 1
			fi
		fi
	done
	# create doxydoc directory to avoid warning
	mkdir doxydoc
	#
	echo "doxygen doxyfile > doxygen.log "
	if ! doxygen doxyfile > doxygen.log
	then
		echo "Error: during doxygen; see doxygen.err"
		exit 1
	fi
	echo "cat doxygen.err >> doxygen.log"
	if ! cat doxygen.err >> doxygen.log
	then
		echo "Error: cannot add errors and warnings to doxygen.log"
		exit 1
	fi
	if ! ./check_doxygen.sh
	then
		dir=`pwd`
		file="$dir/doxygen.log"
		echo "Error: check_doxygen.sh failed; see $file."
		exit 1
	fi
	#
	echo "pushd doxydoc/latex ; make >& ../../doxygen_tex.log"
	if ! pushd doxydoc/latex 
	then
		echo "Error: pushd doxydoc/latex"
		exit 1
	fi
	if ! make >& ../../doxygen_tex.log
	then
		echo "Error: pushd doxydoc/latex ; make"
		exit 1
	fi
	if ! popd 
	then
		echo "Error: pushd doxydoc/latex ; make ; popd"
		exit 1
	fi
	echo "mv doxydoc/latex/refman.pdf doxydoc/html/cppad.pdf"
	if ! mv doxydoc/latex/refman.pdf doxydoc/html/cppad.pdf
	then
		echo "Error: mv doxydoc/latex/refman.pdf doxydoc/html/cppad.pdf"
		exit 1
	fi
	echo "mv doxydoc/html doxydoc"
	if ! mv doxydoc doxydoc.$$
	then
		echo "Error: mv doxydoc doxydoc.$$"
		exit 1
	fi
	if ! mv doxydoc.$$/html doxydoc
	then
		echo "Error: mv doxydoc.$$/html doxydoc"
		exit 1
	fi
	if ! rm -r doxydoc.$$
	then
		echo "Error: rm -r doxydoc.$$"
		exit 1
	fi
	#
	exit 0
fi
# -----------------------------------------------------------------------------
if [ "$1" = "test" ] 
then
	# start log for this test
	date > build_test.log
	# -------------------------------------------------------------
	# Run automated checking of file names in original source directory
	#
	list="
		check_example.sh
		check_include_def.sh
		check_include_file.sh
		check_include_omh.sh
		check_makefile.sh
		check_if_0.sh
	"
	for check in $list 
	do
		if ! ./$check >> build_test.log
		then
			echo "./$check failed"
			exit 1
		fi
	done
	# add a new line after last file check
	echo ""                 >> build_test.log
	#
	# Extract the distribution
	#
	if [ -e cppad-$version ]
	then
		echo "rm -f -r cppad-$version"
		if ! rm -f -r cppad-$version
		then
			echo "Build: cannot remove old cppad-$version"
			exit 1
		fi
	fi
	#
	if [ -e "cppad-$version.cpl.tgz" ]
	then
		dir="."
	else
		if [ -e "doc/cppad-$version.cpl.tgz" ]
		then
			dir="doc"
		else
			echo "cannot find cppad-$version.cpl.tgz"
			exit 1
		fi
	fi
	#
	#
	echo "tar -xzf $dir/cppad-$version.cpl.tgz"
	if ! tar -xzf $dir/cppad-$version.cpl.tgz
	then
		exit 1
	fi
	#
	dir=`pwd`
	cd cppad-$version
	# ===================================================================
	# Configure
	#
	if ! ./build.sh configure
	then
		echo "Error: build.sh configure"  >> $dir/build_test.log
		echo "Error: build.sh configure" 
		exit 1
	fi
	# -------------------------------------------------------------
	# Test user documentation 
	if [ ! -e "doc/index.xml" ]
	then
		echo "Error: doc/index.xml missing" >> $dir/build_test.log
		echo "Error: doc/index.xml missing"
		exit 1
	fi
	for user in doc dev
	do
		for ext in htm xml
		do
			echo "./run_omhelp.sh $user $ext"
			if ! ./run_omhelp.sh $user $ext
			then
				msg="Error: run_omhelp.sh $user $ext"
				echo "$msg" >> $dir/build_test.log 
				echo "$msg" 
				mv omhelp.$user.$ext.log $dir
				exit 1
			fi
			msg="OK: run_omhelp.sh $user $ext"
			echo "$msg" >> $dir/build_test.log
		done
	done
	# Test developer documentation ---------------------------------------
	# remove old error or warning file, check_doxygen.sh will make sure 
	# a new one is created.
	list="
		doxygen.err
		doxydoc
	"
	for name in $list 
	do
		if [ -e $name ]
		then
			if ! rm -r $name
			then
				echo "Error: cannot remove old $name"
				exit 1
			fi
		fi
	done
	# create doxydoc directory to avoid warning
	mkdir doxydoc
	echo "doxygen doxyfile > doxygen.log"
	if ! doxygen doxyfile > doxygen.log
	then
		echo "Error: during doxygen; see doxygen.err"
		exit 1
	fi
	echo "cat doxygen.err >> doxygen.log"
	if ! cat doxygen.err >> doxygen.log
	then
		echo "Error: cannot add errors and warnings to doxygen.log"
		exit 1
	fi
	if ! ./check_doxygen.sh
	then
		dir=`pwd`
		file="$dir/doxygen.log"
		echo "Error: check_doxygen.sh failed; see $file."
		exit 1
	else
		msg="OK: doxygen doxyfile"
	fi
 	echo "$msg" >> $dir/build_test.log
	# -------------------------------------------------------------
	# Build and run all the tests
	echo "make test >& $dir/make.log"
	echo "The following will give an overview of progress of command above"
	echo "	cat $dir/cppad-$version/test.log"
	echo "The following will give details of progress of command above"
	echo "	tail -f $dir/make.log"
	if ! make test >&  ../make.log
	then
		make_test_result="error"
		echo "There are errors in $dir/make.log"
	else
		if grep 'warning:' make.log
		then
			make_test_resuult="warn"
			echo "There are warnings in $dir/make.log"
		else
			make_test_result="ok"
		fi
	fi
	echo "copying $dir/cppad-$version/test.log to $dir/test.log"
	cp $dir/cppad-$version/test.log $dir/test.log
	#
	if [ "$make_test_result" != "ok" ]
	then
		exit 1
	fi
	echo "OK: make test, see test.log" 
	echo "OK: make test, see test.log" >> $dir/build_test.log
	#
	echo "openmp/run.sh"
	if ! openmp/run.sh  >> $dir/build_test.log
	then
		echo "openmp/run.sh failed"
		exit 1
	fi
	# ===================================================================
	cd ..
	# end the build_test.log file with the date and time
	date >> build_test.log
	#
	dir=`pwd`
	echo "Check $dir/build_test.log for errors and warnings."
	exit 0
fi
# -----------------------------------------------------------------------------
if [ "$1" = "gpl" ] 
then
	# create GPL licensed version
	echo "gpl_license.sh"
	if ! ./gpl_license.sh
	then
		echo "Error: gpl_license.sh failed."
		if [ "$2" = "test" ]
		then
			echo "Error: gpl_license.sh failed." >> build_test.log
		fi
		exit 1
	else
		echo "OK: gpl_license.sh."
		if [ "$2" = "test" ]
		then
			echo "OK: gpl_license.sh." >> build_test.log
		fi
	fi
	exit 0
fi
# ----------------------------------------------------------------------------
if [ "$1" = "dos" ]
then
	echo "./dos_format.sh"
	if ! ./dos_format.sh
	then
		echo "Error: dos_format.sh failed."
		if [ "$2" = "test" ]
		then
			echo "Error: dos_format.sh failed." >> build_test.log
		fi
		exit 1
	else
		echo "OK: dos_format.sh."
		if [ "$2" = "test" ]
		then
			echo "OK: dos_format.sh." >> build_test.log
		fi
	fi
	#
	exit 0
fi
if [ "$1" = "move" ] 
then
	# move tarballs and developer documentation into doc directory
	list="
		doxydoc
		cppad-$version.cpl.tgz
		cppad-$version.gpl.tgz
	"
	# check if dos files have been created
	if [ -e cppad-$version.cpl.zip ]
	then
		list="$list cppad-$version.cpl.zip"
	fi
	if [ -e cppad-$version.gpl.zip ]
	then
		list="$list cppad-$version.gpl.zip"
	fi
	for file in $list
	do
		echo "mv $file doc/$file"
		if ! mv $file doc/$file
		then
			echo "Error: mv $file doc."
			if [ "$2" = "test" ]
			then
				echo "Error: mv $file doc." >> build_test.log
			fi
			exit 1
		fi
	done
	exit 0
fi
#
if [ "$1" = "help" ]
then
echo "--------------------------------------------------------------------"
echo "option"
echo "------"
echo "help           print this message"
echo "version        update configure.ac and doc.omh version number"
echo "automake       run aclocal,autoheader,autoconf,automake -> configure"
echo "configure      run configure"
echo "dist           create the distribution file cppad-version.cpl.tgz"
echo "omhelp         build all formats for user documentation in doc/*"
echo "doxygen        build developer documentation in doxydoc/*"
echo "test           unpack *.cpl.tgz, compile, tests, result in build_test.log"
echo "gpl            create *.gpl.tgz"
echo "dos            create *.gpl.zip, and *.cpl.zip"
echo "move           move tarballs and developer documentation to doc directory"
echo
echo "build.sh option_1 option_2 ..."
echo "Where options are in list above, executes them in the specified order."
echo
echo "build.sh all"
echo "Execute all options except help, test, and dos, are excluded."
echo
echo "build.sh all dos"
echo "Execute all options except help, and test, are excluded."
echo
echo "build.sh all test"
echo "Execute all options except help, and dos, are excluded."
echo "------------------------------------------------------------------------"
exit 0
fi
#
echo "build.sh: \"$1\" is an invalid option."
./build.sh help
exit 1
