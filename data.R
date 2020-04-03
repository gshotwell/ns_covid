process_covid <- function(covid) {
  covid$Hospitalized <- NULL
  covid <- covid[, 1:6]
  names(covid) <- c("date", "new_cases", "negatives", "recovered", "in_hospital", "deaths")
  covid$positives <- cumsum(covid$new_cases)
  write.csv(covid, "ns_daily_covid.csv")
  saveRDS(covid, "covid.Rds")
}
