close all; clear all; clc

% Load the MAT file containing gridData
load('example_FullScanGrid.mat');

xIndex = 1;           % column in the grid (X axis)
yIndex = 3;           % row in the grid (Y axis)
measurementIndex = 5; % pick 1-10 

viewPoint(gridData, xIndex, yIndex, measurementIndex);
