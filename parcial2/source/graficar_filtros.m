%% ========================================================================
%  VISUALIZACIÓN 1: MAGNITUD DE TODOS LOS FILTROS (COMPARACIÓN)
figure('Name', 'Comparación de Magnitud');

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
    semilogx(f_iir, 20*log10(abs(h_iir)), 'r--', 'LineWidth', 2.5);

    % Filtro INVAR
    [h_inv, f_inv] = freqz(num_inv{i}, den_inv{i}, 2000, Fs);
    semilogx(f_inv, 20*log10(abs(h_inv)), 'm-.', 'LineWidth', 1.5);
    
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
    legend('Analógico', 'BILINEAL', 'INVAR', 'FIR', 'f_{central}', '-3dB', '-15dB', 'Location', 'best');
    xlim([10 Fs/2]);
    ylim([-30 5]);
end

sgtitle('COMPARACIÓN DE MAGNITUD - TODOS LOS MÉTODOS', 'FontSize', 14, 'FontWeight', 'bold');

%% ========================================================================
%  VISUALIZACIÓN 2: RESPUESTA EN FRECUENCIA COMPLETA DEL SISTEMA


figure('Name', 'Respuesta del Sistema Completo');

% Sistema Analógico
subplot(2,2,1);
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
ylim([-30 5]);

% Sistema IIR BILINEAL
subplot(2,2,2);
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
ylim([-30 5]);


% Sistema IIR INVAR
subplot(2,2,3);
for i = 1:4
    [h_inv, f_inv] = freqz(num_inv{i}, den_inv{i}, 2000, Fs);
    semilogx(f_inv, 20*log10(abs(h_inv)), 'LineWidth', 2); hold on;
end

grid on;
xlabel('Frecuencia (Hz)');
ylabel('Magnitud (dB)');
title('Sistema IIR (INVAR)', 'FontWeight', 'bold');
legend('Banda 1', 'Banda 2', 'Banda 3', 'Banda 4', 'Location', 'southwest');
xlim([10 Fs/2]);
ylim([-30 5]);


% Sistema FIR
subplot(2,2,4);
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
ylim([-30 5]);

sgtitle('RESPUESTA EN FRECUENCIA COMPLETA DE LOS SISTEMAS', 'FontSize', 14, 'FontWeight', 'bold');

%% ========================================================================
%  VISUALIZACIÓN 3: RESPUESTA EN FASE

figure('Name', 'Respuesta en Fase');

for i = 1:4
    subplot(2,2,i);
    
    % Filtro Analógico
    w_plot = logspace(log10(2*pi*10), log10(2*pi*Fs/2), 2000);
    [h_a, ~] = freqs(num_analog{i}, den_analog{i}, w_plot);
    semilogx(w_plot/(2*pi), unwrap(angle(h_a))*180/pi, 'b-', 'LineWidth', 2.5); hold on;
    
    % Filtro IIR
    [h_iir, f_iir] = freqz(num_iir{i}, den_iir{i}, 2000, Fs);
    semilogx(f_iir, unwrap(angle(h_iir))*180/pi, 'r--', 'LineWidth', 2);

     % Filtro INV
    [h_inv, f_inv] = freqz(num_inv{i}, den_inv{i}, 2000, Fs);
    semilogx(f_inv, unwrap(angle(h_inv))*180/pi, 'm-.', 'LineWidth', 1.5);
    
    % Filtro FIR
    [h_fir, f_fir] = freqz(num_fir{i}, 1, 2000, Fs);
    semilogx(f_fir, unwrap(angle(h_fir))*180/pi, 'g:', 'LineWidth', 2.5);
    
    grid on;
    xlabel('Frecuencia (Hz)');
    ylabel('Fase (grados)');
    title(nombres{i}, 'FontSize', 11, 'FontWeight', 'bold');
    legend('Analógico', 'Bilineal', 'Invar', 'FIR', 'Location', 'best');
    xlim([10 Fs/2]);
end

sgtitle('RESPUESTA EN FASE - TODOS LOS MÉTODOS', 'FontSize', 14, 'FontWeight', 'bold');



