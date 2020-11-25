# This script provides an example how to build Ipopt (tested with 3.13.3)
# on Linux (SUSE Linux 5.3.18-24.34-default) using Coin HSL linear solvers (2019.05.21)
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

# Next, you can obtain the HSL library source from the webpage
# http://www.hsl.rl.ac.uk/ipopt/, please obtain the Linux version.
# You will also need to register on the webpage to obtain
# a free academic license. 
# In order to compile the library, to the following:
cd coinhsl-2019.05.21
mkdir build
cd build

# Select the desired installation location
HSL_INSTALL_DIR="$HOME/Libraries/hsl"

../configure --prefix=$HSL_INSTALL_DIR
make
make install

# After the successfull installation, the $HSL_INSTALL_DIR should
# contain include and lib64 sub-directories. Set the environment variables
# so that the library can be later used by other programs.
export LD_LIBRARY_PATH=$HSL_INSTALL_DIR/lib64:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=$HSL_INSTALL_DIR/lib64/pkgconfig:$PKG_CONFIG_PATH

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

# Set the HSL install location
HSLlibdir=${HSL_INSTALL_DIR}/lib64
HSLincludedir=${HSL_INSTALL_DIR}/include

ADD_CXXFLAGS="-fPIC -fexceptions -m64" \
ADD_CFLAGS="-fPIC -fexceptions -m64" \
ADD_FFLAGS="-fPIC -fexceptions -fopenmp -m64" \
../configure  F77=gfortran CC=gcc CXX=g++ \
--with-pic --without-mumps \
--prefix="$INSTALL_DIR" \
--with-hsl="yes" \
--with-hsl-cflags="-I${HSLincludedir} -m64 -I${MKLROOT}/include" \
--with-hsl-lflags="-L${HSLlibdir} -lcoinhsl -lmetis -L${MKLROOT}/lib/intel64 -Wl,--no-as-needed -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lpthread -lm -ldl"
# Hopefully the configure script will run successfuly, without any errors. Otherwise,
# inspect config.log and search for errors, address the problem an run the configure 
# command above again. Note that you need to supply the HSL library and its
# dependencies in the --with-hsl-cflags and --with-hsl-lflags parameters.
# You need to supply also the MKL library, using the env. variable MKLROOT
# set by the MKL initialization script described above in the Dependencies section.
# The specific MKL libraries were configured using the MKL Link advisor available at
# https://software.intel.com/content/www/us/en/develop/articles/intel-mkl-link-line-advisor.html

# Next, run the make and make install
make -j8
make install

# At this point the Ipopt should be successfully installed in the location specified
# by --prefix in the configure command above. It should contain include,lib and share
# sub-directories. Test the installation by running
make test

# In order to be able use the newly compiled Ipopt library, set the following variables
export LD_LIBRARY_PATH="$INSTALL_DIR/lib64":$LD_LIBRARY_PATH
export PKG_CONFIG_PATH="$INSTALL_DIR/lib64/pkgconfig":$PKG_CONFIG_PATH
