%% 1. Loading the required external functions

clear all
close all

%% 2. Download measurement and systemMatrix from http://media.tuhh.de/ibi/mdf/

filenameSM = 'systemMatrix.mdf';
filenameMeas = 'measurement.mdf';

urlwrite('http://media.tuhh.de/ibi/mdfv2/systemMatrix_V2.mdf',filenameSM)
urlwrite('http://media.tuhh.de/ibi/mdfv2/measurement_V2.mdf',filenameMeas)

%% 3. Loading the data
% For the System matrix (later named SM)
% to obtain infos on the file, use the command: infoSM = h5info(filename_SM);
% or read the format documentation

% read the data, saved as real numbers
S = h5read(filenameSM, '/measurement/data');

% reinterpret as complex numbers
S = squeeze(S(1,:,:,:,:) + 1i*S(2,:,:,:,:));
% get rid of background frames
isBG = h5read(filenameSM, '/measurement/isBackgroundFrame');
S = S(isBG == 0,:,:,:);

% For the measurements
% read and convert the data as complex numbers
% note that these data contain 500 measurements
u = h5read(filenameMeas, '/measurement/data');
%u = squeeze(u(1,:,:,:) + 1i*u(2,:,:,:));
u = fft(u);
u = u(1:(size(u,1)/2+1),:,:,:);

%% 4. Pre-process - Remove the frequencies which are lower than 30 kHz, as they are unreliable due to the anologue filter in the scanner

% generate frequency vector
numFreq = h5read(filenameMeas, '/acquisition/receiver/numSamplingPoints')/2+1;
rxBandwidth = h5read(filenameMeas, '/acquisition/receiver/bandwidth');
freq = linspace(0,1,numFreq) .* rxBandwidth;

% we supose that the same frequencies are measured on all channel for 
% the SM and the measurements. use only x/y receive channels
idxFreq = freq > 80e3;
S_truncated = S(:,idxFreq,1:2);
u_truncated = u(idxFreq,1:2,:);

%% 5. Merge frequency and receive channel dimensions
S_truncated = reshape(S_truncated, size(S_truncated,1), size(S_truncated,2)*size(S_truncated,3));
u_truncated = reshape(u_truncated, size(u_truncated,1)*size(u_truncated,2), size(u_truncated,3));

%% 6. Averaged the measurement used for the reconstruction over all temporal frames
u_mean_truncated = mean(u_truncated,2);

%% 7. Make two simple reconstructions
% a normalized regularized kaczmarz approach
c_normReguArt = kaczmarzReg(S_truncated(:,:),...
                        u_mean_truncated(:),...
                        1,1*10^-6,0,1,1);

% and an regularized pseudoinverse approach
[U,Sigma,V] = svd(S_truncated(:,:).','econ');
Sigma2 = diag(Sigma);
c_pseudoInverse = pseudoinverse(U,Sigma2,V,u_mean_truncated,5*10^2,1,1);

%% 8. Display an image
% read the original size of an image
number_Position = h5read(filenameSM, '/calibration/size');

figure
subplot(1,2,1)
imagesc(real(reshape(c_normReguArt(:),number_Position(1),number_Position(2))));
colormap(gray); axis square
title({'Regularized and modified ART - 3 channels';'1 iterations / lambda = 10^{-6} / real part'})

subplot(1,2,2)
imagesc(real(reshape(c_pseudoInverse(:),number_Position(1),number_Position(2))));
colormap(gray); axis square
title({'Pseudoinverse - 3 channels';' lambda = 5*10^{3} / real part'})
