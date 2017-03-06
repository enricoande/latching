%% CLEAN UP
% clearvars;
% close all;
% N.B.: The model has been generated using the parameters given in:
% Clement and Babarit (2012). 'Discrete control of resonant wave energy 
% devices', Philosophical Transactions of the Royal Society A, 370.

%% SIMULATION SETUP
mdl.tStep = 0.001;  % time step length (s)
mdl.tEnd  = 43400;  % end time (s)
mdl.tStart = 200;   % time for the start of the power averaging (s)
mdl.ff = 1/(10*15); % fundamental frequency (Hz) for averaging

%% WEC MODEL PARAMETERS
% Wave data file:
wave.dataFile = './input/waves.mat';

% State-space System Matrices:
ss.dataFile = './input/SS.mat';

% PTO Control Parameter:
pto.dataFile = './input/pto.mat';
pto.dmp  = 1e04;   % (Ns/m), see Clement & Babarit (2012)
pto.lat  = (1e05+246192.085)*80;
pto.eff  = 1;      % PTO efficiency, see Clement & Babarit (2012)

%% CALCULATION
wave = updateWaves(wave);
ss   = updateSS(ss,pto);
pto  = updatePTO(pto);
 
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
function ssNew = updateSS(ssOld,pto)
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

% Update structure for the PTO block:
function ptoNew = updatePTO(ptoOld)
    ptoNew = ptoOld;       % make a copy
    
    load(ptoOld.dataFile); % load the PTO state-space system
    
    % create the matrices for the calculation of the damping coefficients:
    ptoNew.A = Ad;
    ptoNew.B = Bd;
    ptoNew.C = Cd;
    ptoNew.D = Dd;
    
    % Remove the string so that the variable can be passed as a parameter:
    ptoNew = rmfield(ptoNew,'dataFile');
end