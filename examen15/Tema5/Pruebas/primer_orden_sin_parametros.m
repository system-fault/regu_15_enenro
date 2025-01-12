% frecuencia
f = 50; % Hz
wi = 2*pi*f; % rad/s

% Sistema
T = 0.2;

% Diagrama de Bode
s = tf('s');
sys = 1/(T*s+1);

%bode(sys)
%grid on

sysk = tf(1);
w = logspace(-2, 3, 100);
[Ganancia_sysk, Fase_sysk] = bode(sysk, w);
Ganancia_sysk_dB = 20*log10(Ganancia_sysk(:)); 

[Ganancia_sys, Fase_sys] = bode(sys, w);
Ganancia_sys_dB = 20*log10(Ganancia_sys(:)); 

figure;
% Gráficas de Ganancia y Fase para sys
subplot(2,2,1);    
semilogx(w, Ganancia_sys_dB, 'r', 'DisplayName', 'Ganancia sys');
axis([0.01 1000 -60 20]);
grid on;
set(gca,'ytick',[-60 -40 -20 0 20]);
title('Ganancia sys');
ylabel('Ganancia (dB)');
legend('show');

subplot(2,2,3);
semilogx(w, Fase_sys(:), 'r', 'DisplayName', 'Fase sys');
axis([0.01 1000 -100 10]);
grid on;
set(gca,'ytick',[-90 -45 0]);
xlabel('Frecuencia (rad/s)'); 
ylabel('Fase (\circ)');
legend('show');

% Gráficas de Ganancia y Fase para sysk
subplot(2,2,2);    
semilogx(w, Ganancia_sysk_dB, 'k', 'DisplayName', 'Ganancia sysk');
axis([0.01 1000 -60 20]);
grid on;
set(gca,'ytick',[-60 -40 -20 0 20]);
title('Ganancia sysk');
ylabel('Ganancia (dB)');
legend('show');

subplot(2,2,4);
semilogx(w, Fase_sysk(:), 'k', 'DisplayName', 'Fase sysk');
axis([0.01 1000 -100 10]);
grid on;
set(gca,'ytick',[-90 -45 0]);
xlabel('Frecuencia (rad/s)'); 
ylabel('Fase (\circ)');
legend('show');

% Cálculo de Amplitud y Fase
Anplitudea = 1/sqrt((T*wi)^2 + 1);
Desfasea = atan2(T*wi, 1) * 180/pi;