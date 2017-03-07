% optimalSetup.m      E.Anderlini@ed.ac.uk     07/03/2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script initializes the parameters required for the simulation of the
% point absorber with internal mass and optimal latching control.
%
% N.B.: The model has been generated using the parameters given in:
% Clement and Babarit (2012). 'Discrete control of resonant wave energy 
% devices', Philosophical Transactions of the Royal Society A, 370.
%
% This code has been adapted from the code by Gordon Parker at Michigan
% Technological University.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% SIMULATION SETUP
mdl.tStep = 0.005;  % time step length (s)
mdl.tEnd  = 400;    % end time (s)

%% WEC MODEL PARAMETERS
% Wave data file:
wave.dataFile = 'waves.mat';

% State-space System Matrices:
ss.dataFile1 = 'SS.mat';
ss.dataFile2 = 'SSl.mat';

%% CALCULATION
wave     = updateWaves(wave);
[pto,ss] = updateSS(ss);

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
function [pto,ssNew] = updateSS(ssOld)
    ssNew = ssOld;        % make a copy
    load(ssNew.dataFile1); % load state-space system for state vector
    load(ssNew.dataFile2); % load state-space system for costate vector
    
    % Generate the pto structure:
    pto.eff = eff;
    pto.b2  = b2;
    pto.G   = G;
    
    % extract the required matrices - state:
    ssNew.A = A;
    ssNew.B = B;
    ssNew.C = eye(length(A));
    ssNew.D = zeros(size(B));
    
    % extract the required matrices - costate:
    ssNew.Al = Al;
    ssNew.Bl = Bl;
    ssNew.Cl = eye(length(Al));
    ssNew.Dl = zeros(size(Bl));
    
    % Remove the strings so that the variable can be passed as a parameter:
    ssNew = rmfield(ssNew,'dataFile1');
    ssNew = rmfield(ssNew,'dataFile2');
end