library(drake)
library(git2r)
library(RCurl)
source("data.R")

download.file("https://novascotia.ca/coronavirus/data/COVID-19-data.csv", "input.csv")

update_git <- function(output) {
  repo <- repository()
  git2r::commit(repo, all = TRUE, message = "auto-update")
}

plan <- drake_plan(
  raw_data = read_csv("input.csv",  skip = 1),
  processed = process_covid(raw_data),
  report = rmarkdown::render(
    params = list(data = processed),
    knitr_in("index.Rmd"),
    output_file = file_out("index.html"),
    quiet = TRUE
  ),
  git = update_git(report)
)
make(plan)
