# Matlab's Ipopt Interfaces
This tutorial covers Matlab's [mexIPOPT](https://github.com/ebertolazzi/mexIPOPT) interface. This procedure was tested on MacOS with Matlab 2020a. In this tutorial we assume an Ipopt C++ build with [Pardiso linear solver](http://pardiso-project.org/) and [Intel MKL library](https://software.intel.com/content/www/us/en/develop/tools/math-kernel-library/choose-download.html).

## Prerequisities
The first thing you need to do is install a C++ compiler and a Fortran 77 compiler. It is necessary to use the precise compilers supported by your version of Matlab (see [here](https://ch.mathworks.com/de/support/requirements/supported-compilers.html)).

Once you've installed the appropriate compilers, set up and configure Matlab to build MEX files. On Mac with Matlab 2020a it would be:
```
/Applications/MATLAB_R2020a.app/bin/mex -setup C++ -v
```

Of course, it is assumed you have a working C++ Ipopt library (please refer to the tutorial [here](../../Ipopt)). 

## Installation
Get the source code of the interface 
```
git clone https://github.com/ebertolazzi/mexIPOPT.git
```
At the moment of this tutorial, the HEAD was at the commit `908a3e1`. The instructions for the following versions differ since the repository has changed since then significantly.
The repository contains a lot of useful information about the process. Please read through the README files there.

All the important setup happens in the file `lib/compile_osx.m`. You need to specify
* `MATLAB` - full path to Matlab
* `PREFIX` - path to the Ipopt C++ library install location (folder including lib, include, share sub-folders)
* `LIBS` - linker flags for the C++ library and all its dependencies.

For example, the changes can look as following:
```
PREFIX= '<IPOPT_INSTALL_PATH>'
LIBS = '-L<IPOPT_INSTALL_PATH>/lib -lipopt -L/usr/local/Cellar/gcc/9.3.0_1/lib/gcc/9
         <PARDISO_PATH>/libpardiso700-MACOS-X86-64.dylib -lgfortran -lgomp -lquadmath
         -L<MKLROOT>/lib -lmkl_core -lmkl_intel_lp64 -lmkl_sequential -lm  -ldl'
```
Note that in my case I had to include also path to some standard C/C++ libraries (`-L/usr/local/Cellar/gcc/9.3.0_1/lib/gcc/9`). It might not be necessary in your case.

Next, execute the Matlab script and the new Ipopt library should be located in the same folder, i.e. `lib/ipopt.mexmaci64`.

### Static vs dynamic linking

Note that when linking dynamic Ipopt/Pardiso/MKL libraries, there will be conflict in MKL libraries used internally by Matlab (check by running `version -blas` or `version -lapack` in Matlab prompt) and by Ipopt/Pardiso. It is possible to force Matlab to use specific MKL version by setting the environment variables, i.e. as shown below, but this will most likely result in crash of the Matlab's internal routines relying on MKL.
```
BLAS_VERSION=$MKLROOT/lib/intel64/libmkl_rt.so \
LAPACK_VERSION=$MKLROOT/lib/intel64/libmkl_rt.so \
matlab -nodesktop
```

Therefore, it is recommended to link the Ipopt/Pardiso/MKL libraries statically. Do so by updating the `LIBS2` variable such that it containts all the libraries
```
LIBS2 = '-Wl,-Bstatic $IPOPT_HOME/lib64/libipopt.a -Wl,--start-group ...
$PARDISO_HOME/libpardiso.a $PARDISO_HOME/libmetis510_pardiso.a ...
$PARDISO_HOME/libmetis41_pardiso.a $PARDISO_HOME/libmetis41-P_pardiso.a ...
$PARDISO_HOME/libamd.a $PARDISO_HOME/libpils_pardiso.a ...
$MKLROOT/lib/intel64/libmkl_intel_lp64.a $MKLROOT/lib/intel64/libmkl_sequential.a ...
$MKLROOT/lib/intel64/libmkl_core.a ...
-Wl,--end-group -Wl,-Bdynamic -lgfortran -lgomp -lquadmath -lpthread -lm -ldl';
```

## Test
Run of the Matlab examples located in the `examples` directory. In oder to tell Matlab the location of the Ipopt's mex interface, you will have to specify it using `addpath(...)` pointing to the location of the `ipopt.mexmaci64` binary file.

## Troubleshooting

### Cannot load any more object
```
Invalid MEX-file 'ipopt.mexa64': dlopen: cannot load any more object with static TLS
```
Try to preload OpenMP library (see also [here](https://ch.mathworks.com/matlabcentral/answers/309254-using-matlab-2016a-i-get-dlopen-cannot-load-any-more-object-with-static-tls-after-running-my-mex))
```
export LD_PRELOAD=<PATH_TO_GCC>gcc/6.3.0/lib64/libgomp.so
```

### Segfault during the Ipopt execution
```
This is Ipopt version 3.13.4, running with linear solver pardiso.

Number of nonzeros in equality constraint Jacobian...:        4
Number of nonzeros in inequality constraint Jacobian.:        4
Number of nonzeros in Lagrangian Hessian.............:       10

Killed
```
The crash is most likely caused by mismatch between the MKL used internally in Matlab and the version used in Ipopt/Pardiso. The solution is to link statically all the libraries required by Ipopt. See the note on 'Static vs dynamic linking' above.

In case of other problems, please contact me or the [author](https://github.com/ebertolazzi/mexIPOPT.git) of the mex interface.
