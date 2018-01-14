using HDF5, PyPlot, Requests

include("kaczmarzReg.jl")
include("pseudoinverse.jl")
include("utils.jl")

# Download measurement and systemMatrix from http://media.tuhh.de/ibi/mdf/
filenameSM = "systemMatrix.mdf"
filenameMeas = "measurement.mdf"

if !isfile(filenameSM)
  streamSM = get("http://media.tuhh.de/ibi/mdfv2/systemMatrix_V2.mdf")
  save(streamSM, filenameSM)
end
if !isfile(filenameMeas)
  streamMeas = get("http://media.tuhh.de/ibi/mdfv2/measurement_V2.mdf")
  save(streamMeas, filenameMeas)
end

# read the full system matrix
S = readComplexArray(filenameSM, "/measurement/data")
# get rid of background frames
isBG = h5read(filenameSM, "/measurement/isBackgroundFrame")
S = S[isBG .== 0,:,:,:]

# read the measurement data
u = h5read(filenameMeas, "/measurement/data")
u = map(Complex64, rfft(u,1))

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
u = vec(mean(u,2))

# reconstruct using kaczmarz algorithm
c = kaczmarzReg(S,u,1,1e6,false,true,true)

# reconstruct using signular value decomposition
U, Σ, V = svd(S.')
csvd = pseudoinverse(U, Σ, V, u, 5e2, true, true)

# reshape into an image
N = h5read(filenameSM, "/calibration/size")
c = reshape(c,N[1],N[2])
csvd = reshape(csvd,N[1],N[2])

# plot kaczmarz reconstruction
figure()
gray()
imshow(real(c), interpolation="None")

# plot pseudoinverse reconstruction
figure()
gray()
imshow(real(csvd), interpolation="None")
