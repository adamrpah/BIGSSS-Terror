
library("tidyverse")

untar("C:/Users/smncr/Documents/BIGSSS/bigss_terror_20180730A.tar.gz")

setwd("C:/Users/smncr/Documents/BIGSSS/bigss_terror_20180730A")

# generate empty list to store p values from ks tests
p <- list()

for (country in c("Afghanistan", "Colombia", "Iraq")) {

    # load group ids, attack dates and number of attacks from real data of selected country
    real <- read_csv(paste(country, ".csv")) %>%
              select(gname, idate, nattacks)

    for (group in unique(real$gname)) {

      # subset real data for selected group
      filter(real, gname == group)

      #expand real event-dates by number of attacks
      real_exp <- rbind(rep(real$idate, times == real$nattacks))

      # calculate intertemporal event series in real data
      diff_real <- diff(real_exp)

    for (alpha in c(seq(0, 5, 0.05))) {

       for(beta in c(seq(0, 50, 0.1))) {

         for(omega in c(seq(0, 1, 0.5))) {

           # load symulated results for selected parameters' values
           abm <- Sys.glob(paste(country, alpha, beta, omega, "*.csv", sep = "_"))

           # assign variable names
           rename(abm, gname = V1 , tick = V2 , nattacks = V3)

           # subset model data by selected group
           filter(abm, gname == group)

           # expand symulated event-dates by number of attacks
           abm_exp <- rbind(rep(abm$tick, times == abm$nattack))

           # calculate intertemporal event series in symulated data
           diff_abm <- diff(abm_exp)

           # test differences in intertemporal event series
           ks <- ks.test(diff_abm, diff_real))

           # store p-values from ks test
           p <- c(p, ks$p.value)

        }
      }
    }
  }
}
