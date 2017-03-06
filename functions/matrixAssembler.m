% matrixAssembler.m      E.Anderlini@ed.ac.uk     11/01/2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script is used to assemble the required state-space matrices.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
close all;

%% Input data:
m2 = 1e05;          % (kg)
k2 = 7e04;          % (N/m)
minf = 246192.085;  % (kg)
R = 5;              % (m)
T = 10;             % (m)
CD = 2;
tl = 0.1;           % (s)
ta = 0.1;           % (s)
rho = 1025;         % (kg/m3)
g = 9.81;           % (m/s2)
b2 = 1e04;          % (Ns/m)

%% Initialization:
% Load the state-space approximation of the radiation convolution:
load('../data/vcyl_MassDampStiffMatsRadSS.mat');
clear datascaler_in fit_errormax inv_reduced_mass_matrix max_omega ...
    max_real_e_value reduced_damping_matrix reduced_stiffness_matrix ...
    size_Arad;
n = size(sys.a,1);

% Calculate the remaining parameters:
Aw = R^2*pi;        % (m2)
vol = Aw*T;         % (m3)
m = vol*rho;        % (kg)

m1 = m-m2;          % (kg)
k1 = Aw*rho*g;      % (N/m)
G = (m2+minf)*80;   % (Ns/m)

drag = 0.5*CD*2*R*rho;% (kg/m2)

eff = 1;            % efficiency

m1minf = m1+minf;
m1m2minf = m1+m2+minf;

%% Calculate the state-space system matrices:
A = zeros(4+n);
B = zeros(4+n,2);
C = [eye(4),zeros(4,n)];
D = zeros(4,2);

% Complete the A matrix:
A(1,3) = 1;
A(2,4) = 1;
A(3,1) = -k1/m1minf;
A(3,2) = k2/m1minf;
A(3,4) = b2/m1minf;
A(3,5:end) = -sys.c/m1minf;
A(4,1) = k1/m1minf;
A(4,2) = -m1m2minf*k2/(m1minf*m2);
A(4,4) = -m1m2minf*b2/(m1minf*m2);
A(4,5:end) = sys.c/m1minf;
A(5:end,3) = sys.b;
A(5:end,5:end) = sys.a;

% Complete the B matrix:
B(3,1) = 1/m1minf;
B(3,2) = G/m1minf;
B(4,1) = -1/m1minf;
B(4,2) = -G*m1m2minf/(m1minf*m2);

% % For the time delay on the PTO and brake:
% Ad = [-1/tl,0;0,-1/ta];
% Bd = [G/tl,0;0,b2/ta];
% Cd = eye(2);
% Dd = zeros(2);

%% Store the data to file:
save('../data/ss.mat','A','B','C','D','drag','eff','b2','G');
% save('input/pto.mat','Ad','Bd','Cd','Dd');