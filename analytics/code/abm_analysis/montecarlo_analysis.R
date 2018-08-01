library("tidyverse")

setwd("C:/Users/smncr/Documents/BIGSSS/bigss_terror_20180730A")

diff_real <- data.frame(country = character() ,gname=character(), diff=I(list()))
results <- data.frame(country = character(), alpha = double(), beta = double(), 
                      omega = double(), gname=character(), pass = double(), pvalue=double())

#for (country in c("Afghanistan", "Colombia", "Iraq")) {
  country <- "Colombia"
  
  real <- read_csv(paste("C:/Users/smncr/Documents/GitHub/BIGSSS-Terror/analytics/data/", 
                         country, "_abm_events.csv", sep = "")) %>%
    select(gname, idate)
 
  for (group in unique(real$gname)) {
    group_df <- filter(real, gname == group) 
    d <- diff(group_df$idate) 
    if (length(d) != 0) {
      print( rbind(diff_real, data.frame(country = country, gname = group ) ) )
      temp<-data.frame(country =country, gname=group)
      temp$diff <- d
      print(temp)
                       
    }
  }
  diff_real
   
  for (group in unique(real$gname)) {
    
    group_df <- filter(real, gname == group)
    d <- diff(group_df$idate)
    add_row(diff_real, country = country, gname = group, diff = I(d))
    
  }
  
  for (alpha in c(seq(0.5, 1.3, 0.1))) {
    for(beta in c(seq(5, 10, 0.5))) {
      for(omega in c(seq(0, 1, 0.1))) {
        
        group_pvalues <- data.frame(gname=character(), pvalue=double())
        file_names <- Sys.glob(paste(country, alpha, beta, omega, "*.csv", sep = "_"))
        
        for (file_name in file_names) {
          
          df <- read_csv(file_name)   %>% 
            rename(gname = V1 , tick = V2 , nattacks = V3)
          
          #group_pvalues <- data.frame(gname=character(), pvalue=double())
          #p <- list()
          
          for (group in unique(df$gname)) {
            
            filter(df, gname == group)
            sim_data <- rbind(rep(df$tick, times == df$nattack))
            diff_sim <- diff(abm_exp)
            ks <- ks.test(diff_abm, diff_real[ which(diff_real$country == country 
                                                     & diff_real$gname == group), ])
            addrow(group_pvalues, gname = group, pvalue = ks$p.value)
            #p <- c(p, ks$p.value)
            
          }
        }
        
        pass_fail  <- list()
        
        for (group in unique(group_pvalues$gname)) {
          
          filter(group_pvalues, gname == group )
          fail_count <- sum(group_pvalues$pvalue < 0.05)
          pass <- if_else(fail_count/length(group_pvalues) > 0.05, 1, 0)  # check this function
          pass_fail <-  c(pass_fail, pass)
          
        }  # close group
        
        x <- sum(pass_fail = 1)
        n <- length
        p_binom <- binom.test(x, n, p = 0.5, alternative = "less", conf.level = 0.95)
        pass <- p_binom < 0.05
        
        for (group in unique(df$gname)) {
          
          add_row(results, country = country, alpha = alpha, beta = beta, omega = omega, 
                  gname = group, pass = pass, p_value = group_pvalues)
          
        }
      } # close omega
    } # close beta
  } # close alpha
#} # close country


