library("tidyverse")

untar("C:/Users/smncr/Documents/BIGSSS/bigss_terror_20180730A.tar.gz")

setwd("C:/Users/smncr/Documents/BIGSSS/bigss_terror_20180730A")

diff_real <- data.frame(country = character() ,gname=character(), diff=double())
results <- data.frame(country = character(), alpha = double(), beta = double(), 
                      omega = double(), gname=character(), pass = double(), pvalue=double())

for (country in c("Afghanistan", "Colombia", "Iraq")) {
  
  real <- read_csv(paste(country, ".csv")) %>%
    select(gname, idate, nattacks)
  
  for (group in unique(real$gname)) {
    
    filter(real, gname == group)
    real_data <- rbind(rep(real$idate, times == real$nattacks))
    d <- diff(real_data)
    addrow(diff_real, country = country, gname = group, d = diff)
    
  }
  
  for (alpha in c(seq(0.5, 1.3, 0.1))) {
    
    for(beta in c(seq(5, 10, 0.5))) {
      
      for(omega in c(seq(0, 1, 0.1))) {
        
        group_pvalues <- data.frame(gname=character(), pvalue=double())
        par_files <- Sys.glob(paste(country, alpha, beta, omega, "*.csv", sep = "_"))
        
        for (par_file in unique(par_files)) {
          
          par_tab <- read_csv(par_file)   %>% 
            rename(gname = V1 , tick = V2 , nattacks = V3)
          
          #group_pvalues <- data.frame(gname=character(), pvalue=double())
          #p <- list()
          
          for (group in unique(par_tab$gname)) {
            
            filter(par_tab, gname == group)
            sim_data <- rbind(rep(par_tab$tick, times == par_tab$nattack))
            diff_sim <- diff(abm_exp)
            ks <- ks.test(diff_abm, diff_real[ which(diff_real$country == country 
                                                     & diff_real$gname == group), ])
            addrow(group_pvalues, gname = group, pvalue = ks$p.value)
            #p <- c(p, ks$p.value)
            
          }
        }
        
        pass_fail  <- ls()
        
        for (group in unique(group_pvalues$gname)) {
          
          filter(group_pvalues, gname == group )
          fail_count <- sum(group_pvalues$pvalue < 0.05)
          pass <- if_else(fail_count/length(group_pvalues) > 0.05, 1, 0)  # check this function
          pass_fail <-  c(pass_fail, pass)
          
        }  
        
        x <- sum(pass_fail = 1)
        n <- length
        p_binom <- binom.test(x, n, p = 0.5, alternative = "less", conf.level = 0.95)
        pass <- p_binom < 0.05
        
        for (group in unique(par_tab$gname)) {
          
          add_row(results, country = country, alpha = alpha, beta = beta, omega = omega, 
                  gname = group, pass = pass, p_value = group_pvalues)
          
        }
      }
    }
    
  }
}


