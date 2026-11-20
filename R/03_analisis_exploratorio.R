distribucion_frecuencia <- function(base) {
  niveles <- seq_along(frecuencias)
  n <- tabulate(base$codigo_frecuencia, nbins = length(niveles))
  expandidos <- vapply(niveles, function(i) {
    sum(base$peso[base$codigo_frecuencia == i])
  }, numeric(1))
  data.frame(código = niveles, frecuencia = factor(frecuencias, levels = frecuencias),
             n_muestra = n, porcentaje_muestra = 100 * n / sum(n),
             personas_expandidas = expandidos,
             porcentaje_ponderado = 100 * expandidos / sum(expandidos))
}

indicadores <- function(base) {
  diario <- base$codigo_frecuencia == 1L
  uso <- base$codigo_frecuencia %in% 1:4
  total <- sum(base$peso)
  data.frame(n_muestra = nrow(base), n_diario = sum(diario), n_usuarios = sum(uso),
             población_expandida = total, diario_expandido = sum(base$peso[diario]),
             diario_pct = 100 * sum(base$peso[diario]) / total,
             uso_pct = 100 * sum(base$peso[uso]) / total)
}

desglosar <- function(base, campo, resumir) {
  grupos <- split(base, base[[campo]], drop = TRUE)
  do.call(rbind, lapply(names(grupos), function(grupo) {
    data.frame(setNames(list(grupo), campo), resumir(grupos[[grupo]]))
  }))
}

explorar_ecv <- function(base) {
  edad <- base$edad
  edades_tab <- table(edad)
  modas <- as.numeric(names(edades_tab)[edades_tab == max(edades_tab)])
  cuartiles <- quantile(edad, c(.25, .5, .75), names = FALSE)
  estadisticos <- data.frame(
    estadístico = c("N (personas)", "Media", "Mediana", rep("Moda", length(modas)), "Mínimo", "Máximo",
                    "Desviación estándar", "Primer cuartil", "Tercer cuartil", "Rango intercuartílico"),
    valor = c(length(edad), mean(edad), cuartiles[2],
              modas,
              min(edad), max(edad), sd(edad), cuartiles[1], cuartiles[3], diff(cuartiles[c(1, 3)]))
  )
  sexo <- desglosar(base, "sexo", indicadores)
  sexo$composición_muestra_pct <- 100 * sexo$n_muestra / sum(sexo$n_muestra)
  sexo$composición_ponderada_pct <- 100 * sexo$población_expandida / sum(sexo$población_expandida)
  edad_grupos <- desglosar(base, "grupo_edad", indicadores)
  edad_grupos$grupo_edad <- factor(edad_grupos$grupo_edad, levels = levels(base$grupo_edad))
  geo <- desglosar(base, "departamento_codigo", indicadores)
  geo$departamento <- unname(departamentos[geo$departamento_codigo])
  geo <- geo[order(-geo$diario_pct, geo$departamento_codigo),
             c("departamento_codigo", "departamento", names(indicadores(base)))]
  geo <- cbind(puesto = seq_len(nrow(geo)), geo)
  nac <- indicadores(base)
  frecuencia <- distribucion_frecuencia(base)
  por_edad <- desglosar(base, "grupo_edad", distribucion_frecuencia)
  por_edad$grupo_edad <- factor(por_edad$grupo_edad, levels = levels(base$grupo_edad))
  por_sexo <- desglosar(base, "sexo", distribucion_frecuencia)
  por_depto <- desglosar(base, "departamento_codigo", distribucion_frecuencia)
  por_depto$departamento <- unname(departamentos[por_depto$departamento_codigo])
  medianas <- desglosar(base, "frecuencia", function(grupo) {
    data.frame(n_muestra = nrow(grupo), mediana_edad = median(grupo$edad))
  })

  # Comparación de cualquier uso con las cifras publicadas a un decimal.
  observado <- c(nac$uso_pct, sexo$uso_pct[match(sexos, sexo$sexo)],
                 geo$uso_pct[match(c("76", "99"), geo$departamento_codigo)])
  cotejo <- data.frame(dominio = c("Nacional", sexos, "Valle del Cauca", "Vichada"),
                       calculado_pct = round(observado, 1),
                       DANE_pct = c(82.3, 81.6, 82.9, 89.3, 31.3))
  cotejo$coincide <- cotejo$calculado_pct == cotejo$DANE_pct
  stopifnot(sum(frecuencia$n_muestra) == nrow(base), sum(geo$n_muestra) == nrow(base),
            abs(sum(frecuencia$porcentaje_ponderado) - 100) < 1e-8,
            isTRUE(all.equal(nac$diario_pct, frecuencia$porcentaje_ponderado[1L])),
            all(abs(tapply(por_edad$porcentaje_ponderado, por_edad$grupo_edad, sum) - 100) < 1e-8),
            all(abs(tapply(por_sexo$porcentaje_ponderado, por_sexo$sexo, sum) - 100) < 1e-8),
            all(abs(tapply(por_depto$porcentaje_ponderado, por_depto$departamento_codigo, sum) - 100) < 1e-8),
            setequal(geo$departamento_codigo, names(departamentos)))
  list(edad = estadisticos, nacional = nac, frecuencia = frecuencia, sexo = sexo,
       grupos_edad = edad_grupos, frecuencia_edad = por_edad, frecuencia_sexo = por_sexo,
       frecuencia_departamento = por_depto, medianas = medianas, departamentos = geo,
       top10 = head(geo, 10L), cotejo_dane = cotejo)
}
