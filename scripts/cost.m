function pm = cost(sfile,tNow,xFinal,mdl,wave,ss,pto,l)
% cost.m      E.Anderlini@ed.ac.uk      06/03/2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function returns the mean generated power as cost function for the
% optimization of the latched mode duration.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize run:
nextDelatchTime = tNow+l;
assignin('base','c',2);
assignin('base','nextDelatchTime',nextDelatchTime);
set_param(sfile,'SimulationCommand','update');     

%% Run Simulink:
sout = sim(sfile,'StopTime',num2str(tNow+15),...
             'LoadInitialState','on','InitialState','xFinal');
% Extract the instantaneous power:
logsout = sout.get('logsout');
p = logsout.getElement('power').Values.Data;

%% Get the mean generated power (as cost):
pm = -mean(p);

end