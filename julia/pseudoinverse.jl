@doc """
This algorithm solves the Thikonov regularized least squares Problem 
argminₓ(‖Ax-b‖² + λ‖b‖²) using the singular value decomposition of A.

# Arguments

* `U, Σ, V`: Singular value decomposition of A
* `b::Vector`: Measurement vector b
* `lambd::Float64`: The regularization parameter, relative to the matrix trace
* `enforceReal::Bool`: Enable projection of solution on real plane during iteration
* `enforcePositive::Bool`: Enable projection of solution onto positive halfplane during iteration
""" ->
function pseudoinverse{T}(U::Matrix, Σ::Vector, V::Matrix, b::Vector{T}, lambd, enforceReal, enforcePositive)
	# perform regularization
	D = zeros(Σ)
	for i=1:length(Σ)
		σi = Σ[i]
		D[i] = σi/(σi^2+lambd^2)
	end

	# calculate pseudoinverse
	tmp = BLAS.gemv('C', one(T), U, b)
	tmp .*=  D
	c = BLAS.gemv('N', one(T), V, tmp)

	# apply constraints
	if enforceReal && eltype(c) <: Complex
		c = complex.(real.(c),0)
	end
	if enforcePositive
		c[real(c) .< 0] = 0
	end
	
	return c
end
