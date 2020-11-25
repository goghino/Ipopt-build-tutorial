# This script provides an example how to build Ipopt (tested with 3.13.3)
# on Linux (SUSE Linux 5.3.18-24.34-default) using Pardiso linear solver (v6.0)
# and Intel MKL library (v2020.0.166), using GCC 7.5.0

################### Dependencies ##############################
# First of all, you need to install the Intel MKL library. You
# need to create an Intel account in order to download the library. 
# Follow the instructions at the following link:
# https://software.intel.com/content/www/us/en/develop/tools/math-kernel-library/choose-download/macos.html
# After obtaining the installer package follow the instructions.
# When the installation is successfuly completed, don't forget to
# run the initialization script in every new terminal session, or
# better, add this command to your ~/.bashrc or ~/.bash_profile.
# This script initializes your environment so that other programs
# can use the MKL library, in particular this sets the MKLROOT and 
# updates LD_LIBRARY_PATH.
# The path to the mklvars.sh script below might differ for you.
# Please update accordingly.
source /opt/intel/mkl/bin/mklvars.sh  intel64

# Next, you can obtain the precompiled Pardiso library from the Pardiso webpage, please
# obtain the Linux version (it should be named as e.g. libpardiso600-GNU720-X86-64.so).
# You will also need to register on the webpage to obtain
# a free academic license. The URL is https://pardiso-project.org/
# After obtaining the library and the license do the following steps.
# Put the license in the pardiso.lic file in your $HOME directory
$ vim $HOME/pardiso.lic
# and place the Pardiso library to a desired location, we call it PARDISO_PATH,
# e.g. PARDISO_PATH=$HOME/Libraries. Set the environment variables accordingly
export LD_LIBRARY_PATH=$PARDISO_PATH:$LD_LIBRARY_PATH
export OMP_NUM_THREADS=1
export PARDISOLICMESSAGE=1

################### Ipopt build ###############################
# Obtain Ipopt source code
git clone https://github.com/coin-or/Ipopt.git

# Tested with v.3.13.3 (16. October 2020)
cd Ipopt
git checkout releases/3.13.3

# Select the installation location, e.g.
INSTALL_DIR="$HOME/Libraries/ipopt"

# Create separate folder for the build process and go to the build
# directory. Then, run the configure script
mkdir build
cd build
ADD_CFLAGS="-fPIC -fno-common -fexceptions"  \
ADD_CXXFLAGS="-fPIC -fno-common -fexceptions" \
ADD_FFLAGS="-fPIC -fexceptions -fbackslash"  \
../configure F77=gfortran CC=gcc  CXX=g++  \
 --with-pic      \
 --prefix="$INSTALL_DIR" \
 --disable-java \
 --with-pardiso="-L$PARDISO_PATH -lpardiso600-GNU720-X86-64 -lgfortran -lgomp -lquadmath"
# Hopefully the configure script will run successfuly, without any errors. Otherwise,
# inspect config.log and search for errors, address the problem an run the configure 
# command above again. Note that you need to supply the Pardiso library and its
# dependencies in the --with-pardiso parameter. The MKL library is detected automatically,
# using the env. variables MKLROOT and LD_LIBRARY_PATH set by the MKL initialization
# script described above in the Dependencies section.

# Next, run the make and make install
make -j8
make install

# At this point the Ipopt should be successfully installed in the location specified
# by --prefix in the configure command above. It should contain include,lib and share
# sub-directories. Test the installation by running
make test

# In order to be able use the newly compiled Ipopt library, set the following variables
export LD_LIBRARY_PATH="$INSTALL_DIR/lib":$LD_LIBRARY_PATH
export PKG_CONFIG_PATH="$INSTALL_DIR/lib/pkgconfig":$PKG_CONFIG_PATH
