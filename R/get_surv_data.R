#' Get Survival Data
#'
#' @param object object to get survival data from
#' @param ... other arguments depending on class
#'
#' @return a data.frame of survival times
#' @export
#'
#' @rdname get_surv_data
#'
#' @examples
#' # Create the simplest test data set
#' ## same example from survival package
#' test1 <- list(time=c(4,3,1,1,2,2,3),
#'             status=c(1,1,1,0,1,1,0),
#'            x=c(0,2,1,1,1,0,0),
#'            sex=c(0,0,0,0,1,1,1))
#' # Fit a stratified model
#' c1 <- survival::coxph(survival::Surv(time, status) ~ x + survival::
#' strata(sex), test1)
#' km1 <- survival::survfit(survival::Surv(time, status) ~ 1, test1)
#' get_surv_data(c1)
#' get_surv_data(km1)
get_surv_data <- function(object, ...){
  UseMethod("get_surv_data")
}

#' @name get_surv_data
#' @export
get_surv_data.survfit <- function(object, ...){
  s1 <- summary(object)
  df <- data.frame(time = s1$time, surv = s1$surv, std.err = s1$std.err,
                   lower = s1$lower, upper = s1$upper, n.risk = s1$n.risk,
                   n.event = s1$n.event, n.censor = s1$n.censor, cumhaz = s1$cumhaz)
  if(!is.null(object$strata)){
    str1 <- gsub("*=.","",s1$strata[1])
    df[str1] <- gsub(".*=", "", s1$strata)
  }
  return(df)
}

#' @name get_surv_data
#' @export
get_surv_data.coxph <- function(object, ...){
  object1 <- survival::survfit(object, ...)
  s1 <- summary(object1)
  df <- data.frame(time = s1$time, surv = s1$surv, std.err = s1$std.err,
                   lower = s1$lower, upper = s1$upper, n.risk = s1$n.risk,
                   n.event = s1$n.event, n.censor = s1$n.censor, cumhaz = s1$cumhaz)
  if(!is.null(object1$strata)){
    snm <- names(object$xlevels)[grep("strata", names(object$xlevels))]
    str1 <- gsub( "\\).*", "", gsub(".*strata\\(", "", snm))
    df[str1] <- s1$strata
  }
  return(df)
}

