library(EpiNow2)
library(dplyr)

reporting_delay <- estimate_delay(rlnorm(1000,  log(3), 1),
                                  max_value = 15, bootstraps = 1)

generation_time <- get_generation_time(disease = "SARS-CoV-2", source = "ganyani")
incubation_period <- get_incubation_period(disease = "SARS-CoV-2", source = "lauer")
reported_cases <- example_confirmed[1:90]

ns_cases <- covid %>%
  dplyr::filter(date > lubridate::ymd("2021-04-01")) %>%
  ungroup() %>%
  select(date, confirm = change_cases)


estimates <- epinow(reported_cases = ns_cases,
                    generation_time = generation_time,
                    delays = delay_opts(incubation_period, reporting_delay),
                    rt = rt_opts(prior = list(mean = 2, sd = 0.2)),
                    stan = stan_opts(cores = 8), )

estimates$plots$infections +
  scale_x_date(limits = c(lubridate::ymd("2021-04-01"), Sys.Date())) +
  scale_y_continuous(limits = c(0, 300))
