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

tipo = input("Elegir tipo de filtro:\n1: Analógico\n2: IIR bilineal\n3: IIR invar\n4: FIR\n5: Comparar todos\nSelección: ");

% Definición de ganancias por banda
ganancias = input('Ingrese un vector de ganancias (por ejemplo [1 0.5 2 0]): ');



if tipo == 5
    [nombre_analog, y_bandas_analog, y_out_analog] = calcular_filtro_audio(1, ganancias, N_samples, num_analog, den_analog, num_iir, den_iir, num_inv, den_inv, num_fir, x, t);
    [nombre_iir, y_bandas_iir, y_out_iir] = calcular_filtro_audio(2, ganancias, N_samples, num_analog, den_analog, num_iir, den_iir, num_inv, den_inv, num_fir, x, t);
    [nombre_inv, y_bandas_inv, y_out_inv] = calcular_filtro_audio(3, ganancias, N_samples, num_analog, den_analog, num_iir, den_iir, num_inv, den_inv, num_fir, x, t);
    [nombre_fir, y_bandas_fir, y_out_fir] = calcular_filtro_audio(4, ganancias, N_samples, num_analog, den_analog, num_iir, den_iir, num_inv, den_inv, num_fir, x, t);

     % VISUALIZACIÓN DE RESULTADOS
    % Eje de frecuencia para plotear
    N = length(x);
    f_axis = linspace(0, Fs/2, floor(N/2)+1);
    
    % Espectro de entrada (mitad positiva)
    X_fft = fft(x);
    X_mag = 20*log10(abs(X_fft(1:length(f_axis))) + eps);
    
    
    
    figure('Name', "Comparación de filtros");
    
    % --- Subplot 1: Espectro Entrada vs Salida Total ---
    subplot(2, 2, 1);
    Y_fft = fft(y_out_analog);
    Y_mag = 20*log10(abs(Y_fft(1:length(f_axis))) + eps);
    
    plot(f_axis, X_mag, 'Color', [0.7 0.7 0.7], 'LineWidth', 1.5); hold on;
    plot(f_axis, Y_mag, 'b', 'LineWidth', 1.5);
    title(['Entrada vs Salida Total - ' nombre_analog]);
    ylabel('Magnitud (dB)'); xlabel('Frecuencia (Hz)');
    legend('Entrada Original', 'Salida Ecualizada');
    grid on; xlim([20 Fs/2]); ylim([-120 max(X_mag)+10]);
    set(gca, 'XScale', 'log');
    title("Análogo")


    subplot(2, 2, 2);
    Y_fft = fft(y_out_iir);
    Y_mag = 20*log10(abs(Y_fft(1:length(f_axis))) + eps);
    
    plot(f_axis, X_mag, 'Color', [0.7 0.7 0.7], 'LineWidth', 1.5); hold on;
    plot(f_axis, Y_mag, 'b', 'LineWidth', 1.5);
    title(['Entrada vs Salida Total - ' nombre_iir]);
    ylabel('Magnitud (dB)'); xlabel('Frecuencia (Hz)');
    legend('Entrada Original', 'Salida Ecualizada');
    grid on; xlim([20 Fs/2]); ylim([-120 max(X_mag)+10]);
    set(gca, 'XScale', 'log');
    title("IIR bilineal");


     subplot(2, 2, 3);
    Y_fft = fft(y_out_inv);
    Y_mag = 20*log10(abs(Y_fft(1:length(f_axis))) + eps);
    
    plot(f_axis, X_mag, 'Color', [0.7 0.7 0.7], 'LineWidth', 1.5); hold on;
    plot(f_axis, Y_mag, 'b', 'LineWidth', 1.5);
    title(['Entrada vs Salida Total - ' nombre_inv]);
    ylabel('Magnitud (dB)'); xlabel('Frecuencia (Hz)');
    legend('Entrada Original', 'Salida Ecualizada');
    grid on; xlim([20 Fs/2]); ylim([-120 max(X_mag)+10]);
    set(gca, 'XScale', 'log');
    title("IIR invar");


     subplot(2, 2, 4);
    Y_fft = fft(y_out_fir);
    Y_mag = 20*log10(abs(Y_fft(1:length(f_axis))) + eps);
    
    plot(f_axis, X_mag, 'Color', [0.7 0.7 0.7], 'LineWidth', 1.5); hold on;
    plot(f_axis, Y_mag, 'b', 'LineWidth', 1.5);
    title(['Entrada vs Salida Total - ' nombre_fir]);
    ylabel('Magnitud (dB)'); xlabel('Frecuencia (Hz)');
    legend('Entrada Original', 'Salida Ecualizada');
    grid on; xlim([20 Fs/2]); ylim([-120 max(X_mag)+10]);
    set(gca, 'XScale', 'log');
    title("FIR");
        
    sgtitle('Comparación de filtros aplicados en el audio', 'FontSize', 14, 'FontWeight', 'bold');

