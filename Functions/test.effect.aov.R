#' @title Applying an aov to the data
#'
#' @description Applying an aov to the data
#'
#' @param data the whole dataset
#' @param formula which formula to pass to the model
#' @param fun which function for the model
#' 
#' @examples
#'
#' @seealso
#' 
#' @author Thomas Guillerme
#' @export

test.effect.aov <- function(data, formula, fun) {

    ## Testing model assumptions
    aov_data_RF_best <- get.aov.data(whole_data, "RF", "norm", combined = TRUE)
    aov_data_Tr_best <- get.aov.data(whole_data, "Triples", "norm", combined = TRUE)
    aov_data_RF_null <- get.aov.data(whole_data, "RF", "null", combined = TRUE)
    aov_data_Tr_null <- get.aov.data(whole_data, "Triples", "null", combined = TRUE)

    ## Models with normalised tree score function of scenario (with nestedness)
    model_RF_best <- fun(formula = formula, data = aov_data_RF_best)
    model_Tr_best <- fun(formula = formula, data = aov_data_Tr_best)
    model_RF_null <- fun(formula = formula, data = aov_data_RF_null)
    model_Tr_null <- fun(formula = formula, data = aov_data_Tr_null)

    ## Normality of the residuals
    norm_RF_best <- shapiro.test(residuals(model_RF_best))
    norm_Tr_best <- shapiro.test(residuals(model_Tr_best))
    norm_RF_null <- shapiro.test(residuals(model_RF_null))
    norm_Tr_null <- shapiro.test(residuals(model_Tr_null))
    normality <- list(norm_RF_best, norm_Tr_best, norm_RF_null, norm_Tr_null)

    ## Variance homoscedasticity
    homo_RF_best <- bartlett.test(NTS ~ scenario, data = aov_data_RF_best)
    homo_Tr_best <- bartlett.test(NTS ~ scenario, data = aov_data_Tr_best)
    homo_RF_null <- bartlett.test(NTS ~ scenario, data = aov_data_RF_null)
    homo_Tr_null <- bartlett.test(NTS ~ scenario, data = aov_data_Tr_null)
    homoscedasticity <- list(homo_RF_best, homo_Tr_best, homo_RF_null, homo_Tr_null)

    ## Summarise the results
    validity_results <- t(rbind(sapply(normality, function(x) x[c(1,2)]), 
                 sapply(homoscedasticity, function(x) x[c(1,2,3)])))
    validity_results <- matrix(as.numeric(validity_results), ncol = 5)
    colnames(validity_results) <- c("W", "p.value", "Bartlett's K^2", "df", "p.value")
    rownames(validity_results) <- c("RF best", "Triples best", "RF null", "Triples null")
    validity_results <- round(validity_results, 3)

    # ## Check assumption's validities
    check.validity <- function(X) {ifelse(X[2] >= 0.05 && X[5] >= 0.05, TRUE, FALSE)}
    validity <- apply(validity_results, 1, check.validity)

    ## Report results
    validity_results <- cbind(as.data.frame(validity_results), validity)

    return(list("validity" = validity_results, "models" = list(model_RF_best, model_Tr_best, model_RF_null, model_Tr_null)))
}