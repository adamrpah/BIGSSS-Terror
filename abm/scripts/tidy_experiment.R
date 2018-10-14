library(tools)
library(glue)
library(tidyverse)

file <- file.path(
  path.expand("~/workspace/BIGSSS-Terror/abm/outputs/20181002"),
  "results_20181002.csv"
)

df <- read_csv(file, skip = 6) %>%
  mutate(attacks = map(`attacks-csv`, read_csv)) %>%
  unnest %>%
  select(
    run = `[run number]`,
    final_step = `[step]`,
    country = `input-folder`,
    alpha, beta, omega, group, step, num_attacks
  ) %>%
  write_csv(file_path_sans_ext(file) %>% glue("_tidy.csv"))
