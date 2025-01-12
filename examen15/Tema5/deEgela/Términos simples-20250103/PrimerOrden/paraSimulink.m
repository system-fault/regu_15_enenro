%% para simulink
wc=100*2*pi*50; 
T=1/wc;
wi=wc/100; %señal de entrada de 50Hz
wz=2*pi*28000; %señal de ruido 28K Hz
%% Término 1er orden
wc=100*2*pi*50; 
T=1/wc;
s=tf('s');
G=1/(T*s+1);
bode(G, {100, 1000000},'b')
hold on
plot([wi wi],[-40 0],'r')
plot([wz wz],[-40 0],'r')
grid on
