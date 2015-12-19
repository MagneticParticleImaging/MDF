function [ x ] = kaczmarz( A,b,iterations,lambd,shuff,enforceReal,enforcePositive )
%KACZMARZ Summary of this function goes here
%   Detailed explanation goes here

[N, M] = size(A);

x = complex(zeros(N,1)); 

residual = complex(zeros(M,1));

energy = rowEnergy(A);

rowIndexCycle = 1:M;

if shuff
    rowIndexCycle = randperm(M);
end

% estimate regularization parameter
lambdZero = sum(energy.^2)/N;

lambdIter = lambd*lambdZero;

for l = 1:iterations
    for m = 1:M
        k = rowIndexCycle(m);
        
        if energy(k) > 0
            tmp = A(:,k).'*x;
            
            beta = (b(k) - tmp - sqrt(lambdIter)*residual(k)) / (energy(k)^2 + lambdIter);
            
            x = x + beta*conj(A(:,k));
            
            residual(k) = residual(k) + beta*sqrt(lambdIter);
        end
    end
    
    if enforceReal && ~isreal(x)
        x = complex(real(x),0);
    end
    
    if enforcePositive
        x(real(x) < 0) = 0;
    end
end

end


function [ energy ] = rowEnergy(A)

M = size(A,2);

energy = zeros(M,1);

for m = 1:M
    energy(m) = norm(A(:,m));
end

end
