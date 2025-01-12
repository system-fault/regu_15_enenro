%% Integrador
s=tf('s');
G=1/s;
figure(1)
bode(G, {0.01, 100},'r')
grid on
%% Derivador
s=tf('s');
G=s;
figure(2)
bode(G, {0.01, 100},'r')
grid on