llave <- c("DIRECTORIO", "SECUENCIA_P", "ORDEN")

modulos <- list(
  TIC = list(patron = "tecnologias.*informacion.*comunicacion",
             campos = c(llave, "SECUENCIA_ENCUESTA", "P1084", "FEX_C"),
             casos = 221043L, columnas = 89L),
  Personas = list(patron = "caracteristicas.*composicion.*hogar",
                  campos = c(llave, "SECUENCIA_ENCUESTA", "P6040", "P6020", "FEX_C"),
                  casos = 235350L, columnas = 78L),
  Diseño = list(patron = "variables.*diseno.*muestral",
                campos = c(llave, "MPIO", "FEX_C"),
                casos = 235350L, columnas = 11L)
)

sin_acentos <- function(x) {
  tolower(iconv(enc2utf8(x), from = "UTF-8", to = "ASCII//TRANSLIT"))
}

leer_modulo <- function(nombre, ficha, archivos) {
  normalizados <- sin_acentos(basename(archivos))
  extraidos <- archivos[endsWith(normalizados, ".csv") &
                          grepl(ficha$patron, normalizados)]
  contenedor <- "CSV extraído"
  if (length(extraidos) == 1L) {
    ruta <- extraidos
  } else if (length(extraidos) == 0L) {
    zips <- archivos[endsWith(normalizados, ".zip")]
    candidatos <- lapply(zips, function(zip) {
      miembros <- utils::unzip(zip, list = TRUE)$Name
      titulos <- sin_acentos(basename(miembros))
      miembros[endsWith(titulos, ".csv") & grepl(ficha$patron, titulos)]
    })
    if (sum(lengths(candidatos)) != 1L) {
      stop("Se esperaba un CSV de ", nombre, " en DATOS, suelto o dentro de un ZIP.")
    }
    indice <- which(lengths(candidatos) == 1L)
    temporal <- tempfile("ecv_")
    dir.create(temporal)
    on.exit(unlink(temporal, recursive = TRUE), add = TRUE)
    miembro <- candidatos[[indice]]
    utils::unzip(zips[indice], files = miembro, exdir = temporal, junkpaths = TRUE)
    ruta <- file.path(temporal, basename(miembro))
    contenedor <- basename(zips[indice])
  } else {
    stop("Hay varios CSV de ", nombre, ". Conserva una sola copia activa en DATOS.")
  }

  cabecera <- names(utils::read.csv2(ruta, nrows = 0L, check.names = FALSE,
                                      fileEncoding = "UTF-8-BOM"))
  ausentes <- setdiff(ficha$campos, cabecera)
  if (anyDuplicated(cabecera) || length(ausentes) ||
      length(cabecera) != ficha$columnas) {
    stop("Cabecera incompatible con ECV 2025 en ", nombre,
         ". Columnas requeridas ausentes: ", paste(ausentes, collapse = ", "))
  }
  tipos <- ifelse(cabecera %in% ficha$campos, "character", "NULL")
  datos <- utils::read.csv2(ruta, colClasses = tipos, na.strings = c("", "NA"),
                            check.names = FALSE, fill = FALSE, row.names = NULL,
                            fileEncoding = "UTF-8-BOM")

  # Una línea por caso en los CSV oficiales. Una copia textual conserva todas las columnas.
  lineas <- readLines(ruta, encoding = "UTF-8", warn = FALSE)[-1L]
  if (length(lineas) != nrow(datos)) {
    stop("El número de líneas difiere del número de filas CSV en ", nombre, ".")
  }
  repetidas <- duplicated(lineas)
  datos <- datos[!repetidas, , drop = FALSE]
  if (nrow(datos) != ficha$casos) {
    stop("Cantidad de casos únicos distinta del catálogo ECV 2025 en ", nombre, ".")
  }

  list(datos = datos, fuente = data.frame(
    módulo = nombre, archivo = basename(ruta), contenedor = contenedor,
    filas_originales = length(lineas), columnas_originales = length(cabecera),
    columnas_leídas = length(ficha$campos), copias_exactas = sum(repetidas),
    filas_tras_deduplicar = nrow(datos),
    sha256 = digest::digest(ruta, algo = "sha256", file = TRUE)
  ))
}

importar_ecv <- function() {
  archivos <- list.files("DATOS", full.names = TRUE, recursive = TRUE)
  archivos <- archivos[!startsWith(archivos, "DATOS/procesados/")]
  entradas <- lapply(names(modulos), function(nombre) {
    leer_modulo(nombre, modulos[[nombre]], archivos)
  })
  setNames(entradas, names(modulos))
}
