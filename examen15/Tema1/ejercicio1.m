%% Ejercicio 1

close all;
clc;
clear;

%% Definicion de la Fdt

% Definimos la variable de Laplace
s = tf ('s');

% Definimos KGH
KGH = ((s+1)*(s+2))/(s^2*(s+3)*(s+4));

% Guardamos polos y ceros

polos = pole(KGH);
ceros = zero(KGH);

% Inicializamos la figura
figure('Name','LGR')

xlabel('Parte Real');
ylabel('Parte Imaginaria');
title('Lugar de Raíces con Asíntotas');
hold on;

% Calculo de asisntotas
% Rango
num_polos = length(polos);
num_ceros = length(ceros);
rango = num_polos - num_ceros;

% Inicializa vectores para los valores de los angulos de las asintotas
asintotas_rad = zeros(1,rango); % vector col=1 filas=rango
asintotas_grad = zeros(1,rango);

%calculo de las asistotas

for n = 0:(rango-1) % Itera desde 0 hasta rango-1

    % Calcula la asintota en radianes
    asintotas_rad(n+1) = ((2*n+1)*pi)/(rango); % matlab indices desde 1
    % Convertimos los radianes a grados
    asintotas_grad(n+1) = asintotas_rad(n+1) * (180/pi);
end

% Calculo del centroide
% Sumar los calores de los polos y los ceros
suma_polos = sum(polos);
suma_ceros = sum(ceros);
% Resta de sumas polos-ceros
polos_menos_ceros = suma_polos - suma_ceros;

% Centroide

if rango ~= 0 % si rango es diferente de cero
    centroide = polos_menos_ceros/rango;
else % Cuando rango == 0
    centroide = NaN;
    warning('El rango es cero, division entre cero evitada');
end

% Dibuja el centroide
plot(real(centroide), imag(centroide), 'o', 'MarkerSize', 5, ...
    'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k');

% Dibujado de las asintotas
for n = 0:(rango-1)
    % Calcula la direccion de la asintota
    angulo = asintotas_rad(n+1);
    % Ajusta la longitud de la asintota
    longitud_asintota = 15;

    % Calculo de las coordenadas iniciales de la asintota
    x_inicial = real(centroide);
    y_inicial = imag(centroide);

    % Calciulo de las coodenadas finales de la asintota
    x_final = x_inicial + longitud_asintota * cos(angulo);
    y_final = y_inicial + longitud_asintota * sin(angulo);
    

    % Dibujado de las asintotas
    plot([x_inicial, x_final], [y_inicial, y_final], 'g--', ...
        'LineWidth', 1.5);
    hold on;
end

% LGR
rlocus(KGH);
grid on; % Añadir cuadrícula
hold off;