function amplitude = jonswap(wave)
% jonswap.m     E.Anderlini@ed.ac.uk    29/11/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function returns the spectral amplitude for a JONSWAP
% spectrum and the given wave frequencies.
% For more information, see pp. 13-14:
% https://rules.dnvgl.com/docs/pdf/DNV/codes/docs/2012-12/RP-H103.pdf
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Changing the variable names for simplicity: 
f = wave.freq;
fp = 2*pi/wave.period;
Hs = wave.height;

% Store persistent parameters:
gamma = 3.3;
A = 5/16 * Hs^2 * fp^4;
A = A * (1-0.287 * log(gamma));
B = 5/4 * fp^4;

% Calculate other frequency-dependent parameters:
for i=1:length(f)
    if f(i) <= fp
        sigma(i) = 0.07;
    else
        sigma(i) = 0.09;
    end
end
Gamma = exp( -0.5.*((f/fp - 1) ./ sigma).^2);

% Calculate the wave spectrum:
S = A./f.^5 .* exp(-B./f.^4) .*gamma.^Gamma;

% Calculating the spectral amplitude:
dW = f(2)-f(1);
amplitude = sqrt(2*dW) .* sqrt(S); 

end