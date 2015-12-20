@doc "This Type stores the singular value decomposition of a Matrix" ->
type SVD
	U::Matrix
	Σ::Vector
	V::Matrix
	D::Vector
end

SVD(U::Matrix,Σ::Vector,V::Matrix) = SVD(U,Σ,V,1./Σ)

@doc "This solves the Tikhonov regularized problem using the singular value decomposition." ->
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
