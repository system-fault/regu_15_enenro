%% Limpieza

close all;
clear;
clc;

%% Definicion del sistema

% Variable de Laplace
s =tf('s');
G = (550*(s+15))/((s+0.6)*(s+6)*(s+12));
H = 1;

% Obtén los datos del numerador y denominador
[num, den] = tfdata(G, 'v');

% Almacena los coeficientes en variables separadas
G_num = num;
G_den = den;

polos_LA = pole(G*H);
ceros_LA = zero(G*H);


%% Especificaciones

Mp = 1.5/100;
ts = 0.8;

xi = sqrt((log(Mp)^2)/(pi^2+log(Mp)^2));
Wn = (4)/(xi*ts);

%% Polos deseados

Pd1 = -xi*Wn + 1i * Wn * sqrt(1-xi^2);
Pd2 = -xi*Wn - 1i * Wn * sqrt(1-xi^2);

%% LGR Planta vs Polos deseados

figure('Name','LGR Planta');
rlocus(G*H);
axis([-15 1 -5 5]);
sgrid (xi,Wn);
title('LGR planta');

%% Diseno del controlador

% Parametro b
b_adelanto = abs(real(polos_LA(3)));

% Distancias

Pd1_real = abs(real(Pd1));
Pd1_imag = abs(imag(Pd1));

polo_LA_1_real = abs(real(polos_LA(1)));
polo_LA_2_real = abs(real(polos_LA(2)));
polo_LA_3_real = abs(real(polos_LA(3)));

% Angulos
theta1 = 180 - atan2d(Pd1_imag,Pd1_real-polo_LA_3_real);
theta2 = atan2d(Pd1_imag,polo_LA_2_real-Pd1_real);
theta3 = atan2d(Pd1_imag,polo_LA_1_real-Pd1_real);

% Criterio del argumento

critArg = 0 - (theta1+theta2+theta3);

alpha = -180-critArg;

fprintf('El angulo a aportar por el compensador es: %.4f\n',alpha);
disp('');

% Angulos del compensador

gamma = 180 - theta1;
betha = 180 - gamma - alpha;

% Distancias para calcular a_adelanto

h = (Pd1_imag)/(sind(betha));
y = cosd(betha)*h;

a_adelanto = y + Pd1_real;

G_comp_adelanto_sin_K = (s+b_adelanto)/(s+a_adelanto);

%% Ajuste de ganancia

% Ganancia rlocfind

[K_rlocfind,polos_LC] = rlocfind(G_comp_adelanto_sin_K*G*H,Pd1);

%% Representacion sistema controlado

figure('Name','Control 1 concelacion en -0.6');
rlocus(G_comp_adelanto_sin_K*G*H);
axis([-15 1 -5 5]);
sgrid (xi,Wn);
title('Controlador 1 cancelacion -0.6');
hold on;

%% Cancelacion en s = -6

% Parametro b2
b_adelanto2 = abs(real(polos_LA(2)));

% Angulos del compensador

gamma2 = 180 - theta2;
betha2 = 180 - gamma2 - alpha;

% Distancias para calcular a_adelanto

h2 = (Pd1_imag)/(sind(betha2));
y2 = cosd(betha2)*h;

a_adelanto2 = y2 + Pd1_real;

G_comp_adelanto_sin_K2 = (s+b_adelanto2)/(s+a_adelanto2);

% Ajuste de ganancia

% Ganancia rlocfind

[K_rlocfind2,polos_LC2] = rlocfind(G_comp_adelanto_sin_K2*G*H,Pd1);

% Representacion sistema controlado

figure('Name','Control 1 concelacion en -6');
rlocus(G_comp_adelanto_sin_K2*G*H);
axis([-15 1 -5 5]);
sgrid (xi,Wn);
title('Controlador 1 cancelacion -6');
hold on;


%% Funcion de transferencia LC compensador 1

fdt_LC = feedback(K_rlocfind*G_comp_adelanto_sin_K*G,H);

polos_LC = pole(fdt_LC);
ceros_LC = zero(fdt_LC);

%% Funcion de transferencia LC compensador 2

fdt_LC2 = feedback(K_rlocfind2*G_comp_adelanto_sin_K2*G,H);

polos_LC2 = pole(fdt_LC2);
ceros_LC2 = zero(fdt_LC2);


%% Respuesta de los dos sistemas ante respuesta escalon unitario

% Step

figure('Name','Respuesta ante entrada escalon unitario')

% Controlador 1
subplot(1,2,1);
step(fdt_LC,'b');
hold on;
% Referecias de interes
axis([0 1.5 -1 2]);
plot([-1 5],[1+Mp 1+Mp],'r--');
plot([-1 5],[1.2 1.2],'g--');
plot([-1 5],[0.98 0.98],'g--');
plot([ts ts],[-1 2],'k--');
title('Controlador 1 cancelacion -0.6');
hold on;

% Controlador 2
subplot(1,2,2);
step(fdt_LC2,'b');
hold on;
% Referecias de interes
axis([0 1.5 -1 2]);
plot([-1 5],[1+Mp 1+Mp],'r--');
plot([-1 5],[1.2 1.2],'g--');
plot([-1 5],[0.98 0.98],'g--');
plot([ts ts],[-1 2],'k--');
title('Controlador 2 cancelacion -6');


