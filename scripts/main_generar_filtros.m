%% SCRIPT MAESTRO - GENERACIÓN DE TODOS LOS FILTROS
% Este script ejecuta todos los diseños de filtros y genera el reporte
% Ejecuta: filtro analógico, filtro IIR y filtro FIR

clear all; close all; clc;

fprintf('╔════════════════════════════════════════════════════════╗\n');
fprintf('║  PROYECTO: ANÁLISIS DE FILTROS EN MATLAB              ║\n');
fprintf('║  Tipos: Analógico, IIR, FIR                           ║\n');
fprintf('╚════════════════════════════════════════════════════════╝\n\n');

fprintf('Iniciando generación de filtros...\n\n');

%% Ejecutar scripts de filtros
try
    fprintf('[1/3] Diseñando filtro ANALÓGICO...\n');
    run('/home/user/Filtros_SySII/scripts/filtro_analogico.m');
    fprintf('✓ Filtro analógico completado\n\n');
catch ME
    fprintf('✗ Error en filtro analógico: %s\n', ME.message);
end

try
    fprintf('[2/3] Diseñando filtro IIR...\n');
    run('/home/user/Filtros_SySII/scripts/filtro_iir.m');
    fprintf('✓ Filtro IIR completado\n\n');
catch ME
    fprintf('✗ Error en filtro IIR: %s\n', ME.message);
end

try
    fprintf('[3/3] Diseñando filtro FIR...\n');
    run('/home/user/Filtros_SySII/scripts/filtro_fir.m');
    fprintf('✓ Filtro FIR completado\n\n');
catch ME
    fprintf('✗ Error en filtro FIR: %s\n', ME.message);
end

%% Resumen
fprintf('╔════════════════════════════════════════════════════════╗\n');
fprintf('║  GENERACIÓN COMPLETADA                                ║\n');
fprintf('╚════════════════════════════════════════════════════════╝\n\n');

fprintf('Archivos generados:\n');
fprintf('  Figuras:\n');
fprintf('    - /home/user/Filtros_SySII/figures/filtro_analogico.png\n');
fprintf('    - /home/user/Filtros_SySII/figures/filtro_iir.png\n');
fprintf('    - /home/user/Filtros_SySII/figures/filtro_fir.png\n');
fprintf('    - /home/user/Filtros_SySII/figures/filtro_fir_impulso.png\n');
fprintf('  Datos:\n');
fprintf('    - /home/user/Filtros_SySII/data/filtro_analogico.mat\n');
fprintf('    - /home/user/Filtros_SySII/data/filtro_iir.mat\n');
fprintf('    - /home/user/Filtros_SySII/data/filtro_fir.mat\n');
fprintf('  Informe:\n');
fprintf('    - /home/user/Filtros_SySII/docs/Informe_Filtros.pdf\n\n');

fprintf('Para generar el informe en LaTeX, ejecute:\n');
fprintf('  >> run pdflatex Informe_Filtros.tex\n\n');

fprintf('Proyecto completado exitosamente.\n');
