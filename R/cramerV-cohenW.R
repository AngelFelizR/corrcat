
# This function is only need when ci = TRUE and needs
# more processes so we don't need to export it

#' @importFrom tibble is_tibble as_tibble
#' @importFrom utils combn
#' @import data.table

df_to_matrix <- function(DT,
                         var1,
                         var2){

  stopifnot("DT must have 2 character columns" ={
      (is.character(DT[[var1]]) | is.factor(DT[[var1]])) &
      (is.character(DT[[var2]]) | is.factor(DT[[var2]]))
  })

  DT <- data.table::copy(DT)

  data.table::setnames(DT, c(var1, var2), c("V1", "V2"))

  dt_matrix <-
    DT[, .N, c("V1", "V2")] |>
    data.table::dcast(V1 ~ V2, value.var = "N") |>
    (\(x) as.data.frame(x[, !c("V1")], row.names = x$V1) )() |>
    as.matrix()

  return(dt_matrix)

}


calculate_cat_corr <- function(df,
                               fun_col_names,
                               corr_fun,
                               unique,
                               ci,
                               ...){

  stopifnot("df must be data.frame" = is.data.frame(df))

  is_tibble <- tibble::is_tibble(df)
  is_data.table <- data.table::is.data.table(df)

  # Transforming the data.frame into a data.table
  if(!is_data.table){
    df <- data.table::as.data.table(df)
  }

  # We just can apply the next process in data.frames with
  # at least 2 categorical variables
  df <-
    df[, .SD,
       .SDcols = \(x) is.character(x) | is.factor(x)]

  stopifnot("df must have at least 2 categorical variables" = ncol(df) >= 2L)


  # Defining combinations to calculate
  comb <-
    if(unique){
      names(df) |>
        utils::combn(2) |>
        t() |>
        data.table::as.data.table()
    }else{
      data.table::CJ(V1 = names(df),
                     V2 = names(df)
      )[V1 != V2]
    }

  # Calculating cramer value
  all_calculations <-
    comb[,{

      if(ci){
        df_to_matrix(df, V1, V2) |>
          corr_fun(ci = ci, ...)
      }else{
        temp_list <- list(corr_fun(
          df[[V1]],
          df[[V2]],
          ci = ci,
          ...)
        )

        data.table::setattr(temp_list, "names", fun_col_names)

        temp_list
      }
    },
    by = c("V1", "V2")]

  # Returning df to its original class
  all_calculations <-
    if(is_tibble){
      tibble::as_tibble(all_calculations)
    }else if(!is_data.table){
      as.data.frame(all_calculations)
    }else{
      all_calculations
    }

  return(all_calculations)
}


#' @title Cramer's V (phi) for data.frames
#' @description Calculates Cramer's V for each pair of categorical columns
#' in a data.frame, estimating confidence intervals by bootstrap.
#'
#' @author Angel Feliz
#'
#' @importFrom rcompanion cramerV
#'
#' @param df A data.table, tibble or data.frame with factor or character columns.
#' @param unique As the metric is symmetric (\code{cramerV(x,y) == cramerV(y,x)}) it avoids calculating twice the same value.
#' @param ci If TRUE, returns confidence intervals by bootstrap. May be slow.
#' @param ... Additional arguments passed to \code{\link[rcompanion]{cramerV}}.
#'
#' @return A data.table, tibble or data.frame with the columns \code{V1}, \code{V2} and \code{Cramer.V}
#' with a row for each combination of categorical variables present
#' in the original \code{df}.
#'
#' If \code{ci = TRUE} then \code{lower.ci} and \code{upper.ci} will be adding
#' based on the default \code{R} replications.
#'
#' @seealso \code{\link[rcompanion]{cramerV}} \code{\link[corrcat]{cohenW_df}}
#'
#' @export
#'
#' @examples
#' set.seed(2024)
#' df <- data.frame(
#'   gender = sample(c("male", "female"), 100, replace = TRUE) |> factor(),
#'   race = sample(c("white", "black", "asian", "other"), 100, replace = TRUE),
#'   education = sample(c("high school", "college", "graduate"), 100, replace = TRUE),
#'   income = sample(c("low", "medium", "high"), 100, replace = TRUE)
#' )
#' set.seed(NULL)
#'
#' cramerV_df(df)
#' cramerV_df(df, ci = TRUE, R = 50)

cramerV_df <- function(df,
                       unique = TRUE,
                       ci = FALSE,
                       ...){

  calculate_cat_corr(df,
                     fun_col_names = "Cramer.V",
                     corr_fun = rcompanion::cramerV,
                     unique = unique,
                     ci = ci,
                     ...)

}


#' @title Cohen's w for data.frames
#' @description Calculates Cohen's w for each pair of categorical columns
#' in a data.frame, estimating confidence intervals by bootstrap.
#'
#' @author Angel Feliz
#'
#' @importFrom rcompanion cohenW
#'
#' @param df A data.table, tibble or data.frame with factor or character columns.
#' @param unique As the metric is symmetric (\code{cohenW(x,y) == cohenW(y,x)}) it avoids calculating twice the same value.
#' @param ci If TRUE, returns confidence intervals by bootstrap. May be slow.
#' @param ... Additional arguments passed to \code{\link[rcompanion]{cohenW}}.
#'
#' @return A data.table, tibble or data.frame with the columns \code{V1}, \code{V2} and \code{Cohen.w}
#' with a row for each combination of categorical variables present
#' in the original \code{df}.
#'
#' If \code{ci = TRUE} then \code{lower.ci} and \code{upper.ci} will be adding
#' based on the default \code{R} replications.
#'
#' @seealso \code{\link[rcompanion]{cohenW}} \code{\link[corrcat]{cramerV_df}}
#'
#' @export
#'
#' @examples
#' set.seed(2024)
#' df <- data.frame(
#'   gender = sample(c("male", "female"), 100, replace = TRUE) |> factor(),
#'   race = sample(c("white", "black", "asian", "other"), 100, replace = TRUE),
#'   education = sample(c("high school", "college", "graduate"), 100, replace = TRUE),
#'   income = sample(c("low", "medium", "high"), 100, replace = TRUE)
#' )
#' set.seed(NULL)
#'
#' cohenW_df(df)
#' cohenW_df(df, ci = TRUE, R = 50)

cohenW_df <- function(df,
                      unique = TRUE,
                      ci = FALSE,
                      ...){

  calculate_cat_corr(df,
                     fun_col_names = "Cohen.w",
                     corr_fun = rcompanion::cohenW,
                     unique = unique,
                     ci = ci,
                     ...)

}

