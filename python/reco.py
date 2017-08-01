from kaczmarzReg import *
from pseudoinverse import *
from pylab import *
import h5py
import urllib
import os

# Download measurement and systemMatrix from http://media.tuhh.de/ibi/mdf/
filenameSM = "systemMatrix.mdf"
filenameMeas = "measurement.mdf"

if not os.path.isfile(filenameSM):
  fileSM = urllib.request.FancyURLopener()
  fileSM.retrieve('http://media.tuhh.de/ibi/mdfv2/systemMatrix_V2.mdf', filenameSM)
if not os.path.isfile(filenameMeas):
  fileMeas = urllib.request.FancyURLopener()
  fileMeas.retrieve('http://media.tuhh.de/ibi/mdfv2/measurement_V2.mdf', filenameMeas)

fSM = h5py.File(filenameSM, 'r')
fMeas = h5py.File(filenameMeas, 'r')

# read the full system matrix
S = fSM['/measurement/data']
# reinterpret to complex data
#S = S[:,:,:,:,:].view(complex64).squeeze()
S = S[:,:,:,:,:].view(complex128).squeeze()
# get rid of background frames
isBG = fSM['/measurement/isBackgroundFrame'][:].view(bool)
print(S.shape)
S = S[:,:,isBG == False]

# read the measurement data
u = fMeas['/measurement/data']
u = u[:,:,:,:].squeeze()
u = rfft(u)

# generate frequency vector
numFreq = round(fMeas['/acquisition/receiver/numSamplingPoints'].value/2)+1
rxBandwidth = fMeas['/acquisition/receiver/bandwidth'].value
freq = arange(0,numFreq)/(numFreq-1)*rxBandwidth

# remove frequencies below 80 kHz and use only x/y receive channels
idxMin = find(freq[:] > 80e3)[0]
S = S[0:2,idxMin:-1,:]
u = u[:,0:2,idxMin:-1]

print(shape(S))
print(shape(u))

# merge frequency and receive channel dimensions
S = reshape(S, (shape(S)[0]*shape(S)[1],shape(S)[2]))
u = reshape(u, (shape(u)[0],shape(u)[1]*shape(u)[2]))

# average over all temporal frames
u = mean(u,axis=0)

# reconstruct
c = kaczmarzReg(S,u,1,1e6,False,True,True)

# reconstruct using signular value decomposition
U, Sigm, V = svd(S, full_matrices=False)
csvd = pseudoinverse(U, Sigm, V, u, 5e2, True, True)

# reshape into an image
N = fSM['/calibration/size'][:]
c = reshape(c,(N[0],N[1]))
csvd = reshape(csvd,(N[0],N[1]))

# plot kaczmarz reconstruction
figure()
gray()
imshow(real(transpose(c)), interpolation="None")

# plot pseudoinverse reconstruction
figure()
gray()
imshow(real(transpose(csvd)), interpolation="None")

show()
