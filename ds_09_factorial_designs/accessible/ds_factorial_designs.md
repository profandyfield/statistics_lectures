# Factorial designs

**Testing moderation using interactions**

Professor Andy Field, University of Sussex

Links: [acdc that the way](https://profandyfield.github.io/statistics_lectures/shared_media/audio/acdc_that_the_way.mp3) \| [bsky.app](https://bsky.app/profile/profandyfield.bsky.social) \| [youtube.com](https://www.youtube.com/user/ProfAndyField) \| [discoveringstatistics.com](https://www.discoveringstatistics.com) \| [discovr.rocks](https://www.discovr.rocks) \| [statisticsadventure.com](https://www.statisticsadventure.com)

## About this version

This is a plain-text version of the lecture slides. Each slide starts with a heading such as “Slide 5”, and the numbers match the slide numbers shown in the lecture. Content that appeared one piece at a time, in columns or in tabs is shown in reading order. Videos and interactive apps are given as links.

## Slide 2: Learning outcomes

- What is a factorial design?
- Moderation and interaction effects
- Factorial designs and the GLM
  - The process of E.V.I.L.
- Breaking down interactions
  - Plots
  - Simple effects analysis

## Slide 3

![Image: spine map (no description provided yet)](images/spine_map.png)

![Image: spine map lec 02 (no description provided yet)](images/spine_map_lec_02.png)

## Slide 4

![Image: dsr2 fig 04 39 workflow (no description provided yet)](images/dsr2_fig_04_39_workflow.png)

## Slide 5: Terminology

- Variables in experimental designs
  - Predictor variables referred to as **independent variables (IV)** because their value is independent of (is not being predicted from) other variables.
  - Outcome variable referred to as the **dependent variables (DV)**, because their value ‘depends’ upon (is being predicted from) other variables.
- **Factorial design**: Two or more predictor variables/IV have been manipulated
- ***n*-way design**: The number of predictor variables/IVs manipulated
  - Two-way = 2 predictor variables/IVs manipulated
  - Three-way = 3 predictor variables/IVs manipulated
- The allocation of participants
  - **Independent design** = different entities in all conditions
  - **Repeated measures design** = the same entities in all conditions
  - **Mixed design** = different entities in all conditions of at least one predictor/IV, the same entities in all conditions of at least one other predictor variable/IV

## Slide 6 (new section): Moderation: Do video games lead to aggression?

## Slide 7

Video clip: [warcraft final](https://profandyfield.github.io/statistics_lectures/shared_media/video/warcraft_final.mp4)

## Slide 8: Moderation

- Is there a link between video games and aggression?
  - Outcome = aggressive behaviour (`aggress`)
  - Callus Unemotional Traits (`caunts`)
  - Video game Use (`vid_game`)

## Slide 9: Moderation: The theoretical model

![Image: dsr2 fig 10 03 moderation conceptual (no description provided yet)](images/dsr2_fig_10_03_moderation_conceptual.svg)

## Slide 10: Categorical moderator variable

![Plot (no description provided yet)](images/ds_factorial_designs_slide010_unnamed-chunk-2-1.png)

## Slide 11: Continuous moderator variable

![Image: dsr2 fig 10 05 moderation 3d surfaces (no description provided yet)](images/dsr2_fig_10_05_moderation_3d_surfaces.png)

## Slide 12: Moderation: The statistical model

![Image: dsr2 fig 10 06 moderation stat model (no description provided yet)](images/dsr2_fig_10_06_moderation_stat_model.svg)

``` math
 \begin{aligned} \text{aggression}_i = \hat{b}_0 + \hat{b}_1\text{video games}_i + \hat{b}_2\text{caunts}_i + \hat{b}_3\text{video games}\times\text{caunts}_i + e_i \end{aligned} 
```

## Slide 13: Interactions in the linear model

- An interaction term is the product of the two variables:

``` math
 \text{interaction} = \text{video_games} × \text{caunts} 
```

### Interpretation

- If the interaction term is significant, we have a significant moderation effect
- The parameter estimate (*b*) for the interaction quantifies the size of the interaction effect
- The effect of one predictor is stronger at some levels of another predictor
- In factorial designs, the effect of one predictor is stronger in certain categories of the other predictor
- Simple effects analysis

## Slide 14

Video clip: [wii injuries](https://profandyfield.github.io/statistics_lectures/shared_media/video/wii_injuries.mp4)

## Slide 15: A dangerous example

- Injury severity (0-20) measured during video games
- 40 Participants
  - 10 = Xbox One kinect (Static game)
  - 10 = Xbox One kinect (Active game)
  - 10 = Nintendo Switch (Static game)
  - 10 = Nintendo Switch (Active game)
- Variables:
  - Predictor = Type of `console` (Xbox or Switch)
  - Predictor = Type of `game` (static or active)
  - Outcome = `injury` severity (0 = no injury, 20 = severe injury)

> **Note: Statis-tip**
>
> This is a **two-way independent factorial design**.

## Slide 16: The model

``` math
 \begin{aligned} \text{injuries}_i = \hat{b}_0 + \hat{b}_1\text{game}_i + \hat{b}_2\text{console}_i + \hat{b}_3\text{game}\times\text{console}_i + e_i \end{aligned} 
```

## Slide 17: Partitioning variance

![Image: dsr2 fig 13 07 partitioning variance a (no description provided yet)](images/dsr2_fig_13_07_partitioning_variance_a.svg)

## Slide 18: Partitioning variance

![Image: dsr2 fig 13 07 partitioning variance b (no description provided yet)](images/dsr2_fig_13_07_partitioning_variance_b.svg)

## Slide 19: Partitioning variance

![Image: dsr2 fig 13 07 partitioning variance c (no description provided yet)](images/dsr2_fig_13_07_partitioning_variance_c.svg)

## Slide 20: Load and Look

``` r
xbox_tib |> 
  group_by(game, console) |> 
  describe_distribution(select = injury, ci = 0.95) |> 
  data_remove(c(Variable, Skewness, Kurtosis, n_Missing)) |> 
  display()
```

| game   | console  | Mean  | 95% CI (Mean)  | SD   | IQR  | Range          | n   |
|--------|----------|-------|----------------|------|------|----------------|-----|
| Static | Xbox One | 7.00  | (5.65, 8.60)   | 2.67 | 4.50 | (3.00, 11.00)  | 10  |
| Active | Xbox One | 9.40  | (7.40, 11.25)  | 3.37 | 5.75 | (4.00, 14.00)  | 10  |
| Static | Switch   | 6.70  | (5.55, 7.80)   | 1.95 | 2.25 | (3.00, 10.00)  | 10  |
| Active | Switch   | 12.90 | (11.85, 14.35) | 2.51 | 4.00 | (10.00, 18.00) | 10  |

![Image: l hex (no description provided yet)](images/l_hex.png)

## Slide 21: Visualize

``` r
ggplot(xbox_tib, aes(x = console, y = injury, colour = game, shape = game)) +
  stat_summary(fun.data = "mean_cl_normal", geom = "pointrange", position = position_dodge(width = 0.2)) +
  coord_cartesian(ylim = c(0,15)) +
  scale_y_continuous(breaks = 0:15) +
  scale_colour_viridis_d(begin = 0.3, end = 0.85) +
  labs(x = "Type of console", y = "Injury severity (0-20)", colour = "Type of game", shape = "Type of game") +
  theme_minimal()
```

![Plot (no description provided yet)](images/ds_factorial_designs_slide021_unnamed-chunk-4-1.png)

![Image: v hex (no description provided yet)](images/v_hex.png)

## Slide 22: Fit the model

- Remember that for *F*-statistics we typically want Type III sums of squares
- We can fit the model in the usual way using `lm()`, but …
- The `aov_4()` function from the `afex` package
  - An easier option
  - Automatically sets contrasts
  - Built in interaction plot with `afex_plot()`
  - But … no parameter estimates, limited diagnostic plots, no robust methods

``` r
xbox_afx <- afex::aov_4(injury ~ game*console + (1|id), data = xbox_tib)
```

## Slide 23: Overall model summary

``` r
model_parameters(xbox_afx, es_type = "omega") |> 
  display(use_symbols = TRUE)
```

| Parameter    | Sum_Squares | df  | Mean_Square | F     | p       | ω² (partial) |
|--------------|-------------|-----|-------------|-------|---------|--------------|
| game         | 184.90      | 1   | 184.90      | 25.86 | \< .001 | 0.38         |
| console      | 25.60       | 1   | 25.60       | 3.58  | 0.067   | 0.06         |
| game:console | 36.10       | 1   | 36.10       | 5.05  | 0.031   | 0.09         |
| Residuals    | 257.40      | 36  | 7.15        |       |         |              |

ANOVA estimation for factorial designs using ‘afex’

> **Important: ReportR**
>
> The type of game significantly moderated the effect of the games console on injury severity, F(1, 36) = 5.05, *p* = 0.031, $`\hat{\omega}^2_p`$ = 0.09. The interaction explained 9% of the variance in injuries not attributable to other predictors.

## Slide 24: Evaluate assumptions

``` r
check_model(xbox_afx)
```

![Plot (no description provided yet)](images/ds_factorial_designs_slide024_unnamed-chunk-8-1.png)

![Image: e hex (no description provided yet)](images/e_hex.png)

## Slide 25: Interpret

![Plot (no description provided yet)](images/ds_factorial_designs_slide025_unnamed-chunk-10-1.png)

![Image: i hex (no description provided yet)](images/i_hex.png)

## Slide 26: Interpret

![Plot (no description provided yet)](images/ds_factorial_designs_slide026_unnamed-chunk-11-1.png)

![Image: i hex (no description provided yet)](images/i_hex.png)

## Slide 27: Interpret the main effect of console

![Plot (no description provided yet)](images/ds_factorial_designs_slide027_unnamed-chunk-12-1.png)

![Image: i hex (no description provided yet)](images/i_hex.png)

## Slide 28: Interpret the main effect of console

![Plot (no description provided yet)](images/ds_factorial_designs_slide028_unnamed-chunk-13-1.png)

![Image: i hex (no description provided yet)](images/i_hex.png)

## Slide 29: Interpret the main effect of console

![Plot (no description provided yet)](images/ds_factorial_designs_slide029_unnamed-chunk-14-1.png)

![Image: i hex (no description provided yet)](images/i_hex.png)

## Slide 30: Interpret the main effect of console

![Plot (no description provided yet)](images/ds_factorial_designs_slide030_unnamed-chunk-15-1.png)

![Image: i hex (no description provided yet)](images/i_hex.png)

## Slide 31: Interpret the main effect of game

![Plot (no description provided yet)](images/ds_factorial_designs_slide031_unnamed-chunk-16-1.png)

![Image: i hex (no description provided yet)](images/i_hex.png)

## Slide 32: Interpret the main effect of game

![Plot (no description provided yet)](images/ds_factorial_designs_slide032_unnamed-chunk-17-1.png)

![Image: i hex (no description provided yet)](images/i_hex.png)

## Slide 33: Interpret the main effect of game

![Plot (no description provided yet)](images/ds_factorial_designs_slide033_unnamed-chunk-18-1.png)

![Image: i hex (no description provided yet)](images/i_hex.png)

## Slide 34

Video clip: [lazinc durt the time is here](https://profandyfield.github.io/statistics_lectures/shared_media/video/lazinc_durt_the_time_is_here.mp4)

## Slide 35: Interpret the interaction (moderation effect)

![Plot (no description provided yet)](images/ds_factorial_designs_slide035_unnamed-chunk-19-1.png)

| Parameter    | Sum_Squares | df  | Mean_Square | F     | p       | ω² (partial) |
|--------------|-------------|-----|-------------|-------|---------|--------------|
| game         | 184.90      | 1   | 184.90      | 25.86 | \< .001 | 0.38         |
| console      | 25.60       | 1   | 25.60       | 3.58  | 0.067   | 0.06         |
| game:console | 36.10       | 1   | 36.10       | 5.05  | 0.031   | 0.09         |
| Residuals    | 257.40      | 36  | 7.15        |       |         |              |

ANOVA estimation for factorial designs using ‘afex’

![Image: i hex (no description provided yet)](images/i_hex.png)

## Slide 36: Interpreting interactions

### Console moderating the effect of game

![Plot (no description provided yet)](images/ds_factorial_designs_slide036_unnamed-chunk-22-1.png)

![Image: i hex (no description provided yet)](images/i_hex.png)

## Slide 37: Interpreting interactions

### Console moderating the effect of game

![Plot (no description provided yet)](images/ds_factorial_designs_slide037_unnamed-chunk-23-1.png)

``` math
 \begin{aligned} \text{game}_\text{Switch} &= \bar{X}_\text{active, Switch}-\bar{X}_\text{static, Switch} \\ &= 12.90 - 6.70 \\ &= 6.20 \end{aligned} 
```

``` math
 \begin{aligned} \text{game}_\text{Xbox} &= \bar{X}_\text{active, Xbox}-\bar{X}_\text{static, Xbox} \\ &= 9.40 - 7.00 \\ &= 2.40 \end{aligned} 
```

``` math
 \begin{aligned} \text{Interaction} &= \text{game}_\text{Switch} - \text{game}_\text{Xbox} \\ &= 6.2 - 2.40 \\ &= 3.8 \end{aligned} 
```

![Image: i hex (no description provided yet)](images/i_hex.png)

## Slide 38: Interpret simple effects

### The effect of type of game within consoles

``` r
estimate_contrasts(model = xbox_afx,
                   contrast = "game",
                   by = "console",
                   comparison = "joint",
                   p_adjust = "bonferroni") |> 
  display()
```

| Contrast | console  | df1 | df2 | F     | p       |
|----------|----------|-----|-----|-------|---------|
| game     | Xbox One | 1   | 36  | 4.03  | 0.105   |
| game     | Switch   | 1   | 36  | 26.88 | \< .001 |

Marginal Joint Test

*Predictors averaged: id; p-value adjustment method: Bonferroni*

> **Important: ReportR**
>
> The effect of playing active vs. static games is less significant for the Xbox than the switch. The difference in mean injuries between active and static games was not significantly different for the Xbox, *F*(1, 36) = 4.03, *p* = 0.105, but was for the Switch, *F*(1, 36) = 26.88, *p* \< 0.001.

## Slide 39: Interpreting interactions

### Game moderating the effect of console

![Plot (no description provided yet)](images/ds_factorial_designs_slide039_unnamed-chunk-27-1.png)

## Slide 40: Interpreting interactions

### Game moderating the effect of console

![Plot (no description provided yet)](images/ds_factorial_designs_slide040_unnamed-chunk-28-1.png)

``` math
 \begin{aligned} \text{console}_\text{active} &= \bar{X}_\text{active, Switch}-\bar{X}_\text{active, Xbox} \\ &= 12.90 - 9.4 \\ &= 3.5 \end{aligned} 
```

``` math
 \begin{aligned} \text{console}_\text{static} &= \bar{X}_\text{static, Switch}-\bar{X}_\text{static, Xbox} \\ &= 6.7 - 7.00 \\ &= -0.3 \end{aligned} 
```

``` math
 \begin{aligned} \text{Interaction} &= \text{console}_\text{active} - \text{console}_\text{static} \\ &= 3.5 - (-0.3) \\ &= 3.8 \end{aligned} 
```

![Image: i hex (no description provided yet)](images/i_hex.png)

## Slide 41: Interpret: simple effects analysis

### The effect of console within the type of game

``` r
estimate_contrasts(model = xbox_afx,
                   contrast = "console",
                   by = "game",
                   comparison = "joint",
                   p_adjust = "bonferroni") |> 
  display()
```

| Contrast | game   | df1 | df2 | F    | p       |
|----------|--------|-----|-----|------|---------|
| console  | Static | 1   | 36  | 0.06 | \> .999 |
| console  | Active | 1   | 36  | 8.57 | 0.012   |

Marginal Joint Test

*Predictors averaged: id; p-value adjustment method: Bonferroni*

> **Important: ReportR**
>
> The effect of playing Xbox vs. Switch games is less significant for static games than active ones. The difference in mean injuries between Xbox and Switch games was not significantly different for static games, *F*(1, 36) = 0.06, *p* = 1.000, but was for the active games, *F*(1, 36) = 8.57, *p* = 0.012.

## Slide 42

> **Warning: The danger zone!**
>
> Repeat the following mantra:
>
> **“It is never sensible to interpret main effects in the presence of a significant interaction effect.”**

## Slide 43

Video clip: [milton meditation butthole](https://profandyfield.github.io/statistics_lectures/shared_media/video/milton_meditation_butthole.mp4)

## Slide 44 (new section): The beer goggles effect

## Slide 45: A science reflecting art example

- The beer goggles effect: subjective perceptions of physical attractiveness become inaccurate after drinking alcohol
- Chen et al., (2014)<sup>1</sup>
  - Alcohol consumption reduces accuracy in symmetry judgements
  - Symmetric faces have been shown to be rated as more attractive.
  - If the beer-goggles effect is driven by alcohol impairing symmetry judgements then you’d expect a stronger effect for unattractive (asymmetric) faces than attractive (symmetric) ones
- Fictional data but matches Chen et al. findings

![Image: zobo chat edit (no description provided yet)](images/zobo_chat_edit.png)

*Footnotes*

1.  Chen, et al., (2014). The moderating effect of stimulus attractiveness on the effect of alcohol consumption on attractiveness ratings. Alcohol and Alcoholism, 49, 515–519. <https://doi.org/10.1093/alcalc/agu026>

## Slide 46: Study design

- 48 Participants (8 per group)
- Predictor: `alcohol`
  - **Placebo** group: 500 ml of alcohol-free beer
  - **Low-dose** group: 500 ml of beer (4% ABV);
  - **High-dose** group: 500 ml of beer (7% ABV).
- Predictor: `facetype`
- Rated 50 **unattractive** (asymmetric) faces
- Rated 50 **attractive** (symmetric) faces
- Outcome:
  - Median rating of the 50 photos on a scale from 0 (pass me a paper bag) to 10 (pass me their phone number)

> **Note: Statis-tip**
>
> This is a **two-way independent factorial design**.

![Image: zobo chat edit (no description provided yet)](images/zobo_chat_edit.png)

## Slide 47: Load and Look

``` r
goggles_tib |> 
  group_by(facetype, alcohol) |> 
  describe_distribution(select = attractiveness, ci = 0.95) |> 
  data_remove(c(Variable, Skewness, Kurtosis, n_Missing)) |> 
  display()
```

| facetype     | alcohol   | Mean | 95% CI (Mean) | SD   | IQR  | Range        | n   |
|--------------|-----------|------|---------------|------|------|--------------|-----|
| Unattractive | Placebo   | 3.50 | (2.38, 4.32)  | 1.60 | 2.50 | (1.00, 6.00) | 8   |
| Attractive   | Placebo   | 6.38 | (5.81, 6.82)  | 0.92 | 1.00 | (5.00, 8.00) | 8   |
| Unattractive | Low dose  | 4.88 | (4.06, 5.69)  | 1.25 | 1.75 | (3.00, 7.00) | 8   |
| Attractive   | Low dose  | 6.50 | (5.88, 7.00)  | 0.93 | 1.00 | (5.00, 8.00) | 8   |
| Unattractive | High dose | 6.62 | (5.93, 7.32)  | 1.06 | 1.75 | (5.00, 8.00) | 8   |
| Attractive   | High dose | 6.12 | (5.43, 6.75)  | 1.13 | 2.00 | (5.00, 8.00) | 8   |

![Image: l hex (no description provided yet)](images/l_hex.png)

## Slide 48: Visualize

![Plot (no description provided yet)](images/goggles_plot-1.png)

![Image: v hex (no description provided yet)](images/v_hex.png)

## Slide 49: Fit the model

``` r
goggles_afx <- afex::aov_4(attractiveness ~ facetype*alcohol + (1|id), data = goggles_tib)

model_parameters(goggles_afx, es_type = "omega") |> 
  display(use_symbols = TRUE)
```

| Parameter        | Sum_Squares | df  | Mean_Square | F     | p       | ω² (partial) |
|------------------|-------------|-----|-------------|-------|---------|--------------|
| facetype         | 21.33       | 1   | 21.33       | 15.58 | \< .001 | 0.23         |
| alcohol          | 16.54       | 2   | 8.27        | 6.04  | 0.005   | 0.17         |
| facetype:alcohol | 23.29       | 2   | 11.65       | 8.51  | \< .001 | 0.24         |
| Residuals        | 57.50       | 42  | 1.37        |       |         |              |

ANOVA estimation for factorial designs using ‘afex’

> **Important: ReportR**
>
> The dose of alcohol significantly moderated the effect of the type of face on attractiveness ratings, F(2, 42) = 8.51, *p* \< 0.001, $`\hat{\omega}^2_p`$ = 0.24. The interaction explained 24% of the variance in injuries not attributable to other predictors.

## Slide 50: Evaluate assumptions

``` r
check_model(goggles_afx)
```

![Plot (no description provided yet)](images/ds_factorial_designs_slide050_unnamed-chunk-34-1.png)

![Image: e hex (no description provided yet)](images/e_hex.png)

## Slide 51: Interpret simple effects

### Simple effects: facetype within alcohol group

| Contrast | alcohol   | df1 | df2 | F     | p       |
|----------|-----------|-----|-----|-------|---------|
| facetype | Placebo   | 1   | 42  | 24.15 | \< .001 |
| facetype | Low dose  | 1   | 42  | 7.72  | 0.024   |
| facetype | High dose | 1   | 42  | 0.73  | \> .999 |

Marginal Joint Test

*Predictors averaged: id; p-value adjustment method: Bonferroni*

## Slide 52: Interpret simple effects

### Simple effects: facetype within alcohol group

![Plot (no description provided yet)](images/ds_factorial_designs_slide052_unnamed-chunk-36-1.png)

![Image: i hex (no description provided yet)](images/i_hex.png)

## Slide 53: Interpret simple effects

### Simple effects: facetype within alcohol group

![Plot (no description provided yet)](images/ds_factorial_designs_slide053_unnamed-chunk-37-1.png)

![Image: i hex (no description provided yet)](images/i_hex.png)

## Slide 54: Interpret simple effects

### Simple effects: alcohol within facetype

| Contrast | facetype     | df1 | df2 | F     | p       |
|----------|--------------|-----|-----|-------|---------|
| alcohol  | Unattractive | 2   | 42  | 14.33 | \< .001 |
| alcohol  | Attractive   | 2   | 42  | 0.21  | \> .999 |

Marginal Joint Test

*Predictors averaged: id; p-value adjustment method: Bonferroni*

![Image: i hex (no description provided yet)](images/i_hex.png)

## Slide 55: Interpret simple effects

### Simple effects: alcohol within facetype

![Plot (no description provided yet)](images/ds_factorial_designs_slide055_unnamed-chunk-39-1.png)

![Image: i hex (no description provided yet)](images/i_hex.png)

## Slide 56: Interpret simple effects

### Simple effects: alcohol within facetype

![Plot (no description provided yet)](images/ds_factorial_designs_slide056_unnamed-chunk-40-1.png)

![Image: i hex (no description provided yet)](images/i_hex.png)

## Slide 57: Summary

- Factorial designs: two or more predictor variables are manipulated
- Moderation: Where the effect of one predictor differs at levels of another-
- Testing moderation (interaction effects)
  - The model: a linear model in which predictors are entered as well as their interaction
  - Interpret interactions using plots or simple effects analysis, which quantifies the effect of one predictor at each level of another
  - The process of E.V.I.L.
- Main effects
  - The effect of one predictor variable collapsed across levels of other predictors
  - Uninteresting in the presence of a significant interaction
