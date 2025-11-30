addpath('source');
run('definir_filtros.m');

running = true;
while running
    option = input(['1: Graficar filtros\n' ...
                    '2: Probar filtros con audio\n' ...
                    '3: Reducir orden de filtros\n' ...
                    '4: Salir\n\nSelección: ']);
    if option == 1
        run('graficar_filtros.m');
    elseif option == 2
        run('prueba_de_filtros.m');
    elseif option == 3
        run('punto5');
    elseif option == 4
        running = false;
    else
        disp('Opción inválida. Intente de nuevo.');
    end
end
