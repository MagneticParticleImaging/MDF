using HDF5
using PyPlot

include("kaczmarzReg.jl")
include("pseudoinverse.jl")

filenameSM = "../systemMatrix.h5"
filenameMeas = "../measurement.h5"

# read the full system matrix
S = h5read(filenameSM, "/calibration/dataFD")
# reinterpret to complex data
S = reinterpret(Complex{eltype(S)}, S, (size(S,2),size(S,3),size(S,4)))

# read the measurement data
u = h5read(filenameMeas, "/measurement/dataFD")
u = reinterpret(Complex{eltype(u)}, u, (size(u,2), size(u,3), size(u,4)))

# we now load the frequencies
freq = h5read(filenameMeas, "/acquisition/receiver/frequencies")

# remove frequencies below 30 kHz
idxMin = findfirst( freq .> 30e3)
S = S[:,idxMin:end,:]
u = u[idxMin:end,:,:]

# merge frequency and receive channel dimensions
S = reshape(S, size(S,1), size(S,2)*size(S,3))
u = reshape(u, size(u,1)*size(u,2), size(u,3))

# average over all temporal frames
u = vec(mean(u,2))

# reconstruct using kaczmarz algorithm
c = kaczmarzReg(S,u,1,1e6,false,true,true)

# reconstruct using signular value decomposition
SSVD = SVD(svd(S.')...)
csvd = pseudoinverse(SSVD, u, 5e3, true, true)

# reshape into an image
N = h5read(filenameSM, "/calibration/size")
c = reshape(c,N[1],N[2])
csvd = reshape(csvd,N[1],N[2])

# plot kaczmarz reconstruction
figure()
gray()
imshow(real(c))

# plot pseudoinverse reconstruction
figure()
gray()
imshow(real(csvd))
