function phi = randphase(wave)
% randphase.m     E.Anderlini@ed.ac.uk     29/11/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function returns a vector with different random phases.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize the random number generator with a fixed seed:
rng(wave.seed);
% Generate the random numbers:
phi = 2*pi*rand(size(wave.freq));  %[0,2pi]

end
