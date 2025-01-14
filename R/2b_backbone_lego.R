#' Design your own custom backbone easily
#' 
#' You can use the `bblego` functions in order to create 
#' custom backbones using various components. Please note that the `bblego` 
#' functions currently only allow you to create tree-like backbones. 
#' 
#' A backbone always needs to start with a single `bblego_start()` state and
#' needs to end with one or more `bblego_end()` states.
#' The order of the mentioned states needs to be such that a state is never
#' specified in the first argument (except for `bblego_start()`) before
#' having been specified as the second argument.
#' 
#' @param from The begin state of this component.
#' @param to The end state of this component.
#' @param type Some components have alternative module regulatory networks. 
#' 
#' `bblego_start()`, `bblego_linear()`, `bblego_end()`: 
#' 
#' * `"simple"`: a sequence of modules in which every module upregulates the next module.
#' * `"doublerep1"`: a sequence of modules in which every module downregulates the next
#'   module, and each module has positive basal expression.
#' * `"doublerep2"`: a sequence of modules in which every module upregulates the next 
#'   module, but downregulates the one after that.
#' * `"flipflop"`: a sequence of modules in which every module upregulates the next module.
#'   In addition, the last module upregulates itself and strongly downregulates the first module.
#'   
#' `bblego_branching()`: 
#' 
#' * `"simple"`: a set of `n` modules (with `n = length(to)`) which all downregulate
#'   one another and upregulate themselves. This causes a branching to occur in the trajectory.
#'   
#' @param num_modules The number of modules this component is allowed to use. 
#'   Various components might require a minimum number of components in order to work properly.
#' @param burn Whether or not these components are part of the warm-up simulation.
#' @param ...,.list `bblego` components, either as separate args or as a list.
#' 
#' @export
#' 
#' @examples 
#' backbone <- bblego(
#'   bblego_start("A", type = "simple", num_modules = 2),
#'   bblego_linear("A", "B", type = "simple", num_modules = 3),
#'   bblego_branching("B", c("C", "D"), type = "robust", num_modules = 6),
#'   bblego_end("C", type = "flipflop", num_modules = 4),
#'   bblego_end("D", type = "doublerep1", num_modules = 7)
#' )
bblego <- function(..., .list = NULL) {
  mods <- c(list(...), .list)
  
  backbone(
    module_info = map_df(mods, "module_info"),
    module_network = map_df(mods, "module_network"),
    expression_patterns = map_df(mods, "expression_patterns")
  )
}

#' @rdname bblego
#' @export
bblego_linear <- function(
  from, 
  to, 
  type = sample(c("simple", "doublerep1", "doublerep2", "flipflop"), 1),
  num_modules = sample(4:6, 1),
  burn = FALSE
) {
  assert_that(num_modules >= 1)
  
  module_ids <- c(
    paste0(from, seq_len(num_modules)),
    paste0(to, 1)
  )
  
  module_info <- tibble(
    module_id = module_ids %>% head(-1),
    ba = 0,
    burn = burn
  )
  
  if (type == "simple") {
    module_network <- 
      tibble(
        from = module_ids %>% head(-1),
        to = module_ids %>% tail(-1),
        effect = 1,
        strength = 1,
        cooperativity = 2
      )
  } else if (type == "doublerep1") {
    assert_that(num_modules >= 2)
    
    bas <- c(0, rep(1, num_modules-1), 0)
    if (num_modules %% 2 == 0) {
      bas[[2]] <- 0
    }
    module_info <- module_info %>% mutate(
      ba = bas %>% head(-1),
      burn = burn | ba > 0
    )
    
    module_network <- 
      tibble(
        from = module_ids %>% head(-1),
        to = module_ids %>% tail(-1),
        effect = ifelse(bas[-1] > 0, -1, 1),
        strength = ifelse(effect == 1, 1, 10),
        cooperativity = 2
      )
  } else if (type == "doublerep2") {
    assert_that(num_modules >= 4)
    pos_to <- 
      if (num_modules %% 2 == 1) {
        module_ids[c(2, num_modules, num_modules + 1)]
      } else {
        module_ids[c(2, num_modules + 1)]
      }
    module_network <- 
      bind_rows(
        tibble(
          from = module_ids %>% head(-1),
          to = module_ids %>% tail(-1),
          effect = ifelse(to %in% pos_to, 1, -1),
          strength = 1,
          cooperativity = 2
        ),
        tibble(
          from = module_ids %>% head(-2) %>% head(-1),
          to = module_ids %>% tail(-2) %>% head(-1),
          effect = 1,
          strength = seq_along(from),
          cooperativity = 2
        ) %>% 
          head(., ifelse(num_modules %% 2 == 1, nrow(.) - 1, nrow(.)))
      )
  } else if (type == "flipflop") {
    assert_that(num_modules >= 4)
    
    module_info <- tibble(
      module_id = module_ids %>% head(-1),
      ba = 0,
      burn = burn
    )
    
    module_network <- bind_rows(
      tibble(
        from = module_ids %>% head(-1),
        to = module_ids %>% tail(-1),
        effect = 1,
        strength = 1,
        cooperativity = 2
      ),
      tribble(
        ~from, ~to, ~effect, ~strength, ~cooperativity,
        nth(module_ids, -2), nth(module_ids, 1), -1, 10, 2,
        nth(module_ids, -3), nth(module_ids, -1), -1, 100, 2,
        nth(module_ids, -2), nth(module_ids, -2), 1, 1, 2
      )
    )
  } else {
    stop("Unknown 'type' parameter")
  }
  
  expression_patterns <- tibble(
    from = paste0("s", from),
    to = paste0("s", to),
    module_progression = paste0("+", module_ids %>% head(-1), collapse = ","),
    start = FALSE,
    burn = burn,
    time = as.numeric(case_when(
      type == "flipflop" ~ num_modules * 2L,
      TRUE ~ num_modules
    ))
  )
  
  lst(module_info, module_network, expression_patterns)
}

