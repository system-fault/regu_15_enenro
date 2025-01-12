%% Limpieza

close all;
clear;
clc;

% formato lonf para coma flotante
format long;

%% Definicion sistema a controlar

% Variable de Laplace
s = tf('s');

K = 498.25;
T = 0.053;

G = (K)/(T*s+1);
H = 1;

[num,den] = tfdata(G*H,'v');


%% Definicion de parametros

h = 0.001;
Kp = 0.059788;
Ti = 0.006673;
b = 0;
Mw = 444.4444;

%% Parametros de la ecuacion en diferencias

A = Kp*(b+((h)/(2*Ti)));
B = Kp*(((h)/(2*Ti))-b);
C = Kp*(1+((h)/(2*Ti)));
D = Kp*(1-((h)/(2*Ti)));

%% Variables para simulink
% Paso de rpm a radianes/s
radianes = (2*pi)/(60);

