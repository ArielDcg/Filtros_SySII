%% DISEÑO DE FILTRO ANALÓGICO
% Este script implementa un filtro Butterworth analógico de paso bajo
% Especificaciones:
%   - Tipo: Butterworth de orden 4
%   - Configuración: Paso bajo
%   - Frecuencia de corte: 1 kHz

clear all; close all; clc;

%% Especificaciones del Filtro
fprintf('\n========== FILTRO ANALÓGICO ==========\n');
fprintf('Tipo: Butterworth de paso bajo\n');
fprintf('Orden: 4\n');

Fc = 1000;          % Frecuencia de corte en Hz
Wc = 2*pi*Fc;       % Frecuencia de corte en rad/s
orden = 4;          % Orden del filtro

fprintf('Frecuencia de corte: %.0f Hz (%.2f rad/s)\n\n', Fc, Wc);

%% Diseño del Filtro Butterworth Analógico
[num_an, den_an] = butter(orden, Wc, 's');

% Crear el sistema analógico
H_analog = tf(num_an, den_an);

fprintf('Función de transferencia analógica:\n');
disp(H_analog);

%% Respuesta en Frecuencia
w = logspace(0, 5, 1000);  % Rango de frecuencias: 1 Hz a 100 kHz en escala logarítmica

[mag, phase, w] = bode(H_analog, w);
mag_dB = 20*log10(squeeze(mag));      % Convertir magnitud a dB
phase_deg = squeeze(phase);            % Fase en grados

%% Guardar datos
datos.w = w;
datos.mag_dB = mag_dB;
datos.phase_deg = phase_deg;
datos.Fc = Fc;
datos.orden = orden;
datos.tipo = 'Analógico';
datos.num = num_an;
datos.den = den_an;

save('/home/user/Filtros_SySII/data/filtro_analogico.mat', 'datos');

%% Gráficas
figure('Position', [100 100 1200 600]);

% Gráfica de Magnitud
subplot(1,2,1);
semilogx(w, mag_dB, 'b', 'LineWidth', 2);
grid on; grid minor;
xlabel('Frecuencia (rad/s)', 'FontSize', 11);
ylabel('Magnitud (dB)', 'FontSize', 11);
title('Respuesta en Magnitud - Filtro Analógico', 'FontSize', 12, 'FontWeight', 'bold');
xlim([min(w) max(w)]);

% Línea de -3dB
hold on;
yline(-3, 'r--', 'LineWidth', 1.5, 'Label', 'Punto de -3dB');
xline(Wc, 'g--', 'LineWidth', 1.5, 'Label', sprintf('Fc = %.0f Hz', Fc));
legend('Respuesta', 'Punto -3dB', 'Fc', 'FontSize', 10);

% Gráfica de Fase
subplot(1,2,2);
semilogx(w, phase_deg, 'r', 'LineWidth', 2);
grid on; grid minor;
xlabel('Frecuencia (rad/s)', 'FontSize', 11);
ylabel('Fase (grados)', 'FontSize', 11);
title('Respuesta en Fase - Filtro Analógico', 'FontSize', 12, 'FontWeight', 'bold');
xlim([min(w) max(w)]);

sgtitle('Diagrama de Bode - Filtro Butterworth Analógico de Orden 4', ...
    'FontSize', 13, 'FontWeight', 'bold');

saveas(gcf, '/home/user/Filtros_SySII/figures/filtro_analogico.png');
close;

%% Información adicional
fprintf('Polos del filtro:\n');
polos = pole(H_analog);
disp(polos);

fprintf('\nMagnitud a frecuencia de corte (Fc = %.0f Hz):\n', Fc);
[mag_Fc, phase_Fc] = bode(H_analog, Wc);
fprintf('  Magnitud: %.2f dB\n', 20*log10(mag_Fc));
fprintf('  Fase: %.2f grados\n\n', phase_Fc);

fprintf('Archivo guardado: /home/user/Filtros_SySII/figures/filtro_analogico.png\n');
