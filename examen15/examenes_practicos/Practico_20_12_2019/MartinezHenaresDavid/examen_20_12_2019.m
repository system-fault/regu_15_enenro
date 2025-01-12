%% Limpieza

close all;
clear;
clc;

% formato largo para coma flotante
format long;

%% definiciondel la variable de Laplace y sistema a controlar

% Variable de LAplace
s = tf('s');

% Planta
G = (3.4768)/(s*(s+1)*(s+2));
H = 1;

[num,den] = tfdata(G*H,'v');

polos_LA = pole(G*H);
ceros_LA = zero(G*H);

%% Especificaciones

% Originales
Mp_og = 31.1/100;
ts_og = 10.6;

xi_og = sqrt((log(Mp_og)^2)/(pi^2+log(Mp_og)^2));
Wn_og = (4)/(xi_og*ts_og);

Pd1_og = -xi_og * Wn_og + 1i * Wn_og * sqrt(1-xi_og^2);
Pd2_og = -xi_og * Wn_og - 1i * Wn_og * sqrt(1-xi_og^2);

% Especificaciones nuevas

Mp = 14.77/100;
ts = 8.547;

xi = sqrt((log(Mp)^2)/(pi^2+log(Mp)^2));
Wn = (4)/(xi*ts);

Pd1 = -xi * Wn + 1i * Wn * sqrt(1-xi^2);
Pd2 = -xi * Wn - 1i * Wn * sqrt(1-xi^2);


%% Controlador origina (og)

% Parametros originales
K_og = 1;
b_og = 1;
a_og = 1.697;

Gc_original_sin_K = (s+b_og)/(s+a_og);

%% Comprobacion control modificando la k original

figure('Name','LGR control original VS polos deseados');
subplot(1,2,1);
rlocus(Gc_original_sin_K*G*H);
hold on;
sgrid(xi_og,Wn_og);
plot([0 0],[-10 10],'k');
plot(real(Pd1_og),imag(Pd1_og),'r*','MarkerSize',5);
plot(real(Pd2_og),imag(Pd2_og),'r*','MarkerSize',5);
plot([-10 5],[(Wn_og*sqrt(1-xi_og^2)) (Wn_og*sqrt(1-xi_og^2))],'y--', ...
    'LineWidth',0.3);
plot([(-xi_og*Wn_og) (-xi_og*Wn_og)],[-10 10],'y--', ...
    'LineWidth',0.3);
xlabel('Parte Real');
ylabel('Parte Imaginaria');
title('LGR controlado VS Polos deseados OG');

subplot(1,2,2);
rlocus(Gc_original_sin_K*G*H);
hold on;
sgrid(xi,Wn);
plot([0 0],[-10 10],'k');
plot(real(Pd1),imag(Pd1),'r*','MarkerSize',5);
plot(real(Pd2),imag(Pd2),'r*','MarkerSize',5);
plot([-10 5],[(Wn*sqrt(1-xi^2)) (Wn*sqrt(1-xi^2))],'y--','LineWidth',0.3);
plot([(-xi*Wn) (-xi*Wn)],[-10 10],'y--','LineWidth',0.3);
xlabel('Parte Real');
ylabel('Parte Imaginaria');
title('LGR controlado VS Polos deseados');
hold off;

fprintf(['Las nuevas especificaciones se pueden satisfacer ajustando una' ...
    ' nueva ganancia.\n\n']);

%% Ajuste de la nueva ganancia

% Mantenenmos la fdt original del controlador pero sin su ganancia

% Calculamos una nueva ganancia para los nuevos polos deseados

[K_rlocfind, polos_LC] = rlocfind(Gc_original_sin_K*G*H,Pd1);

fprintf('Los polos en lazo cerrado son:\n');
for n=1:length(polos_LC)
    if imag(polos_LC(n))>=0
        fprintf('- Polo %.d: %.4f + %.4fi\n',n,real(polos_LC(n)),imag(polos_LC(n)));
    else
        fprintf('- Polo %.d: %.4f %.4fi\n',n,real(polos_LC(n)),imag(polos_LC(n)));
    end
        
end

%% Repuesta temporal ante entrada escalon

% Funcion de transferencia en lazo cerrado

fdt_lc = feedback(K_rlocfind*Gc_original_sin_K*G,H);

figure('Name','Respuesta ante escalon');
step(fdt_lc);
hold on;
plot([-0.1 20],[1+Mp 1+Mp],'r--','LineWidth',0.3);
plot([-0.1 20],[1.02 1.02],'g--','LineWidth',0.3);
plot([-0.1 20],[0.98 0.98],'g--','LineWidth',0.3);
plot([ts ts],[-0.1 2],'k-.','LineWidth',0.3);
titulo = sprintf('El Mp es: %.4f\n',(1+Mp));
title(titulo); 
hold off;


%% Analisis en el ambito de la frecuencia

figure('Name','Analisis frecuencial');

% Diagrama de bode
subplot(1,2,1);
bode(fdt_lc);
grid on;
hold on;
title('Diagrama de bode');

% Funcion margin
subplot(1,2,2);
margin(fdt_lc);
grid on;
hold off;
[MG,MF,wcg,wcf] = margin(fdt_lc);
MG_db = 20*log10(MG);

% Ancho de banda

anchoBanda = bandwidth(fdt_lc);

fprintf('\n- El margen de Ganancia es %.4f dB\n',MG_db);
fprintf('- La frecuencia wcg es %.4f rad/s\n',wcg);
fprintf('- El margen de Fase es %.4f grados\n',MF);
fprintf('- La frecuencia wcf es %.4f rad/s\n',wcf);
fprintf('- El ancho de banda es %.4f rad/s\n',anchoBanda);

fprintf(['\n- El sistema de control es estable ya que los margenenes de ' ...
    'ganancia y de fase son positivos, matlab avisa si el sistema ' ...
    'no es estable\n']);

%% Periodo de muestreo

% Tenemos una respuesta similar a un sistema de segundo orden por lo tanto
% usaremos esta expresion para calcular h expr: h = (2Pi)/(20*Wn);

h = (2*pi)/(20*Wn);











