# Python's Ipopt Interface
This tutorial covers Python's [cyipopt](https://github.com/matthias-k/cyipopt) interface. Quoting the project's site "_cyipopt is a Python wrapper around Ipopt. It enables using Ipopt from the comfort of the Python programming language._" It is availabe through various package managers, including PyPi, or Anaconda, by default distributed with configuration using Mumps linear solver. Other linear solvers are usually more efficient, thus we provide a step-by-step tutorial on how to set up the Python's Ipopt interface in order to use our custom built Ipopt library (covered by tutorial [here](../../Ipopt)). 


## Prerequisities 
It is assumed you have a working Ipopt C++ library, ideally the one you have build from source. For detailed instruction please refer to the [tutorial](../../Ipopt).

Next, you need the dependencies for a Python environment, namely [cython](https://cython.org/) and numpy. We use conda 4.9.2 in this tutorial.
```
conda create --name test python=3.8.5
conda activate test
conda install -c anaconda cython
conda install -c anaconda numpy
conda install -c anaconda six
```

## Installation
Next, set up the environment variables pointing to the Ipopt library, assuming it is installed in `IPOPT_INSTALL_DIR` (the directory including sub-directories lib, include, share). Additionally, the other dependencies of the Ipopt library need to be added, here we use Pardiso, located in `PARDISO_DIR` and the MKL library, which is already present in the enviroment, assuming you have executed its activation script (mklvars.sh or compilervars.sh).
```
export LD_LIBRARY_PATH=$IPOPT_INSTALL_DIR/lib:$PARDISO_DIR:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=$IPOPT_INSTALL_DIR/lib/pkgconfig:$PKG_CONFIG_PATH
```
Note, Ipopt might sometimes name the directory containing the library `lib64` instead of `lib`. Please update the path above accordingly.

Finally, get the interface source code and run the install script. We have used 0.3.0.dev0 version, in case you want the latest stable release switch to v0.2.0 in the git repository before running the install script using command `git checkout v0.2.0`.
```
git clone https://github.com/matthias-k/cyipopt.git
cd cyipopt
python setup.py install
```

In case of errors, it is advisable to remove the cyipopt directory and start from a clean repository since some intermediate files are cached, thus repeated call of the `setup.py` script might not produce the desired results.

## Test
Test the installation by navigating to the `test` folder in the `cyipopt` repository and run
```
python examplehs071.py 
```
In case of successfull installation you should see a message "_EXIT: Optimal Solution Found_" and the correct Ipopt version and linear solver in the output log.

## Troubleshooting
###  Cannot open shared object file
```
ImportError: libipopt.so.1: cannot open shared object file: No such file or directory
```
This indicates that the installation was not performed correctly. Make sure the `LD_LIBRARY_PATH` and `PKG_CONFIG_PATH` variables are set correctly, and that the location they are referring to contains Ipopt library `libipopt.so` (for Linux) or `libipopt.dylib` (for MacOS) and the pkg-config script `ipopt.pc`. A similar advice applies if other shared libraries are missing.

### INTEL MKL ERROR
```
INTEL MKL ERROR: /opt/intel/compilers_and_libraries_2020.0.166/linux/mkl/lib/intel64_lin/libmkl_avx.so: undefined symbol: mkl_sparse_optimize_bsr_trsm_i8.
Intel MKL FATAL ERROR: Cannot load libmkl_avx.so or libmkl_def.so.
```
This is a common problem in Anaconda environment if the Ipopt library depends on MKL BLAS library, see discussion [here](https://github.com/BVLC/caffe/issues/3884).
The solution (really a hack) is to call the script by explicitly loading the libraries:
```
LD_PRELOAD=$MKLROOT/lib/intel64_lin/libmkl_core.so:$MKLROOT/lib/intel64_lin/libmkl_sequential.so python examplehs071.py
```

### Segmentation fault
This occures if there is MKL library in your Conda environment and Ipopt depends on MKL library installed using the Intel installer. The two versions conflict and cause the segmentation fault. The solution is to remove MKL from the Conda environment.
