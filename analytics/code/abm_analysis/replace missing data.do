import delimited "C:\Users\smncr\Documents\BIGSSS\abm_runs_uniques.csv", clear

save "C:\Users\smncr\Documents\BIGSSS\abm_runs_uniques.dta", replace

import delimited "C:\Users\smncr\Documents\BIGSSS\missing_data.csv", clear

save "C:\Users\smncr\Documents\BIGSSS\missing_data.dta", replace

use "C:\Users\smncr\Documents\BIGSSS\abm_runs_uniques.dta", clear

merge  1:1 country alpha beta omega using "C:\Users\smncr\Documents\BIGSSS\missing_data.dta"

gen pass = 1 if _merge == 3
replace pass = 0 if _merge == 2

drop _merge

export delimited using "C:\Users\smncr\Documents\BIGSSS\abm_runs_corrected.csv", replace

*import delimited "C:\Users\smncr\Documents\BIGSSS\abm_runs_v2_pvalue_analysis_v2_direct.csv", clear
