library(tools)
library(tidyverse)

input_file <- file.path(
  path.expand("~/workspace/BIGSSS-Terror/abm/outputs/20181009"),
  "results_20181009.csv"
)

output_file <- str_glue(file_path_sans_ext(input_file), "_tidy.csv")

split_col <- "omega"

df_list <-
  read_csv(input_file, skip = 6) %>%
  split(.[[split_col]])

walk(df_list, function(df) {
  gc(verbose = TRUE) # this helps a lot...
  print(df) # just to see where we're at
  df %>%
    mutate(attacks = map(`attacks-csv`, read_csv)) %>%
    unnest() %>%
    select(
      run = `[run number]`,
      final_step = `[step]`,
      country = `input-folder`,
      alpha, beta, omega, group, step, num_attacks
    ) %>%
    write_csv(
      output_file,
      # write in 'append' mode except for the first chunk:
      append = (.[[split_col]][1] != df_list[[1]][[split_col]][1])
    )
})
