
function rowEnergy(A)
  M = size(A,2)
  energy = zeros(Float64, M)

  for m=1:M
    energy[m] = norm(A[:,m])
  end

  return energy
end

function dot_with_matrix_row(A, x, k)
  tmp = 0.0
  for n=1:size(A,1)
    tmp += A[n,k]*x[n]
  end
  tmp
end


function kaczmarz{T}(A::AbstractMatrix{T}, b::Vector{T}, iterations, lambd, shuff, enforceReal, enforcePositive )
  M = size(A,2)
  N = size(A,1)

  x = zeros(T, N)
  residual = zeros(T, M)

  energy = rowEnergy(A)
    
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
      x = complex(real(x),0)
    end
    if enforcePositive
      x[real(x) .< 0] = 0
    end
  end

  return x
end
