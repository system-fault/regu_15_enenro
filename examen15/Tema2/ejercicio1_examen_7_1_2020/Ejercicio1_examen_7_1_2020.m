% Limpia el entorno
close all;
clear;
clc;

%% Análisis de la planta y LGR
% Definimos la variable de Laplace
s = tf('s');

% Definimos la planta
G = (1)/(10*s^2);
% Realimentación unitaria
H = 1;

% Polos y ceros en lazo abierto
polos_LA = pole(G*H);
ceros_LA = zero(G*H);

% Figura para el lugar de raíces
figure('Name', 'Lugar de las Raíces');

% Primer subplot: Lugar de raíces de la planta original
subplot(1, 2, 1);
rlocus(G*H);
axis([-5 1 -5 5]);
grid on;
xlabel('Parte Real');
ylabel('Parte Imaginaria');
title('Lugar de las raíces planta original');

%% Especificaciones y polos deseados
% Especificaciones
ts = 4;
Mp = 20.788 / 100;
ess = 0;
% Xi y Wn
xi = sqrt((log(Mp)^2) / (pi^2 + log(Mp)^2));
Wn = (4) / (xi * ts);

% Polos deseados
Pd1 = -xi * Wn + 1i * Wn * sqrt(1 - xi^2);
Pd2 = -xi * Wn - 1i * Wn * sqrt(1 - xi^2);

%% Comprobación de polos deseados en el LGR
% Segundo subplot: Lugar de raíces con polos deseados
subplot(1, 2, 2);
rlocus(G*H);
axis([-5 1 -5 5]); 
sgrid(xi, Wn); % Agregar especificaciones de xi y Wn
xlabel('Parte Real');
ylabel('Parte Imaginaria');
title('Lugar de Raíces VS Polos deseados');

% Añadir polos deseados
hold on;
plot(real([Pd1, Pd2]), imag([Pd1, Pd2]), 'r*', 'MarkerSize', 10);
xline(0, '--k', 'LineWidth', 0.5); % Línea en el eje imaginario
hold off;

% Comprobacion metodo del argumento

% Distancias
Pd1_real = abs(real(Pd1));
Pd1_imaginario = abs(imag(Pd1));

polo1_LA_real = abs(real(polos_LA(1)));


% Angulos 1 y 2 DOS CEROS!!
theta1 = 180-atan2d(Pd1_imaginario,Pd1_real);


% Criterio del argumento

critArg = (0-(theta1*2)); % Hay dos ceros en el mismo punto

fprintf('Criterio del argumento: %.4f\n',critArg);
disp('');

% Angulo a aportar por el compensador

alpha = -180-critArg;

fprintf('Angulo a aportar por el compensador: %.4f\n',alpha);
disp('');

%% Diseno compensador

% Metodo vertical

% Situamos el cero en -1
b_adelanto = 1;

% buscamos beta para poder trabajar con el triangulo
% gamma es el angulo opuesto a beta y alpha
gamma = 90;
beta = 180 - gamma - alpha;

% definimos h como la hipotenusa del triangulo
h = (Pd1_imaginario)/(sind(beta));
% definimos y como la base del triangulo
y = cosd(beta)*h;

% Calculamos la variable a de nuestro compensador

a_adelanto = y + Pd1_real;

G_adelanto_sin_K = (s+b_adelanto)/(s+a_adelanto)

%% Calculo de la ganancia

% Con rlocfind

[K_rlocfind, polos_LC_rlocfind] = rlocfind(G_adelanto_sin_K*G*H,Pd1);


% Criterio del modulo

% Distancias
% l2 seria igual a l3 ya que son polo y cero, necesitamos l1, l4 y l5
l1 = sqrt((Pd1_imaginario)^2+(Pd1_real)^2);
l2 = l1;
l3 = Pd1_imaginario;
l4 = h;

K_total = (l1*l2*l4)/(l3);
K_modulo = K_total*10;

%% Comprobacion Error ess

% Funcion tipo 2 error ess = 1/Ka

KGH = K_rlocfind*G_adelanto_sin_K*G*H;

Ka = dcgain(s^2 * KGH); %evalua cuadno s^2 tiende a cero

ess_1 = 1/Ka;

fprintf('El error ess es: %.4f\n', ess_1);
disp('');

%% Diseno compensador retraso

% En este caso no es necesario compensador de retraso

%% Comprobacion del sistema aplciando el(los) compensadores

% Podemos comprobar de 3 formas los resultados
% a) Analisis de polos y ceros
% b) Funcion step()
% c) Mediante simulacion en Simulink

% a) Analisis de polos y ceros

% Utilizamos feedback para crear la fdt en lazo cerrado

fdt_LC = feedback(K_rlocfind*G_adelanto_sin_K*G,H);

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