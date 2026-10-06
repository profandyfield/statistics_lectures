# The Beast of Bias

Professor Andy Field, University of Sussex

Links: [bsky.app](https://bsky.app/profile/profandyfield.bsky.social) \| [youtube.com](https://www.youtube.com/user/ProfAndyField) \| [discoveringstatistics.com](https://www.discoveringstatistics.com) \| [discovr.rocks](https://www.discovr.rocks) \| [statisticsadventure.com](https://www.statisticsadventure.com)

## About this version

This is a plain-text version of the lecture slides. Each slide starts with a heading such as “Slide 5”, and the numbers match the slide numbers shown in the lecture. Content that appeared one piece at a time, in columns or in tabs is shown in reading order. Videos and interactive apps are given as links.

## Slide 2

Audio clip: [beast of bias narration](https://profandyfield.github.io/statistics_lectures/ds_04_bias/media/beast_of_bias_narration.mp3)

All is not well in the island of linearis modelus.

For years, humans and dragons have lived in harmony, until recently.

The rulers of the 134 kingdoms want the island for themselves.

Through a campaign of propaganda, they have convinced their subjects

that the dragons should be banished.

They have sent their best knights to slay the dragons.

Only Melvin, a wise wizzard of statistics, can save them.

He meets with the commander in chief of the knights of the 134 kingdoms.

## Slide 3

Video clip: [zach i am zach field caption](https://profandyfield.github.io/statistics_lectures/ds_04_bias/media/zach_i_am_zach_field_caption.mp4)

## Slide 4

Video clip: [zach kill dragons thank you caption](https://profandyfield.github.io/statistics_lectures/ds_04_bias/media/zach_kill_dragons_thank_you_caption.mp4)

## Slide 5

Video clip: [zach reasons captions](https://profandyfield.github.io/statistics_lectures/ds_04_bias/media/zach_reasons_captions.mp4)

## Slide 6

Video clip: [zach only kidnap princesses caption](https://profandyfield.github.io/statistics_lectures/ds_04_bias/media/zach-only_kidnap_princesses_caption.mp4)

## Slide 7

Video clip: [arlo stop zach caption](https://profandyfield.github.io/statistics_lectures/ds_04_bias/media/arlo_stop_zach_caption.mp4)

## Slide 8

![Image: spine map (no description provided yet)](images/spine_map.png)

## Slide 9

![Image: spine lec 04 (no description provided yet)](images/spine_lec_04.png)

## Slide 10 (new section): Part 1: Outliers and do dragons eat sheep?

> “Coz they eat all our sheep”
>
> *Sir Knight Zach, Defender of the world of Military*

## Slide 11

![Plot (no description provided yet)](images/ds_bias_slide011_unnamed-chunk-4-1.png)

## Slide 12

![Plot (no description provided yet)](images/ds_bias_slide012_unnamed-chunk-5-1.png)

## Slide 13: Detecting outliers

- Graphs
  - Scatterplots (less helpful with several predictors)
  - Histograms
- Standardized residual
  - In an average sample, 95% of standardized residuals should lie between $`\pm 2`$
  - 99% of standardized residuals should lie between $`\pm 2.5`$
  - Any case for which the absolute value of the standardized residual is 3 or more, is likely to be an outlier

## Slide 14: Detecting influential cases

### DF Beta

- The change in *b* when a case is removed
- Be wary of standardized values with absolute values \> 1

#### Full sample

| Parameter   | Coefficient | SE   | 95% CI         | t(51) | p       |
|-------------|-------------|------|----------------|-------|---------|
| (Intercept) | 18.82       | 2.93 | (12.94, 24.69) | 6.43  | \< .001 |
| dragons     | 1.38        | 0.53 | (0.31, 2.44)   | 2.59  | 0.013   |

#### Influential cases removed

| Parameter   | Coefficient | SE   | 95% CI         | t(49) | p       |
|-------------|-------------|------|----------------|-------|---------|
| (Intercept) | 22.27       | 1.64 | (18.98, 25.56) | 13.60 | \< .001 |
| dragons     | 0.31        | 0.31 | (-0.31, 0.93)  | 0.99  | 0.325   |

## Slide 15: Detecting influential cases

### Cook’s distance

- Measures the *influence* of a single case on the model as a whole
- Absolute values greater than 1 are cause for concern (Cook & Weisberg , 1982), but check any \> 0.5.

``` r
out_lm <- lm(livestock ~ dragons, data = out_tib)

check_outliers(out_lm,
               method = "cook",
               threshold = list('cook' = 0.5)
               ) |> 
  plot()
```

![Plot (no description provided yet)](images/ds_bias_slide015_unnamed-chunk-9-1.png)

## Slide 16

Video clip: [shrek burp](https://profandyfield.github.io/statistics_lectures/ds_04_bias/media/shrek_burp.mp4)

## Slide 17: Robust estimation

### Normal model (OLS)

``` r
out_lm <- lm(livestock ~ dragons, data = out_tib)
model_parameters(out_lm) |> 
  display()
```

| Parameter   | Coefficient | SE   | 95% CI         | t(51) | p       |
|-------------|-------------|------|----------------|-------|---------|
| (Intercept) | 18.82       | 2.93 | (12.94, 24.69) | 6.43  | \< .001 |
| dragons     | 1.38        | 0.53 | (0.31, 2.44)   | 2.59  | 0.013   |

### Robust model

``` r
out_rob <- robust::lmRob(livestock ~ dragons, data = out_tib)
model_parameters(out_rob) |> 
  display()
```

| Parameter   | Coefficient | SE   | 95% CI         | t(51) | p       |
|-------------|-------------|------|----------------|-------|---------|
| (Intercept) | 22.35       | 1.81 | (18.72, 25.98) | 12.36 | \< .001 |
| dragons     | 0.30        | 0.34 | (-0.38, 0.98)  | 0.88  | 0.381   |

Fixed Effects

## Slide 18

Video clip: [arlo have you saved the dragons yet 2 caption](https://profandyfield.github.io/statistics_lectures/ds_04_bias/media/arlo_have_you_saved_the_dragons_yet_2_caption.mp4)

## Slide 19

## Slide 20

Video clip: [zach shakes head](https://profandyfield.github.io/statistics_lectures/ds_04_bias/media/zach_shakes_head.mp4)

## Slide 21

Video clip: [dragon chase](https://profandyfield.github.io/statistics_lectures/ds_04_bias/media/dragon_chase.mp4)

## Slide 22 (new section): Part 2: Linearity, spherical errors and do dragons kidnap royalty?

> “Coz they kidnap the princesses”
>
> *Sir Knight Zach, Defender of the world of Military*

## Slide 23: Are more princesses kidnapped in areas with more dragons?

``` math
\hat{\text{royalty}}_i = 3.98 + 0.12\text{dragons}_{i}
```

| Parameter   | Coefficient | SE   | 95% CI           | t(128) | p       |
|-------------|-------------|------|------------------|--------|---------|
| (Intercept) | 3.98        | 0.30 | (3.39, 4.57)     | 13.32  | \< .001 |
| dragons     | 0.12        | 0.06 | (5.30e-03, 0.23) | 2.07   | 0.040   |

![Plot (no description provided yet)](images/ds_bias_slide023_unnamed-chunk-13-1.png)

## Slide 24: Are more princesses kidnapped in areas that have dragons?

``` math
\hat{\text{royalty}}_i = 4.26 + 1.21\text{dragons}_{i}
```

| Parameter         | Coefficient | SE   | 95% CI       | t(87) | p       |
|-------------------|-------------|------|--------------|-------|---------|
| (Intercept)       | 4.26        | 0.41 | (3.43, 5.08) | 10.28 | \< .001 |
| dragons (Dragons) | 1.21        | 0.53 | (0.15, 2.26) | 2.27  | 0.026   |

![Plot (no description provided yet)](images/ds_bias_slide024_unnamed-chunk-15-1.png)

## Slide 25: Key assumptions of the General Linear Model

### Linearity and additivity

### Spherical errors

The population model should have:

- Homoscedastic errors
  - Inspect the model residuals
- Independent errors
  - Inspect the model residuals

### Normality of something-or-other

- Population model errors
- Sampling distribution

## Slide 26: Linearity and additivity

The relationship between predictor(s) and outcome is, in reality, linear

``` math
\text{royalty}_i = \hat{b}_0 + \hat{b}_1\text{dragons}_{i} + e_i
```

The combined effect of predictors is additive

``` math
\text{royalty}_i = \hat{b}_0 + \hat{b}_1\text{dragons}_{i} + \hat{b}_2\text{strict regime}_{i} + e_i
```

> **Note: Statis-tip**
>
> - Test linearity using plots. If the data cloud looks banana shaped (curved), linearity probably can’t be assumed.

## Slide 27: Errors vs. Residuals

> **Note: Statis-tip**
>
> - A model’s **ERROR**s refer to the differences between predicted values and observed values of the outcome variable **in the population model**
> - These values cannot be observed

> **Note: Statis-tip**
>
> - A model’s **RESIDUAL**s refer to the differences between predicted values and observed values of the outcome variable **in the sample model**
> - These values can be observed and are representative of the population model errors.

## Slide 28

![Image: ds6 fig 06 03 pop model no obs (no description provided yet)](images/ds6_fig_06_03_pop_model_no_obs.png)

## Slide 29: Normally distributed errors

``` math
 \begin{aligned} \text{Ringing}_i &= \hat{b}_0 + \hat{b}_1\text{Volume}_i + \varepsilon_i \\ \varepsilon_i &\sim N(0, \sigma^2) \end{aligned} 
```

## Slide 30: Errors (Population model)

![Image: ds6 fig 06 06 pooled errors (no description provided yet)](images/ds6_fig_06_06_pooled_errors.png)

## Slide 31: Residuals (are observable)

![Image: ds6 fig 06 07 sample model (no description provided yet)](images/ds6_fig_06_07_sample_model.png)

## Slide 32: Spherical errors

### Errors should be independent

- The **population** error in prediction for one case should not be related to the error in prediction for another case (**autocorrelation**).
- Independent observations tend to lead to independent errors
- **Because we cannot observe population errors we inspect the sample residuals**

### Errors should be homoscedastic

- Variance of population errors (residuals) should be consistent at different values of the predictor variable
- **Because we cannot observe population errors we inspect the sample residuals**

### Violation of the assumption

- *b*s are unbiased but not optimal
- Standard error is incorrect
  - Therefore, *t*-tests, *p*-values and confidence intervals will also be incorrect

## Slide 33: Residuals vs. Predicted values

![Image: dsr2 fig 06 28 pred resid (no description provided yet)](images/dsr2_fig_06_28_pred_resid.png)

## Slide 34: Residuals vs. Predicted values

![Image: dsr2 fig 06 28 pred resid overlay (no description provided yet)](images/dsr2_fig_06_28_pred_resid_overlay.png)

## Slide 35

### Homoscedastic

![Image: hom con plot (no description provided yet)](images/hom_con_plot.png)

### Our data

![Image: het con plot (no description provided yet)](images/het_con_plot.png)

## Slide 36

### Homoscedastic

![Image: hom con plot layer (no description provided yet)](images/hom_con_plot_layer.png)

### Our data: Heteroscedastic

![Image: het con plot layer (no description provided yet)](images/het_con_plot_layer.png)

## Slide 37

### Homoscedastic

![Image: hom cat plot (no description provided yet)](images/hom_cat_plot.png)

### Our data

![Image: het cat plot (no description provided yet)](images/het_cat_plot.png)

## Slide 38

### Homoscedastic

![Image: hom cat plot layer (no description provided yet)](images/hom_cat_plot_layer.png)

### Our data: Heteroscedastic

![Image: het cat plot layer (no description provided yet)](images/het_cat_plot_layer.png)

## Slide 39

Video clip: [heteroscedasticity song](https://profandyfield.github.io/statistics_lectures/ds_04_bias/media/heteroscedasticity_song.mp4)

## Slide 40: Levene’s Test

> **Warning: The danger zone!**
>
> - You might hear about it but **don’t use it**: think about what we know about sample sizes and significance.
> - For the avoidance of doubt, **don’t use it**.
> - One more time … **don’t use it**

## Slide 41

Video clip: [shocked baby levene](https://profandyfield.github.io/statistics_lectures/ds_04_bias/media/shocked_baby_levene.mp4)

## Slide 42

Video clip: [zach dragon hunt caption](https://profandyfield.github.io/statistics_lectures/ds_04_bias/media/zach_dragon_hunt_caption.mp4)

## Slide 43

Video clip: [dragon chase 2](https://profandyfield.github.io/statistics_lectures/ds_04_bias/media/dragon_chase_2.mp4)

## Slide 44 (new section): Part 3: Normality and does dragons poo kill crops?

> “Coz their dung doesn’t help our crops to grow”
>
> *Sir Knight Zach, Defender of the world of Military*

## Slide 45: Is dung associated with crop yield?

``` math
\hat{\text{yield}}_i = 14.34 + 2.02\text{poop}_{i}
```

| term        | estimate | std.error | statistic | p.value | conf.low | conf.high |
|-------------|----------|-----------|-----------|---------|----------|-----------|
| (Intercept) | 14.34    | 6.77      | 2.12      | 0.04    | 0.56     | 28.12     |
| poop        | 2.02     | 1.37      | 1.48      | 0.15    | -0.77    | 4.82      |

![Plot (no description provided yet)](images/ds_bias_slide045_unnamed-chunk-19-1.png)

## Slide 46: Normally distributed errors

> **Warning: The danger zone!**
>
> People usually (falsely) think the data or population need to be normally distributed.

![Plot (no description provided yet)](images/ds_bias_slide046_unnamed-chunk-20-1.png)

## Slide 47: Normally distributed errors

### Estimation

- Normal errors don’t really matter
- When errors are not normally distributed, *b* will be unbiased and optimal (i.e., will minimize the variance), but there may be classes of estimator (other than OLS) that are more accurate (Wilcox, 2010)

### Confidence intervals and significance tests

- When residuals are normal
  - It can be shown that the *b*s have a normal sampling distribution.
  - Test statistics of *b*s (usually testing the null of *b* = 0) follow a *t*-distribution.
- If they are not normal then
  - We can’t base confidence intervals on the properties of the normal distribution.
  - We don’t know what distribution tests statistics have.

## Slide 48: The Central Limit Theorem (CLT)

![Image: dsr2 fig 06 12 clt (no description provided yet)](images/dsr2_fig_06_12_clt.png)

## Slide 49: Exploring normality of model errors

- Check the distribution of the model residuals using a P-P/Q-Q plot

### Large samples

- You don’t need to worry about this assumption in large samples because of the CLT

### Small samples

- Use a **bootstrap** to get an empirical confidence interval and standard error (more on this later …)

## Slide 50: The K-S Test

> **Warning: The danger zone!**
>
> - You might hear about it but **don’t use it**: think about what we know about sample sizes and significance.
> - For the avoidance of doubt, **don’t use it**.
> - One more time … **don’t use it**

## Slide 51

Video clip: [shocked cat ks](https://profandyfield.github.io/statistics_lectures/ds_04_bias/media/shocked_cat_ks.mp4)

## Slide 52

### Normal residuals

![Image: poop norm qq plot (no description provided yet)](images/poop_norm_qq_plot.png)

### Our residuals: Non-normal

![Image: poop qq plot (no description provided yet)](images/poop_qq_plot.png)

## Slide 53

Video clip: [normality song](https://profandyfield.github.io/statistics_lectures/ds_04_bias/media/normality_song.mp4)

## Slide 54

Video clip: [normality song instrumental](https://profandyfield.github.io/statistics_lectures/ds_04_bias/media/normality_song_instrumental.mp4)

## Slide 55 (new section): Part 4: Correcting problems

## Slide 56: Robust procedures

![Image: dsr2 fig 08 13 robust flow (no description provided yet)](images/dsr2_fig_08_13_robust_flow.png)

## Slide 57: Robust procedures

### The bootstrap

- Standard errors are derived empirically using a resampling technique
- Results in robust confidence intervals and *p*-values
- Designed for small samples (when normality matters)

### Heteroskedasticity-consistent standard errors

- Use a sandwich estimator
- HC3 and HC4 methods work best

## Slide 58

Video clip: [bootstrap hippo](https://profandyfield.github.io/statistics_lectures/ds_04_bias/media/bootstrap_hippo.mp4)

## Slide 59: The Bootstrap

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|
| yield | 0 | 6 | 6 | 7 | 7 | 7 | 7 | 7 | 8 | 8 | 12 | 13 | 13 | 15 | 15 | 16 | 16 | 16 | 20 | 22 | 22 | 23 | 26 | 28 | 28 | 29 | 31 | 32 | 40 | 44 | 47 | 48 | 69 | 95 |

Mean = 23.03

Bootstrap sample 1:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|
| yield | 0 | 0 | 6 | 7 | 7 | 7 | 7 | 7 | 8 | 8 | 8 | 12 | 12 | 13 | 13 | 15 | 16 | 16 | 20 | 22 | 22 | 22 | 22 | 23 | 26 | 28 | 29 | 32 | 47 | 48 | 48 | 69 | 69 | 95 |

Mean = 23.06

Bootstrap sample 2:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|
| yield | 0 | 0 | 6 | 7 | 7 | 7 | 7 | 7 | 7 | 7 | 7 | 7 | 8 | 8 | 15 | 15 | 16 | 16 | 20 | 20 | 22 | 23 | 23 | 28 | 31 | 40 | 44 | 44 | 44 | 47 | 48 | 48 | 69 | 95 |

Mean = 23.32

## Slide 60

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|
| yield | 0 | 6 | 6 | 7 | 7 | 7 | 7 | 7 | 8 | 8 | 12 | 13 | 13 | 15 | 15 | 16 | 16 | 16 | 20 | 22 | 22 | 23 | 26 | 28 | 28 | 29 | 31 | 32 | 40 | 44 | 47 | 48 | 69 | 95 |

![Image: bootstrap hist (no description provided yet)](images/bootstrap_hist.gif)

## Slide 61

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|
| yield | 0 | 6 | 6 | 7 | 7 | 7 | 7 | 7 | 8 | 8 | 12 | 13 | 13 | 15 | 15 | 16 | 16 | 16 | 20 | 22 | 22 | 23 | 26 | 28 | 28 | 29 | 31 | 32 | 40 | 44 | 47 | 48 | 69 | 95 |

![Image: bootstrap hist (no description provided yet)](images/bootstrap_hist.png)

## Slide 62

Video clip: [zach chops arlos tail](https://profandyfield.github.io/statistics_lectures/ds_04_bias/media/zach_chops_arlos_tail.mp4)

## Slide 63: Do dragons really kidnap royalty?

### Normal model (number of dragons)

``` r
kidnap_lm <- lm(royalty ~ dragons,data = hov_cont_tib)
model_parameters(kidnap_lm) |> 
  display()
```

| Parameter   | Coefficient | SE   | 95% CI           | t(128) | p       |
|-------------|-------------|------|------------------|--------|---------|
| (Intercept) | 3.98        | 0.30 | (3.39, 4.57)     | 13.32  | \< .001 |
| dragons     | 0.12        | 0.06 | (5.30e-03, 0.23) | 2.07   | 0.040   |

### Robust model (number of dragons) HC4 Standard errors

``` r
kidnap_lm <- lm(royalty ~ dragons, data = hov_cont_tib)
model_parameters(kidnap_lm, vcov = "HC4") |> 
  display()
```

| Parameter   | Coefficient | SE   | 95% CI        | t(128) | p       |
|-------------|-------------|------|---------------|--------|---------|
| (Intercept) | 3.98        | 0.24 | (3.50, 4.45)  | 16.49  | \< .001 |
| dragons     | 0.12        | 0.06 | (-0.01, 0.24) | 1.81   | 0.072   |

## Slide 64: Do dragons really kidnap royalty?

### Normal model (dragons or not)

``` r
kidnap_gp_lm <- lm(royalty ~ dragons, data = hov_cat_tib)
model_parameters(kidnap_gp_lm) |> 
  display()
```

| Parameter         | Coefficient | SE   | 95% CI       | t(87) | p       |
|-------------------|-------------|------|--------------|-------|---------|
| (Intercept)       | 4.26        | 0.41 | (3.43, 5.08) | 10.28 | \< .001 |
| dragons (Dragons) | 1.21        | 0.53 | (0.15, 2.26) | 2.27  | 0.026   |

### Robust model (dragons or not) HC4 standard errors

``` r
kidnap_gp_lm <- lm(royalty ~ dragons, data = hov_cat_tib)
model_parameters(kidnap_gp_lm, vcov = "HC4") |> 
  display()
```

| Parameter         | Coefficient | SE   | 95% CI            | t(87) | p       |
|-------------------|-------------|------|-------------------|-------|---------|
| (Intercept)       | 4.26        | 0.57 | (3.13, 5.39)      | 7.50  | \< .001 |
| dragons (Dragons) | 1.21        | 0.61 | (-5.94e-03, 2.42) | 1.98  | 0.051   |

## Slide 65: Does dragon poo help crops to grow?

### Normal model

``` r
poop_lm <- lm(yield ~ poop, data = poop_tib)
model_parameters(poop_lm) |> 
  display()
```

| Parameter   | Coefficient | SE   | 95% CI        | t(32) | p     |
|-------------|-------------|------|---------------|-------|-------|
| (Intercept) | 14.34       | 6.77 | (0.56, 28.12) | 2.12  | 0.042 |
| poop        | 2.02        | 1.37 | (-0.77, 4.82) | 1.48  | 0.150 |

### Bootstrap model

``` r
poop_lm <- lm(yield ~ poop, data = poop_tib)
model_parameters(poop_lm, bootstrap = TRUE) |> 
  display()
```

| Parameter   | Coefficient | 95% CI        | p     |
|-------------|-------------|---------------|-------|
| (Intercept) | 14.14       | (5.12, 25.92) | 0.002 |
| poop        | 2.06        | (0.09, 3.92)  | 0.046 |

## Slide 66

Video clip: [arlo have you saved the dragons yet 2 caption](https://profandyfield.github.io/statistics_lectures/ds_04_bias/media/arlo_have_you_saved_the_dragons_yet_2_caption.mp4)

## Slide 67

Video clip: [zach not allowed to kill dragons caption](https://profandyfield.github.io/statistics_lectures/ds_04_bias/media/zach_not_allowed_to_kill_dragons_caption.mp4)

## Slide 68

Video clip: [zach what can i kill caption](https://profandyfield.github.io/statistics_lectures/ds_04_bias/media/zach_what_can_i_kill_caption.mp4)

## Slide 69

Video clip: [zach kill you caption](https://profandyfield.github.io/statistics_lectures/ds_04_bias/media/zach_kill_you_caption.mp4)
