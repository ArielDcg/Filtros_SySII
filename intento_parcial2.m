
clear; close all; clc;

%% ========================================================================
%  DISEÑAR FILTROS 
% Parámetros del sistema
Fs = 64000;
f_central = [102.4, 512, 2560, 12800];
f_corte = zeros(1,5);
f_corte(1) = f_central(1) / sqrt(5);
for i = 2:4
    f_corte(i) = sqrt(f_central(i-1) * f_central(i));
end
f_corte(5) = f_central(4) * sqrt(5);

Ap = 3; As = 15;

fprintf('Diseñando filtros...\n');

%% FILTROS ANALÓGICOS
Wp1 = 2*pi*f_corte(2);
Ws1 = 2*pi*f_central(2);
[n1, Wn1] = buttord(Wp1, Ws1, Ap, As, 's');

Wp2 = 2*pi*[f_corte(2), f_corte(3)];
Ws2 = 2*pi*[f_central(1), f_central(3)];
[n2, Wn2] = buttord(Wp2, Ws2, Ap, As, 's');

Wp3 = 2*pi*[f_corte(3), f_corte(4)];
Ws3 = 2*pi*[f_central(2), f_central(4)];
[n3, Wn3] = buttord(Wp3, Ws3, Ap, As, 's');

Wp4 = 2*pi*f_corte(4);
Ws4 = 2*pi*f_central(3);
[n4, Wn4] = buttord(Wp4, Ws4, Ap, As, 's');

n_max_analog = max([n1, n2, n3, n4]);

[num_analog{1}, den_analog{1}] = butter(n_max_analog, Wn1, 'low', 's');
[num_analog{2}, den_analog{2}] = butter(n_max_analog, Wn2, 'bandpass', 's');
[num_analog{3}, den_analog{3}] = butter(n_max_analog, Wn3, 'bandpass', 's');
[num_analog{4}, den_analog{4}] = butter(n_max_analog, Wn4, 'high', 's');

%% FILTROS IIR (Bilineal)
wp1 = f_corte(2)/(Fs/2);
ws1 = f_central(2)/(Fs/2);
[n_iir1, Wn_iir1] = buttord(wp1, ws1, Ap, As);

wp2 = [f_corte(2), f_corte(3)]/(Fs/2);
ws2 = [f_central(1), f_central(3)]/(Fs/2);
[n_iir2, Wn_iir2] = buttord(wp2, ws2, Ap, As);

wp3 = [f_corte(3), f_corte(4)]/(Fs/2);
ws3 = [f_central(2), f_central(4)]/(Fs/2);
[n_iir3, Wn_iir3] = buttord(wp3, ws3, Ap, As);

wp4 = f_corte(4)/(Fs/2);
ws4 = f_central(3)/(Fs/2);
[n_iir4, Wn_iir4] = buttord(wp4, ws4, Ap, As);

n_max_iir = max([n_iir1, n_iir2, n_iir3, n_iir4]);

[num_iir{1}, den_iir{1}] = butter(n_max_iir, Wn_iir1, 'low');
[num_iir{2}, den_iir{2}] = butter(n_max_iir, Wn_iir2, 'bandpass');
[num_iir{3}, den_iir{3}] = butter(n_max_iir, Wn_iir3, 'bandpass');
[num_iir{4}, den_iir{4}] = butter(n_max_iir, Wn_iir4, 'high');

%% FILTROS FIR
df = zeros(1,4);
df(1) = abs(f_central(2) - f_corte(2));
df(2) = min(abs(f_corte(2) - f_central(1)), abs(f_central(3) - f_corte(3)));
df(2) = max(df(2), 100);
df(3) = min(abs(f_corte(3) - f_central(2)), abs(f_central(4) - f_corte(4)));
df(3) = max(df(3), 200);
df(4) = abs(f_corte(4) - f_central(3));

M1 = ceil(3.3*Fs/df(1)); M1 = min(M1, 1000);
if mod(M1,2)==0, M1=M1+1; end
if M1 < 3, M1 = 3; end
num_fir{1} = fir1(M1-1, min(f_corte(2)/(Fs/2), 0.99), 'low', hamming(M1));

M2 = ceil(3.3*Fs/df(2)); M2 = min(M2, 1000);
if mod(M2,2)==0, M2=M2+1; end
if M2 < 3, M2 = 3; end
num_fir{2} = fir1(M2-1, min([f_corte(2), f_corte(3)]/(Fs/2), 0.99), 'bandpass', hamming(M2));

