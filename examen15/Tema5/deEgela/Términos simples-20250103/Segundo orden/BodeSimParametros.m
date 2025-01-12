
close all;
clc;
clear;

% frecuencia
f = 10; % Hz
wi = 2*pi*f % rad/s

%% SISTEMA DE PRIMER ORDEN

% Define T para el sistema de priemr orden
T = 0.2;

% Diagrama de Bode
s = tf('s')
sys = 1/(T*s+1)

%bode(sys)
%grid on

sysk = tf(1);
w=logspace(-2,3,100);
[I,F]=bode(sysk,w);
I_dB=20*log10(I(:)); 

w=logspace(-2,3,100);
[Irabazpena,Fasea]=bode(sys,w);
Irabazpena_dB=20*log10(Irabazpena(:)); 

figure("Name","Primer orden")
subplot(2,1,1);    
    semilogx(w,Irabazpena_dB,'r');
    hold on
    semilogx(w,I_dB,'k');
    axis([0.01 1000 -60 20])
    grid on
    set(gca,'ytick',[-60 -40 -20 0 20]);
    %plot([wi wi],[-60 20],'b')
    grid on
    title('Diagrama de Bode');
    ylabel('Ganancia (dB)');
subplot(2,1,2);
    semilogx(w,Fasea(:),'r');
    hold on
    semilogx(w,F(:),'k');
    axis([0.01 1000 -100 10])
    plot([wi wi],[-100 10],'b')
    grid on
    set(gca,'ytick',[-90 -45 0]);
    %set(gca,'YTicklabel','-180|-135|-90|-45|0');
    %grid on
    xlabel('Frecuencia (rad/s)'); 
    ylabel('Fase (\circ)');
% irabazia eta desfasea
%|KGH|
Anplitudea = 1/sqrt((T*wi)^2 + 1)
Desfasea = atan2(T*wi,1)*180/pi

%% Sisntema de Segundo orden1
% Sistema
f2 = 5000; % Hz
wn = 2*pi*f2; % rad/s
xi = 1/sqrt(2);
sys2 = wn^2/(s^2+2*xi*wn*s+wn^2);
wz = 2*pi*28000;

wn2 = 2*pi*10;
xi2 = 0.05
wr = wn2*sqrt(1-2*xi2^2); % Calculo de la freq de resonancia segun el 
                          % desarrollo de la derivada


sysk = tf(1);
w3=logspace(2,6,100);
[I2,F2]=bode(sysk,w3);
I_dB2=20*log10(I2(:)); 

w4=logspace(2,6,100);
[Gananacia2,Fase2]=bode(sys2,w4);
Gananacia_dB2=20*log10(Gananacia2(:)); 

figure('Name',"Sistema de segundo orden 1")
subplot(2,1,1);    
    semilogx(w4,Gananacia_dB2,'r');
    hold on
    semilogx(w4,I_dB2,'k');
    axis([100 1000000 -60 20])
    grid on
    set(gca,'ytick',[-60 -40 -20 0 20]);
    plot([wi wi],[-60 20],'b')
    plot([wz wz],[-60 20],'g')
    grid on
    title('Diagrama de Bode');
    ylabel('Ganancia (dB)');
subplot(2,1,2);
    semilogx(w4,Fase2(:),'r');
    hold on
    semilogx(w4,F2(:),'k');
    axis([100 1000000 -200 10])
    plot([wi wi],[-200 10],'b')
    plot([wz wz],[-200 10],'g')
    grid on
    set(gca,'ytick',[-180 -135 -90 -45 0]);
    %set(gca,'YTicklabel','-180|-135|-90|-45|0');
    %grid on
    xlabel('Frecuencia (rad/s)'); 
    ylabel('Fase (\circ)');
% irabazia eta desFase

%%
sys3 = wn2^2/(s^2+2*xi2*wn2*s+wn2^2);
sysk = tf(1);

w=logspace(0,5,1000);
[I,F]=bode(sysk,w);
I_dB=20*log10(I(:)); 

w=logspace(0,5,1000);
[Gananacia,Fase]=bode(sys3,w);
Gananacia_dB=20*log10(Gananacia(:)); 

figure('Name',"Sistema de segundo orden 2")
subplot(2,1,1);    
    semilogx(w,Gananacia_dB,'r');
    hold on
    semilogx(w,I_dB,'k');
    axis([1 10000 -60 30])
    grid on
    set(gca,'ytick',[-60 -40 -20 0 20]);
    plot([wr wr],[-60 30],'b')
    plot([wr/4 wr/4],[-60 30],'g')
    grid on
    title('Diagrama de Bode');
    ylabel('Ganancia (dB)');
subplot(2,1,2);
    semilogx(w,Fase(:),'r');
    hold on
    semilogx(w,F(:),'k');
    axis([1 10000 -200 10])
    plot([wr wr],[-200 10],'b')
    plot([wr/4 wr/4],[-200 10],'g')
    grid on
    set(gca,'ytick',[-180 -90 0]);
    %set(gca,'YTicklabel','-180|-135|-90|-45|0');
    %grid on
    xlabel('Frecuencia (rad/s)'); 
    ylabel('Fase (\circ)');
