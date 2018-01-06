% In this experiment, it is the mirror rather than the light sours that rotates.
% This is for the reconstructed system.
%%
clc;
clear;
close all
%% calibration
%% 125mm
close all
basePath_125 = '/home/zhi/Datasets/beam_direction/Experiment_20180105/125mm/';
[k_125,r_125] = f_calibration_1D(basePath_125);
%% 252mm
close all
basePath_252 = '/home/zhi/Datasets/beam_direction/Experiment_20180105/252mm/';
[k_252,r_252] = f_calibration_1D(basePath_252);
%% 385mm
close all
basePath_385 = '/home/zhi/Datasets/beam_direction/Experiment_20180105/385mm/';
[k_385,r_385] = f_calibration_1D(basePath_385);
%% 497mm
close all
basePath_497 = '/home/zhi/Datasets/beam_direction/Experiment_20180105/497mm/';
[k_497,r_497] = f_calibration_1D(basePath_497);
%% regression
close all
K = [k_125;k_252;k_385;k_497];
D = [125;252;385;497];
B_K = f_K_regression( K,D );
%% system noise estimation
close all
basePath_centers = '/home/zhi/Datasets/beam_direction/Experiment_20180105/centers/';
f_noise_analysis( basePath_centers, K)
%% Evaluations
close all
basePath_327 = '/home/zhi/Datasets/beam_direction/Experiment_20180105/327mm/';
f_evaluation_1D( basePath_327, B_K, 327 )