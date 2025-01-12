%% Limpieza

close all;
clear;
clc;

% Formato largo para coma flotante
format long;

%% Defginicion de la variable de laplace y el sistema a controlar

% Variable de Laplace
s = tf('s');

% Valores dados
K = 2.5;
T = 0.25;
% Planta
G = (K)/(s*(T*s + 1));
H = 1;

[num,den] = tfdata(G,'v');

polos_LA = pole(G*H);
ceron_LA = zero(G*H);

%% Especificaciones

xi = 0.5912;
Mp = 100 * (exp((-xi*pi)/(sqrt(1-xi^2))));

ts = 0.2;
Wn = (4)/(xi*ts);

% Polos deseados
Pd1 = -xi*Wn + 1i * Wn * sqrt(1-xi^2);
Pd2 = -xi*Wn - 1i * Wn * sqrt(1-xi^2);

%% Comprobacion grafica posibilidad de regular con una K

figure('Name','LGR VS Polos Deseados');
rlocus(G*H);
sgrid(xi,Wn);
axis([-21 1 -30 30]);
hold on;
plot([real(Pd1) real(Pd2)],[imag(Pd1) imag(Pd2)],'r*', 'MarkerSize', 5, ...
    'LineWidth', 1)
title('LGR VS POLOS DESEADOS');
xlabel('PARTE REAL');
ylabel('PARTE IMAGINARIA');

% Se ve en el grafico que no podrias situar los polos sobre el LGR con una
% simple gangncia ya que las ramas estan situadas en -2 y los polos
% deseados en -20, hay ue modificar el LGR para que las ramas pasen por los
% polos deseados

%% Diseno compensador de adelanto

% Distancias
Pd1_real = abs(real(Pd1));
Pd1_imag = abs(imag(Pd1));

b_adelanto = Pd1_real;

alpha = 66.62418;
gamma = 90;
bheta = 180-gamma-alpha;

h = (Pd1_imag)/(sind(bheta));
y = cosd(bheta) * h;

a_adelanto = y + Pd1_real;

% FDT compensador

G_com_Adelanto_sin_K = (s + b_adelanto)/(s + a_adelanto);

% Ajuste de ganancia

[K_rlocfind,polos_lc_rlocfind] = rlocfind(G_com_Adelanto_sin_K*G*H,Pd1);

fdt_LC = feedback(K_rlocfind*G_com_Adelanto_sin_K*G,H);

ceros_LC = zero(fdt_LC);

fprintf('Los polos en lazo cerrado son;\n');
for n=1:length(polos_lc_rlocfind)
    fprintf('Polo %d: %.4f + %.4fi\n', n, real(polos_lc_rlocfind(n)), imag(polos_lc_rlocfind(n)));
end

fprintf('\n');

fprintf('Los ceros en lazo cerrado son;\n');
for n=1:length(ceros_LC)
    fprintf('Cero %d: %.4f + %.4fi\n', n, real(ceros_LC(n)), imag(ceros_LC(n)));
end
fprintf('\n');
% A la vista de los polos y ceros que se calculan en lazo cerrado creoq ue
% si se cumpliran la especificaciones porque los polos deseados parecen ser
% domianntes sobre el tercer polo de -47.1288 + 0i

%% Eleccion del periodo de muestreo

% Tenemos una respuesta con sobre impulso asi que es similar a una
% respuesta de un sistema de segundo orden por ello usamos h = 2pi/20Wn

h_digitalizacion = (2*pi)/(20*Wn);

%% Analisis en el ambito de la frecuencia

figure('Name','Respuesta ambito de la frecuencia');
margin(fdt_LC);
[MG,MF, wcg, wcf] = margin(fdt_LC);
anchoBanda = bandwidth(fdt_LC);

MG_dB = 20*log10(MG);
fprintf('El MG es: %.4f dB\n',MG_dB);
fprintf('La wcg: %.4f rads/s\n',wcg);
fprintf('El MF es: %.4f grados\n',MF);
fprintf('La wcf: %.4f rads/s\n',wcf);
fprintf('El ancho de banda es: %.4f rads/s\n',anchoBanda);