%% mas ganancia


figure('Name','Respuestas con diferentes ganancias');

% Configuración del subplot
ganancias = 15:2:25; % Factores de ganancia a usar
numGanancias = length(ganancias);

for i = 1:numGanancias
    % Calcular la ganancia
    factor = ganancias(i);
    ganancia = K_rlocfind2 * factor;
    fdt_temp = feedback(ganancia * G_comp_adelanto_sin_K2 * G, H);

    % Subplot para cada ganancia
    subplot(2, 3, i);
    step(fdt_temp);
    hold on;
    axis([0 1.5 -1 2]);
    plot([-1 5], [1 + Mp 1 + Mp], 'r--'); % Línea del sobreimpulso
    plot([-1 5], [1.02 1.02], 'g--');    % Tolerancia superior
    plot([-1 5], [0.98 0.98], 'g--');    % Tolerancia inferior
    plot([ts ts], [-1 2], 'k--');        % Línea del tiempo de asentamiento
    title(['Ganancia = ', num2str(ganancia)]);
end

sgtitle('Respuesta a escalón para diferentes ganancias');


% Incluiria una ganacia o implementaria un controlador PID, con la ganancia
% tendriamos que reconsiderar las especificaciones como el MP


%% Respuesta en frecuencia

% Control 1 cancelacion en -0.6

comp_1_lc = feedback(G_comp_adelanto_sin_K*G,H);

figure('Name','Control 1 cancelacion en -0.6')
subplot(1,2,1);
bode ( comp_1_lc );
grid on;
title('Bode');
hold on;

% Margen de Ganancia y Fase

% "Bode"
subplot(1,2,2);
margin(comp_1_lc);
grid on;

% Guarda valores
[MG, MF, wcg, wcf]=margin(comp_1_lc);

MG_db = 20*log10(MG);

anchoBanda1 = bandwidth (comp_1_lc);

fprintf('El MG es: %.4f\n',MG_db);
disp('');
fprintf('Wcg se encuentra en: %.4f rad/s\n',wcg);
disp('');
fprintf('El MF es: %.4f\n',MF);
disp('');
fprintf('Wcf se encuentra en: %.4f rad/s\n',wcf);
disp('');
fprintf('Ancho de banda 1: %.4f rad/s\n',anchoBanda1);
disp('');

% Crear el título con los valores calculados
titulo1 = sprintf('MG = %.2f dB, MF = %.2f°, Ancho de Banda = %.2f rad/s', ...
    MG_db, MF, anchoBanda1);
% Asignar el título a la gráfica
title(titulo1);


% Control 2 cancelacion en -6

comp_2_lc = feedback(G_comp_adelanto_sin_K2*G,H);

figure('Name','Control 2 cancelacion en -6')
subplot(1,2,1);
bode ( comp_2_lc );
grid on;
title('Bode');
hold on;

% Margen de Ganancia y Fase

% margin
subplot(1,2,2);
margin(comp_2_lc);
grid on;


% Guarda valores
[MG2, MF2, wcg2, wcf2]=margin(comp_2_lc);

MG_db2 = 20*log10(MG2);

anchoBanda2 = bandwidth (comp_2_lc);

% Crear el título con los valores calculados
titulo2 = sprintf('MG = %.2f dB, MF = %.2f°, Ancho de Banda = %.2f rad/s', ...
    MG_db2, MF2, anchoBanda2);
% Asignar el título a la gráfica
title(titulo2);

fprintf('El MG es: %.4f\n',MG_db2);
disp('');
fprintf('Wcg se encuentra en: %.4f rad/s\n',wcg2);
disp('');
fprintf('El MF es: %.4f\n',MF2);
disp('');
fprintf('Wcf se encuentra en: %.4f rad/s\n',wcf2);
disp('');
fprintf('Ancho de banda 2: %.4f rad/s\n',anchoBanda2);
disp('');


%% Resumen

fprintf('\n● El angulo a aportar por el compensador es: %.4f\n', alpha);
fprintf('\n● El MG es: %s\n', 'Inf');
fprintf('● Wcg se encuentra en: %s rad/s\n', 'Inf');
fprintf('● El MF es: %.4f\n', MF);
fprintf('● Wcf se encuentra en: %.4f rad/s\n', wcf);
fprintf('● Ancho de banda 1: %.4f rad/s\n\n', anchoBanda1);

fprintf('● El MG2 es: %s\n', 'Inf');
fprintf('● Wcg se encuentra en: %s rad/s\n', 'Inf');
fprintf('● El MF2 es: %.4f\n', MF2);
fprintf('● Wcf2 se encuentra en: %.4f rad/s\n', wcf2);
fprintf('● Ancho de banda 2: %.4f rad/s\n\n', anchoBanda2);

fprintf('● El sistema tiene un MG = infinito en los dos casos ya que la ganancia\n');
fprintf('  total del sistema controlado no disminuye en ningun momento de -180\n');
fprintf('  grados, podrian soportar aumentos de ganancia significativos sin llegar a\n');
fprintf('  la inestabilidad.\n\n');













                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    