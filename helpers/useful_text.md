---- for slides ----

## {background-image="media/lone_knight.jpg" background-size="cover"}
## {background-video="media/zach_not_allowed_to_kill_dragons_caption.mp4" background-size="cover"}


::: notes
:::

::: fragment
:::

:::: columns
::: {.column width="45%"}
:::

::: {.column width="10%"}
:::

::: {.column width="45%"}
:::
:::

::: {.r-fit-text}
:::

--- callouts


::: tip
`r cat_space()`

:::

::: notes
`r pen()`
:::

::: tip
`r bug()`
:::

---code

```{r}
#| echo: TRUE
#| eval: FALSE
#| code-line-numbers: "1"
x <- 1:10
x
LETTERS[x]
```


---- for equations ----

::: center-h
::: txt_mulberry
::: txt_300
:::
:::
:::

---- for figures ----


![](../shared_media/images/xxxx.png){fig-align="center" height=600}

![](media/xxxx.png){fig-align="center" height=600}


{fig-align="center" height=600}

1050 x 700

---- callouts ----

-- hypothesis

::: {.callout-caution icon = false}
## {{< fa brain >}} Hypothesis

- xxxxx
:::

-- tip

::: {.callout-tip icon = false}
## `r cat_space()` What they are:

- Intervals that contain the 'true' population value of the parameter in 95% of samples.

:::

-- question

:::{.callout-note icon=false}
## {{< fa question >}} Questions to ask yourself

- xxx?

:::

-- list

:::{.callout-tip icon=false}
## {{< fa list-ul >}} All models have a S.P.I.N.E

::: incremental
- 

:::
:::


-- warning

::: fragment
::: {.callout-warning icon = false}
## `r bug()` What they are not:

- There is NOT a 95% probability that a given interval contains the population value.
    - It is *p* = 0 or *p* = 1, but you can’t know which!
- They do NOT reflect confidence in the value of the population parameter.

:::
:::


