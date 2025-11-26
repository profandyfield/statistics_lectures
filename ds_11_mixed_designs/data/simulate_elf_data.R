library(tidyverse)
library(easystats)
library(faux)


name_pool <- discovr::santas_log$id


# simulate

between <- list(helper = c(elf = "Elf", fairy = "Fairy"))
within <- list(treat = c("Pudding", "Mulled wine"),
               quantity = c("One", "Two", "Three", "Four", "Five"))
mu <- data.frame(
  elf    = c(12, 12, 18, 22, 30, 11, 14, 25, 32, 45),
  fairy    = c(12, 14, 20, 20, 30, 9, 13, 26, 40, 60),
  row.names = c("pud1", "pud2", "pud3", "pud4", "pud5", "wine1", "wine2", "wine3", "wine4", "wine5")
)

sd <- data.frame(
  elf    = c(2.5, 3.5, 5, 6, 7, 3, 4, 7, 8, 10),
  fairy    = c(2.5, 3.5, 5, 6, 7, 3, 4, 8, 12, 15),
  row.names = c("pud1", "pud2", "pud3", "pud4", "pud5", "wine1", "wine2", "wine3", "wine4", "wine5")
)

r <- list(
  elf = 0.2,
  fairy = 0.4
)

df <- sim_design(within, between, n = 50,
                 mu = mu, sd = sd, r = r,
                 dv = c(speed = "Delivery time (ms)"),
                 plot = FALSE, long = TRUE, empirical = TRUE)

df <- df |>
  as_tibble() |>
  mutate(
    helper = stringr::str_to_sentence(helper) |> as_factor() |>  fct_relevel("Elf"),
    quantity = as_factor(quantity) |>  fct_relevel("One", "Two", "Three", "Four", "Five"),
    treat = as_factor(treat) |>  fct_relevel("Pudding"),
    speed = round(speed),
    id = rep(sample(x = discovr::santas_log$id, size = 100), 10)
  )



xmas_afx <- afex::aov_4(speed ~ treat*quantity*helper + (treat*quantity|id), data = df)


model_parameters(xmas_afx, es_type = "omega")

afex::afex_plot(object = xmas_afx,
                x = "quantity",
                trace = "helper",
                panel = "treat",
                mapping = c("shape", "color"),
                error = "within")  +
  theme_minimal()


estimate_contrasts(model = xmas_afx,
                   contrast = c("treat", "quantity", "helper"),
                   interaction = c(treat = "trt.vs.ctrl", quantity = "trt.vs.ctrl", helper = "trt.vs.ctrl"),
                   ref = 1,
                   p_adjust = "bonferroni",
                   backend = "emmeans")

df |>
  filter(quantity == "Three") |>
  afex::aov_4(speed ~ treat*helper + (treat|id), data = _) |>
  model_parameters()



here::here("ds_11_mixed_designs/data/xmas_mixed.rds") |>
  write_rds(x = df, file = _)


