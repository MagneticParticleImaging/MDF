using Pkg
using UUIDs

# Install required packages

# Due to the removal of Pkg.installed() (https://discourse.julialang.org/t/how-to-use-pkg-dependencies-instead-of-pkg-installed/36416/7), we need to know the UUIDs of the packages.
packageUUIDs = Dict{String, UUID}(
"HDF5" => UUID("f67ccb44-e63f-5c2f-98bd-6dc0ccc4ba2f"),
"FFTW" => UUID("7a1cc6ca-52ef-59f5-83cd-3a7055c09341"),
"HTTP" => UUID("cd3eb016-35fb-5094-929b-558a96fad6f3"),
"PyPlot" => UUID("d330b81b-6aea-500a-939a-2ce795aea3ee"),
)

for P in keys(packageUUIDs)
  !haskey(Pkg.dependencies(), packageUUIDs[P]) && Pkg.add(P)
end

using HDF5, PyPlot, HTTP, FFTW
using LinearAlgebra, Random, Statistics

include("kaczmarzReg.jl")
include("pseudoinverse.jl")
include("utils.jl")

# Download measurement and systemMatrix from http://media.tuhh.de/ibi/mdf/
filenameSM = "systemMatrix.mdf"
filenameMeas = "measurement.mdf"

if !isfile(filenameSM)
  HTTP.open("GET", "http://media.tuhh.de/ibi/mdfv2/systemMatrix_V2.mdf") do http
    open(filenameSM, "w") do file
        write(file, http)
    end
  end
end
if !isfile(filenameMeas)
  HTTP.open("GET", "http://media.tuhh.de/ibi/mdfv2/measurement_V2.mdf") do http
    open(filenameMeas, "w") do file
        write(file, http)
    end
  end
end

# read the full system matrix
S = readComplexArray(filenameSM, "/measurement/data")
# get rid of background frames
isBG = h5read(filenameSM, "/measurement/isBackgroundFrame")
S = S[isBG .== 0,:,:,:]

# read the measurement data
u = h5read(filenameMeas, "/measurement/data")
u = map(ComplexF32, rfft(u,1))

numFreq = div(h5read(filenameMeas, "/acquisition/receiver/numSamplingPoints"),2)+1
rxBandwidth = h5read(filenameMeas, "/acquisition/receiver/bandwidth")
freq = collect(0:(numFreq-1))./(numFreq-1).* rxBandwidth

# remove frequencies below 80 kHz and use only x/y receive channels
idxMin = findfirst( freq .> 80e3)
S = S[:,idxMin:end,1:2,:,1] # 1 is the multi patch dimension
u = u[idxMin:end,1:2,1,:]

# merge frequency and receive channel dimensions
S = reshape(S, size(S,1), size(S,2)*size(S,3))
u = reshape(u, size(u,1)*size(u,2), size(u,3))

# average over all temporal frames
u = vec(mean(u,dims=2))

# reconstruct using kaczmarz algorithm
c = kaczmarzReg(S,u,1,1e6,false,true,true)

# reconstruct using signular value decomposition
U, Σ, V = svd(copy(transpose(S)))
csvd = pseudoinverse(U, Σ, V, u, 5e2, true, true)

# reshape into an image
N = h5read(filenameSM, "/calibration/size")
c = reshape(c,N[1],N[2])
csvd = reshape(csvd,N[1],N[2])

# plot kaczmarz reconstruction
figure()
gray()
imshow(real.(c), interpolation="None")

# plot pseudoinverse reconstruction
figure()
gray()
imshow(real.(csvd), interpolation="None")
