clear all; close all;clc;
% Robot pick and place 
s = tf('s')

compAdelanto = 25.4530*(s + 1)/(s + 7.1610);
planta = 2/(s*(s + 1)*(s + 4));
H = 1; % fdt de la realimentación

fdtLazoAbierto = compAdelanto*planta*H;



% Análisis de estabilidad del sistema controlado
figure
margin(fdtLazoAbierto) % Ver en figura
[MG MF wcg wcf] = margin(fdtLazoAbierto) % Almacenar en variables
% Esta función no proporciona el Margen de Ganancia en dB, esto
% es, 20log10(|fdtLazoAbierto|), proporciona directamente el
% valor del módulo. En este caso |fdtLazoAbierto|.
% wpc: frecuencia de cruce de fase
% wgc: frecuencia de cruce de ganancia


% Valores iniciales de Ka y T para la ejecución del modelo
Ka = 1;
T = 0.0;

%%
% "Jugamos" con la ganancia, introducimos una Ka.
% Cambiar para comprobar su efecto.

figure
margin(fdtLazoAbierto,'b')
hold on

Ka = MG/2;
hold on;
margin (Ka*fdtLazoAbierto,'g')

Ka = MG;
hold on;
margin (Ka*fdtLazoAbierto,'r')

Ka = 2*MG;
hold on;
margin (Ka*fdtLazoAbierto,'K')


legend('Original','Ka=MG/2','Ka=MG','Ka=MG*2')

%%
Ka = 1;
% Para "jugar" con la fase
% Mediante el bloque "Manual switch", podemos incluir un 
% término de retraso en la realimentación.

% Algunos cálculos. ¿Cuál debería de ser T (tiempo de retardo)
% para llevar al sistema al límite de la estabilidad?
% Hemos almacenado el MF original en la variable FT, también
% hemos almacenado en qué frecuencia se da, wcg.
% A esa frecuencia, si el término de retraso alcanzara el valor
% -FT, llevaríamos al sistema al límite de la estabilidad
% (oscilante)
% -wcg*T = -FT*pi/180
Toscilante = MF*pi/(180*wcf);
T = Toscilante;
%T = 2; % Si se desea, modificar el valor de T 
% para observar su efecto en la estabilidad.

T1 = T*0.5;
T2 = T
T3= T*1.5
retardo1=tf(1,1,'InputDelay',T*0.5)
retardo2=tf(1,1,'InputDelay',T)
retardo3=tf(1,1,'InputDelay',1.5*T)
figure; margin (fdtLazoAbierto,'b')
grid on;
set(gca,'XLim',[0.1 10])
set(gca,'YLim',[-360 -80])
hold on

margin (fdtLazoAbierto*retardo1,'g')
hold on
margin (fdtLazoAbierto*retardo2,'r')
hold on
margin (fdtLazoAbierto*retardo3,'k')

legend('Original','T=0.6/2','T=0.6','T=0.6*1.5')

%% % Comportamiento del sistema controlado (en lazo cerrado)
fdtLazoCerrado = feedback(compAdelanto*planta,H);
figure
bode(fdtLazoCerrado)
grid on
% Ancho de banda
AB = bandwidth(fdtLazoCerrado)