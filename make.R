library(git2r)

download.file("https://novascotia.ca/coronavirus/data/ns-covid19-data.csv", "input.csv")
update_git <- function(output) {
  repo <- repository()
  git2r::commit(repo, all = TRUE, message = "auto-update")
}

process_covid <- function(raw_data) {
  raw_data$Hospitalized <- NULL
  covid <- raw_data[, 1:7]
  names(covid) <- tolower(names(covid))
  names(covid)[1:2] <- c("date", "new_cases")
  covid$positives <- cumsum(covid$new_cases)
  write.csv(covid, "ns_daily_covid.csv")
  saveRDS(covid, "covid.Rds")
  return(covid)
}


raw_data = readr::read_csv("input.csv",  skip = 1)

#if (max(raw_data$Date) >= Sys.Date()) {
  processed = process_covid(raw_data)
  report = rmarkdown::render(
    "index.Rmd",
    params = list(data = processed),
    output_file = "index.html",
    quiet = TRUE
  )
  git = update_git(report)
#}

