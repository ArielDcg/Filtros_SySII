% Frecuencia elegida: 512
format long;

%% Reducir orden de pasabandas análogo
disp("=========== Análogo ===========");
num = num_analog{2};
den = den_analog{2};

mostrar_fracciones_parciales(num, den, 's');


%% Reducir orden de pasabandas IIR
disp("=========== IIR ===========");
num = num_iir{2};
den = den_iir{2};

mostrar_fracciones_parciales(num, den, 'z');


%% Reducir orden de pasaaltos FIR
disp("=========== FIR ===========");
disp('La función de transferencia de un  filtro FIR es un polinomio: no es posible realiar fracciones parciales.')