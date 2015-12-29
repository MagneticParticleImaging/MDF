%% 1. Loading the required external functions
disp('1. Load the required external functions');
clear all
close all

addpath(genpath(fullfile('.','regu')))
addpath(genpath(fullfile('.','ourFunctions')))

%% 2. Loading the data
disp('2. Load the data'); tic

% For the System matrix (later named SM)
% the filename
filename_SM = fullfile('..','systemMatrix.h5');
% to obtain infos on the file, use the command: infoSM = h5info(filename_SM);
% or read the format documentation

% read the data, saved as real numbers
S = h5read(filename_SM, '/calibration/dataFD');

% reinterpret as complex numbers
S = squeeze(S(1,:,:) + 1i*S(2,:,:));

% For the measurements
% the filename
filename_Meas = fullfile('..','measurement.h5');

% read and convert the data as complex numbers
% note that these data contain 500 measurements
u = h5read(filename_Meas, '/measurement/dataFD');
u = squeeze(u(1,:,:) + 1i*u(2,:,:));
toc

%% 3. Pre-process and display the SM
disp('3. Pre-process and display the SM'); tic

% read the number of frequencies per channel for the SM
freq_SM = h5read(filename_SM, '/acquisition/receiver/frequencies');
numberFreq_SM = size(freq_SM,1);

% Separate all the receive channels
% as we know how it was saved
S2(1,:,:) = S(:,1:numberFreq_SM);
S2(2,:,:) = S(:,numberFreq_SM+1:2*numberFreq_SM);
S2(3,:,:) = S(:,2*numberFreq_SM+1:end);

% read the numbers of points used to discretize the 3D volume
number_Position = h5read(filename_SM, '/calibration/size');

% display one part of the first channel of the SM
figure
for i=1:100
    subplot(10,10,i)
    frequencyComponent = 50+i;
    imagesc(reshape(abs(S2(1,:,frequencyComponent)),number_Position(1),number_Position(2)));
    axis square
    set(gca,'XTickLabel',[],'YTickLabel',[]);
    title(sprintf('%i FC',frequencyComponent));
end
colormap(gray)
toc

%% 4. Pre-process and display a measurement
disp('4. Pre-process and display the SM'); tic

% load the frequencies corresponding to the matrices indexes
% hoping that they are the same for the SM and the phantom measurements :)
freq_Meas = h5read(filename_Meas, '/acquisition/receiver/frequencies');
numberFreq_Meas = size(freq_Meas,1);

u2(1,:,:) = u(1:numberFreq_Meas,:);
u2(2,:,:) = u(numberFreq_Meas+1:2*numberFreq_Meas,:);
u2(3,:,:) = u(2*numberFreq_Meas+1:end,:);

figure
semilogy(freq_Meas,abs(u2(1,:,1)))
title('Absolute value of a transformed FFT of the first measure on the first channel')
ylabel('Transformed FFT (unknown unit)')
xlabel('Frequency (Hz)')
toc

%% 5. Remove the frequencies which are lower than 30 kHz, as they are unreliable due to the anologue filter in the scanner
disp('5. Post-processing: remove the frequencies'); tic

% we supose that the same frequencies are measured on all channel for 
% the SM and the measurements
idxFreq = freq_Meas > 30e3;
S_truncated = S2(:,:,idxFreq);
u_truncated = u2(:,idxFreq,:);
toc

%% 6. Averaged the measurement used for the reconstruction over all temporal frames
disp('6. Post-processing: average the measurements'); tic

u3 = mean(u_truncated,3);

%% 7. Make four simple reconstructions using a single receive channel
disp('7. Make 4 simple recontruction'); tic

%with the build in least square
% using a maximum of 1000 iterations
maxIteration = 1000;
% and a small tolerance
tolerance = 10^-6;
c_lsqr = lsqr(squeeze(S_truncated(1,:,:)).', u3(1,:).',tolerance,maxIteration);

% and an external ART function
% using a maximum of 3 iterations
maxIteration = 3;
c_art = art(squeeze(S_truncated(1,:,:)).',u3(1,:),maxIteration);

% and a modified version of the external ART function
% forcing a real and non-negative solution
% using a maximum of 3 iterations
maxIteration = 3;
c_artGael = artGael(squeeze(S_truncated(1,:,:)).',u3(1,:),maxIteration);

% and a normalized regularized kaczmarz approach
maxIteration = 1;
c_normReguArt = regularizedKaczmarz(squeeze(S_truncated(1,:,:)),...
                        u3(1,:),...
                        maxIteration,...
                        1*10^-6,0,1,1);% lambda,shuffle,enforceReal,enforcePositive
                    
% and an SVD approach

toc
%% 8. Display an image
disp('8. Display the 4 reconstruction')

figure
subplot(2,2,1)
imagesc(real(reshape(c_lsqr(:),number_Position(1),number_Position(2))));
colormap(gray); axis square
title({'Matlab least square - 1st channel';'1000th iterations / real part'})

subplot(2,2,2)
imagesc(real(reshape(c_art(:,1),number_Position(1),number_Position(2))));
colormap(gray); axis square
title({'External ART - 1st channel';'1st iterations / real part'})

subplot(2,2,3)
imagesc(real(reshape(c_artGael(:,1),number_Position(1),number_Position(2))));
colormap(gray); axis square
title({'Modified ART - 1st channel';'1st iterations / real part'})

subplot(2,2,4)
imagesc(real(reshape(c_normReguArt(:),number_Position(1),number_Position(2))));
colormap(gray); axis square
title({'Regularized and modified ART - 1st channel';'1 iterations / lambda = 10^{-6} / real part'})
