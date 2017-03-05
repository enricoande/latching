function plotSimData(logOut)
% plotSimData.m     E.Anderlini@ed.ac.uk     09/02/2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function plots the results of the latching control
% applied to the point absorber with an internal mass.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Extract the data:
t = logOut.getElement('state').Values.Time;
x = logOut.getElement('state').Values.Data;
elevation   = logOut.getElement('elevation').Values.Data;
x1          = x(:,1);
x2          = x(:,2);
v1          = x(:,3);
v2          = x(:,4);
latch       = logOut.getElement('latch').Values.Data;
excit       = logOut.getElement('exforce').Values.Data;
force       = logOut.getElement('PTOforce').Values.Data;
power       = logOut.getElement('ipower').Values.Data;
mean_power  = logOut.getElement('mpower').Values.Data;
energy      = logOut.getElement('energy').Values.Data;

%% Motions:
figure;
subplot(3,1,1);
plot(t,elevation,'-.');
hold on;
plot(t,x1,'--');
hold on;
plot(t,x2);
hold off;
ylabel('$x$, $\zeta$ (m)','Interpreter','Latex');
l=legend('$\zeta$','$x_1$','$x_2$','Location','SouthWest');
set(l,'Interpreter','Latex');
grid on;
subplot(3,1,2);
plot(t,v1,'--','Color',[0.8500,0.3250,0.0980]);
hold on;
plot(t,v2,'Color',[ 0.9290,0.6940,0.1250]);
ylabel('$\dot{x}$ (m/s)','Interpreter','Latex');
l=legend('$\dot{x}_1$','$\dot{x}_2$','Location','SouthWest');
set(l,'Interpreter','Latex');
grid on;
subplot(3,1,3);
plot(t,latch,'--','Color',[0.4940,0.1840,0.5560]);
xlabel('$Time (s)$','Interpreter','Latex');
ylabel('$u$','Interpreter','Latex');
grid on;
set(gcf,'color','w');

%% Force, power and energy:
figure;
subplot(3,1,1);
plot(t,excit,'--','Color',[0.3010,0.7450,0.9330]);
hold on;
plot(t,force,'Color',[0.6350,0.0780,0.1840]);
ylabel('$F$ (N)','Interpreter','Latex');
l=legend('wave','PTO','Location','SouthWest');
set(l,'Interpreter','Latex');
grid on;
subplot(3,1,2);
plot(t,power,'Color',[0.4660,0.6740,0.1880]);
hold on;
plot(t,mean_power,'--','Color',[0.6350,0.0780,0.1840]);  %,'LineWidth',2);
hold off;
ylabel('$P$ (W)','Interpreter','Latex');
l=legend('inst.','mean','Location','SouthWest');
set(l,'Interpreter','Latex');
grid on;
subplot(3,1,3);
plot(t,energy,'Color',[0.4940,0.1840,0.5560]);
xlabel('$Time (s)$','Interpreter','Latex');
ylabel('$E$ (J)','Interpreter','Latex');
grid on;
set(gcf,'color','w');

end