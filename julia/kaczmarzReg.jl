"""
The regularized kaczmarz algorithm solves the Thikonov regularized least squares Problem
argminₓ(‖Ax-b‖² + λ‖b‖²).

# Arguments

* `A::AbstractMatrix`: System matrix A
* `b::Vector`: Measurement vector b
* `iterations::Int`: Number of iterations of the iterative solver
* `lambd::Float64`: The regularization parameter, relative to the matrix trace
* `shuff::Bool`: Enables random shuffeling of rows during iterations in the kaczmarz algorithm
* `enforceReal::Bool`: Enable projection of solution on real plane during iteration
* `enforcePositive::Bool`: Enable projection of solution onto positive halfplane during iteration
"""
function kaczmarzReg(A::AbstractMatrix{T}, b::Vector{T}, iterations, lambd, shuff,
                     enforceReal, enforcePositive) where T
  M = size(A,2)
  N = size(A,1)

  x = zeros(T, N)
  residual = zeros(T, M)

  energy = zeros(Float64, M)
  for m=1:M
    energy[m] = norm(A[:,m])
  end

  rowIndexCycle = collect(1:M)

  if shuff
    shuffle(rowIndexCycle)
  end

  lambdIter = lambd

  for l=1:iterations
    for m=1:M
      k = rowIndexCycle[m]
      if energy[k] > 0
        tmp = dot_with_matrix_row(A,x,k)

        beta = (b[k] - tmp - sqrt(lambdIter)*residual[k]) / (energy[k]^2 + lambd)

        for n=1:size(A,1)
          x[n] += beta*conj(A[n,k])
        end

        residual[k] = residual[k] + beta*sqrt(lambdIter)
      end
    end

    if enforceReal && eltype(x) <: Complex
      x = complex.(real.(x), 0)
    end
    if enforcePositive
      x[real.(x) .< 0] .= 0
    end
  end

  return x
end

"""
Calculates the dot product between x and the k-th matrix row of A.

# Arguments

* `A::AbstractMatrix`: System matrix A
* `x::Vector`: Measurement vector b
* `k::Int: matrix row
"""
function dot_with_matrix_row(A, x, k)
  tmp = 0.0
  for n=1:size(A,1)
    tmp += A[n,k]*x[n]
  end
  tmp
end
