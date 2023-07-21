#' Creating complete survival estimates
#'
#' expand and fill in the data.frame from start to finish. No more missing days
#'
#' @param object either survift or coxph object
#' @param cap if you want survival capped at any timepoint, default is max of data
#' @param ignore ignore warnings or not
#'
#' @importFrom dplyr sym
#' @importFrom dplyr ungroup
#' @importFrom dplyr filter
#' @importFrom dplyr select
#' @importFrom dplyr tibble
#' @importFrom tidyr crossing
#' @importFrom dplyr bind_rows
#' @importFrom dplyr arrange
#' @importFrom dplyr group_by
#' @importFrom tidyr fill
#' @importFrom tidyr complete
#' @importFrom dplyr any_of
#' @importFrom dplyr .data
#' @importFrom rlang :=
#'
#' @return a complete dataset of survival estimates and time
create_surv_rates <- function(object, cap = NA, ignore = FALSE){
  dW <- getOption("warn")

  if(ignore){
    options(warn = -1)
  }

  sd <- get_surv_data(object) |>
    dplyr::select(-dplyr::any_of(c("std.err", "lower", "upper", "n.risk", "n.event", "n.censor", "cumhaz")))

  if(any(sd$time<0)){
    warning("Model contains negative times, estimates may be unreliable")
  }

  f_df <- data.frame(time = c(-1, max(sd$time) + 1), surv = c(1, NA))

  cond <- colnames(sd) %in% c("time", "surv")

  if(!all(cond)){
    str1 <- colnames(sd)[which(!cond)]
    f_df <- tidyr::crossing(f_df, !!str1 := levels(as.factor(sd[,str1])))
    sd <- dplyr::arrange(dplyr::bind_rows(sd, f_df), time) |>
      dplyr::group_by(!!sym(str1))

  }else{
    sd <- dplyr::arrange(dplyr::bind_rows(sd, f_df), time)
  }

  if(is.na(cap)){cap <- max(sd$time)}

  sd <- sd |>
    tidyr::complete(time = -1:max(.data$time)) |>
    fill(.data$surv, .direction = "down") |>
    filter(.data$time >= 0) |>
    filter(.data$time <= cap) |>
    ungroup()

  options(warn = dW)

  return(sd)

}
