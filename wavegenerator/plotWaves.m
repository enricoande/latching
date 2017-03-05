function plotWaves(time,elevation,excitation)
% plotWaves.m     E.Anderlini@ed.ac.uk     23/12/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is used to visualize the generated wave elevation and
% corresponding excitation force.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure;
subplot(2,1,1);
plot(time,elevation);
ylabel('$\zeta$ (m)','Interpreter','Latex');
grid on;
subplot(2,1,2);
plot(time,excitation,'Color',[0.8500,0.3250,0.0980]);
xlabel('Time (s)','Interpreter','Latex');
ylabel('$f_\mathrm{Ex}$ (N)','Interpreter','Latex');
grid on;
set(gcf,'color','w');

end