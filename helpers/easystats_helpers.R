# Easystats helpers

# format p-values
report_p <- function(p, p_digits = 3){
  p_dp <- paste0("%.", p_digits, "f")

  ifelse(p < 0.001,
         "*p* < 0.001",
         paste("*p* =", sprintf(fmt = p_dp, p)))
}

# format numeric values

report_value <- function(x, digits = 2, scientific = FALSE){
  if(scientific){
    dp <- paste0("%.", digits, "e")
  } else {
    dp <- paste0("%.", digits, "f")
  }

  sprintf(fmt = dp, x)
}

# extract a value from an ez object

value_from_ez <- function(ezobj, row = 1, value = "Coefficient", digits = 2, p_digits = 3, scientific = FALSE, as_is = FALSE, exponentiate = FALSE){
  val <- ezobj |>
    pull({{value}})

  val <- val[row]

  if(exponentiate){
    val <- exp(val)
  }

  if(as_is){
    val
  } else {
    if(value == "p"){
      report_p(val, p_digits = p_digits)
    } else {
      report_value(val, digits = digits, scientific = scientific)
    }
  }
}

# extract values as percentages

percent_from_ez <- function(ezobj, row = 1, value = "Coefficient", digits = 0){
  val  = value_from_ez(ezobj = ezobj,
                       row = row,
                       value = value,
                       as_is = TRUE)
  if(val > 1 | val < 0){
    print("Input to percent_from_ez() must be a proportion")
    } else {
      paste0(report_value(100*val, digits = digits), "%")
    }
  }


# report likelihood ratio and wald tests

report_lrt <- function(lrt, row = 2, digits = 2, p_digits = 3, df_digits = 0){
  dfm <- value_from_ez(lrt, row = row, value = "df_diff", digits = df_digits)
  dfr <- value_from_ez(lrt, row = row, value = "df", digits = df_digits)
  p <- value_from_ez(lrt, row = row, value = "p", p_digits = p_digits)

  if(exists("F", where = lrt)){
    f <- value_from_ez(lrt, row = row, value = "F", digits = digits)
    paste0("*F*(", dfm, ", ", dfr, ") = ", f, ", ", p)
  } else {
    chi <- value_from_ez(lrt, row = row, value = "Chi2", digits = digits)
    paste0("$\\chi^2$(", dfm, ") = ", chi, ", ", p)
  }
}

# report parameter estimates

report_pe <- function(ezobj, row = 2, digits = 2, p_digits = 3, df_digits = 0, symbol = "$\\hat{b}$"){
  b <- value_from_ez(ezobj, row = row, value = "Coefficient", digits = digits)
  p <- value_from_ez(ezobj, row = row, value = "p", p_digits = p_digits)
  ci <- paste0("(", value_from_ez(ezobj, row = row, value = "CI_low", digits = digits), ", ", value_from_ez(ezobj, row = row, value = "CI_high", digits = digits), ")")

  if(exists("t", where = ezobj)){
    df <- value_from_ez(ezobj, row = row, value = "df_error", digits = df_digits)
    t <- value_from_ez(ezobj, row = row, value = "t", digits = digits)
    paste0(symbol, " = ", b, " ", ci, ", *t*(", df, ") = ", t, ", ", p)
  } else {
    z <- value_from_ez(ezobj, row = row, value = "z", digits = digits)
    paste0(symbol, " = ", b, " ", ci, ", *z* = ", z, ", ", p)
  }
}

# report simple slopes

report_ss <- function(ezobj, row = 2, digits = 2, p_digits = 3, df_digits = 0, symbol = "$\\hat{b}$"){
  b <- value_from_ez(ezobj, row = row, value = "Slope", digits = digits)
  p <- value_from_ez(ezobj, row = row, value = "p", p_digits = p_digits)
  ci <- paste0("(", value_from_ez(ezobj, row = row, value = "CI_low", digits = digits), ", ", value_from_ez(ezobj, row = row, value = "CI_high", digits = digits), ")")

  if(exists("t", where = ezobj)){
    df <- value_from_ez(ezobj, row = row, value = "df", digits = df_digits)
    t <- value_from_ez(ezobj, row = row, value = "t", digits = digits)
    paste0(symbol, " = ", b, " ", ci, ", *t*(", df, ") = ", t, ", ", p)
  } else {
    z <- value_from_ez(ezobj, row = row, value = "z", digits = digits)
    paste0(symbol, " = ", b, " ", ci, ", *z* = ", z, ", ", p)
  }
}

# report contrasts

report_con <- function(ezobj, row = 2, digits = 2, p_digits = 3, df_digits = 0){
  df1 <- value_from_ez(ezobj, row = row, value = "df1", digits = df_digits, as_is = T)
  df2 <- value_from_ez(ezobj, row = row, value = "df2", digits = df_digits, as_is = T)
  f <- value_from_ez(ezobj, row = row, value = "F", digits = digits)
  p <- value_from_ez(ezobj, row = row, value = "p", p_digits = p_digits)

  paste0("*F*(", df1, ", ", df2, ") = ", f, ", ", p)
}

# Report effect sizes

