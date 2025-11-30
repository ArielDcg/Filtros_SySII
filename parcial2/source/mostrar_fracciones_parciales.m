function mostrar_fracciones_parciales(num, den, tipo)
    if tipo == 's'
        [z, p, k] = residue(num, den);

        % Parte polinómica si existe
        if ~isempty(k)
            fprintf('Parte polinómica K(s) = ');
            for i = 1:length(k)
                if i == 1
                    fprintf('%g', k(i));
                else
                    fprintf(' + %g*s^%d', k(i), length(k)-i);
                end
            end
            fprintf('\n');
        else
            fprintf('No hay parte polinómica (K(s) = 0)\n');
        end


        % Fracciones parciales
        fprintf('Fracciones parciales:\n');
        for i = 1:length(z)
            if abs(z(i)) < 1e-12
                continue  % ignorar residuos casi cero
            end
    
            a = real(z(i));
            b = imag(z(i));
            c = real(p(i));
            d = imag(p(i));
            
            fprintf('  (%g %+gi) / (s - (%g %+gi))\n', a, b, c, d);
        end



    elseif tipo == 'z'
        [z, p, k] = residue(num, den);

        
        % Parte polinómica si existe   
        if ~isempty(k)
            fprintf('Parte polinómica K(z) = ');
            for i = 1:length(k)
                if i == 1
                    fprintf('%g', k(i));
                else
                    fprintf(' + %g*z^%d', k(i), length(k)-i);
                end
            end
            fprintf('\n');
        else
            fprintf('No hay parte polinómica (K(z) = 0)\n');
        end

        % Fracciones parciales
        fprintf('Fracciones parciales:\n');
        for i = 1:length(z)
            if abs(z(i)) < 1e-12
                continue  % ignorar residuos casi cero
            end
    
            a = real(z(i));
            b = imag(z(i));
            c = real(p(i));
            d = imag(p(i));
            
            fprintf('  (%g %+gi) / (z - (%g %+gi))\n', a, b, c, d);
        end

    else
        error("Tipo incorrecto.")
    end

end
