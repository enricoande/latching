function amplitude = bretschneider(wave)
% bretschneider.m     E.Anderlini@ed.ac.uk    29/11/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function returns the spectral amplitude for a Bretschneider
% spectrum and the given wave frequencies.
% For more information, see pp. 13-14:
% https://rules.dnvgl.com/docs/pdf/DNV/codes/docs/2012-12/RP-H103.pdf
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Changing the variable names for simplicity: 
f = wave.freq;
fp = 2*pi/wave.period;
Hs = wave.height;

% Store persistent parameters:
A = 5/16 * Hs^2 * fp^4;
B = 5/4 * fp^4;

% Calculate the wave spectrum:
S = A./f.^5 .* exp(-B./f.^4);

% Calculating the spectral amplitude:
dW = f(2)-f(1);
amplitude = sqrt(2*dW) .* sqrt(S); 

end