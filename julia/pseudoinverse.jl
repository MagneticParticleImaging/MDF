@doc """
This type stores the singular value decomposition V⁺ΣU of a matrix A as well
as the inverse singular values, which are neccessary to calculate its
pseudoinverse.
"""->
type SVD
	U::Matrix
	Σ::Vector
	V::Matrix
	D::Vector
end

SVD(U::Matrix,Σ::Vector,V::Matrix) = SVD(U,Σ,V,1./Σ)

@doc """
This algorithm solves the Thikonov regularized least squares Problem 
argminₓ(‖Ax-b‖² + λ‖b‖²) using the singular value decomposition of A.

# Arguments

* `SVD::SVD`: Singular value decomposition of A
* `b::Vector`: Measurement vector b
* `lambd::Float64`: The regularization parameter, relative to the matrix trace
* `enforceReal::Bool`: Enable projection of solution on real plane during iteration
* `enforcePositive::Bool`: Enable projection of solution onto positive halfplane during iteration
""" ->
function pseudoinverse{T}(S::SVD, b::Vector{T}, lambd, enforceReal, enforcePositive)
	# perform regularization
	for i=1:length(S.Σ)
		σi = S.Σ[i]
		S.D[i] = σi/(σi^2+lambd^2)
	end

	# calculate pseudoinverse
	tmp = BLAS.gemv('C', one(T), S.U, b)
	tmp .*=  S.D
	c = BLAS.gemv('N', one(T), S.V, tmp)

	# apply constraints
	if enforceReal && eltype(c) <: Complex
		c = complex(real(c),0)
	end
	if enforcePositive
		c[real(c) .< 0] = 0
	end
	
	return c
end
