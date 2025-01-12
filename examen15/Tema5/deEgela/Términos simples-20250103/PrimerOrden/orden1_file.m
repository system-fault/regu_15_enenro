%% Término 1er orden
figure
wc=10; 
T=1/wc;
s=tf('s');
G=1/(T*s+1);
bode(G, {0.01, 10000},'r')
grid on
%% Inversa del término de 1er orden 
figure
wc=10; 
T=1/wc;
s=tf('s');
Ginv=(T*s+1);
bode(Ginv, {0.01, 10000},'r')
grid on
%% Comparativa término de 1er orden (en azul) y su inversa (en rojo) 
figure
wc=10; 
T=1/wc;
s=tf('s');
G=1/(T*s+1);
bode(G, {0.01, 10000},'b')
grid on
hold on 
Ginv=(T*s+1);
bode(Ginv, {0.01, 10000},'r')
legend('polo real','cero real')
