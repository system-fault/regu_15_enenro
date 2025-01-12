%% Limpieza
close all;
clear;
clc;

%% Analisis de la planta
s = tf('s'); 
G = (25)/(s*(s^2+15*s+50));
H = 1;

% Extraemos polos y ceros de la fdt
polos_LA = pole(G*H);
ceros_LA = zero(G*H);

figure('Name','Lugar de las raices.');

% LGR planta original
subplot(1,2,1);
rlocus(G*H);
axis([-12 1 -10 10]);
grid on;
xlabel('Parte Real');
ylabel('Parte Imaginaria')
title('Lugar de las raices planta original');

%% Especificaciones y polos deseados

Mp = 4.33/100;
ts = 1.5;
ess = 0.5;
xi = sqrt((log(Mp)^2)/(pi^2+log(Mp)^2));
Wn = (4)/(xi*ts);

Pd1 = -xi * Wn + 1i * Wn * sqrt(1-xi^2);
Pd2 = -xi * Wn - 1i * Wn * sqrt(1-xi^2);

%% Comprobacion de los polos deseados con el LGR

subplot(1,2,2);
rlocus(G*H);
axis([-12 1 -10 10]);
sgrid(xi,Wn);
xlabel('Parte Real');
ylabel('Parte Imaginaria')
title('Lugar de las raices vs Polos deseados');

% Polos deseados
hold on;
plot(real([Pd1,Pd2]), imag([Pd1, Pd2]), 'r*','MarkerSize',10);
xline(0,'--k','LineWidth',0.5);
hold off;

% Comprobacion metodo del argumento

real_Pd1 = abs(real(Pd1));
imag_Pd1 = abs(imag(Pd1));

real_P1_La = abs(real(polos_LA(1)));
real_P2_La = abs(real(polos_LA(2)));
real_P3_La = abs(real(polos_LA(3)));

theta1 = 180-atan2d(imag_Pd1, real_Pd1);
theta2 = atan2d(imag_Pd1, real_P3_La-real_Pd1);
theta3 = atan2d(imag_Pd1, real_P2_La-real_Pd1);

% Criterio del argumento

critArg = 0-(theta1+theta2+theta3);

% Angulo a aportar por el compensador

alpha = -180-critArg;

fprintf('Angulo a aportar por el compensador: %.4f\n',alpha);
disp('');

%% Diseno compensador
% Metodo de la vertical

% b del compensador
b_adelanto = abs(real(Pd1));

% Angulos
gamma = 90;
betha = 180-gamma-alpha;

h = (imag_Pd1)/(sind(betha));
y = cosd(betha)*h;

% a del compensador

a_adelanto = y + real_Pd1;

G_comp_sin_K = (s+b_adelanto)/(s+a_adelanto);

%% Ajuste de ganancia

% Mediante rlocfind

[K_rlocfind,polos_LC_rlocfind] = rlocfind(G_comp_sin_K*G*H,Pd1);

% Mediante distancias

l1 = sqrt(real_Pd1^2 + imag_Pd1^2);
l2 = imag_Pd1;
l3 = sqrt((a_adelanto-real_Pd1)^2 + imag_Pd1^2);
l4 = sqrt((real_P3_La-real_Pd1)^2 + imag_Pd1^2);
l5 = sqrt((real_P2_La-real_Pd1)^2 + imag_Pd1^2);

K_total_manual = (l1*l3*l4*l5)/(l2);
K_manual = K_total_manual / 25;

%% Comprobacion ESS

% Tipo 1 ess = 1/Kv

KGH = K_rlocfind*G_comp_sin_K*G*H;

Kv = dcgain(s * KGH);

ess_1 = 1/Kv;

if ess_1 <= ess
    disp('El error es menor o igual al deseado en las especificiciones');
else
    disp(['El error es mayor que el deseado, se necesita compensador de ' ...
        'retraso']);
end

%% Diseno compensador de retraso

% Valores 
a_retraso = 0.01;
K_retraso = 1;

Kv_deseado = 1/ess;

b_retraso = (Kv_deseado*a_retraso*a_adelanto*50)/(K_rlocfind*real_Pd1*25);

G_comp_retraso= K_retraso*((s+b_retraso)/(s+a_retraso));


%% Comprobacion ESS

% Tipo 1 ess = 1/Kv

KGH2 = G_comp_retraso*K_rlocfind*G_comp_sin_K*G*H;

Kv2 = dcgain(s * KGH2);

ess_2 = 1/Kv2;

tolerancia = 1e-6; % Margen de tolerancia

if abs(ess_2 - ess) <= tolerancia
    disp('El error es menor o igual al deseado en las especificaciones');
else
    disp(['El error es mayor que el deseado, se necesita compensador de ' ...
        'retraso']);
end


%% Comprobacion del sistema aplciando el(los) compensadores

% Podemos comprobar de 3 formas los resultados
% a) Analisis de polos y ceros
% b) Funcion step()
% c) Mediante simulacion en Simulink

% a) Analisis de polos y ceros

% Utilizamos feedback para crear la fdt en lazo cerrado

fdt_LC = feedback(G_comp_retraso*K_rlocfind*G_comp_sin_K*G,H);

polos_LC = pole(fdt_LC);
ceros_LC = zero(fdt_LC);
disp(polos_LC);
disp(' ');
disp(ceros_LC);
disp(' ');

% b) Funcion step()

figure('Name','Test sistema de control');
step(fdt_LC,'b');
title('Respuesta entrada escalon');
hold on;

% Marcamos lineas de interes en el grafico
axis([0 3 0 1.3]);
plot([0 5],[1+Mp 1+Mp],'r--'); % Maximo sobre impulso premitido
plot([0 5],[1.02 1.02],'g--'); % Margen superior del 2%
plot([0 5],[0.98 0.98],'g--'); % Margen inferior del 2%
plot([ts ts],[0 2],'k--');   % Linea que marca ts

% Variables para la simulacion de simulink

final_escalon = 1;