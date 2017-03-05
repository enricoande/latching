function [time,elevation,extelev] = regwaves(wave)
% irrwaves.m      E.Anderlini@ed.ac.uk     23/12/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function generates the wave elevation for regular waves.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialization:
N = wave.duration/wave.dt+1;   % tot. no. steps
nR = wave.rampdur/wave.dt+1;   % no. steps for initial ramp function
nH = length(wave.irf);         % no. steps of the IRF
time      = zeros(N,1);
elevation = zeros(N,1);
extelev   = zeros(N+(nH-1)/2,1);
omega = 2*pi/wave.period;      % circular wave frequency (rad/s)
amplitude = wave.height/2;     % wave amplitude (m)

%% Get the wave elevation:
for i=1:N
    time(i) = (i-1)*wave.dt;
    % Calculating the ramp function:
    if i <= nR
        Rf = 0.5 * (1+cos(pi+pi*i/nR));
    else
        Rf = 1;
    end
    % Calculating the wave elevation:
    elevation(i) = Rf * amplitude * sin(omega*time(i));
end

%% Get the extended wave elevation (for the diffraction convolution):
extelev(1:N) = elevation;

% Calculate the wave elevation for an additional time equal to half of the
% time of the impulse response function:
for i=(N+1):(N+(nH-1)/2)
    t = (i-1)*wave.dt;
    % Calculating the wave elevation:
    extelev(i) = Rf * amplitude * sin(omega*t);
end

% Extending the wave elevation to negative time as well for a time length
% equal to half of the time of the impulse response function:
tmp = fliplr(elevation(1:(nH-1)/2)); % mirroring the first portion of the wave elevation
extelev = [tmp;extelev];             % adding it to the time series before t=0 s

end