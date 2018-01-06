% In this experiment, it is the mirror rather than the light sours that rotates.
% This is for the reconstructed system.
%%
clc;
clear;
close all
%% calibration
basePath = '/home/zhi/Datasets/beam_direction/Experiment_20180103/190mm/';
[k,r] = f_calibration_1D(basePath);