M3 = ceil(3.3*Fs/df(3)); M3 = min(M3, 1000);
if mod(M3,2)==0, M3=M3+1; end
if M3 < 3, M3 = 3; end
num_fir{3} = fir1(M3-1, min([f_corte(3), f_corte(4)]/(Fs/2), 0.99), 'bandpass', hamming(M3));

M4 = ceil(3.3*Fs/df(4)); M4 = min(M4, 1000);
if mod(M4,2)==0, M4=M4+1; end
if M4 < 3, M4 = 3; end
num_fir{4} = fir1(M4-1, min(f_corte(4)/(Fs/2), 0.99), 'high', hamming(M4));

fprintf('Filtros diseñados correctamente!\n\n');

%% ========================================================================
%  VISUALIZACIÓN 1: MAGNITUD DE TODOS LOS FILTROS (COMPARACIÓN)
figure('Position', [50 50 1600 900], 'Name', 'Comparación de Magnitud');

nombres = {'Banda 1: 102.4 Hz (Pasabajos)', 'Banda 2: 512 Hz (Pasabanda)', ...
           'Banda 3: 2560 Hz (Pasabanda)', 'Banda 4: 12.8 kHz (Pasaaltos)'};

for i = 1:4
    subplot(2,2,i);
    
    % Filtro Analógico
    w_plot = logspace(log10(2*pi*10), log10(2*pi*Fs/2), 2000);
    [h_a, ~] = freqs(num_analog{i}, den_analog{i}, w_plot);
    semilogx(w_plot/(2*pi), 20*log10(abs(h_a)), 'b-', 'LineWidth', 2); hold on;
    
    % Filtro IIR
    [h_iir, f_iir] = freqz(num_iir{i}, den_iir{i}, 2000, Fs);
    semilogx(f_iir, 20*log10(abs(h_iir)), 'r--', 'LineWidth', 2);
    
    % Filtro FIR
    [h_fir, f_fir] = freqz(num_fir{i}, 1, 2000, Fs);
    semilogx(f_fir, 20*log10(abs(h_fir)), 'g:', 'LineWidth', 2.5);
    
    % Líneas de referencia
    plot([f_central(i) f_central(i)], [-60 5], 'k--', 'LineWidth', 0.5);
    plot([10 Fs/2], [-3 -3], 'k:', 'LineWidth', 0.5);
    plot([10 Fs/2], [-15 -15], 'm:', 'LineWidth', 0.5);
    
    grid on;
    xlabel('Frecuencia (Hz)');
    ylabel('Magnitud (dB)');
    title(nombres{i}, 'FontSize', 11, 'FontWeight', 'bold');
    legend('Analógico', 'IIR', 'FIR', 'f_{central}', '-3dB', '-15dB', 'Location', 'best');
    xlim([10 Fs/2]);
    ylim([-60 5]);
end

sgtitle('COMPARACIÓN DE MAGNITUD - TODOS LOS MÉTODOS', 'FontSize', 14, 'FontWeight', 'bold');

%% ========================================================================
%  VISUALIZACIÓN 2: RESPUESTA EN FRECUENCIA COMPLETA DEL SISTEMA


figure('Position', [100 100 1600 600], 'Name', 'Respuesta del Sistema Completo');

% Sistema Analógico
subplot(1,3,1);
w_plot = logspace(log10(2*pi*10), log10(2*pi*Fs/2), 2000);
for i = 1:4
    [h_a, ~] = freqs(num_analog{i}, den_analog{i}, w_plot);
    semilogx(w_plot/(2*pi), 20*log10(abs(h_a)), 'LineWidth', 2); hold on;
end
grid on;
xlabel('Frecuencia (Hz)');
ylabel('Magnitud (dB)');
title('Sistema Analógico', 'FontWeight', 'bold');
legend('Banda 1', 'Banda 2', 'Banda 3', 'Banda 4', 'Location', 'southwest');
xlim([10 Fs/2]);
ylim([-60 5]);

% Sistema IIR
subplot(1,3,2);
for i = 1:4
    [h_iir, f_iir] = freqz(num_iir{i}, den_iir{i}, 2000, Fs);
    semilogx(f_iir, 20*log10(abs(h_iir)), 'LineWidth', 2); hold on;
end

grid on;
xlabel('Frecuencia (Hz)');
ylabel('Magnitud (dB)');
title('Sistema IIR (Bilineal)', 'FontWeight', 'bold');
legend('Banda 1', 'Banda 2', 'Banda 3', 'Banda 4', 'Location', 'southwest');
xlim([10 Fs/2]);
ylim([-60 5]);

