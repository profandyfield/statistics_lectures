# Load library
library(MASS)
library(lavaan)
library(easystats)

set.seed(666)  # reproducibility

# Target correlation matrix
target_cor <- matrix(c( 1.00,  0.89, -0.49,
                        0.89,  1.00, -0.48,
                        -0.49, -0.48,  1.00), nrow = 3, byrow = TRUE)

# Check positive-definiteness
eigen(target_cor)$values  # should all be > 0

# Function to rescale continuous variable to integer range
rescale_to_int <- function(x, min_val, max_val) {
  scaled <- (x - min(x)) / (max(x) - min(x))
  scaled_int <- round(scaled * (max_val - min_val) + min_val)
  return(scaled_int)
}

# Function to compute fit to target correlations
cor_diff <- function(df, target) {
  actual <- cor(df)
  sum((actual - target)^2)
}

# Optimization loop
best_df <- NULL
best_diff <- Inf
n <- 666  # sample size

my_mod <- 'crit ~ c*ai + b*cog
          cog ~ a*ai
       
          indirect_effect := a*b
          total_effect := c + (a*b)
         '

for (i in 1:500) {  # try 500 random seeds
  raw <- mvrnorm(n = n, mu = c(0, 0, 0), Sigma = target_cor)
  df <- as.data.frame(raw)
  names(df) <- c("ai", "cog", "crit")
  
  df$ai   <- rescale_to_int(df$ai,   0, 25)
  df$cog  <- rescale_to_int(df$cog,  0, 25)
  df$crit <- rescale_to_int(df$crit, 0, 35)
  
  ai_fit <- lavaan::sem(my_mod, data = df, missing = "FIML", estimator = "MLR")
  ai_pars <- model_parameters(ai_fit)
  
  te <- ai_pars$Coefficient[5]
  ie <- ai_pars$Coefficient[4]
  de <- ai_pars$Coefficient[4]
  
  effects <- c(te, ie, de)
  targets <- c(-0.42, -0.25, -0.17)
  
  diff_val <- sum((effects - targets)^2)
  if (diff_val < best_diff) {
    best_diff <- diff_val
    best_df <- df
  }
}

# Show results
cat("Best correlation matrix (rounded to 2 decimals):\n")
print(round(cor(best_df), 2))
cat("\nDifference from target (sum of squared errors):", round(best_diff, 4), "\n")

head(best_df)

### try mediation analysis

my_mod <- 'crit ~ c*ai + b*cog
          cog ~ a*ai
       
          indirect_effect := a*b
          total_effect := c + (a*b)
         '

ai_fit <- lavaan::sem(my_mod, data = best_df, missing = "FIML", estimator = "MLR")

model_parameters(ai_fit)

 # To further explore the relationship between AI tool usage and critical thinking, a mediation analysis was conducted, with cognitive offloading as the mediating variable. The analysis revealed that cognitive offloading significantly mediated this relationship. The total effect of AI tool usage on critical thinking was significant (b = −0.42, SE = 0.08, p < 0.001). The indirect effect through cognitive offloading was also significant (b = −0.25, SE = 0.06, p < 0.001), indicating that cognitive offloading partially mediates this relationship. The direct effect of AI usage remained significant (b = −0.17, SE = 0.05, p < 0.01). These findings suggest that cognitive offloading plays a substantial role in explaining the negative impact of AI usage on critical thinking. This mediating role highlights the importance of addressing cognitive offloading when evaluating the broader implications of AI adoption on decision-making and critical thought processes.


gerlich_2025 <- best_df |> 
  dplyr::rename(crit_think = crit, cog_off = cog)

here::here("gerlich_2025.rds") |> saveRDS(object = best_df, file = _)

