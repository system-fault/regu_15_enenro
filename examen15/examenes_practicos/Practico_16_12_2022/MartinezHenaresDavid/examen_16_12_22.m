%% Limpieza

close all;
clear;
clc;
% Numero en coma flotante largos
format long
%% Definimos es sistema a controlar 

% Definimos la variable de Laplace
s = tf('s');

% Funcion de tranferencia de la planta
G = (5)/(s*(s+5));
H = 1;

% Extraemos los coeficientes del num y den
[num,den] = tfdata(G,'v');
G_num = num;
G_den = den;

% Polos y ceros Lazo abierto
polos_LA = pole(G*H);
ceros_LA = zero(G*H);

%% Especificaciones

Mp = 2/100;
ts = 1;

%% Coeficiente de amortiguamiento y Frecuencia natural
xi = sqrt((log(Mp)^2)/(pi^2+log(Mp)^2));
Wn = (4)/(xi*ts);

%% Polos deseados

Pd1 = -xi*Wn + 1i * Wn*sqrt(1-xi^2);
Pd2 = -xi*Wn - 1i * Wn*sqrt(1-xi^2);

%% LGR Planta

figure('Name','LGR planta original');
rlocus(G*H);
axis([-7 1 -4 4]);
title('PLANTA');
xlabel('Parte real');
ylabel('Parte Imaginaria');
grid on;

%% Diseno del controlador

% Distania Pd1
Pd1_real = abs(real(Pd1));
Pd1_imag = abs(imag(Pd1));

% Definimos b_adelanto en la vertical de Pd1
b_adelanto = Pd1_real;

% Distancias polos LA
 polo_1_LA_real = abs(real(polos_LA(1)));
 polo_2_LA_real = abs(real(polos_LA(2)));

 % Angulos
 theta1 = 180 - atan2d(Pd1_imag,Pd1_real);
 theta2 = atan2d(Pd1_imag,polo_2_LA_real-Pd1_real);

 critArg = 0 - (theta2 + theta1);

 alpha = -180-critArg;
 
 fprintf('El angulo a aportar por el compensador es: %.2f grados\n', alpha);

 % Calculo de angulos necesarios para calcular a_adelanto

gamma = 90;
bheta = 180 - gamma - alpha;

h = (Pd1_imag)/(sind(bheta));
y = cosd(bheta)*h;

a_adelanto = y + Pd1_real;

G_comp_adelanto_sin_K = (s+b_adelanto)/(s+a_adelanto);

% Calculo de la ganancia

[K_rlocfind,polos_LC] = rlocfind(G_comp_adelanto_sin_K*G*H,Pd1);

%% REpresentacion sistema controlado

figure('Name','Sistema controlado');


subplot(1,2,1);
rlocus(G*H);
axis([-7 1 -6 6]);
title('Control con una K cualquiera');
xlabel('Parte real');
ylabel('Parte Imaginaria');
grid on;

% Sistema con controlador de adelanto
subplot(1,2,2);
fdt_lc = feedback(K_rlocfind*G_comp_adelanto_sin_K*G,H);
rlocus(fdt_lc);
axis([-7 1 -6 6]);
title('Sistema con controlador de adelanto');
xlabel('Parte real');
ylabel('Parte Imaginaria');
grid on;

polos_LC = pole(fdt_lc);
ceros_LC = zero(fdt_lc);

% Imprime los polos en lazo cerrado
fprintf('Los polos en lazo cerrado son:\n');
for i = 1:length(polos_LC)
    fprintf('Polo %d: %.4f + %.4fi\n', i, real(polos_LC(i)), imag(polos_LC(i)));
end

fprintf(['Las especificaciones aparentamente se cumpliran pero seria ' ...
    'necesario simular para confirmar\n'])
disp('');



%% Respuesta ante entrada escalon

figure('Name','Respuesta ante entrada escalon unitario');
step(fdt_lc,'b');
hold on;
axis([-0.1 3 -0.1 1.3]);
plot([-1 4],[1+Mp 1+Mp],'r');
plot([-1 4],[1.02 1.02],'g--');
plot([-1 4],[0.98 0.98],'g--');

%% Analisis ambito de la frecuencia

figure('Name','Analisis frecuencial');

% Diagrama de Bode
subplot(1,2,1);
bode(fdt_lc);
grid on;
title('Diagrama de Bode');
hold on;

% Margen de Ganancia y Fase

% "Bode"
subplot(1,2,2);
margin(fdt_lc);
grid on;
% Guarda valores
[MG, MF, wcg, wcf]=margin(fdt_lc);

MG_db = 20*log10(MG);

anchoBanda = bandwidth (fdt_lc);

fprintf('El MG es: %.4f\n',MG_db);
disp('');
fprintf('Wcg se encuentra en: %.4f rad/s\n',wcg);
disp('');
fprintf('El MF es: %.4f\n',MF);
disp('');
fprintf('Wcf se encuentra en: %.4f rad/s\n',wcf);
disp('');
fprintf('Ancho de banda 1: %.4f rad/s\n',anchoBanda);
disp('');

% Crear el título con los valores calculados
titulo = sprintf('MG = %.2f dB, MF = %.2f°, Ancho de Banda = %.2f rad/s', ...
    MG_db, MF, anchoBanda);
% Asignar el título a la gráfica
title(titulo);

% Atenuada unos 50 dB
% Retrasada unos 175 grados



%% Digitalizacion

h_digitalizacion = 0.006;


A = (2-(a_adelanto*h_digitalizacion))/(2+(a_adelanto*h_digitalizacion));
B = K_rlocfind*(2+(b_adelanto*h_digitalizacion))/(2+(a_adelanto*h_digitalizacion));
C = K_rlocfind*((b_adelanto*h_digitalizacion)-2)/(2+(a_adelanto*h_digitalizacion));










