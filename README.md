# Filtros_SySII

## Descripción del Proyecto

Este proyecto contiene el diseño e implementación de tres tipos fundamentales de filtros para un curso de **Sistemas y Señales II**:

1. **Filtro Analógico**: Butterworth de paso bajo (orden 4, $f_c = 1000$ Hz)
2. **Filtro IIR**: Digital Butterworth (orden 5, $f_c = 500$ Hz)
3. **Filtro FIR**: Con ventana Hamming (orden 64, $f_c = 1000$ Hz)

## Estructura del Proyecto

```
Filtros_SySII/
├── scripts/                      # Scripts MATLAB
│   ├── filtro_analogico.m       # Diseño de filtro analógico
│   ├── filtro_iir.m             # Diseño de filtro IIR
│   ├── filtro_fir.m             # Diseño de filtro FIR
│   └── main_generar_filtros.m   # Script maestro
├── figures/                      # Gráficas generadas
│   ├── filtro_analogico.png
│   ├── filtro_iir.png
│   ├── filtro_fir.png
│   └── filtro_fir_impulso.png
├── data/                         # Datos y resultados
│   ├── filtro_analogico.mat
│   ├── filtro_iir.mat
│   └── filtro_fir.mat
├── docs/                         # Documentación
│   └── Informe_Filtros.tex      # Informe en LaTeX
└── README.md                     # Este archivo
```

## Cómo Ejecutar

### Requisitos

- MATLAB R2021a o superior
- Signal Processing Toolbox

### Ejecución

1. Abrir MATLAB y navegar al directorio del proyecto:
   ```matlab
   cd('/home/user/Filtros_SySII')
   ```

2. Ejecutar el script maestro:
   ```matlab
   run('scripts/main_generar_filtros.m')
   ```

Este script ejecutará automáticamente:
- `filtro_analogico.m`
- `filtro_iir.m`
- `filtro_fir.m`

### Salida

Se generarán automáticamente:
- **Gráficas**: Diagramas de Bode (magnitud y fase) en formato PNG
- **Datos**: Archivos .mat con los resultados numéricos
- **Informe**: Documento LaTeX compilable en Overleaf

## Especificaciones de los Filtros

### Filtro Analógico Butterworth

| Parámetro | Valor |
|-----------|-------|
| Tipo | Paso Bajo |
| Orden | 4 |
| Frecuencia de Corte | 1000 Hz (6283.19 rad/s) |
| Atenuación @ Fc | -3 dB |
| Pendiente | 80 dB/década |

### Filtro IIR Butterworth Digital

| Parámetro | Valor |
|-----------|-------|
| Tipo | Paso Bajo |
| Orden | 5 |
| Frecuencia de Muestreo | 5000 Hz |
| Frecuencia de Corte | 500 Hz |
| Método | Transformación Bilineal |
| Estabilidad | Garantizada |

### Filtro FIR con Ventana Hamming

| Parámetro | Valor |
|-----------|-------|
| Tipo | Paso Bajo |
| Orden | 64 (65 coeficientes) |
| Ventana | Hamming |
| Frecuencia de Muestreo | 8000 Hz |
| Frecuencia de Corte | 1000 Hz |
| Fase | Lineal |

## Contenidos de Cada Script

### `filtro_analogico.m`
- Diseña un filtro Butterworth analógico usando `butter(orden, Wc, 's')`
- Calcula la respuesta en frecuencia
- Genera gráficas de Bode (magnitud y fase)
- Muestra información de polos

### `filtro_iir.m`
- Diseña un filtro IIR digital usando transformación bilineal
- Verifica estabilidad (polos dentro del círculo unitario)
- Genera diagramas de Bode
- Analiza frecuencia de corte real

### `filtro_fir.m`
- Diseña un filtro FIR con ventana Hamming
- Verifica simetría de coeficientes (fase lineal)
- Genera gráficas de Bode y respuesta al impulso
- Analiza rizado y atenuación

### `main_generar_filtros.m`
- Ejecuta todos los scripts de diseño
- Proporciona retroalimentación visual del progreso
- Resumen de archivos generados

## Resultados

### Gráficas Generadas

Cada filtro produce gráficas que muestran:

1. **Respuesta en Magnitud** (dB):
   - Eje X: Frecuencia en escala logarítmica
   - Eje Y: Magnitud en decibelios
   - Línea de referencia: Punto de -3 dB

2. **Respuesta en Fase** (grados):
   - Eje X: Frecuencia en escala logarítmica
   - Eje Y: Fase en grados
   - Muestra el comportamiento de fase del filtro

### Datos Guardados

Cada archivo `.mat` contiene:
- `w` o `f`: Vector de frecuencias
- `mag_dB`: Magnitud en decibelios
- `phase_deg`: Fase en grados
- Parámetros de diseño
- Coeficientes del filtro

## Informe LaTeX

El archivo `Informe_Filtros.tex` contiene:

1. **Introducción**: Conceptos básicos de filtros
2. **Fundamentos Teóricos**: Matemática de filtros analógicos, IIR y FIR
3. **Especificaciones**: Detalles técnicos de cada filtro
4. **Procedimiento**: Pasos de diseño e implementación
5. **Resultados**: Análisis de gráficas y comportamiento
6. **Comparación**: Tabla comparativa de características
7. **Conclusiones**: Resumen y recomendaciones
8. **Referencias**: Bibliografía académica

El documento incluye:
- Ecuaciones matemáticas en LaTeX
- Gráficas incrustadas de los resultados
- Tablas de especificaciones
- Código MATLAB comentado
- Análisis detallado de cada filtro

## Sincronización con Overleaf

Este repositorio está sincronizado con Overleaf. Los cambios en los archivos `.tex` se sincronizarán automáticamente cuando se realicen `push` al repositorio.

Para compilar el PDF en Overleaf:
1. Acceder al proyecto Overleaf
2. El archivo compilará automáticamente
3. El PDF se generará en la pestaña "PDF"

## Notas Importantes

- Los scripts requieren la Signal Processing Toolbox de MATLAB
- Las gráficas se guardan en formato PNG en 300 DPI para buena calidad
- Los datos se guardan en formato MATLAB (.mat) para análisis posterior
- El informe puede compilarse en cualquier editor de LaTeX (Overleaf, TeXLive, MiKTeX, etc.)

## Contacto y Soporte

Para preguntas sobre el contenido técnico, consulte el documento `Informe_Filtros.pdf`.

---

**Última actualización**: Noviembre 2025
