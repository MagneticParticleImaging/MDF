# MDF julia code

This folder contains example Julia code for a simple MPI reconstruction.

## Set up
In order to use this code one first has to download Julia (version 1.x) and install the  packages `HDF5`, `FFTW`, `HTTP` and `PyPlot` by executing

```julia
using
Pkg.add("HDF5")
Pkg.add("FFTW")
Pkg.add("HTTP")
Pkg.add("PyPlot")
```

## Reconstruction Examples
After installation the reconstruction example script can executed. To do so, move into the MDF directory, run the Julia REPL and execute the reconstruction script

```julia
include("reco.jl")
```

Note that the measurement and system matrix MDF files will be automatically downloaded into your MDF directory.
