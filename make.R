library(drake)
library(git2r)
source("data.R")
download.file("https://novascotia.ca/coronavirus/data/COVID-19-data.csv", "input.csv")
repo <- repository()
git2r::commit(repo, all = TRUE, message = "auto-update")

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
