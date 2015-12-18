using HDF5
using PyPlot

include("kaczmarz.jl")

filenameSM = "../systemMatrix.h5"
filenameMeas = "../measurement.h5"

# read the full system matrix
S = h5read(filenameSM, "/calibration/dataFD")
# reinterpret to complex data
S = reinterpret(Complex{eltype(S)}, S, (size(S,2),size(S,3)))

# read the measurement data
u = h5read(filenameMeas, "/measurement/dataFD")
u = reinterpret(Complex{eltype(u)}, u, (size(u,2), size(u,3)))

# we now load the frequencies
freq = h5read(filenameMeas, "/acquisition/receiver/frequencies")

# remove frequencies below 30 kHz
idxMin = findfirst( freq .> 30e3)
S = S[:,idxMin:end]
u = u[idxMin:end,:]

# average over all temporal frames
u = vec(mean(u,2))

# reconstruct
c = kaczmarz(S,u,1,1e6,false,true,true)

# reshape into an image
N = h5read(filenameSM, "/calibration/size")
c = reshape(c,N[1],N[2])

gray()
imshow(real(c))

