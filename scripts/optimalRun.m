% optimalRun.m     E.Anderlini@ed.ac.uk     07/03/2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is used to run optimal latching control of the point absorber
% using Pontryagin's principle with forward integration of the state vector
% and backward integration of the costate vector.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Clean Up:
clearvars;
close all;

%% Suppress Warning
warning('off', 'Simulink:SimState:SimStateParameterChecksumMisMatch');

%% Initialization:
% Run the set-up file:
optimalSetup;
% Getting the lenght of the vectors:
n = mdl.tEnd/mdl.tStep+1;
% Initializing the control vector:
tu = wave.time(1:n);
u  = zeros(n,1);
% Initialize a structure for holding accumulated data:
data.t  = nan(n,1);    % time (s)
data.y  = nan(n,8);    % states
data.l  = nan(n,1);    % latching signal
data.f  = nan(n,2);    % PTO & wave excitation force (N)
data.el = nan(n,1);    % wave elevation (m)
data.p  = nan(n,2);    % instantaneous & mean power (W)
data.e  = nan(n,1);    % energy (J)

tic;
%% Load the Simulink files:
% Simulink files:
ffile = 'forward';
bfile = 'backward';
% Load the Simulink files:
load_system(ffile);
load_system(bfile);

%% Run Simulink:
% Run the first shot:
sout = sim(ffile,'StopTime',num2str(mdl.tEnd));
% Extract the velocity vector:
v2 = logsout.getElement('state').Values.Data(:,4);



toc;

%% Post-processing:
% Snatch data:
logsout = sout.get('logsout');
t  = logsout.getElement('state').Values.Time;
y  = logsout.getElement('state').Values.Data;
f  = logsout.getElement('exforce').Values.Data;
el = logsout.getElement('elevation').Values.Data;
p =  logsout.getElement('power').Values.Data;
en = logsout.getElement('energy').Values.Data;
% Accumulate data:
data.t      = t;
data.y      = y;
data.l      = u;    
data.f(:,2) = f;
data.el     = el; 
data.p(:,1) = p;
data.e      = en;  
% Calculate the PTO force:
data.f(:,1) = data.y(:,4).*(pto.b2+data.l*pto.G);
% Calculate the mean power:
b = (1/20*mdl.tStep)*ones(1,20/mdl.tStep);
a = 1;
data.p(:,2) = filter(b,a,p);

% Plot the results
plotData(data);