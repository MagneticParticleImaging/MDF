 function [ energy ] = rowEnergy(A)		
 % Calculate the norm of each row of the input		
 % This is an image of the energy stored by each frequency component		
 % but the scaling is unclear.		
 		
 energy = sqrt(sum(abs(A.*A),1));		
 		
 end		
