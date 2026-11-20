crear_graficos <- function(base, eda) {
  azul <- "#176F82"
  paleta <- setNames(c("#176F82", "#5574AA", "#D39E46", "#7F6098", "#A2AEB6"), frecuencias)
  tema <- theme_minimal(base_size = 12) +
    theme(panel.grid.minor = element_blank(),
          plot.title = element_text(face = "bold", color = "#172D3B"),
          plot.subtitle = element_text(color = "#405969"),
          legend.position = "bottom")
  escala_pct <- scale_y_continuous(breaks = seq(0, 100, 20), limits = c(0, 100),
                                   labels = function(x) paste0(x, " %"))
  distribucion <- function(tabla, campo, titulo, eje) {
    ggplot(tabla, aes(x = .data[[campo]], y = porcentaje_ponderado, fill = frecuencia)) +
      geom_col(position = position_stack(reverse = TRUE), width = .7) +
      scale_fill_manual(values = paleta, drop = FALSE) + escala_pct + tema +
      labs(title = titulo, subtitle = "Porcentaje ponderado dentro de cada grupo",
           x = eje, y = "Personas de 5 años o más", fill = NULL)
  }
  territorios <- function(tabla, titulo, barras = FALSE) {
    tabla$departamento <- reorder(tabla$departamento, tabla$diario_pct)
    p <- ggplot(tabla, aes(departamento, diario_pct))
    p <- if (barras) p + geom_col(fill = azul, width = .66) else p + geom_point(color = azul, size = 2.6)
    p + geom_hline(yintercept = eda$nacional$diario_pct, linetype = "dashed", color = "#A24731") +
      escala_pct + coord_flip() + tema +
      labs(title = titulo, subtitle = "La línea discontinua marca la estimación nacional",
           x = NULL, y = "Porcentaje ponderado de uso diario")
  }

  list(
    histograma_edad = ggplot(base, aes(edad)) +
      geom_histogram(binwidth = 5, boundary = 5, closed = "left", fill = azul, color = "white") +
      tema + labs(title = "Edades de las personas encuestadas",
                  subtitle = "Intervalos de cinco años. Conteos de la muestra",
                  x = "Edad (años cumplidos)", y = "Personas"),
    composicion_sexo = ggplot(eda$sexo, aes(sexo, composición_muestra_pct)) +
      geom_col(fill = azul, width = .55) + escala_pct + tema +
      labs(title = "Composición de la muestra por sexo al nacer",
           x = NULL, y = "Porcentaje sin ponderar"),
    frecuencia_nacional = ggplot(eda$frecuencia, aes(frecuencia, porcentaje_ponderado, fill = frecuencia)) +
      geom_col(width = .65, show.legend = FALSE) +
      scale_fill_manual(values = paleta) + escala_pct + tema +
      labs(title = "Frecuencia de uso de internet en Colombia",
           x = NULL, y = "Porcentaje ponderado"),
    cajas_edad = ggplot(base, aes(frecuencia, edad, fill = frecuencia)) +
      geom_boxplot(outlier.alpha = .15, show.legend = FALSE) +
      scale_fill_manual(values = paleta) + coord_flip() + tema +
      labs(title = "Edad según frecuencia de uso de internet",
           subtitle = "Medianas y cuartiles de la muestra", x = NULL, y = "Edad (años cumplidos)"),
    frecuencia_edad = distribucion(eda$frecuencia_edad, "grupo_edad",
                                   "Frecuencia de uso por grupo de edad", "Grupo de edad (años)"),
    frecuencia_sexo = distribucion(eda$frecuencia_sexo, "sexo",
                                   "Frecuencia de uso por sexo al nacer", NULL),
    departamentos = territorios(eda$departamentos, "Uso diario por departamento y Bogotá D.C.") +
      theme(axis.text.y = element_text(size = 12, color = "#233744", margin = margin(r = 7)),
            axis.text.x = element_text(size = 11, color = "#233744"),
            plot.margin = margin(10, 14, 10, 10)),
    top10 = territorios(eda$top10, "Diez dominios con mayor proporción de uso diario", barras = TRUE)
  )
}
