function wavegen(wave)
% 23/01/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is used to pregenerate the waves. At the moment, only
% regular waves or irregular waves with either a Bretschneider or JONSWAP
% spectrum are supported.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Generate the desired waves:
switch wave.spectrum
    case 1     % Bretschneider spectrum, irregular waves
        % Calculate the spectral amplitude for each frequency:
        amplitude = bretschneider(wave);
        % Generate random phases:
        phi = randphase(wave);
        % Calculate the wave elevation:
        [time,elev,extelev] = irrwaves(wave,amplitude,phi);
        excit = getForce(wave,time,extelev);
    case 2     % JONSWAP spectrum, irregular waves
        % Calculate the spectral amplitude for each frequency:
        amplitude = jonswap(wave);
        % Generate random phases:
        phi = randphase(wave);
        % Calculate the wave elevation:
        [time,elev,extelev] = irrwaves(wave,amplitude,phi);
        excit = getForce(wave,time,extelev);
    otherwise  % regular waves 
        % Calculate the wave elevation:
        [time,elev,extelev] = regwaves(wave);
        excit = getForce(wave,time,extelev);
end

%% Store data to file:
save('input/waves.mat','time','elev','excit');

end