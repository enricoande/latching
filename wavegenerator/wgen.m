clear;
close all;

%% Load the input data:
load('../input/waves.mat');

%% Set the new data:
tEnd = 500.0;
tStep = 0.0005;

%% Run Simulink:
options = simset('SrcWorkspace','current');
[t,~,data] = sim('wvgen',tEnd,options);

%% Store the new data to file:
time = t;
elev = data(:,3);
excit = data(:,2);
save('../input/waves2.mat','time','elev','excit');