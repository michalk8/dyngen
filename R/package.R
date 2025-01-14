#' Generating TI data
#'
#' @import dplyr
#' @import tidyr
#' @importFrom purrr %>% map map_df map_chr map_lgl map_int map_dbl discard keep pmap map2 set_names
#' @importFrom tibble is_tibble as_tibble as_data_frame tibble data_frame enframe deframe lst tribble rownames_to_column column_to_rownames
#' @importFrom magrittr set_rownames set_colnames
#' @importFrom methods as
#' @importFrom utils head tail
#' @import assertthat
#' @import dynutils
#' @import dynwrap
#' @importFrom Matrix t Matrix sparseMatrix summary
#' @importFrom pbapply pblapply 
#'
#' @docType package
#' @name dyngen
NULL

# when next version of rlang is released
# @importFrom rlang %|%
`%|%` <- function(x, y) {
  ifelse(is.na(x), y, x)
}