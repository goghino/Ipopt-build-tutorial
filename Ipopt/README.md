# Building Ipopt From Source

This section describes a process of building Ipopt from source using different configurations. In general, the process is as follows
1. Gather all the dependencies (including their build process)
   1. Compiler (e.g. [GNU GCC](https://gcc.gnu.org/))
   2. Linear solvers (e.g. [HSL codes](http://www.hsl.rl.ac.uk/ipopt/), [Pardiso](https://pardiso-project.org/), [Mumps](http://mumps.enseeiht.fr/))
   3. Other dependencies of the linear solvers (e.g. BLAS, Lapack, Metis, OpenMP, ...)
2. Run the `configure` script to generate Makefiles
3. Compile the code using `make`
4. Install the library using `make install`

When working with dynamic (a.k.a shared) libraries, it is important to update the appropriate environment variables specifying the location of the libraries
(`LD_LIBRARY_PATH` on Linux, `DYLD_LIBRARY_PATH` on MacOS) or location of the installation scripts for `pkg-config` tool in the variable `PKG_CONFIG_PATH`.

A collection of the example scripts provide tutorials throughout the whole process of building Ipopt from collecting, building and installing the dependencies
to installing and using the Ipopt library.
