function c = cost(sfile,tNow,xFinal,mdl,wave,ss,pto,l)
% cost.m      E.Anderlini@ed.ac.uk      06/03/2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function returns the mean generated power as cost function for the
% optimization of the latched mode duration.
% N.B.: Instead of optimizing for the power, I optimize for the latching
% time that results in a response with a peak closest to that of the peak
% of the predicted excitation force.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize run:
nextDelatchTime = tNow+l;
assignin('base','nextDelatchTime',nextDelatchTime);
set_param(sfile,'SimulationCommand','update');     

%% Run Simulink:
sout = sim(sfile,'StopTime',num2str(tNow+10),...
             'LoadInitialState','on','InitialState','xFinal');
% Extract the excitation force and the velocity of body 2:
logsout = sout.get('logsout');
f   = logsout.getElement('exforce').Values.Data;
v2  = logsout.getElement('state').Values.Data(:,4);
% Find the maximum position:
[~,iF] = max(abs(f));
[~,iV] = max(abs(v2));

%% Get the mean generated power (as cost):
c = abs(iF-iV);

end