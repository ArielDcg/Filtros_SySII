function [nombre_sys, y_bandas, y_out] = calcular_filtro_audio(tipo, ganancias, N_samples, num_analog, den_analog, num_iir, den_iir, num_inv, den_inv, num_fir, x, t)

    if tipo == 1
        nombre_sys = "Sistema analógico";
    elseif tipo == 2
        nombre_sys = "Sistema IIR bilineal";
    elseif tipo == 3
        nombre_sys = "Sistema IIR invar";
    elseif tipo == 4
        nombre_sys = "Sistema FIR";
    else
        error("Input incorrecto.");
    end
    



    y_bandas = zeros(N_samples, 4);
    
    if tipo == 1
        for i = 1:4
            sys = tf(num_analog{i}, den_analog{i});
            y_bandas(:,i) = ganancias(i) * lsim(sys, x, t);
        end
    elseif tipo == 2  % IIR bilineal
        for i = 1:4
            y_bandas(:,i) = ganancias(i) * filter(num_iir{i}, den_iir{i}, x);
        end
    elseif tipo == 3 % IIR invar
        for i = 1:4
            y_bandas(:,i) = ganancias(i) * filter(num_inv{i}, den_inv{i}, x);
        end
            
    elseif tipo == 4  % FIR digital
        for i = 1:4
            y_bandas(:,i) = ganancias(i) * filter(num_fir{i}, 1, x);  % FIR: den=1
        end
    end
    
    % Suma de todas las bandas
    y_out = sum(y_bandas, 2);

end