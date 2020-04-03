library(drake)
source("data.R")
download.file("https://novascotia.ca/coronavirus/data/COVID-19-data.csv", "input.csv")
plan <- drake_plan(
  raw_data = readr::read_csv("input.csv",
                               skip = 1),
  processed = process_covid(raw_data),
  report = rmarkdown::render(
    params = list(data = processed),
    knitr_in("index.Rmd"),
    output_file = file_out("index.html"),
    quiet = TRUE
  )
)
make(plan)