elseif tipo == 1 || tipo == 2 || tipo == 3 || tipo == 4
    [nombre_sys, y_bandas, y_out] = calcular_filtro_audio(tipo, ganancias, N_samples, num_analog, den_analog, num_iir, den_iir, num_inv, den_inv, num_fir, x, t);
    
    
    
    % VISUALIZACIÓN DE RESULTADOS
    % Eje de frecuencia para plotear
    N = length(x);
    f_axis = linspace(0, Fs/2, floor(N/2)+1);
    
    % Espectro de entrada (mitad positiva)
    X_fft = fft(x);
    X_mag = 20*log10(abs(X_fft(1:length(f_axis))) + eps);
    
    
    
    figure('Name', nombre_sys);
    
    % --- Subplot 1: Espectro Entrada vs Salida Total ---
    subplot(3, 2, [1 2]);
    Y_fft = fft(y_out);
    Y_mag = 20*log10(abs(Y_fft(1:length(f_axis))) + eps);
    
    plot(f_axis, X_mag, 'Color', [0.7 0.7 0.7], 'LineWidth', 1.5); hold on;
    plot(f_axis, Y_mag, 'b', 'LineWidth', 1.5);
    title(['Entrada vs Salida Total - ' nombre_sys]);
    ylabel('Magnitud (dB)'); xlabel('Frecuencia (Hz)');
    legend('Entrada Original', 'Salida Ecualizada');
    grid on; xlim([20 Fs/2]); ylim([-120 max(X_mag)+10]);
    set(gca, 'XScale', 'log');
    
    % --- Subplots 2-5: Espectros Individuales por Banda ---
    colores_banda = {'r', 'g', 'm', 'b'};
    titulos_banda = {'Low (102 Hz)', 'Mid-Low (512 Hz)', 'Mid-High (2.5 kHz)', 'High (12.8 kHz)'};
    
    
        for b = 1:4
            subplot(3, 2, 2+b);
            B_fft = fft(y_bandas(:,b));
            B_mag = 20*log10(abs(B_fft(1:length(f_axis))) + eps);
            
            plot(f_axis, X_mag, 'Color', [0.8 0.8 0.8]); hold on;
            plot(f_axis, B_mag, colores_banda{b}, 'LineWidth', 1.5);
            
            title(sprintf('Banda %d: %s - G=%.2f', b, titulos_banda{b}, ganancias(b)));
            grid on; xlim([20 Fs/2]); set(gca, 'XScale', 'log'); ylim([-120 max(max(X_mag), max(B_mag))]);
        end
        
    sgtitle(['ANÁLISIS ESPECTRAL: ' nombre_sys], 'FontSize', 14, 'FontWeight', 'bold');
    
    
    
    
    %% ========================================================================
    %  PARTE 3: ESCUCHA Y GUARDADO DE AUDIO
    % ========================================================================
    
    fprintf('\n=== REPRODUCCIÓN DE AUDIO ===\n');
    
    
    
    %  NORMALIZACIÓN (IMPORTANTE)
    % Como aplicamos ganancia de 2, la señal puede salirse del rango [-1, 1].
    % Esto ajusta el volumen máximo a 1 para evitar que suene "roto" (clipping).
    max_val = max(abs(y_out));
    if max_val > 1
        senal_normalizada = y_out / max_val;
        fprintf('Aviso: La señal fue normalizada para evitar saturación.\n');
    else
        senal_normalizada = y_out;
    end
    
    % 3. REPRODUCIR EN MATLAB
    fprintf('Reproduciendo resultado del %s...\n', nombre_sys);
    fprintf('Presiona Ctrl+C o escribe "clear sound" en la consola para detener.\n');
    
    sound(senal_normalizada, Fs); 
    
    % 4. GUARDAR EN UN ARCHIVO NUEVO 
    % Esto crea un archivo .wav nuevo en la carpeta para que lo escuches fuera de MATLAB
    nombre_archivo_salida = 'Audio_Ecualizado.wav';
    audiowrite(nombre_archivo_salida, senal_normalizada, Fs);
    fprintf('Archivo guardado como: %s\n', nombre_archivo_salida);
end