report_es <- function(es_obj, col, row = 1, digits = 2){
  nrow <- nrow(es_obj)
  dp <- paste0("%.", digits, "f")

  par <- ifelse(grepl("_d", col) | grepl("_rm", col), "$\\hat{d}$",
                ifelse(grepl("_g", col), "$\\hat{g}$",
                       ifelse(grepl("Omega", col), "$\\hat{\\omega}_p$",
                              ifelse(grepl("Odds", col), "$\\hat{OR}$", "$\\hat{\\eta}_p$"))))

  es_row  <- es_obj |>
    tibble::as_tibble() |>
    dplyr::rename(
      es = !!{col}
    ) |>
    dplyr::mutate(
      dplyr::across(
        where(is.double), \(x) sprintf(dp, x)),
      row_no = 1:nrow
    )

  paste0(par, " = ", es_row$es[row], " [", es_row$CI_low[row], ", ", es_row$CI_high[row], "]")
}

## report ANOVA models

report_ez_aov <- function(ez_aov, row = 1, digits = 2, p_digits = 3, df_digits = 0, es_type = "Omega2"){
  f <- value_from_ez(ez_aov, row = row, value = "F", digits = digits)
  p <- value_from_ez(ez_aov, row = row, value = "p", p_digits = p_digits)
  dfm <- value_from_ez(ez_aov, row = row, value = "df", digits = df_digits)
  if(exists("df_error", where = ez_aov)){
    dfr <- value_from_ez(ez_aov, row = row, value = "df_error", digits = df_digits)
  } else {
    dfr <- value_from_ez(ez_aov, row = length(ez_aov$df), value = "df", digits = df_digits)
  }

  out <- paste0("F(", dfm, ", ", dfr,  ") = ", f, ", ", p)

  if(exists(es_type, where = ez_aov)){
    es <- value_from_ez(ez_aov, row = row, value = es_type, digits = digits)
    if(grepl("omega", es_type, ignore.case = TRUE)){
      symboltxt = "omega"
    } else {
      symboltxt = "eta"
    }

    if(length(ez_aov$Parameter) > 2){
      es_ext <- "_p"
    } else {
      es_ext <- ""
    }
    es_txt <- paste0("$\\hat{\\", symboltxt, "}^2", es_ext, "$ = ", es)
    ci_low_label <- paste0(sub("_partial", "", x = es_type), "_CI_low")
    if(exists(ci_low_label, where = ez_aov)){
      es_ci <- paste0("(", value_from_ez(ez_aov, row = row, value = paste0(sub("_partial", "", x = es_type), "_CI_low"), digits = digits), ", ", value_from_ez(ez_aov, row = row, value = paste0(sub("_partial", "", x = es_type), "_CI_high"), digits = digits), ")")
      es_txt <- paste0(es_txt, " ", es_ci)
    }
    out <- paste0(out, ", ", es_txt)
  }
  out
}

## report post hoc tests

report_ph <- function(ezobj, row = 2, digits = 2, p_digits = 3, df_digits = 0, symbol = "$\\bar{X}_\\text{Diff}$"){
  b <- value_from_ez(ezobj, row = row, value = "Difference", digits = digits)
  p <- value_from_ez(ezobj, row = row, value = "p", p_digits = p_digits)
  df <- value_from_ez(ezobj, row = row, value = "df", digits = df_digits)
  ci <- paste0("(", value_from_ez(ezobj, row = row, value = "CI_low", digits = digits), ", ", value_from_ez(ezobj, row = row, value = "CI_high", digits = digits), ")")
  test_stat <- value_from_ez(ezobj, row = row, value = "t", digits = digits)
  stat_text <- paste0(", *t*(", df, ") = ", test_stat)


  paste0(symbol, " = ", b, " ", ci, stat_text, ", ", p)
}

## report bayes factors

report_bf <- function(ezobj, row = 2, digits = 2, symbol = "BF~10~", as_is = FALSE){
  bf <- value_from_ez(ezobj, row = row, value = "log_BF", digits = digits, as_is = TRUE) |>  exp()

  if(as_is){
    bf
  } else {
    paste0(symbol, " = ", report_value(bf))
  }
}


## report SEM fit

report_fit <- function(ezobj, report = "both", row = 1, digits = 2, p_digits = 3){
  chi <- value_from_ez(ezobj, row = row, value = "Chi2", digits = digits)
  if(exists("df", where = ezobj)){
    chi_df <- value_from_ez(ezobj, row = row, value = "df", digits = 0)
  } else {
    chi_df <- value_from_ez(ezobj, row = row, value = "Chi2_df", digits = 0)
  }

  chi_p <- value_from_ez(ezobj, row = row, value = "p_Chi2", as_is = T) |> report_p(p_digits = p_digits)
  rmsea <- value_from_ez(ezobj, row = row, value = "RMSEA", digits = digits)
  rmsea_low <- value_from_ez(ezobj, row = row, value = "RMSEA_CI_low", digits = digits)
  rmsea_high <- value_from_ez(ezobj, row = row, value = "RMSEA_CI_high", digits = digits)
  coverage <- percent_from_ez(ezobj, row = row, value = "RMSEA_CI")

  chi_text <- paste0("$\\chi^2$(", chi_df, ") = ", chi, ", ", chi_p)
  rmsea_text <- paste0("RMSEA = ", rmsea, ", ", coverage, " CI [", rmsea_low, ", ", rmsea_high, "]")

  if(report == "both"){
    paste0(chi_text, ", ", rmsea_text)
  } else {
    if(report == "rmsea"){
      rmsea_text
    } else {
      chi_text
    }
  }
}