% Sistema FIR
subplot(1,3,3);
for i = 1:4
    [h_fir, f_fir] = freqz(num_fir{i}, 1, 2000, Fs);
    semilogx(f_fir, 20*log10(abs(h_fir)), 'LineWidth', 2); hold on;
end
grid on;
xlabel('Frecuencia (Hz)');
ylabel('Magnitud (dB)');
title('Sistema FIR (Hamming)', 'FontWeight', 'bold');
legend('Banda 1', 'Banda 2', 'Banda 3', 'Banda 4', 'Location', 'southwest');
xlim([10 Fs/2]);
ylim([-60 5]);

sgtitle('RESPUESTA EN FRECUENCIA COMPLETA DE LOS SISTEMAS', 'FontSize', 14, 'FontWeight', 'bold');

%% ========================================================================
%  VISUALIZACIÓN 3: RESPUESTA EN FASE

figure('Position', [150 150 1600 900], 'Name', 'Respuesta en Fase');

for i = 1:4
    subplot(2,2,i);
    
    % Filtro Analógico
    w_plot = logspace(log10(2*pi*10), log10(2*pi*Fs/2), 2000);
    [h_a, ~] = freqs(num_analog{i}, den_analog{i}, w_plot);
    semilogx(w_plot/(2*pi), unwrap(angle(h_a))*180/pi, 'b-', 'LineWidth', 2); hold on;
    
    % Filtro IIR
    [h_iir, f_iir] = freqz(num_iir{i}, den_iir{i}, 2000, Fs);
    semilogx(f_iir, unwrap(angle(h_iir))*180/pi, 'r--', 'LineWidth', 2);
    
    % Filtro FIR
    [h_fir, f_fir] = freqz(num_fir{i}, 1, 2000, Fs);
    semilogx(f_fir, unwrap(angle(h_fir))*180/pi, 'g:', 'LineWidth', 2.5);
    
    grid on;
    xlabel('Frecuencia (Hz)');
    ylabel('Fase (grados)');
    title(nombres{i}, 'FontSize', 11, 'FontWeight', 'bold');
    legend('Analógico', 'IIR', 'FIR', 'Location', 'best');
    xlim([10 Fs/2]);
end

sgtitle('RESPUESTA EN FASE - TODOS LOS MÉTODOS', 'FontSize', 14, 'FontWeight', 'bold');



%% ========================================================================
%  VISUALIZACIÓN 4: ESPECIFICACIONES CUMPLIDAS

figure('Position', [350 350 1400 800], 'Name', 'Verificación de Especificaciones');

colores = {'b', 'r', 'g', 'm'};