#' @rdname bblego
#' @export
bblego_branching <- function(
  from, 
  to, 
  type = c("robust", "simple"),
  num_modules = length(to) * 2 + 2,
  burn = FALSE
) {
  assert_that(
    length(to) >= 2,
    num_modules >= length(to) * 2 + 1
  )
  
  type <- match.arg(type)
  
  # todo: implement reversible branching again
  
  lin_length <- num_modules - 2 * length(to)
  
  my_module_ids <- 
    paste0(from, seq_len(lin_length))
  our_module_ids <- 
    paste0(from, seq(lin_length + 1, num_modules))
  our_module_ids1 <- 
    our_module_ids[seq_len(length(our_module_ids) / 2)]
  our_module_ids2 <- 
    our_module_ids[-seq_len(length(our_module_ids) / 2)]
  their_module_ids <- 
    paste0(to, 1)
  module_ids <- c(my_module_ids, our_module_ids, their_module_ids)
  
  module_info <- tibble(
    module_id = c(my_module_ids, our_module_ids),
    ba = 0,
    burn = burn
  )
  
  module_network <- bind_rows(
    modnet_chain(my_module_ids),
    modnet_edge(last(my_module_ids), our_module_ids1),
    modnet_edge(our_module_ids1, our_module_ids2, strength = 2),
    modnet_edge(our_module_ids2, our_module_ids1, strength = 2),
    modnet_edge(our_module_ids1, first(my_module_ids), effect = -1, strength = 5),
    modnet_edge(our_module_ids2, their_module_ids),
    modnet_pairwise(our_module_ids1, effect = -1, strength = 100),
    modnet_pairwise(our_module_ids1, our_module_ids2, effect = -1, strength = 10000000)
  )
  
  in_edge <- if (length(my_module_ids) >= 1) {
    paste0("+", my_module_ids, ",", collapse = "")
  } else {
    c()
  }
  
  expression_patterns <- tibble(
    from = paste0("s", from),
    to = paste0("s", to),
    module_progression = paste0(in_edge, "+", our_module_ids1, ",+", our_module_ids2),
    start = FALSE,
    burn = burn,
    time = num_modules + 1
  )
  
  lst(module_info, module_network, expression_patterns)
}

#' @rdname bblego
#' @export
bblego_start <- dynutils::inherit_default_params(
  list(bblego_linear), 
  function(to, type, num_modules) {
    out <- bblego_linear(
      from = "Burn", 
      to = to,
      type = type,
      num_modules = num_modules,
      burn = TRUE
    )
    out$module_info <- 
      out$module_info %>% 
      mutate(ba = ifelse(module_id == "Burn1", 1, ba))
    out$expression_patterns <-
      out$expression_patterns %>% 
      mutate(start = TRUE)
    out
  }
)

#' @rdname bblego
#' @export
bblego_end <- dynutils::inherit_default_params(
  list(bblego_linear), 
  function(from, type, num_modules) {
    out <- bblego_linear(from, paste0("End", from), type = type, num_modules = num_modules)
    out$module_network <- out$module_network %>% filter(!grepl("^End", to))
    out$expression_patterns <- out$expression_patterns %>% mutate(
      time = time - 1
    ) %>% 
      filter(time > 0)
    out
  }
)