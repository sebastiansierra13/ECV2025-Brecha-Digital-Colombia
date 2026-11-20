# Diccionario de variables

Unidad de análisis: persona de 5 años o más incluida en el capítulo TIC. Características y diseño tienen cobertura de todas las edades en la muestra.

| Variable | Módulo | Tipo y unidad | Valores y uso |
|---|---|---|---|
| P1084 | TIC | Ordinal, una categoría por persona | 1 todos los días, 2 al menos semanalmente con menor frecuencia que diario, 3 al menos mensualmente con menor frecuencia que semanal, 4 al menos anualmente con menor frecuencia que mensual, 5 no utiliza. El catálogo enumera esos cinco códigos. Los menores de 5 años están fuera del universo. El campo define la intensidad de uso desde cualquier lugar y dispositivo. |
| P6040 | Características y composición | Cuantitativa discreta, años cumplidos | Enteros no negativos, con cero válido para menores de un año. El diccionario no especifica código especial para la edad y muestra 0–108 en esta entrega. Define elegibilidad y agrupación etaria. |
| P6020 | Características y composición | Nominal, una categoría por persona | 1 Hombre, 2 Mujer. El catálogo enumera ambos códigos para sexo al nacer. Permite describir la composición y comparar la frecuencia de uso. |
| MPIO | Diseño muestral | Identificador nominal, cinco caracteres numéricos | Código DANE de municipio o unidad geográfica equivalente. Los dos primeros caracteres corresponden al dominio departamental. La rutina comprueba la longitud y el prefijo DIVIPOLA. |
| FEX_C | Diseño muestral, también presente en TIC y Composición | Cuantitativa continua, factor de expansión por persona | Factor calibrado dentro de los bloques. Se utiliza la versión de Diseño. Debe ser positivo y finito. |
| DIRECTORIO | Tres módulos | Identificador de vivienda, texto | Componente de la llave de persona. Se requiere un valor de dígitos. |
| SECUENCIA_P | Tres módulos | Identificador de hogar, texto | Componente de la llave dentro de la vivienda. Se requiere un valor de dígitos. |
| ORDEN | Tres módulos | Identificador de persona, texto | Componente de la llave dentro del hogar. Se requiere un valor de dígitos. |
| SECUENCIA_ENCUESTA | TIC y Composición | Identificador auxiliar, texto | Se coteja después del cruce por la llave compuesta. |

| Derivada | Definición |
|---|---|
| departamento_codigo | Prefijo de dos caracteres de MPIO. Incluye Bogotá D.C. como dominio propio. |
| departamento | Etiqueta DIVIPOLA. San Andrés se identifica como cabecera por la cobertura de la ECV. |
| grupo_edad | 5–11, 12–17, 18–28, 29–44, 45–59 y 60+. Cortes elegidos para el EDA. Los dos primeros tramos separan niñez y adolescencia escolar. |
| diario y cualquier uso | Para diario, P1084 = 1. Para cualquier uso, P1084 entre 1 y 4. En ambos, P1084 = 5 forma parte del denominador. |

Los blancos y los valores fuera de código se auditan por separado. Los resultados de la auditoría de esta entrega están en [calidad.csv](../RESULTADOS/tablas/calidad.csv).

**Fuentes DANE**

- [P1084](https://microdatos.dane.gov.co/index.php/catalog/905/variable/F15/V837?name=P1084).
- [P6040](https://microdatos.dane.gov.co/index.php/catalog/905/variable/F9/V473?name=P6040).
- [P6020](https://microdatos.dane.gov.co/index.php/catalog/905/variable/F9/V471?name=P6020).
- [MPIO y FEX_C en el módulo de diseño](https://microdatos.dane.gov.co/index.php/catalog/905/data-dictionary/F30).
- [DIVIPOLA](https://www.dane.gov.co/index.php/sistema-estadistico-nacional-sen/normas-y-estandares/nomenclaturas-y-clasificaciones/nomenclaturas/codificacion-de-la-division-politica-administrativa-de-colombia-divipola).
