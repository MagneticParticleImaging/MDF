This folder contains examplary Julia code for a simple MPI reconstruction. In order to use this code one first has to download Julia and apply the packages `HDF5` and `PyPlot` by executing

```julia
Pkg.add("HDF5")
Pkg.add("PyPlot")
```

The later requires a functional Python/Matplotlib installation such as the one provided by the Anaconda Python distribution.
After installation of the package, the reconstruction can be started by executing

```julia
include("reco.jl")
```
