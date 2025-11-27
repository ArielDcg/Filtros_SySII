%% DISEÑO DE FILTRO FIR (FINITE IMPULSE RESPONSE)
% Este script implementa un filtro FIR de paso bajo usando el método
% de diseño con ventana
% Especificaciones:
%   - Tipo: FIR con ventana Hamming
%   - Configuración: Paso bajo
%   - Orden: 64
%   - Frecuencia de corte: 1000 Hz
%   - Frecuencia de muestreo: 8000 Hz

clear all; close all; clc;

%% Especificaciones del Filtro FIR
fprintf('\n========== FILTRO FIR (FINITE IMPULSE RESPONSE) ==========\n');
fprintf('Tipo: FIR con ventana Hamming\n');
fprintf('Método: Diseño con ventana\n');

Fs = 8000;          % Frecuencia de muestreo en Hz
Fc = 1000;          % Frecuencia de corte en Hz
Wn = Fc / (Fs/2);   % Frecuencia normalizada (respecto a Nyquist)
N = 64;             % Orden del filtro (número de coeficientes - 1)

fprintf('Orden (N): %d coeficientes\n', N+1);
fprintf('Frecuencia de muestreo: %.0f Hz\n', Fs);
fprintf('Frecuencia de corte: %.0f Hz\n', Fc);
fprintf('Frecuencia de Nyquist: %.0f Hz\n', Fs/2);
fprintf('Frecuencia normalizada: %.4f\n\n', Wn);

%% Diseño del Filtro FIR con Ventana Hamming
% Crear ventana de Hamming
ventana = hamming(N+1)';

% Diseñar filtro usando fir1
num_fir = fir1(N, Wn, 'low', ventana);

% Crear el sistema discreto
H_fir = tf(num_fir, 1, 1/Fs);

fprintf('Número de coeficientes: %d\n', length(num_fir));
fprintf('Tipo de ventana: Hamming\n\n');

%% Respuesta en Frecuencia
f = logspace(0, 4, 1000);  % Rango de frecuencias: 1 Hz a 10 kHz
w = 2*pi*f;                % Convertir a rad/s

[H] = freqz(num_fir, 1, w, Fs);
mag_dB = 20*log10(abs(H));           % Magnitud en dB
phase_deg = angle(H) * 180/pi;       % Fase en grados

%% Guardar datos
datos.f = f;
datos.w = w;
datos.mag_dB = mag_dB;
datos.phase_deg = phase_deg;
datos.Fc = Fc;
datos.Fs = Fs;
datos.N = N;
datos.tipo = 'FIR';
datos.num = num_fir;
datos.ventana = ventana;

save('/home/user/Filtros_SySII/data/filtro_fir.mat', 'datos');

%% Gráficas
figure('Position', [100 100 1200 600]);

% Gráfica de Magnitud
subplot(1,2,1);
semilogx(f, mag_dB, 'b', 'LineWidth', 2);
grid on; grid minor;
xlabel('Frecuencia (Hz)', 'FontSize', 11);
ylabel('Magnitud (dB)', 'FontSize', 11);
title('Respuesta en Magnitud - Filtro FIR', 'FontSize', 12, 'FontWeight', 'bold');
xlim([min(f) max(f)]);
ylim([min(mag_dB)-5 5]);

% Línea de -3dB
hold on;
yline(-3, 'r--', 'LineWidth', 1.5, 'Label', 'Punto de -3dB');
xline(Fc, 'g--', 'LineWidth', 1.5, 'Label', sprintf('Fc = %.0f Hz', Fc));
xline(Fs/2, 'm--', 'LineWidth', 1.5, 'Label', sprintf('Nyquist = %.0f Hz', Fs/2));
legend('Respuesta', 'Punto -3dB', 'Fc', 'Nyquist', 'FontSize', 10);

% Gráfica de Fase
subplot(1,2,2);
semilogx(f, phase_deg, 'r', 'LineWidth', 2);
grid on; grid minor;
xlabel('Frecuencia (Hz)', 'FontSize', 11);
ylabel('Fase (grados)', 'FontSize', 11);
title('Respuesta en Fase - Filtro FIR', 'FontSize', 12, 'FontWeight', 'bold');
xlim([min(f) max(f)]);

sgtitle('Diagrama de Bode - Filtro FIR Paso Bajo (Ventana Hamming, Orden 64)', ...
    'FontSize', 13, 'FontWeight', 'bold');

saveas(gcf, '/home/user/Filtros_SySII/figures/filtro_fir.png');
close;

%% Respuesta al Impulso
figure('Position', [100 100 1000 500]);
stem(0:N, num_fir, 'b', 'LineWidth', 1.5, 'MarkerSize', 5);
grid on;
xlabel('n (muestras)', 'FontSize', 11);
ylabel('h[n]', 'FontSize', 11);
title('Respuesta al Impulso del Filtro FIR', 'FontSize', 12, 'FontWeight', 'bold');

saveas(gcf, '/home/user/Filtros_SySII/figures/filtro_fir_impulso.png');
close;

%% Información adicional
fprintf('Coeficientes del filtro FIR:\n');
fprintf('h[0:5] = [');
fprintf('%.6f ', num_fir(1:min(6, length(num_fir))));
fprintf('...]\n\n');

% Encontrar frecuencia de corte (-3dB)
[~, idx] = min(abs(mag_dB + 3));
Fc_real = f(idx);
fprintf('Frecuencia de corte real (-3dB): %.2f Hz\n', Fc_real);
fprintf('Magnitud a Fc: %.2f dB\n', mag_dB(idx));

fprintf('\nAnálisis de rizado:\n');
% Encontrar máximo del lóbulo principal y primer lóbulo lateral
mag_pasabanda = mag_dB(f <= Fc_real*2);
rizado_pasabanda = max(mag_pasabanda) - min(mag_pasabanda);
fprintf('Rizado en banda de paso: %.2f dB\n', rizado_pasabanda);

% Atenuación en banda de rechazo
mag_rechazo = mag_dB(f >= Fs/4);
fprintf('Atenuación aproximada en banda de rechazo: %.2f dB\n', min(mag_rechazo));

fprintf('\nArchivos guardados:\n');
fprintf('  - /home/user/Filtros_SySII/figures/filtro_fir.png\n');
fprintf('  - /home/user/Filtros_SySII/figures/filtro_fir_impulso.png\n');

%% Análisis de fase lineal
fprintf('\nAnálisis de fase:\n');
fprintf('Simetría de coeficientes: ');
if max(abs(num_fir - fliplr(num_fir))) < 1e-10
    fprintf('SÍ (Fase lineal)\n');
else
    fprintf('NO\n');
end
