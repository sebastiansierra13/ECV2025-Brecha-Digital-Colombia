# Brecha digital en Colombia · ECV 2025

Tarea I de Análisis Exploratorio de Datos. El informe describe con R Markdown la frecuencia de uso de internet por edad, sexo al nacer y departamento en la población de 5 años o más cubierta por la ECV 2025.

## Pregunta y objetivos

¿Cómo varía la frecuencia de uso de internet según la edad, el sexo al nacer y el departamento de residencia entre las personas de 5 años o más cubiertas por la ECV 2025 en Colombia?

El objetivo general es describir esa distribución y cuantificar sus diferencias por edad, sexo al nacer y dominio departamental. Los objetivos específicos son caracterizar las variables, auditar las llaves y la calidad de los datos, y estimar las proporciones ponderadas por grupo y territorio.

## Datos, limpieza y metodología

La fuente es la Encuesta Nacional de Calidad de Vida 2025 del DANE. Se integran los módulos TIC, Características y composición del hogar y Variables de diseño muestral mediante `DIRECTORIO`, `SECUENCIA_P` y `ORDEN`. Se revisan duplicados, coincidencia de llaves, valores faltantes y códigos válidos. La población de estudio comprende personas de cinco años o más. No se imputan respuestas.

Las variables centrales son `P1084` (frecuencia de internet), `P6040` (edad), `P6020` (sexo al nacer), `MPIO` (código geográfico) y `FEX_C` (factor de expansión calibrado). Las proporciones ponderadas usan el factor del módulo de diseño. El denominador incluye a quienes declaran no usar internet. La moda y los estadísticos de edad describen la muestra sin ponderar.

El análisis conservó 221.043 personas elegibles. La proporción ponderada de uso diario fue 66,09 % y la de cualquier uso fue 82,26 %. Atlántico encabezó el ranking de uso diario con 80,46 %. Son estimaciones puntuales. El estudio no calcula intervalos de confianza ni permite inferir causalidad. La cobertura de San Andrés corresponde a la cabecera de la encuesta.

La [descripción metodológica](DOCUMENTACION/metodologia.md) detalla los controles y las limitaciones. Los nombres y aportes del equipo deben diligenciarse con información real.

[Informe público en GitHub Pages](https://sebastiansierra13.github.io/ECV2025-Brecha-Digital-Colombia/PROYECTO_ECV2025.html) · [Repositorio](https://github.com/sebastiansierra13/ECV2025-Brecha-Digital-Colombia) · [Código del informe](PROYECTO_ECV2025.Rmd) · [Metodología](DOCUMENTACION/metodologia.md) · [Rúbrica y equipo](DOCUMENTACION/PLAN_Y_RUBRICA.md)

## Ejecutar en RStudio para Windows

1. Abre `ECV2025_Brecha_Digital.Rproj` con RStudio. En la consola del proyecto, instala las dependencias una vez.

   ```r
   install.packages(c("rmarkdown", "knitr", "ggplot2", "digest"), repos = "https://cloud.r-project.org")
   ```

2. Si acabas de clonar el proyecto, descarga estos tres paquetes desde [Archivos de datos de la ECV 2025](https://microdatos.dane.gov.co/index.php/catalog/905/get-microdata). Coloca los ZIP o los CSV extraídos en `DATOS/`, incluso en subcarpetas. Conserva una copia activa del CSV por módulo. Si también está su ZIP, se prioriza el CSV suelto.

   - `DBF-ECV-Tecnologias_informacion_comunicacion-2025.zip`
   - `DBF-ECV-Caracteristicas_composicion_hogar-2025.zip`
   - `DBF-ECV-Variables_diseno_muestral-2025.zip`

   El prefijo DBF es parte del nombre del paquete de descarga. La rutina utiliza los CSV oficiales separados por punto y coma, con coma decimal. Las demás versiones de los mismos archivos (DTA y SAV) pueden permanecer en sus carpetas.

3. Abre `PROYECTO_ECV2025.Rmd` y pulsa **Knit**. Se genera `PROYECTO_ECV2025.html` en la raíz. Para regenerarlo desde la consola de RStudio también puedes utilizar:

   ```r
   rmarkdown::render("PROYECTO_ECV2025.Rmd", encoding = "UTF-8")
   ```

   Desde una terminal con R en el PATH, `Rscript R/ejecutar.R` genera los CSV, PNG y RDS. Para compilar HTML fuera de RStudio, instala Pandoc o define `RSTUDIO_PANDOC` con la carpeta que contiene `pandoc.exe` de RStudio. Si la terminal hereda `LC_ALL=C.UTF-8` y R para Windows rechaza esa configuración, usa en PowerShell `$env:LC_ALL = 'English_United States.utf8'` antes de iniciar R.

## Archivos y resultados

- `R/` contiene la importación, auditoría, limpieza, EDA, gráficos y el punto de entrada compartido.
- `DATOS/` conserva los archivos originales en la ubicación en que se descargaron. La base analítica local `procesados/personas_tic_ecv2025.rds` contiene edad, sexo al nacer, grupo etario, frecuencia, departamento y peso. Git excluye los microdatos y el RDS.
- `RESULTADOS/tablas/` contiene CSV agregados en UTF-8, con separador `;` y coma decimal. Al importar códigos geográficos en una hoja de cálculo, indica que son texto para retener los ceros iniciales. La auditoría registra tamaños y huellas SHA-256. Las tablas incluyen las cinco frecuencias por edad, sexo y departamento.
- `RESULTADOS/graficos/` contiene ocho PNG. El HTML es autocontenido y sirve también sin conexión una vez descargado.
- `DOCUMENTACION/` contiene el diccionario, la metodología, la verificación de la rúbrica y la plantilla editable de portada.

## Publicación y entrega

1. Completa los campos editables de `params` en el encabezado de `PROYECTO_ECV2025.Rmd` (universidad, asignatura, docente, tres integrantes, fecha y contribuciones reales). Vuelve a compilar el informe para actualizar la ficha y la sección de contribuciones. Registra también los aportes y su evidencia en [Plan y rúbrica](DOCUMENTACION/PLAN_Y_RUBRICA.md).
2. Con tu cuenta de GitHub, crea un repositorio **público vacío** y copia su URL real. En esta carpeta configura Git con tu nombre y correo si aún hace falta. Revisa `git status --short --ignored`, añade los archivos con `git add .`, comprueba la lista con `git diff --cached --name-only` y realiza el commit. Añade la URL real con `git remote add origin` seguida de la URL y ejecuta `git push -u origin main`.
3. En GitHub, abre **Settings → Pages**, elige **Deploy from a branch**, `main` y `/ (root)`. Cuando termine el despliegue, copia la URL base que muestre GitHub Pages y añade `PROYECTO_ECV2025.html` como nombre de archivo al final. Comprueba el repositorio y el informe desde una ventana privada. [Documentación de GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site).
4. Completa [la portada editable](DOCUMENTACION/PORTADA_ENTREGA.md) con los integrantes y los dos enlaces reales. Expórtala a PDF, abre el archivo y prueba ambos hipervínculos antes de entregarlo.
