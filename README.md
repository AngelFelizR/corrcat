# corrcat

<!-- badges: start -->
[![R-CMD-check](https://github.com/AngelFelizR/corrcat/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/AngelFelizR/corrcat/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

`corrcat` facilitates to explore correlations between categorical and ordinal variables in a tidy way using `data.table` as back-end.

## Installation

```r
The development version from GitHub:

# install.packages("pak")
pak::pak("AngelFelizR/corrcat")
```

## Syntax

To use the functions of this library you need to input a `data.table`, `tibble` or `data.frame`, then the functions will work to calculate all possible values of the metric returning as a result other data frame with all the metrics.

### Correlation between nominal variables

Validating correlations is an important step for every EDA, if all the columns are numeric is really easy to use the pearson correlation to make our estimation, there are also alternatives for categorical variables that can simplify a lot our analysis.

**Data**

```{r}
set.seed(2024)

df <- data.frame(
  gender = sample(c("male", "female"), 100, replace = TRUE) |> factor(),
  race = sample(c("white", "black", "asian", "other"), 100, replace = TRUE),
  education = sample(c("high school", "college", "graduate"), 100, replace = TRUE),
  income = sample(c("low", "medium", "high"), 100, replace = TRUE)
)
set.seed(NULL)

head(df)

#   gender   race   education income
# 1 female  other high school   high
# 2   male  black high school medium
# 3   male  white    graduate    low
# 4 female  other    graduate   high
# 5   male  white high school   high
# 6   male  other    graduate medium

```

**Cramer correlation for each pair of columns**

```{r}
cramerV_df(df)

#          V1        V2 Cramer.V
# 1    gender      race  0.15370
# 2    gender education  0.07143
# 3    gender    income  0.10350
# 4      race education  0.18480
# 5      race    income  0.18920
# 6 education    income  0.19900
```


**cohenW correlation for each pair of columns**

```{r}
cohenW_df(df)

#          V1        V2 Cohen.w
# 1    gender      race 0.15370
# 2    gender education 0.07143
# 3    gender    income 0.10350
# 4      race education 0.26130
# 5      race    income 0.26750
# 6 education    income 0.28140
```
