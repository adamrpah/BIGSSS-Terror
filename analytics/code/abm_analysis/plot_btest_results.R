
                                    ##### AMB Analytics figures #####
                                    ##### BIGSSS-Terror #####
                                    ##### Rithvik Yarlagadda #####

rm(list = ls()) #clear the environment
setwd("~/Documents/project_bigsss") #set directory

#load the required libraries
library(ggplot2)
library(dplyr)
library(miscTools)
library("ggforce")
library(tidyverse)
require(gridExtra)

# load the data
df<-read.csv("updated_abm_analysis_results.csv") #this is the revised results file that Adam posted after fixing the indendation error


# check for missing values if any
table(df$country)
summary(df$pfrac)
# confirms no missing values 

#devtools::install_version('rlang', '0.2.2', repo = 'http://cran.rstudio.com', dep=FALSE) # to avoid the rlang error 

## generate dummy for pfrac > 0.05 
df <- mutate(df, fail = as.factor(if_else(pfrac > 0.05, 1, 0))) # here fail = '1' indicates the probability of the fraction of abm results (pfrac) that are significantly different from real data

# Summary of the parameter set
table(df$fail)
unique(df$alpha)
unique(df$beta)
unique(df$omega)

# produce final graph divided in two pages
i<-NA
for(i in 1:2){
  ggplot(df, aes(as.factor(alpha), as.factor(beta))) +
    geom_tile(aes(fill = as.factor(fail)), colour = "white", size=0.25) +
    facet_grid_paginate(omega~country, 
                        nrow = 6, ncol = 3,
                        labeller = label_bquote(rows = omega == .(omega)),
                        page = i) +
    theme_minimal(base_size = 10) +
    #scale_fill_viridis_d(name = "ABM = Real Data (p \u2264 0.05)", 
                         #labels = c("Pass", "Fail"), option = "viridis", aesthetics = "fill") +
    scale_fill_brewer(name = "ABM = Real Data (p \u2264 0.05)", 
                      labels = c("Pass", "Fail"), type = "qual", palette = "Set1", direction = 1)+
    scale_y_discrete(breaks = c("4", "5", "6", "7", "8"), 
                     name = expression(beta)) +
    scale_x_discrete(breaks = c("0.1", "0.2", "0.5", "0.9"),
                     name = expression(alpha)) +
    coord_fixed()  + 
    theme(legend.position = "right",
          axis.ticks=element_line(size=0.4),
          strip.text.x = element_text(face = "bold"),
          axis.text.x=element_text(size=8),
          axis.text.y=element_text(size=8))
  
  ggsave(paste0("btest_results", i, ".png"),
         path = "~/Documents/project_bigsss")
  
}


## to check for missing values of alpha in Iraq
df_iraq<-df[df$country=="Iraq", ]
unique(df_iraq$alpha) #missing values 0.6, 0.9 for Iraq case
unique(df_iraq$beta)  
unique(df_iraq$omega)

df_afg<-df[df$country=="Afghanistan", ]
df_col<-df[df$country=="Colombia", ]

# percentage of results in afghanistan that failed
(sum(df_afg$fail==0)/nrow(df_afg))*100
(sum(df_col$fail==0)/nrow(df_col))*100

(sum(df_iraq$fail==0)/nrow(df_iraq))*100




