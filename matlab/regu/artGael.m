function [X,rho,eta] = artGael(A,b,k)
%ART  Algebraic reconstruction technique (Kaczmarz's method).
%
% [X,rho,eta] = art(A,b,k)
%
% Classical Kaczmarz iteration, or ART (algebraic reconstruction
% technique), applied to the system A x = b.  The number of
% iterations is k.

% Reference: F. Natterer and F. Wübbeling, Mathematical Methods
% in Image Reconstruction, SIAM, Philadelphia, 2001; Sect. 5.3.1.

% Per Christian Hansen, IMM, Dec. 6, 2006.

% Modified by Gael Bringout in 2013 for used with MPI reconstruction
% main modification: line 43 to 50
% forcing the negative and imaginary result to zero
% in order to enforce a real and positive solution
% Initialization.
if (k < 1), error('Number of steps k must be positive'), end
[m,n] = size(A); X = zeros(n,k);
if (nargout > 1)
   eta = zeros(k,1); rho = eta;
end

% Prepare for iteration.
x = zeros(n,1);
%nai2 = full(sum(A.*A,2));
nai2 = full(sum(abs(A.*A),2));
I = find(nai2>0)';

% Iterate.

reverseStr = '';
for j=1:k
   for i=I
      Ai = full(A(i,:));
      x = x + (b(i)-Ai*x)*Ai'/nai2(i);
   end
   if (nargout > 1)
      eta(j) = norm(x); rho(j) = norm(b-A*x);
   end
   for p = 1:length(x)
       if x(p)<0
           x(p) = 0;
       end
       %if imag(x(p))~=0
       %    x(p) = real(x(p));
       %end
   end
   X(:,j) = x;
   
    msg = sprintf('Loop %i on %i\n',j,k);
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'),1,length(msg));
end