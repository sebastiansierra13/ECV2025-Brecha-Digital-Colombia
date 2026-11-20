# Metodología y trazabilidad

## Procedencia e integración

La fuente principal son los CSV locales entregados con los tres paquetes del catálogo 905 de la ECV 2025. Se verificaron las dimensiones de TIC (221.043 × 89), características y composición (235.350 × 78) y diseño (235.350 × 11) contra el diccionario. Los conteos de los cinco códigos de P1084 y los dos códigos de P6020 coinciden con sus fichas. El [inventario reproducible](../RESULTADOS/tablas/auditoria.csv) incluye tamaños, columnas leídas y SHA-256 de los CSV locales. Las huellas identifican los archivos usados en esta ejecución.

La descripción breve del módulo de diseño en el portal menciona 2024, aunque el título del módulo dice ENCV 2025. El archivo local concilia las 235.350 llaves de personas y produce estimaciones concordantes con el boletín de 2025, como muestran los [controles de cruce](../RESULTADOS/tablas/uniones.csv) y el [cotejo con publicaciones](../RESULTADOS/tablas/cotejo_dane.csv). [Diccionario del módulo de diseño](https://microdatos.dane.gov.co/index.php/catalog/905/data-dictionary/F30).

La llave es el triplete DIRECTORIO, SECUENCIA_P y ORDEN. Se auditaron las copias textuales de filas completas y las llaves repetidas después de retirar copias exactas. El cruce detiene la ejecución si detecta una llave repetida con filas diferentes, falta alguna persona en el diseño o no coincide la cobertura esperada del capítulo TIC. Los 14.307 menores de 5 años quedan fuera de la pregunta por diseño. Se encontró una correspondencia única para las 221.043 personas elegibles y se conservaron todos esos registros.

## Criterios de limpieza

Se verifican edad entera no negativa, sexo dentro del catálogo, frecuencia en 1–5, MPIO de cinco dígitos con prefijo departamental reconocido y factor de expansión positivo y finito. Se documentan los vacíos y los valores inválidos por variable antes de aplicar un criterio común de casos completos. La auditoría local no detectó valores faltantes aplicables, inválidos, copias exactas ni llaves repetidas. Se unifica la base de comparación sin imputación. La secuencia de encuesta se coteja donde existe en ambos módulos.

Para el peso se toma FEX_C del archivo de diseño. Las diferencias máximas de las copias en TIC y Composición son de aproximadamente 0,000001, compatibles con precisión de exportación. El factor de diseño se aplica a personas, y su suma en el universo analizado aproxima el tamaño poblacional cubierto.

## Estimadores y límites

La proporción diaria por dominio es 100 × suma de FEX_C entre quienes reportan P1084 = 1, dividida por la suma de FEX_C de quienes tienen una categoría válida 1–5 en el dominio. La proporción de cualquier uso sigue la misma fórmula con códigos 1–4 en el numerador. En ambos casos se mantiene el código 5 en el denominador. El orden del Top 10 se define con estimaciones sin redondear y código DIVIPOLA ascendente para desempatar. Los tamaños de muestra se publican junto a cada indicador. El histograma, las cajas y los descriptivos de edad son muestrales. La moda es la edad exacta, en años cumplidos, con el mayor conteo sin ponderar. Si varias edades empatan en el máximo, se reportan todas.

Los 33 dominios corresponden a los 32 departamentos y Bogotá D.C. El prefijo de dos caracteres de MPIO identifica el dominio y se conservan los ceros iniciales. El dominio de San Andrés corresponde a la cabecera cubierta. Las cifras son estimaciones puntuales. El error muestral del diseño estratificado, multietápico y por conglomerados no se cuantifica en este EDA. El orden describe los datos ponderados sin establecer diferencias significativas ni relaciones causales. Las estimaciones solo corresponden a los dominios indicados.

El boletín permite cotejar el porcentaje de cualquier uso a un decimal para el total nacional, hombres y mujeres, Valle del Cauca y Vichada. La distribución completa de P1084 y el Top 10 de uso diario son resultados del proyecto calculados con los microdatos.

[Catálogo y cobertura](https://microdatos.dane.gov.co/index.php/catalog/905) · [Materiales técnicos](https://microdatos.dane.gov.co/index.php/catalog/905/related-materials) · [Boletín de resultados ECV 2025](https://www.dane.gov.co/files/operaciones/ECV/bol-ECV-2025.pdf)

## Validación de la ejecución

Se utilizó R 4.6.2 para Windows, rmarkdown 2.32, knitr 1.52, ggplot2 4.0.4, digest 0.6.39 y Pandoc 3.10 incluido en RStudio. La ejecución aislada a partir de ZIP con los CSV locales reprodujo las tablas analíticas. En copias temporales, se verificó la retirada de una fila exacta adicional y la detención ante una llave repetida con contenido distinto. Se verificaron los ocho gráficos exportados y la apertura local del HTML autocontenido en Edge.

En la revisión final, la ejecución desde los CSV originales reprodujo los 17 CSV de resultados y el RDS previo byte por byte. La comprobación independiente de las llaves y los factores validó las proporciones de uso diario y de cualquier uso a nivel nacional y por sexo al nacer, edad y dominio. El ajuste de presentación eliminó una columna de índices sin encabezado en tres tablas y mejoró la legibilidad del gráfico de los 33 dominios.
