clear; close all; clc;

%% ========================================================================
%  DISEÑAR FILTROS 
% Parámetros del sistema
Fs = 64000;
f_central = [102.4, 512, 2560, 12800, 5*12800];
f_corte = zeros(1,5);
f_corte(1) = f_central(1) / sqrt(5);
for i = 2:5
    f_corte(i) = sqrt(f_central(i-1) * f_central(i));
end

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

%% FILTROS IIR (INVAR)

% Crear pasabandas para el último filtro
Wp4 = 2*pi*[f_corte(4), f_corte(5)];
Ws4 = 2*pi*[f_central(3), f_central(5)];

[n4, Wn4] = buttord(Wp4, Ws4, Ap, As, 's');

n_max_inv = max(n4, n_max_analog);

[b, a] = butter(n_max_inv, Wn4, 'bandpass', 's');



% Usar filtros analógicos creados previamente
for i=1:3
    [num_inv{i}, den_inv{i}] = impinvar(num_analog{i}, den_analog{i}, Fs);
end

[num_inv{4}, den_inv{4}] = impinvar(b, a, Fs);




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

fprintf('\nFILTROS IIR (INVAR):\n');
fprintf('  Orden utilizado: %d\n', n_max_analog);
for i = 1:4
    fprintf('  Banda %d: %d polos, %d ceros\n', i, length(den_inv{i})-1, length(num_inv{i})-1);
end

fprintf('\nFILTROS FIR:\n');
ordenes_fir = [M1-1, M2-1, M3-1, M4-1];
for i = 1:4
    fprintf('  Banda %d: Orden = %d coeficientes\n', i, ordenes_fir(i)+1);
end

fprintf('\nFRECUENCIAS DEL SISTEMA:\n');
fprintf('  Centrales: %.1f, %.1f, %.1f, %.1f Hz\n', f_central);
fprintf('  Corte (-3dB): %.1f, %.1f, %.1f, %.1f, %.1f Hz\n\n', f_corte);
