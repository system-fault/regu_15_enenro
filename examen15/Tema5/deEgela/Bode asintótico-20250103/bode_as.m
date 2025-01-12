function bode_as(num, den)
    % Esta función genera un diagrama de Bode asintótico para un sistema
    % definido por los coeficientes del numerador y denominador

    % Encuentra las raíces del numerador y denominador
    zroots = roots(num);
    proots = roots(den);
    
    % Encuentra y cuenta las raíces cero del numerador y denominador
    [iz, jz] = find(abs(zroots) == 0); 
    numz = length(iz); 
    [ip, jp] = find(abs(proots) == 0); 
    nump = length(ip); 
    
    % Calcula la pendiente inicial
    pend = numz - nump;
    
    % Elimina las raíces cero del numerador y denominador
    sz = [1:length(zroots)];
    sp = [1:length(proots)];
    zroots = zroots(setdiff(sz, iz), :);
    proots = proots(setdiff(sp, ip), :);
    
    % Calcula las raíces ajustadas para el diagrama de Bode
    zroots2 = abs(zroots) - j * real(zroots) ./ abs(zroots);
    proots2 = abs(proots) - j * real(proots) ./ abs(proots);
    
    % Prepara las matrices para los ceros y polos
    zz = ones(size(zroots2, 1), 3);
    zz(:, 2) = real(zroots2);
    zz(:, 3) = imag(zroots2);
    pp = -ones(size(proots2, 1), 3);
    pp(:, 2) = real(proots2);
    pp(:, 3) = imag(proots2);
    
    % Traza los módulos
    pp_mag = pp;
    zz_mag = zz;
    vect = [zz_mag; pp_mag];
    
    % Ordena las filas del vector por la segunda columna (valores reales)
    vect = sortrows(vect, 2);
    
    % Inicializa el intervalo de frecuencias
    interval = zeros(1, size(vect, 1) + 2);
    interval(:, [2:(size(vect, 1) + 1)]) = vect(:, 2)';
    try
        interval(1, 1) = 0.01 * vect(1, 2);
        interval(1, end) = 100 * vect(end, 2);
    catch
        interval(1, 1) = 0.01 * 1;
        interval(1, 2) = 100 * 1;
    end
    
    % Genera el diagrama de Bode para el primer intervalo
    [g, p] = bode(num, den, interval(1)); grid on
    
    % Calcula la magnitud en dB
    y(1) = 20 * log10(g);
    indice = 2;
    y_old = y(1);
    i_old = interval(1);
    for i = interval(:, [2:length(interval) - 1])
        y(indice) = 20 * pend * log10(i) + y_old - 20 * pend * log10(i_old);
        pend = pend + vect(indice - 1, 1);
        i_old = i;
        y_old = y(indice);
        indice = indice + 1;
    end
    y(indice) = 20 * pend * log10(interval(end)) + y_old - 20 * pend * log10(i_old);
    
    % Grafica el diagrama de Bode de magnitud
    subplot(2, 1, 1)
    semilogx(interval, y, 'b');
    hold on;
    grid on
    
    % Convierte a espacio de estados y grafica el diagrama de Bode original
    [AAA, BBB, CCC, DDD] = tf2ss(num, den);
    sys = ss(AAA, BBB, CCC, DDD);
    [m1, m2, m3] = bode(num, den, {interval(1, 1), interval(1, end)});
    hold on;
    plot(m3, 20 * log10(m1)); grid on
    
    clear interval;
    
    % Traza las fases
    [ii, jj] = find(vect(:, 3) < 0);
    vect(ii, 1) = -(vect(ii, 1));
    
    % Inicializa el intervalo de frecuencias para la fase
    for i = 1:size(vect, 1)
        interval(1, indice) = 0.1 * vect(i, 2);
        interval(2, indice) = vect(i, 1);
        indice = indice + 1;
        interval(1, indice) = vect(i, 2);
        interval(2, indice) = 0;
        indice = indice + 1;
        interval(1, indice) = 10 * vect(i, 2);
        interval(2, indice) = -vect(i, 1);
        indice = indice + 1;
    end
    try
        interval = interval';
        interval = sortrows(interval, 1);
        interval = interval';
    catch
        interval(:, 1) = [0.01 * 1; 0];
        interval(:, 2) = [100 * 1; 0];
        interval = interval';
        interval = sortrows(interval, 1);
        interval = interval';
    end
    
    % Agrega intervalos adicionales para cubrir todo el rango de frecuencias
    interval = [[0.1 * interval(1, 1); 0] interval [10 * interval(1, end); 0]];
    [g, p, w3] = bode(num, den, interval(1)); grid on
    
    % Calcula y ajusta las fases
    pp = p;
    x = round(p / 90);
    p = 90 * x;
    
    yf(1) = p;
    indice = 2;
    yf_old = yf(1);
    i_old = interval(1, 1);
    pend = 0;
    for i = interval(1, [2:size(interval, 2) - 1])
        yf(indice) = 45 * pend * log10(i) + yf_old - 45 * pend * log10(i_old);
        pend = pend + interval(2, indice);
        i_old = i;
        yf_old = yf(indice);
        indice = indice + 1;
    end
    
    % Grafica el diagrama de Bode de fase
    yf(indice) = yf_old;
    subplot(2, 1, 2)
    semilogx(interval(1, :), yf, 'b');
    hold on;
    [m1, m2, m3] = bode(num, den, {interval(1, 1), interval(1, end)}); grid on
    diff = m2(1) - pp;
    m2 = m2 - diff;
    hold on
    semilogx(m3, m2); grid on
end