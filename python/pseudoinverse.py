import numpy as np
import scipy as sp

"""
This algorithm solves the Thikonov regularized least squares problem 
using the singular value decomposition of A.

# Arguments

* `U, Sigm, V`: Singular value decomposition of A
* `b::Vector`: Measurement vector b
* `lambd::Float64`: The regularization parameter, relative to the matrix trace
* `enforceReal::Bool`: Enable projection of solution on real plane during iteration
* `enforcePositive::Bool`: Enable projection of solution onto positive halfplane during iteration
"""
def pseudoinverse(U, Sigm, V, b, lambd, enforceReal, enforcePositive):
  # perform regularization
  D = np.zeros(np.size(Sigm))
  for i in range(np.size(Sigm)):
    sigmi = Sigm[i]
    D[i] = sigmi/(sigmi**2+lambd**2)

  # calculate pseudoinverse
  tmp = np.dot(U.conjugate().transpose(),b[:]) #  conjugate transpose
  tmp =  tmp*D
  c = np.dot(V.conjugate().transpose(),tmp) # not transposed

  if enforceReal and np.iscomplexobj(c):
    c.imag = 0
  if enforcePositive:
    c = c * (c.real > 0)

  return c
