% Script para extraer órdenes de los filtros sin gráficas
clear; close all; clc;

% Parámetros del sistema
Fs = 64000;
f_central = [102.4, 512, 2560, 12800];
f_corte = zeros(1,5);
f_corte(1) = f_central(1) / sqrt(5);
for i = 2:4
    f_corte(i) = sqrt(f_central(i-1) * f_central(i));
end
f_corte(5) = f_central(4) * sqrt(5);

Ap = 3; As = 15;

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
Wp4_inv = 2*pi*[f_corte(4), f_corte(5)];
Ws4_inv = 2*pi*[f_central(3), f_corte(5)];
[n4_inv, Wn4_inv] = buttord(Wp4_inv, Ws4_inv, Ap, As, 's');
n_max_inv = max(n4_inv, n_max_analog);

[b, a] = butter(n_max_inv, Wn4_inv, 'bandpass', 's');

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

M2 = ceil(3.3*Fs/df(2)); M2 = min(M2, 1000);
if mod(M2,2)==0, M2=M2+1; end
if M2 < 3, M2 = 3; end

M3 = ceil(3.3*Fs/df(3)); M3 = min(M3, 1000);
if mod(M3,2)==0, M3=M3+1; end
if M3 < 3, M3 = 3; end

M4 = ceil(3.3*Fs/df(4)); M4 = min(M4, 1000);
if mod(M4,2)==0, M4=M4+1; end
if M4 < 3, M4 = 3; end

%% MOSTRAR RESULTADOS
fprintf('\n=== ÓRDENES DE FILTROS CALCULADOS ===\n\n');

fprintf('ÓRDENES POR BANDA:\n');
fprintf('Banda 1 - Analógico: %d | IIR Bilineal: %d | IIR Invar: %d | FIR: %d\n', n_max_analog, n_max_iir, n_max_inv, M1-1);
fprintf('Banda 2 - Analógico: %d | IIR Bilineal: %d | IIR Invar: %d | FIR: %d\n', n_max_analog, n_max_iir, n_max_inv, M2-1);
fprintf('Banda 3 - Analógico: %d | IIR Bilineal: %d | IIR Invar: %d | FIR: %d\n', n_max_analog, n_max_iir, n_max_inv, M3-1);
fprintf('Banda 4 - Analógico: %d | IIR Bilineal: %d | IIR Invar: %d | FIR: %d\n', n_max_analog, n_max_iir, n_max_inv, M4-1);

fprintf('\nORDENES MÁXIMOS:\n');
fprintf('Analógico: %d\n', n_max_analog);
fprintf('IIR Bilineal: %d\n', n_max_iir);
fprintf('IIR Invar: %d\n', n_max_inv);

fprintf('\nMÁXIMO DE COEFICIENTES FIR:\n');
fprintf('Banda 1: %d\n', M1);
fprintf('Banda 2: %d\n', M2);
fprintf('Banda 3: %d\n', M3);
fprintf('Banda 4: %d\n', M4);
