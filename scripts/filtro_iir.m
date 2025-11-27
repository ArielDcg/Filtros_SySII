%% DISEÑO DE FILTRO IIR (INFINITE IMPULSE RESPONSE)
% Este script implementa un filtro IIR de paso bajo usando el método de
% transformación bilineal de un filtro analógico
% Especificaciones:
%   - Tipo: Butterworth de orden 5
%   - Configuración: Paso bajo
%   - Frecuencia de corte: 500 Hz
%   - Frecuencia de muestreo: 5000 Hz

clear all; close all; clc;

%% Especificaciones del Filtro IIR
fprintf('\n========== FILTRO IIR (INFINITE IMPULSE RESPONSE) ==========\n');
fprintf('Tipo: Butterworth de paso bajo\n');
fprintf('Orden: 5\n');

Fs = 5000;          % Frecuencia de muestreo en Hz
Fc = 500;           % Frecuencia de corte en Hz
Wn = Fc / (Fs/2);   % Frecuencia normalizada (respecto a Nyquist)
orden = 5;          % Orden del filtro

fprintf('Frecuencia de muestreo: %.0f Hz\n', Fs);
fprintf('Frecuencia de corte: %.0f Hz\n', Fc);
fprintf('Frecuencia de Nyquist: %.0f Hz\n', Fs/2);
fprintf('Frecuencia normalizada: %.4f\n\n', Wn);

%% Diseño del Filtro IIR Butterworth
[num_iir, den_iir] = butter(orden, Wn);

% Crear el sistema discreto
H_iir = tf(num_iir, den_iir, 1/Fs);

fprintf('Función de transferencia IIR (tiempo discreto):\n');
disp(H_iir);

%% Respuesta en Frecuencia
f = logspace(0, 4, 1000);  % Rango de frecuencias: 1 Hz a 10 kHz
w = 2*pi*f;                % Convertir a rad/s

[H] = freqz(num_iir, den_iir, w, Fs);
mag_dB = 20*log10(abs(H));           % Magnitud en dB
phase_deg = angle(H) * 180/pi;       % Fase en grados

%% Guardar datos
datos.f = f;
datos.w = w;
datos.mag_dB = mag_dB;
datos.phase_deg = phase_deg;
datos.Fc = Fc;
datos.Fs = Fs;
datos.orden = orden;
datos.tipo = 'IIR';
datos.num = num_iir;
datos.den = den_iir;

save('/home/user/Filtros_SySII/data/filtro_iir.mat', 'datos');

%% Gráficas
figure('Position', [100 100 1200 600]);

% Gráfica de Magnitud
subplot(1,2,1);
semilogx(f, mag_dB, 'b', 'LineWidth', 2);
grid on; grid minor;
xlabel('Frecuencia (Hz)', 'FontSize', 11);
ylabel('Magnitud (dB)', 'FontSize', 11);
title('Respuesta en Magnitud - Filtro IIR', 'FontSize', 12, 'FontWeight', 'bold');
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
title('Respuesta en Fase - Filtro IIR', 'FontSize', 12, 'FontWeight', 'bold');
xlim([min(f) max(f)]);

sgtitle('Diagrama de Bode - Filtro IIR Butterworth de Orden 5', ...
    'FontSize', 13, 'FontWeight', 'bold');

saveas(gcf, '/home/user/Filtros_SySII/figures/filtro_iir.png');
close;

%% Información adicional
fprintf('Polos del filtro digital:\n');
polos = pole(H_iir);
disp(polos);

fprintf('\nCeros del filtro digital:\n');
ceros = zero(H_iir);
disp(ceros);

% Encontrar frecuencia de corte (-3dB)
[~, idx] = min(abs(mag_dB + 3));
Fc_real = f(idx);
fprintf('\nFrecuencia de corte real (-3dB): %.2f Hz\n', Fc_real);
fprintf('Magnitud a Fc: %.2f dB\n', mag_dB(idx));

fprintf('\nArchivo guardado: /home/user/Filtros_SySII/figures/filtro_iir.png\n');

%% Análisis de estabilidad
fprintf('\nAnálisis de estabilidad:\n');
fprintf('Todos los polos están dentro del círculo unitario: ');
if all(abs(polos) < 1)
    fprintf('SÍ (Filtro estable)\n');
else
    fprintf('NO (Filtro inestable)\n');
end
