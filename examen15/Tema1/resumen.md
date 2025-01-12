Resumen del código proporcionado
Este código realiza un análisis del lugar de raíces (LGR) y cálculo de asíntotas
de una función de transferencia (FDT) en MATLAB.
Además, incluye la representación gráfica del LGR con información adicional
como el centroide y las asíntotas.
A continuación, se explica el código y las funciones principales utilizadas.

---

1. Inicio y configuración

```matlab
close all;
clc;
clear;
```

Estas instrucciones cierran todas las figuras abiertas, limpian la consola y
eliminan variables existentes en el espacio de trabajo para comenzar con un
entorno limpio.

---

2. Definición de la FDT

```matlab
s = tf('s');
KGH = ((s+1)*(s+2))/(s^2*(s+3)*(s+4));

```

-   `tf('s')`: Define la variable simbólica de Laplace `s` en el entorno de MATLAB
    para crear funciones de transferencia.
-   `KGH`: Define la función de transferencia `KGH` como el cociente de un
    polinomio numerador y un polinomio denominador.

---

3. Cálculo de polos y ceros

```matlab
polos = pole(KGH);
ceros = zero(KGH);
```

-   `pole()`: Calcula los polos de la FDT.
-   `zero()`: Calcula los ceros de la FDT.
    Estos resultados se almacenan en las variables `polos` y `ceros`.

---

4. Inicialización de la figura

```matlab
figure('Name','LGR');
xlabel('Parte Real');
ylabel('Parte Imaginaria');
title('Lugar de Raíces con Asíntotas');
hold on;
```

-   `figure()`: Crea una nueva ventana gráfica con el título especificado.
-   `xlabel`, `ylabel`, `title`: Configuran las etiquetas de los ejes y el título.
-   `hold on`: Permite agregar múltiples elementos a la misma figura.

---

5. Cálculo de las asíntotas
   Determinación del rango y configuración inicial:

```matlab
num_polos = length(polos);
num_ceros = length(ceros);
rango = num_polos - num_ceros;
asintotas_rad = zeros(1, rango);
asintotas_grad = zeros(1, rango);
```

-   `length()`: Determina el número de polos y ceros.
-   `rango`: Calcula la diferencia entre polos y ceros, indicando el número de
    asíntotas.
-   `zeros()`: Inicializa vectores para almacenar los ángulos de las asíntotas.

---

6. Cálculo del centroide

```matlab
suma_polos = sum(polos);
suma_ceros = sum(ceros);
polos_menos_ceros = suma_polos - suma_ceros;
if rango ~= 0
centroide = polos_menos_ceros / rango;
else
centroide = NaN;
warning('El rango es cero, división entre cero evitada');
end
```

-   `sum()`: Suma los polos y ceros.
-   `centroide`: Calcula el punto medio de las asíntotas.
-   Maneja el caso especial cuando `rango = 0` para evitar divisiones por cero.

---

7. Representación del centroide y asíntotas

```matlab
plot(real(centroide), imag(centroide), 'o', 'MarkerSize', 5, 'MarkerFaceColor', 'g',
'MarkerEdgeColor', 'k');
```

-   `plot()`: Dibuja el centroide como un punto verde en el plano complejo.

---

8. Cálculo y trazado del LGR

```matlab
rlocus(KGH);
grid on;
hold off;
```

-   `rlocus()`: Traza el lugar de raíces de la FDT.
-   `grid on`: Añade una cuadrícula al gráfico.
    El resultado es una herramienta visual para analizar la estabilidad y el
    comportamiento de sistemas de control en el dominio de Laplace.
