# MDF julia code

This folder contains examplary Julia code for a simple MPI reconstruction.

## Set up
In order to use this code one first has to download Julia and apply the packages `HDF5` and `PyPlot` by executing

```julia
Pkg.add("HDF5")
Pkg.add("PyPlot")
```

The later requires a functional Python/Matplotlib installation such as the one provided by the Anaconda Python distribution.
After installation of the package, the reconstruction can be started by executing

## Reconstruction Examples
After the set up the reconstruction example script can be run from within Julia by

```julia
include("reco.jl")
```

## Sanity Check
To help bring forward your own implementation of the Magnetic Particle Imaging Data Format a sanitycheck is provided wit the Julia code.

To check a file simply run

```julia
include("sanitycheck.jl")
isvalid_mdf("/path/to/your/testfile")
```

If your `testfile` passes all tests `isvalid_mdf` will return `true`, else warnings will be given to point out were your `testfile`does not agree with the MDF specifications.
