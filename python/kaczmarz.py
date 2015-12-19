import numpy as np
import scipy as sp


def computeRowEnergy(A):
  """
  Calculate the energy of the system matrix rows
  """
  M = A.shape[0]
  energy = np.zeros(M, dtype=np.double)

  for m in xrange(M):
    energy[m] = np.linalg.norm(A[m,:])
  return energy


      
def kaczmarz(A, b, iterations=10, lambd=0, weights=(), enforceReal=False, enforcePositive=False, shuffle=False):
  M = A.shape[0]
  N = A.shape[1]

  x = np.zeros(N, dtype=b.dtype)
  residual = np.zeros(M, dtype=x.dtype)
  
  energy = computeRowEnergy(A)
    
  rowIndexCycle = np.arange(0,M)

  if shuffle:
    np.random.shuffle(rowIndexCycle)

  lambdIter = lambd

  for l in xrange(iterations):
    for m in xrange(M):
      k = rowIndexCycle[m]          
      if energy[k] > 0:
        if lambd > 0 and len(weights) == M:
          if weights[k] > 0:
            lambdIter = lambd / weights[k]
          
        beta = (b[k] - A[k,:].dot(x) + np.sqrt(lambdIter)*residual[k]) / (energy[k]**2 + lambd)

        if isspmatrix_csr(A):
          row = A[k,:]
          x[row.indices] += beta*row.data.conjugate()
        else:
          x +=  beta*A[k,:].conjugate()
        
        residual[k] += np.sqrt(lambdIter) * beta

    if enforceReal and np.iscomplexobj(x):
      x.imag = 0
    if enforcePositive:
      x = x * (x.real > 0)
      
  return x