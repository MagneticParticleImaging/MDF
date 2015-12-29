from kaczmarzReg import *
from pylab import *
import h5py

filenameSM = '../systemMatrix.h5'
filenameMeas = '../measurement.h5'

fSM = h5py.File(filenameSM, 'r')
fMeas = h5py.File(filenameMeas, 'r')

# read the full system matrix
S = fSM['/calibration/dataFD']
# reinterpret to complex data
S = S[:,:,:,:].view(complex64).squeeze()

# read the measurement data
u = fMeas['/measurement/dataFD']
u = u[:,:,:,:].view(complex64).squeeze()

# we now load the frequencies
freq = fMeas['/acquisition/receiver/frequencies']

# remove frequencies below 30 kHz
idxMin = find(freq[:] > 30e3)[0]
S = S[:,idxMin:-1,:]
u = u[:,:,idxMin:-1]

print(shape(S))
print(shape(u))

# merge frequency and receive channel dimensions
S = reshape(S, (shape(S)[0]*shape(S)[1],shape(S)[2]))
u = reshape(u, (shape(u)[0],shape(u)[1]*shape(u)[2]))

# average over all temporal frames
u = mean(u,axis=0)

# reconstruct
c = kaczmarzReg(S,u,1,1e6,False,True,True)

# reshape into an image
N = fSM['/calibration/size'][:]
c = reshape(c,(N[0],N[1]))

gray()
imshow(real(c))
show()