for i = 1:4
    subplot(2,2,i);
    
    % Solo IIR para claridad
    [h_iir, f_iir] = freqz(num_iir{i}, den_iir{i}, 4096, Fs);
    mag_db = 20*log10(abs(h_iir));
    
    semilogx(f_iir, mag_db, colores{i}, 'LineWidth', 2); hold on;
    
    % Marcar frecuencias importantes
    plot(f_central(i), 0, 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
    
    % Líneas de especificación
    plot([10 Fs/2], [-3 -3], 'k--', 'LineWidth', 1.5);
    plot([10 Fs/2], [-15 -15], 'r--', 'LineWidth', 1.5);
    
    % Zonas de paso y rechazo
    if i == 1 % Pasabajos
        xline(f_corte(2), 'b:', 'LineWidth', 2);
        xline(f_central(2), 'r:', 'LineWidth', 2);
    elseif i == 4 % Pasaaltos
        xline(f_corte(4), 'b:', 'LineWidth', 2);
        xline(f_central(3), 'r:', 'LineWidth', 2);
    else % Pasabanda
        xline(f_corte(i), 'b:', 'LineWidth', 2);
        xline(f_corte(i+1), 'b:', 'LineWidth', 2);
        xline(f_central(i-1), 'r:', 'LineWidth', 2);
        xline(f_central(i+1), 'r:', 'LineWidth', 2);
    end
    
    grid on;
    xlabel('Frecuencia (Hz)');
    ylabel('Magnitud (dB)');
    title(nombres{i}, 'FontSize', 11, 'FontWeight', 'bold');
    legend('Respuesta', 'f_{central}', '-3dB (paso)', '-15dB (rechazo)', 'Location', 'best');
    xlim([10 Fs/2]);
    ylim([-60 5]);
end

sgtitle('VERIFICACIÓN DE ESPECIFICACIONES (IIR)', 'FontSize', 14, 'FontWeight', 'bold');

%% ========================================================================
%  RESUMEN DE INFORMACIÓN

fprintf('\n=== RESUMEN DE FILTROS DISEÑADOS ===\n\n');

fprintf('FILTROS ANALÓGICOS:\n');
fprintf('  Orden utilizado: %d\n', n_max_analog);
for i = 1:4
    fprintf('  Banda %d: %d polos, %d ceros\n', i, length(den_analog{i})-1, length(num_analog{i})-1);
end

fprintf('\nFILTROS IIR (Bilineal):\n');
fprintf('  Orden utilizado: %d\n', n_max_iir);
for i = 1:4
    fprintf('  Banda %d: %d polos, %d ceros\n', i, length(den_iir{i})-1, length(num_iir{i})-1);
end

fprintf('\nFILTROS FIR:\n');
ordenes_fir = [M1-1, M2-1, M3-1, M4-1];
for i = 1:4
    fprintf('  Banda %d: Orden = %d coeficientes\n', i, ordenes_fir(i)+1);
end

fprintf('\nFRECUENCIAS DEL SISTEMA:\n');
fprintf('  Centrales: %.1f, %.1f, %.1f, %.1f Hz\n', f_central);
fprintf('  Corte (-3dB): %.1f, %.1f, %.1f, %.1f, %.1f Hz\n\n', f_corte);

fprintf('=== VISUALIZACIÓN COMPLETA ===\n');
fprintf('Se generaron 7 figuras con todas las características de los filtros\n');
fprintf('Puedes navegar entre ellas usando las pestañas de MATLAB\n\n');
%% ========================================================================
%  PARTE 2: IMPLEMENTACIÓN DE SISTEMAS DE AUDIO
% ========================================================================
% 1. CARGA DE LA SEÑAL DE ENTRADA

try
    [x, fs_leida] = audioread('AudioBillie.wav');
    fprintf('Archivo cargado correctamente.\n');
    
    x = x(:,1); % Asegurar que sea monofónico
    
    % Re-muestrear a 64 kHz si es necesario
    if fs_leida ~= Fs
        x = resample(x, Fs, fs_leida); 
        fprintf('Re-muestreado a %d Hz.\n', Fs);
    end
    
    % --- CORRECCIÓN: DEFINICIÓN DEL VECTOR DE TIEMPO 't' ---
    % lsim necesita saber los instantes de tiempo del audio real
    dt = 1/Fs;
    N_samples = length(x);
    t = (0:N_samples-1) * dt; 
    
    fprintf('Procesando audio (esto puede tardar unos segundos)...\n');

catch
    error('No se encontró el archivo "AudioBillie.wav". Verifica que esté en la carpeta actual.');
end

% Definición de ganancias por banda
ganancias = [1, 1, 1, 1];

% Inicialización de salidas totales
y_total_analog = zeros(size(x));
y_total_iir = zeros(size(x));
y_total_fir = zeros(size(x));

% Matrices para guardar las salidas individuales de cada banda (para graficar)
% Tamaño: [muestras, 4 bandas]
bandas_out_analog = zeros(length(x), 4);
bandas_out_iir    = zeros(length(x), 4);
bandas_out_fir    = zeros(length(x), 4);

%% 2. PROCESAMIENTO DE LOS SISTEMAS
for i = 1:4
    fprintf('  Procesando Banda %d (%.1f Hz) - Ganancia: %.2f\n', i, f_central(i), ganancias(i));
    
    % --- SISTEMA A: ANALÓGICO (Simulado con lsim) ---
    % Convertimos Transfer Function a Espacio de Estados para lsim
    sys_ss = ss(tf(num_analog{i}, den_analog{i}));
    
    % lsim requiere que x y t tengan dimensiones compatibles
    temp_analog = lsim(sys_ss, x, t); 
    
    % Asegurar orientación de vectores (columna)
    if size(temp_analog, 2) > 1; temp_analog = temp_analog'; end
    
    bandas_out_analog(:,i) = temp_analog;
    y_total_analog = y_total_analog + (temp_analog * ganancias(i));
    
    % --- SISTEMA B: DIGITAL IIR (Butterworth Bilineal) ---
    temp_iir = filter(num_iir{i}, den_iir{i}, x);
    bandas_out_iir(:,i) = temp_iir;
    y_total_iir = y_total_iir + (temp_iir * ganancias(i));
    
    % --- SISTEMA C: DIGITAL FIR (Ventana Hamming) ---
    temp_fir = filter(num_fir{i}, 1, x);
    bandas_out_fir(:,i) = temp_fir;
    y_total_fir = y_total_fir + (temp_fir * ganancias(i));
end

%% 3. VISUALIZACIÓN DE RESULTADOS
% Eje de frecuencia para plotear
N = length(x);
f_axis = linspace(0, Fs/2, floor(N/2)+1);

% Espectro de entrada (mitad positiva)
X_fft = fft(x);
X_mag = 20*log10(abs(X_fft(1:length(f_axis))) + eps);

nombres_sis = {'SISTEMA ANALÓGICO (Simulación)', 'SISTEMA IIR', 'SISTEMA FIR'};
salidas_totales = {y_total_analog, y_total_iir, y_total_fir};
salidas_bandas  = {bandas_out_analog, bandas_out_iir, bandas_out_fir};

for k = 1:3
    figure('Position', [100 50 1200 800], 'Name', nombres_sis{k});
    
    % --- Subplot 1: Espectro Entrada vs Salida Total ---
    subplot(3, 2, [1 2]);
    Y_fft = fft(salidas_totales{k});
    Y_mag = 20*log10(abs(Y_fft(1:length(f_axis))) + eps);
    
    plot(f_axis, X_mag, 'Color', [0.7 0.7 0.7], 'LineWidth', 1.5); hold on;
    plot(f_axis, Y_mag, 'b', 'LineWidth', 1.5);
    title(['Entrada vs Salida Total - ' nombres_sis{k}]);
    ylabel('Magnitud (dB)'); xlabel('Frecuencia (Hz)');
    legend('Entrada Original', 'Salida Ecualizada');
    grid on; xlim([20 Fs/2]); ylim([-120 max(X_mag)+10]);
    set(gca, 'XScale', 'log');
    
    % --- Subplots 2-5: Espectros Individuales por Banda ---
    colores_banda = {'r', 'g', 'm', 'b'};
    titulos_banda = {'Low (102 Hz)', 'Mid-Low (512 Hz)', 'Mid-High (2.5 kHz)', 'High (12.8 kHz)'};
    
    for b = 1:4
        subplot(3, 2, 2+b);
        B_fft = fft(salidas_bandas{k}(:,b));
        B_mag = 20*log10(abs(B_fft(1:length(f_axis))) + eps);
        
        plot(f_axis, X_mag, 'Color', [0.8 0.8 0.8]); hold on;
        plot(f_axis, B_mag, colores_banda{b}, 'LineWidth', 1.5);
        
        title(sprintf('Banda %d: %s - G=%.2f', b, titulos_banda{b}, ganancias(b)));
        grid on; xlim([20 Fs/2]); set(gca, 'XScale', 'log'); ylim([-120 10]);
    end
    
    sgtitle(['ANÁLISIS ESPECTRAL: ' nombres_sis{k}], 'FontSize', 14, 'FontWeight', 'bold');
end
fprintf('\nProceso completado. Revisa las figuras generadas.\n');


%% ========================================================================
%  PARTE 3: ESCUCHA Y GUARDADO DE AUDIO
% ========================================================================

fprintf('\n=== REPRODUCCIÓN DE AUDIO ===\n');

% 1. ELEGIR QUÉ SISTEMA ESCUCHAR
% Cambia esto por: y_total_analog, y_total_iir, o y_total_fir
senal_a_escuchar = y_total_iir; 
nombre_sistema = 'Sistema IIR';

% 2. NORMALIZACIÓN (IMPORTANTE)
% Como aplicamos ganancia de 2, la señal puede salirse del rango [-1, 1].
% Esto ajusta el volumen máximo a 1 para evitar que suene "roto" (clipping).
max_val = max(abs(senal_a_escuchar));
if max_val > 1
    senal_normalizada = senal_a_escuchar / max_val;
    fprintf('Aviso: La señal fue normalizada para evitar saturación.\n');
else
    senal_normalizada = senal_a_escuchar;
end

% 3. REPRODUCIR EN MATLAB
fprintf('Reproduciendo resultado del %s...\n', nombre_sistema);
fprintf('Presiona Ctrl+C o escribe "clear sound" en la consola para detener.\n');

sound(senal_normalizada, Fs); 

% 4. GUARDAR EN UN ARCHIVO NUEVO 
% Esto crea un archivo .wav nuevo en la carpeta para que lo escuches fuera de MATLAB
nombre_archivo_salida = 'Audio_Ecualizado_IIR.wav';
audiowrite(nombre_archivo_salida, senal_normalizada, Fs);
fprintf('Archivo guardado como: %s\n', nombre_archivo_salida);