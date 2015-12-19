from kaczmarz import *
from pylab import *
import h5py

filenameSM = '../systemMatrix.h5'
filenameMeas = '../measurement.h5'

fSM = h5py.File(filenameSM, 'r')
fMeas = h5py.File(filenameMeas, 'r')

# read the full system matrix
S = fSM['/calibration/dataFD']
# reinterpret to complex data
S = S[:,:,:].view(complex64).squeeze()

# read the measurement data
u = fMeas['/measurement/dataFD']
u = u[:,:,:].view(complex64).squeeze()

# we now load the frequencies
freq = fMeas['/acquisition/receiver/frequencies']

# remove frequencies below 30 kHz
idxMin = find(freq[:] > 30e3)[0]
S = S[idxMin:-1,:]
u = u[:,idxMin:-1]

# average over all temporal frames
u = mean(u,axis=0)

# reconstruct
c = kaczmarz(S,u,1,1e6,False,True,True)

# reshape into an image
N = fSM['/calibration/size'][:]
c = reshape(c,(N[0],N[1]))

gray()
imshow(real(c))
show()
