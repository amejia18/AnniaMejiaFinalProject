## European Values Study 2017 Data Explorer
By using 'AnniaMejiaFinalProject_1.Rmd', this interactive Shiny dashboard could be replicated to browse data from the 2017 European Values Study. 

This dashboard showcases two variables of interest found in the EVS 2017 data set. 
The first variable (v72) is concerned with the level of agreement with the statement: Men should have more right to a job than women when jobs are scarce.
The second variable (v80) is concerned with the level of agreement with the statement: Employers should give priority to nationals over immigrants when jobs are scarce.

Looking at these two variables of interest provides valuable information about how these attitudes vary age, sex and education to inform policy making across Europe.

This "European Values Study 2017 Data Explorer" dashboard has three sidebar tabs called:
1. Overview: Summarizes the purpose of this dashboard in the 'About this app' section, explains the variables of interest in the 'Variables of interest' section, provides instructions on how to naviate this dashboard in the 'How to navigate' section, and explains the controls on the sidebar in the 'Side Bar Controls' section.
2. Exploration: Shows distribution plots for the selected outcome and the three control variables: age, education, sex.
3. Regression: Shows OLS coefficient table and residuals vs. fitted plot for chosen model

Here is a link to the dashboard: https://yvwcnk-annia-mejia.shinyapps.io/evs-data-explorer/

This dashboard also allows for the generation of reports. An example of the report for Austria is saved in this repository as: evs_report_Austria_2026-04-25.html.

## Replicating This Dashboard
1. The full code that was used to create this shinyapp can be reviewed using 'AnniaMejiaFinalProject_1.Rmd'.
2. To replicate this application, make sure to run the chunk below which requires the following files: "app.R", "evs_clean.rds", and "dynamic_report.Rmd" after running the chunks in the 'AnniaMejiaFinalProject_1.Rmd' file. Some personalized modifications may be required. You must also create an account on www.shinyapps.io.

 ```{r connect-to-shiny}
rsconnect::deployApp(
  appDir = ".", 
  appFiles = c(
    "app.R", 
    "evs_clean.rds", 
    "dynamic_report.Rmd" 
  ),
  appName = "evs-data-explorer",
  forceUpdate = TRUE
)
```  

## Session Info
```{r}
sessionInfo()
```
R version 4.3.0 (2023-04-21 ucrt)
Platform: x86_64-w64-mingw32/x64 (64-bit)
Running under: Windows 10 x64 (build 19045)

Matrix products: default


locale:
[1] LC_COLLATE=English_United States.utf8  LC_CTYPE=English_United States.utf8   
[3] LC_MONETARY=English_United States.utf8 LC_NUMERIC=C                          
[5] LC_TIME=English_United States.utf8    

time zone: America/Guatemala
tzcode source: internal

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
 [1] rsconnect_1.8.0      DT_0.34.0            shinydashboard_0.7.3 shiny_1.11.1         kableExtra_1.4.0    
 [6] broom_1.0.6          plotly_4.12.0        lubridate_1.9.3      forcats_1.0.0        stringr_1.5.1       
[11] dplyr_1.2.0          purrr_1.0.2          readr_2.1.5          tidyr_1.3.1          tibble_3.2.1        
[16] ggplot2_4.0.2        tidyverse_2.0.0     

loaded via a namespace (and not attached):
 [1] gtable_0.3.6        httr2_1.2.0         xfun_0.52           bslib_0.9.0         htmlwidgets_1.6.4  
 [6] lattice_0.21-8      tzdb_0.4.0          crosstalk_1.2.1     vctrs_0.7.2         tools_4.3.0        
[11] generics_0.1.4      curl_7.0.0          pkgconfig_2.0.3     Matrix_1.5-4        data.table_1.18.2.1
[16] RColorBrewer_1.1-3  S7_0.2.1            lifecycle_1.0.5     compiler_4.3.0      farver_2.1.2       
[21] fontawesome_0.5.3   httpuv_1.6.15       htmltools_0.5.8.1   sass_0.4.9          yaml_2.3.10        
[26] lazyeval_0.2.2      later_1.3.2         pillar_1.11.0       jquerylib_0.1.4     openssl_2.3.5      
[31] cachem_1.1.0        nlme_3.1-162        mime_0.13           tidyselect_1.2.1    digest_0.6.35      
[36] stringi_1.8.4       splines_4.3.0       labeling_0.4.3      fastmap_1.2.0       grid_4.3.0         
[41] cli_3.6.2           magrittr_2.0.3      withr_3.0.2         rappdirs_0.3.4      scales_1.4.0       
[46] promises_1.3.2      backports_1.5.0     timechange_0.3.0    rmarkdown_2.29      httr_1.4.7         
[51] askpass_1.2.1       hms_1.1.3           memoise_2.0.1       evaluate_1.0.5      knitr_1.50         
[56] haven_2.5.4         viridisLite_0.4.2   mgcv_1.8-42         rlang_1.1.7         Rcpp_1.1.1         
[61] xtable_1.8-4        glue_1.7.0          renv_1.2.1          xml2_1.3.8          svglite_2.1.3      
[66] rstudioapi_0.18.0   jsonlite_2.0.0      R6_2.6.1            systemfonts_1.1.0  
