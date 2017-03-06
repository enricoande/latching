%% CLEAN UP
% clearvars;
% close all;
% N.B.: The model has been generated using the parameters given in:
% Clement and Babarit (2012). 'Discrete control of resonant wave energy 
% devices', Philosophical Transactions of the Royal Society A, 370.

%% SIMULATION SETUP
mdl.tStep = 0.001;  % time step length (s)
mdl.tEnd  = 400;    % end time (s)
mdl.tStart = 200;   % time for the start of the power averaging (s)
mdl.ff = 1/(10*20); % fundamental frequency (Hz) for averaging

%% WEC MODEL PARAMETERS
% Wave data file:
wave.dataFile = 'waves.mat';

% State-space System Matrices:
ss.dataFile = 'SS.mat';

%% CALCULATION
wave = updateWaves(wave);
ss   = updateSS(ss);
 
%% SUPPORT FUNCTIONS
% Update structure for wave excitation:
function waveNew = updateWaves(waveOld)
    waveNew = waveOld;      % make a copy
    load(waveNew.dataFile); % load wave dat
    waveNew.time = time;
    waveNew.elevation = elev;
    waveNew.excitation = excit;
    waveNew.dt = time(2)-time(1);
    
    % Remove the string so that the variable can be passed as a parameter:
    waveNew = rmfield(waveNew,'dataFile');
end

% Update structure for state-space system and other simulation parameters:
function ssNew = updateSS(ssOld)
    ssNew = ssOld;        % make a copy
    load(ssNew.dataFile); % load state-space system 

    % extract the multiplier to get the viscous drag force:
    ssNew.drag = drag;

    % extract the required matrices - state-space system:
    ssNew.A = A;
    ssNew.B = B;
    ssNew.C = eye(length(A));      %C;
    ssNew.D = zeros(size(B));      %D;
    
    % Remove the string so that the variable can be passed as a parameter:
    ssNew = rmfield(ssNew,'dataFile');
end