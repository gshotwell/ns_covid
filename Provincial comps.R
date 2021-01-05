library(tidyverse)
library(httr)

get_province <- function(province) {
  resp <- GET(paste0("https://api.covid19tracker.ca/reports/province/", province))
  resp <- tibble(raw = content(resp)$data)

  out <- resp %>%
    unnest_auto(raw) %>%
    mutate(province = province)
  return(out)
}


provinces <- GET("https://api.covid19tracker.ca/provinces")
provinces <- content(provinces)
provs <- map_chr(provinces, "code")

data <- map_dfr(provs, get_province)
options(scipen=999)
data %>%
  filter(date > "2020-12-15") %>%
  filter(province %in% c("NS", "ON", "QC", "BC", "AB", "NB", "MB", "SK")) %>%
  mutate(active = total_cases - total_fatalities - total_recoveries) %>%
  mutate(vaccinated_to_active = total_vaccinations / active,
         date = lubridate::ymd(date)) %>%
  ggplot(aes(x = date, y = vaccinated_to_active, group = province, colour = province)) +
  geom_path() +
  labs(
    title = "Vaccinated to active cases",
    y = "Doses administered per active case",
    x = "Date"
  ) +
  scale_y_log10()
