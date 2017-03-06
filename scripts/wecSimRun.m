% wecSimRun.m     E.Anderlini@ed.ac.uk     06/03/2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is used to run latching control of the point absorber.
% At the end of each half of a wave cycle, the following data are stored:
% * time stamp;
% * wave amplitude;
% * excitation force amplitude;
% * root mean squared excitation force;
% * duration of the averaging period (from v=0 to v=0);
% * time from start to peak of the excitation force;
% * latched mode duration;
% * x amplitude;
% * v amplitude;
% * root mean squared x;
% * root mean squared v;
% * mean generated power.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Clean Up:
clearvars;
close all;

%% Suppress Warning
warning('off', 'Simulink:SimState:SimStateParameterChecksumMisMatch');

%% Generate the waves:
% % Run the set-up file:
% wavegenSetUp;   % change parameters in this file
% % Generate the waves
% wavegen(wave);
% As an alternative, load pregenerated data:
load('waves.mat');
% % Uncomment for debugging:
% plotWaves(time,elev,excit);

%% Initialization:
% Run the set-up file:
wecSimSetup;
% Determine the maximum no. steps:
n = mdl.tEnd/mdl.tStep+1;
% Initialize a structure for holding accumulated data:
data.t  = nan(n,1);    % time (s)
data.y  = nan(n,6);    % states
data.l  = nan(n,2);    % latching signal
data.f  = nan(n,2);    % PTO & wave excitation force (N)
data.el = nan(n,1);    % wave elevation (m)
data.p  = nan(n,2);    % instantaneous & mean power (W)
data.e  = nan(n,1);    % energy (J)

% Initialize the latched mode duration:
l = 0;

% Activate the stop block:
c = 0.1;

tic;
%% Load the Simulink file:
% Simulink file:
sfile = 'wecSim';
% Load the Simulink file:
load_system(sfile);

%% Setup Fast Restart and run first shot:
set_param(sfile,'FastRestart','on');
set_param(sfile,'SaveFinalState','on');
set_param(sfile,'SaveCompleteFinalSimState','on');
set_param(sfile,'SimulationCommand','update');

% Run the first shot:
sout = sim(sfile,'StopTime',num2str(mdl.tEnd));

% Snatch data:
logsout = sout.get('logsout');
t = logsout.getElement('state').Values.Time;
y = logsout.getElement('state').Values.Data;
f = [logsout.getElement('PTOforce').Values.Data,logsout.getElement('exforce').Values.Data];
el = logsout.getElement('elevation').Values.Data;
p = [logsout.getElement('ipower').Values.Data,logsout.getElement('mpower').Values.Data];
en = logsout.getElement('energy').Values.Data;

s = 1;
% Grab the time at which the simulation stopped due to a zero crossing:
tNow = t(end);
e = round(tNow/mdl.tStep)+1;

% Accumulate data:
data.t(s:e)   = t;
data.y(s:e,:) = y;
data.l(s:e,:) = l*ones(length(t),1);    
data.f(s:e,:) = f;
data.el(s:e)  = el; 
data.p(s:e,:) = p;
data.e(s:e)   = en;  

% Store data required for machine learning analysis:
[m,i] = max(abs(f(:,2)));
store = [tNow,max(abs(el)),m,rms(f(:,2)),t(end)-t(1),t(i)-t(1),l,...
max(abs(y(:,1))),max(abs(y(:,2))),rms(y(:,1)),rms(y(:,2)),mean(p(:,1))];

%% Loop until done:
while tNow < mdl.tEnd
    % Snatch simstate:
    assignin('base', 'xFinal', sout.get('xFinal'));
    
    %% Find the optimal PTO coefficients:
    % Specify the limits of the PTO coefficients:
    lb = 0;
    ub = 5; 
    % Set the initial values:
    x0 = 0;
    % Find the optimal PTO coefficients:
    fun = @(x)cost(sfile,tNow,xFinal,mdl,wave,ss,pto,x);
    options = optimoptions('fmincon','Display', 'off');
    l = fmincon(fun,x0,[],[],[],[],lb,ub,[],options);

    %% Continue marching along:
    % Activate the stop block:
    c = 0.1;
    % Update parameters and run:
    set_param(sfile,'SimulationCommand','update'); 
    
    sout = sim(sfile,'StopTime',num2str(mdl.tEnd),...
        'LoadInitialState','on','InitialState', 'xFinal');

    % Snatch data:
    logsout = sout.get('logsout');
    t = logsout.getElement('state').Values.Time;
    y = logsout.getElement('state').Values.Data;
    f = [logsout.getElement('PTOforce').Values.Data,logsout.getElement('exforce').Values.Data];
    el = logsout.getElement('elevation').Values.Data;
    p = [logsout.getElement('ipower').Values.Data,logsout.getElement('mpower').Values.Data];
    en = logsout.getElement('energy').Values.Data;

    s = e+1;
    % Grab the time at which the simulation stopped due to a zero crossing:
    tNow = t(end);
    e = round(tNow/mdl.tStep)+1;

    % Accumulate data:
    data.t(s:e)   = t;
    data.y(s:e,:) = y;
    data.c(s:e,:) = l*ones(length(t),1);    
    data.f(s:e,:) = f;
    data.el(s:e)  = el; 
    data.p(s:e,:) = p;
    data.e(s:e)   = en;

    % Store data required for machine learning analysis:
    [m,i] = max(abs(f(:,2)));
    store = [tNow,max(abs(el)),m,rms(f(:,2)),t(end)-t(1),t(i)-t(1),l,...
    max(abs(y(:,1))),max(abs(y(:,2))),rms(y(:,1)),rms(y(:,2)),mean(p(:,1))];
end

%% Close the Simulink file:
set_param(sfile,'FastRestart','off');
close_system(sfile);
toc;

%% Post-processing:
% Plot the results
plotData(data);