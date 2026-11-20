frecuencias <- c("Diario", "Semanal", "Mensual", "Anual", "No utiliza")
sexos <- c("Hombre", "Mujer")

departamentos <- c(
  "05" = "Antioquia", "08" = "Atlántico", "11" = "Bogotá D.C.",
  "13" = "Bolívar", "15" = "Boyacá", "17" = "Caldas", "18" = "Caquetá",
  "19" = "Cauca", "20" = "Cesar", "23" = "Córdoba", "25" = "Cundinamarca",
  "27" = "Chocó", "41" = "Huila", "44" = "La Guajira", "47" = "Magdalena",
  "50" = "Meta", "52" = "Nariño", "54" = "Norte de Santander",
  "63" = "Quindío", "66" = "Risaralda", "68" = "Santander",
  "70" = "Sucre", "73" = "Tolima", "76" = "Valle del Cauca",
  "81" = "Arauca", "85" = "Casanare", "86" = "Putumayo",
  "88" = "San Andrés (cabecera)", "91" = "Amazonas", "94" = "Guainía",
  "95" = "Guaviare", "97" = "Vaupés", "99" = "Vichada"
)

numero_local <- function(x) {
  suppressWarnings(as.numeric(sub(",", ".", trimws(x), fixed = TRUE)))
}

limpiar_ecv <- function(entradas) {
  auditoria <- do.call(rbind, lapply(entradas, function(x) x$fuente))
  tablas <- lapply(entradas, function(x) x$datos)
  claves <- lapply(tablas, function(tabla) {
    partes <- lapply(tabla[llave], trimws)
    if (any(!vapply(partes, function(x) all(grepl("^[0-9]+$", x)), logical(1)))) {
      stop("Hay identificadores faltantes o mal formados en la llave de persona.")
    }
    do.call(paste, c(partes, sep = "/"))
  })
  auditoria$llaves_repetidas_restantes <- vapply(claves, function(x) {
    sum(duplicated(x))
  }, integer(1))
  if (any(auditoria$llaves_repetidas_restantes > 0L)) {
    stop("Llaves repetidas con filas distintas en: ",
         paste(auditoria$módulo[auditoria$llaves_repetidas_restantes > 0L], collapse = ", "))
  }

  tic <- tablas$TIC
  personas <- tablas$Personas
  diseno <- tablas$Diseño
  pos_tic <- match(claves$Personas, claves$TIC)
  pos_diseno <- match(claves$Personas, claves$Diseño)
  edad <- trimws(personas$P6040)
  edad_valida <- grepl("^[0-9]{1,3}$", edad)
  cumple_edad <- edad_valida & numero_local(edad) >= 5
  fuera_universo <- edad_valida & !cumple_edad
  control_union <- data.frame(
    cruce = c("TIC sin Personas", "Personas sin Diseño", "Diseño sin Personas",
              "Elegibles sin TIC", "TIC en menores de 5 años",
              "Secuencia de encuesta distinta en TIC y Personas"),
    casos = c(sum(!claves$TIC %in% claves$Personas),
              sum(is.na(pos_diseno)),
              sum(!claves$Diseño %in% claves$Personas),
              sum(cumple_edad & is.na(pos_tic)),
              sum(fuera_universo & !is.na(pos_tic)),
              sum(!is.na(pos_tic) & (is.na(personas$SECUENCIA_ENCUESTA) |
                    is.na(tic$SECUENCIA_ENCUESTA[pos_tic]) |
                    personas$SECUENCIA_ENCUESTA != tic$SECUENCIA_ENCUESTA[pos_tic])))
  )
  if (any(control_union$casos > 0L)) {
    stop("Los módulos no concilian: ",
         paste(control_union$cruce[control_union$casos > 0L], collapse = ", "))
  }

  frecuencia <- trimws(tic$P1084[pos_tic])
  sexo <- trimws(personas$P6020)
  municipio <- trimws(diseno$MPIO[pos_diseno])
  codigo_depto <- substr(municipio, 1L, 2L)
  peso_original <- diseno$FEX_C[pos_diseno]
  peso <- numero_local(peso_original)
  validos <- list(P6040 = edad_valida, P6020 = sexo %in% c("1", "2"),
                  P1084 = frecuencia %in% as.character(1:5),
                  MPIO = grepl("^[0-9]{5}$", municipio) & codigo_depto %in% names(departamentos),
                  FEX_C = is.finite(peso) & peso > 0)
  originales <- list(P6040 = edad, P6020 = sexo, P1084 = frecuencia,
                     MPIO = municipio, FEX_C = peso_original)
  calidad <- do.call(rbind, lapply(names(originales), function(campo) {
    aplica <- if (campo == "P1084") !fuera_universo else rep(TRUE, nrow(personas))
    vacio <- is.na(originales[[campo]]) | originales[[campo]] == ""
    data.frame(variable = campo, aplicables = sum(aplica),
               no_aplica = sum(!aplica), faltantes = sum(aplica & vacio),
               inválidos = sum(aplica & !vacio & !validos[[campo]]),
               válidos = sum(aplica & validos[[campo]]))
  }))
  apto <- cumple_edad & Reduce("&", validos)
  analisis <- data.frame(
    edad = numero_local(edad[apto]),
    sexo = factor(sexo[apto], levels = 1:2, labels = sexos),
    codigo_frecuencia = as.integer(frecuencia[apto]),
    frecuencia = factor(frecuencia[apto], levels = 1:5, labels = frecuencias, ordered = TRUE),
    departamento_codigo = codigo_depto[apto],
    departamento = unname(departamentos[codigo_depto[apto]]),
    peso = peso[apto]
  )
  analisis$grupo_edad <- cut(analisis$edad, breaks = c(5, 12, 18, 29, 45, 60, Inf),
                           labels = c("5–11", "12–17", "18–28", "29–44", "45–59", "60+"),
                           right = FALSE, ordered_result = TRUE)
  flujo <- data.frame(
    etapa = c("Personas encuestadas en la muestra de hogares", "Menores de 5 (fuera de TIC)",
              "Edad faltante o inválida", "Personas de 5 años o más", "Excluidas por calidad tras elegibilidad",
              "Personas en la base analítica"),
    filas = c(nrow(personas), sum(fuera_universo), sum(!edad_valida), sum(cumple_edad),
              sum(cumple_edad & !apto), nrow(analisis))
  )
  diferencias_peso <- list(TIC = abs(numero_local(tic$FEX_C[pos_tic]) - peso),
                           Personas = abs(numero_local(personas$FEX_C) - peso))
  control_pesos <- do.call(rbind, lapply(names(diferencias_peso), function(nombre) {
    comparacion <- diferencias_peso[[nombre]]
    data.frame(módulo = nombre, comparables = sum(is.finite(comparacion)),
               diferentes = sum(comparacion > 0, na.rm = TRUE),
               máxima_diferencia = max(c(0, comparacion), na.rm = TRUE))
  }))

  if (nrow(analisis) == 0L) stop("No hay personas válidas para el análisis.")
  list(base = analisis, auditoria = auditoria, uniones = control_union, calidad = calidad,
       flujo = flujo, pesos = control_pesos)
}
