library(git2r)
source("data.R")

download.file("https://novascotia.ca/coronavirus/data/COVID-19-data.csv", "input.csv")
update_git <- function(output) {
  repo <- repository()
  git2r::commit(repo, all = TRUE, message = "auto-update")
}

process_covid <- function(covid) {
  covid$Hospitalized <- NULL
  covid <- covid[, 1:11]
  names(covid) <- tolower(names(covid))
  names(covid)[1:6] <- c("date", "new_cases", "negatives", "recovered",
                    "in_hospital", "deaths")
  covid$positives <- cumsum(covid$new_cases)
  write.csv(covid, "ns_daily_covid.csv")
  saveRDS(covid, "covid.Rds")
  return(covid)
}


raw_data = readr::read_csv("input.csv",  skip = 1)

if (max(raw_data$Date) >= Sys.Date()) {
  processed = process_covid(raw_data)
  report = rmarkdown::render(
    params = list(data = processed),
    knitr_in("index.Rmd"),
    output_file = file_out("index.html"),
    quiet = TRUE
  )
  git = update_git(report)
}

