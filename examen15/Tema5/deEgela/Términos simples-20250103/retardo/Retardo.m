
s = tf('s')

% Retardo de un milisegundo
retardo = tf(1,1,'InputDelay',0.001);
bode(retardo,'r')
grid on