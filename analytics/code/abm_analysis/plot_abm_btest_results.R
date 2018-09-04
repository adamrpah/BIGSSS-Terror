# This file: plot results of binomial tests for difference between abm results and real data

# load libraries

library("tidyverse")
library("viridis")
library("ggforce")

# notes: this first chunk of code can be used to fix problems in the data (missing values, multiple observations..)
# part of the code is missing (joins were done in stata)

# generate complete matrix of parameters combinations for filling missing values
# setwd("C:/Users/smncr/Documents/BIGSSS")
# missing_data <- data.frame(expand.grid(country = c("Afghanistan", "Iraq", "Colombia"), 
#                                       alpha= c(seq(0.1, 0.9, 0.1)), 
#                                       beta = c(seq(4, 8, 0.5)), 
#                                       omega = c(seq(0, 1, 0.1)))) 
# missing_data <- mutate(missing_data, pvalue = 0.000000)
# write_csv(missing_data, "missing_data.csv")

# restrict abm data to unique combinations of parameters
# setwd("C:/Users/smncr/Documents/BIGSSS")
# d <- read_csv("abm_runs_v2_pvalue_analysis_v2_direct.csv")
# unique <- unique(d[ ,c("country", "alpha", "beta", "omega")])
# write_csv(unique, "abm_runs_uniques.csv")

setwd("C:/Users/smncr/Documents/GitHub/BIGSSS-Terror/analytics")

# import abm data
df <- read_csv("abm_runs_v2_pvalue_analysis_v2_direct.csv")

# notes: things to do before running the ggplot code

# 1. check for multiple observations: unique(d[ ,c("country", "alpha", "beta", "omega")])
# 2. check missing values
# 3. check intervals of parameters in the data vs. plot

# generate dummy for p > 0.05 
df <- mutate(df, pass = as.factor(if_else(pvalue > 0.05, 1, 0)))

# produce final graph divided in two pages
for(i in 1:2){
  ggplot(df, aes(as.factor(alpha), as.factor(beta))) +
    geom_tile(aes(fill = as.factor(pass)), colour = "white", size=0.25) +
    facet_grid_paginate(omega~country, 
                        nrow = 6, ncol = 3,
                        labeller = label_bquote(rows = omega == .(omega)),
                        page = i) +
    theme_minimal(base_size = 10) +
    scale_fill_viridis_d(name = "ABM = Real Data (p > 0.05)", 
                         labels = c("Fail", "Pass"), option = "viridis") +
    scale_y_discrete(breaks = c("5", "6", "7", "8", "9", "10"), 
                     name = expression(beta)) +
    scale_x_discrete(breaks = c("0.5", "0.7", "0.9", "1.1", "1.3"), 
                     name = expression(alpha)) +
    coord_fixed()  + 
    theme(legend.position = "right",
          axis.ticks=element_line(size=0.4),
          strip.text.x = element_text(face = "bold"),
          axis.text.x=element_text(size=8),
          axis.text.y=element_text(size=8))
  
  ggsave(paste0("btest_results_", i, ".pdf"),
         path = "/analytics/figures/")
  
}