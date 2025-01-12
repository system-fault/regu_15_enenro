%% Limpieza

close all;
clear;
clc

% Formato largo para coma flotante
format long;

%% Definicion del plano s y sistema a controlar

% Variable de Laplace
s = tf('s');
% Panta
% Datos
K_h = 11.4;
p1 = 1.4;
% FDT
G = (K_h)/(s*(s + p1));
%Realimantecion
H = 1;

[num, den] = tfdata(G,'v');

G_num = num;
G_den = den;

% Polos Lazo abierto
polos_LA = pole(G*H);
ceros_LA = zero(G*H);

figure('Name','LGR Planta');
rlocus(G*H);
grid on;
hold on;
xlabel('Parte real');
ylabel('Parte Imaginaria');
title('LGR PLANTA');
hold off;

%% Especificaciones

Mp = 10/100;
ts = 0.6;

% Coefic. xi y Wn
xi = sqrt((log(Mp)^2)/(pi^2 + log(Mp)^2));
% Xi sin sobre impulso
% xi = 1;
Wn = (4)/(xi*ts);

% Polos deseados
Pd1 = -xi*Wn + 1i * Wn * sqrt(1-xi^2);
Pd2 = -xi*Wn - 1i * Wn * sqrt(1-xi^2);

%% Parametros controlador

Kp = (Wn^2)/(K_h);
Td = (2*xi*Wn-p1)/(K_h*Kp);

G_PD = Kp * (1 + Td*s);

%% Comprobacion dominio de la frecuencia

fdt_lc = feedback(G_PD*G,H);

figure('Name','Analisis dominio de la frecuencia');
margin(fdt_lc);
hold on;
grid on;
title('Respuesta en frecuencia PD');
hold on;

[MG, MF, wcg, wcf] = margin(fdt_lc);

MG_dB = 20*log10(MG);

anchoBanda = bandwidth(fdt_lc);

fprintf('- El margen de ganancia es: %.2f dB.\n',MG_dB);
fprintf('- La wcg esta en: %.2f rad/s.\n',wcg);
fprintf('- El margen de fase es: %.2f grados.\n',MF);
fprintf('- La wcg esta en: %.2f rad/s.\n',wcf);
fprintf('- El ancho de banda es: %.2f rad/s.\n\n',anchoBanda);

%% Respuesta ante entrada escalon

figure('Name','Respuesta PD');
step(fdt_lc ,'b');
title('Respuesta ante entrada escalon PD');
hold on;
plot([-1 5],[1+Mp 1+Mp],'r');

%% Controlador alternativo

K_alter = -11.156;
b_alter = 1.4;
a_alter = 13.3333;

G_comp_alter_sin_K = (s + b_alter)/(s + a_alter);

figure('Name',"LGR Control alternativo");
rlocus(G_comp_alter_sin_K*G);
grid on;
hold on;

G_comp_alter = K_alter*((s + b_alter)/(s + a_alter));

fdt_lc_alter = feedback(G_comp_alter*G,H);

polos_lc_alter = pole(fdt_lc_alter);
ceros_lc_alter = zero(fdt_lc_alter);

num_polos = length(polos_lc_alter);

fprintf('Los polos en lazo cerrado alternativo son:\n');
for n = 1:num_polos
    fprintf('Polo %d: %.4f + %.4fi\n', n, real(polos_lc_alter(n)), imag(polos_lc_alter(n)));
end

fprintf('Los polos no son los deseados\n\n');

%% Comprobacion K alternativa

[K_rlocfind,polos_lc_rlocfind] = rlocfind(G_comp_alter_sin_K*G*H,Pd1);

fdt_lc_alter_modificada = feedback(K_rlocfind*G_comp_alter_sin_K*G,H);

fprintf('Los polos en lazo cerrado alternativo modificado son:\n');
for n = 1:length(polos_lc_rlocfind)
    fprintf('Polo %d: %.4f + %.4fi\n', n, real(polos_lc_rlocfind(n)), imag(polos_lc_rlocfind(n)));
end

fprintf('Los polos son los deseados\n\n');




%% Comprobacion dominio de la frecuencia


figure('Name','Analisis dominio de la frecuencia controlador alternativo');
margin(fdt_lc_alter_modificada);
hold on;
grid on;
title('Respuesta en frecuencia controlador alternativo');
hold on;

[MG_alt, MF_alt, wcg_alt, wcf_alt] = margin(fdt_lc_alter_modificada);

MG_dB_alt = 20*log10(MG_alt);

anchoBanda_alt = bandwidth(fdt_lc_alter_modificada);

fprintf('- El margen de ganancia es: %.2f dB.\n',MG_dB_alt);
fprintf('- La wcg esta en: %.2f rad/s.\n',wcg_alt);
fprintf('- El margen de fase es: %.2f grados.\n',MF_alt);
fprintf('- La wcg esta en: %.2f rad/s.\n',wcf_alt);
fprintf('- El ancho de banda es: %.2f rad/s.\n\n',anchoBanda_alt);


%% Respuesta ante entrada escalon controlador alternativo

figure('Name','Respuesta alternativa modificada');
step(fdt_lc_alter_modificada ,'r');
hold on;
plot([-1 5],[1+Mp 1+Mp],'b');
title('Respuesta ante entrada escalon diseno alternativo');
hold on;

%% Digitalizacion

% h_digitalizacion (periodo de muestreo)
% Sistema con una respuesta similar a un sistema de segundo orden h =
% 2pi/20Wn

h_digitalizacion = (2*pi)/(20*Wn);

bheta = 0;


A = Kp*((1+((2*bheta*Td)/(h_digitalizacion))));
B = Kp*((1-((2*bheta*Td)/(h_digitalizacion))));
C = Kp*((1+((2*Td)/(h_digitalizacion))));
D = Kp*((1-((2*Td)/(h_digitalizacion))));

%% Conclusion

% Vista la senal de control del sistema digitalizado usando la variante pd
% no se logra eliminar por completo el sobre impulso, el diseno alternativo
% con el metodo de cancelacion cero-polo si conseguia cumplir ante entrada
% escalon digitalizando ese controlador podrian cumplirse las
% especificaciones.

