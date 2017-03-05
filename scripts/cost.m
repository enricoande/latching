function pm = cost(sfile,tNow,xFinal,mdl,wave,ss,pto,coeffs)
% cost.m      E.Anderlini@ed.ac.uk      03/03/2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function returns the mean generated power as cost function for the
% optimization of the PTO coefficients.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize run:
assignin('base', 'b', coeffs(1));
assignin('base', 'k', coeffs(2));
assignin('base', 'c', 2.0);
set_param(sfile,'SimulationCommand','update');     

%% Run Simulink:
% set_param(sfile,'StartTime',num2str(tNow));
sout = sim(sfile,'StopTime',num2str(tNow+15), ...
             'LoadInitialState','on','InitialState','xFinal');
% Extract the instantaneous power:
logsout = sout.get('logsout');
p = logsout.getElement('ipower').Values.Data;

%% Get the mean generated power (as cost):
pm = -mean(p);

end