ejecutar_ecv <- function() {
  paquetes <- c("digest", "ggplot2")
  faltantes <- paquetes[!vapply(paquetes, requireNamespace, logical(1), quietly = TRUE)]
  if (length(faltantes)) {
    stop("Instala primero las dependencias: ", paste(faltantes, collapse = ", "))
  }
  if (!dir.exists("DATOS")) stop("Ejecuta desde la raíz del proyecto con la carpeta DATOS.")
  for (archivo in c("01_importacion", "02_validacion_limpieza",
                    "03_analisis_exploratorio", "04_visualizaciones")) {
    source(file.path("R", paste0(archivo, ".R")), local = TRUE, encoding = "UTF-8")
  }

  limpieza <- limpiar_ecv(importar_ecv())
  eda <- explorar_ecv(limpieza$base)
  library(ggplot2)
  graficos <- crear_graficos(limpieza$base, eda)

  tablas <- c(limpieza[setdiff(names(limpieza), "base")], eda)
  dir.create("DATOS/procesados", recursive = TRUE, showWarnings = FALSE)
  dir.create("RESULTADOS/tablas", recursive = TRUE, showWarnings = FALSE)
  dir.create("RESULTADOS/graficos", recursive = TRUE, showWarnings = FALSE)
  saveRDS(limpieza$base, "DATOS/procesados/personas_tic_ecv2025.rds")
  for (nombre in names(tablas)) {
    utils::write.csv2(tablas[[nombre]], file.path("RESULTADOS/tablas", paste0(nombre, ".csv")),
                      row.names = FALSE, fileEncoding = "UTF-8")
  }
  for (nombre in names(graficos)) {
    ggplot2::ggsave(file.path("RESULTADOS/graficos", paste0(nombre, ".png")), graficos[[nombre]],
                    width = 8.6, height = if (nombre == "departamentos") 12.8 else 4.6,
                    units = "in", dpi = 180, bg = "white")
  }
  list(limpieza = limpieza, eda = eda, graficos = graficos)
}

if (sys.nframe() == 0L) invisible(ejecutar_ecv())
