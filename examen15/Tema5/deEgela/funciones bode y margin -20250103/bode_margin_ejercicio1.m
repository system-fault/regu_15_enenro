clear all;close all;clc;

% Se desea analizar la estabilidad relativa de un sistema controlado cuya 
% función de tranferencia en lazo abierto es la siguiente:
% kGH(s) = 320*(s + 2)/[s*(s + 1)*(s^2 + 8*s + 64)]
s=tf('s')
kGH=320*(s + 2)/(s*(s + 1)*(s^2 + 8*s + 64))

% Otra forma de hacerlo:
% numerador = 320*[1 2];
% denominador = conv([1 1 0], [1 8 64]);
% 
% kGH=tf(numerador, denominador);
%-----
figure(1);
bode(kGH);grid on;
% Para analizar la estabilidad relativa, mejor emplear "margin" en lugar de
% "Bode"
figure(2);
margin(kGH);grid on;

%La función margin() también se puede emplear para guardar el MG, MG, wcg y
%wcf (en este orden)
[MG, MF, wcg, wcf]=margin(kGH)

%OJO! el margen de ganancia NO lo devuelve en decibelios, lo devuelve en unidades originales.

MG_db = 20*log10(MG)