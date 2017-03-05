function excitation = getForce(wave,time,elevation)
% getForce.m     E.Anderlini@ed.ac.uk     23/12/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is used to obtain the wave excitation force from the wave
% elevation and the diffraction impulse response function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialization:
N  = length(time);
nH = length(wave.irf);
excitation = zeros(size(time));

%% Obtain the wave excitation force:
for i=1:N
    tmp = wave.irf .* elevation(((nH-1)+i):-1:i); 
    excitation(i) = wave.dt * trapz(tmp);      
end

end