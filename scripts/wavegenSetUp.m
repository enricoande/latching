%% CLEAN UP
% clearvars;
% close all;

%% Wave parameters:
wave.irfFile  = './input/irf.mat'; % diffraction impulse response function
wave.diffFile = './input/X.mat';   % diffraction coefficients
wave.duration = 1000;% time duration (s) - must be <15 minutes
wave.rampdur  = 50; % time duration (s) of the initial ramp function
wave.spectrum = 0;  % 0: regular waves
                    % 1: Bretschneider
                    % 2: JONSWAP
wave.height   = 1;  % significant wave height (m)
wave.period   = 10; % energy wave period (s)
wave.seed     = 0;  % seed value to the random number generator

%% Extract values:
wave = updateWave(wave);

%% Support function:
function waveNew = updateWave(waveOld)
    % Create a copy to remove possible errors:
    waveNew = waveOld;
    % Load the diffraction coefficients:
    load(waveOld.diffFile);
    % Store the circular wave frequencies:
    waveNew.freq = omega';
    % Load the impulse response function:
    load(waveOld.irfFile);
    waveNew.irf = H;
    waveNew.dt = dt;
end