function [ c ] = regularizedPseudoinverse( U,Sigma,V,u,lambd,enforceReal,enforcePositive )
% This algorithm solves the Thikonov regularized least squares Problem 
% argmin(?Ax-b?² + ??b?²) using the singular value decomposition of A.
% Arguments
% `U,Sigma,V`: Compact singular value decomposition of A
% `u`: Measurement vector u
% `lambd`: The regularization parameter, relative to the matrix trace
% `enforceReal::Bool`: Enable projection of solution on real plane during iteration
% `enforcePositive::Bool`: Enable projection of solution onto positive halfplane during iteration

D = zeros(length(Sigma),1);
for i=1:length(Sigma)
    D(i) = Sigma(i)/(Sigma(i)^2+lambd^2);
end

% calculate pseudoinverse
tmp = U'*u(:); % gemv('C',...) conjugate transpose
tmp =  tmp.*D;
c = V*tmp; % gemv('N',...) not transposed

% apply constraints
if enforceReal
    c = real(c);
end
if enforcePositive
    idxNega = real(c)<0;
    c(idxNega) = 0;
end
    
end

