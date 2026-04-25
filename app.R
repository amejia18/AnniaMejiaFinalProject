#This app.R file is used to publish the rShiny dashboard for the
#European Values Study 2017 Data Explorer that created by Annia Mejia on April 25, 2026.

#This dashboard uses two variables of interest found in this EVS 2017 data set. 
#The first variable (v72) is concerned with the level of agreement with the statement: 
#Men should have more right to a job than women when jobs are scarce. 
#The second variable (v80) is concerned with the level of agreement with the statement: 
#Employers should give priority to nationals over immigrants when jobs are scarce. 
#Looking at these two variables of interest provides valuable information about 
#how these attitudes vary age, sex and education to inform policy making across Europe. 

library(shiny)
library(shinydashboard)
library(tidyverse)
library(plotly)
library(DT)
library(broom)


COL_V72 <- "#2166ac"
COL_V80 <- "#d6604d"
COL_BAR <- "#4C6A92"

# Data preparation functions
load_evs_data <- function(path = "evs_clean.rds") {
  if (!file.exists(path)) {
    stop("EVS data file not found. Check the path.")
  }
  readRDS(path)
}

filter_data <- function(data, country_input) {
  if (country_input == "overall") return(data)
  data %>% filter(country == country_input)
}

build_formula <- function(outcome, controls, age_poly) {
  age_term <- if (age_poly == 1) "age" else paste0("poly(age, ", age_poly, ")")
  rhs      <- paste(c(age_term, controls), collapse = " + ")
  paste(outcome, "~", rhs)
}

fit_model <- function(data, outcome, controls, age_poly) {
  f <- as.formula(build_formula(outcome, controls, age_poly))
  lm(f, data = data, na.action = na.omit)
}

outcome_label <- function(v) {
  switch(v,
         v72 = "Gender attitude: men's job priority over women (v72)",
         v80 = "Immigration attitude: nationals' job priority over immigrants (v80)",
         v
  )
}


evs <- load_evs_data()

evs <- evs %>%
  mutate(country = haven::as_factor(country))

country_choices <- c(
  "Overall (all countries)" = "overall",
  setNames(
    sort(unique(as.character(evs$country))),
    sort(unique(as.character(evs$country)))
  )
)

# Plot theme
evs_theme <- theme_minimal(base_size = 12) +
  theme(
    plot.title       = element_text(face = "bold", colour = "#2C3E50"),
    panel.grid.minor = element_blank(),
    axis.title       = element_text(colour = "#555555")
  )

outcome_colour <- function(outcome_var) {
  if (outcome_var == "v72") COL_V72 else COL_V80
}

plot_outcome <- function(data, outcome_var) {
  col <- outcome_colour(outcome_var)
  df <- data %>%
    filter(!is.na(.data[[outcome_var]])) %>%
    count(value = .data[[outcome_var]]) %>%
    mutate(
      pct   = n / sum(n) * 100,
      label = factor(value, levels = 1:5,
                     labels = c("1 - Strongly agree", "2", "3", "4",
                                "5 - Strongly disagree"))
    )
  p <- ggplot(df, aes(x = label, y = pct,
                      text = paste0(label, "<br>", round(pct, 1), "% (n = ", n, ")"))) +
    geom_col(fill = col, alpha = 0.88, width = 0.7) +
    scale_y_continuous(labels = scales::label_percent(scale = 1),
                       expand = expansion(mult = c(0, 0.1))) +
    labs(x = NULL, y = "% of respondents") +
    evs_theme
  ggplotly(p, tooltip = "text") %>% layout(margin = list(b = 40))
}

plot_age <- function(data) {
  df <- data %>% filter(!is.na(age))
  p <- ggplot(df, aes(x = age,
                      text = paste0("Age: ", after_stat(x)))) +
    geom_histogram(binwidth = 5, fill = COL_BAR, colour = "white", alpha = 0.88) +
    labs(x = "Age (years)", y = "Count") +
    evs_theme
  ggplotly(p, tooltip = "text")
}

plot_education <- function(data) {
  df <- data %>%
    filter(!is.na(edu_f)) %>%
    count(edu_f) %>%
    mutate(pct = n / sum(n) * 100)
  p <- ggplot(df, aes(x = edu_f, y = pct,
                      text = paste0(edu_f, "<br>", round(pct, 1), "%"))) +
    geom_col(fill = COL_BAR, alpha = 0.88, width = 0.6) +
    scale_y_continuous(labels = scales::label_percent(scale = 1),
                       expand = expansion(mult = c(0, 0.1))) +
    labs(x = "Education level", y = "% of respondents") +
    evs_theme
  ggplotly(p, tooltip = "text")
}

plot_sex <- function(data) {
  df <- data %>%
    filter(!is.na(sex_f)) %>%
    count(sex_f) %>%
    mutate(pct = n / sum(n) * 100)
  p <- ggplot(df, aes(x = sex_f, y = pct,
                      text = paste0(sex_f, "<br>", round(pct, 1), "%"))) +
    geom_col(fill = COL_BAR, alpha = 0.88, width = 0.5) +
    scale_y_continuous(labels = scales::label_percent(scale = 1),
                       expand = expansion(mult = c(0, 0.1))) +
    labs(x = "Sex", y = "% of respondents") +
    evs_theme
  ggplotly(p, tooltip = "text")
}

plot_residuals <- function(model) {
  df <- broom::augment(model)
  p <- ggplot(df, aes(x = .fitted, y = .resid,
                      text = paste0("Fitted: ", round(.fitted, 2),
                                    "<br>Residual: ", round(.resid, 2)))) +
    geom_point(alpha = 0.20, colour = COL_BAR, size = 1.2) +
    geom_hline(yintercept = 0, colour = "#e74c3c", linewidth = 0.8,
               linetype = "dashed") +
    geom_smooth(method = "loess", se = FALSE, colour = "#2C3E50",
                linewidth = 0.8) +
    labs(x = "Fitted values", y = "Residuals") +
    evs_theme
  ggplotly(p, tooltip = "text") %>% layout(margin = list(b = 40))
}


# UI
# UI
ui <- dashboardPage(
  skin = "black",
  
  # Header
  dashboardHeader(
    title = "EVS Data Explorer",
    titleWidth = 230
  ),
  
  # Sidebar
  dashboardSidebar(
    width = 230,
    sidebarMenu(
      id = "sidebar",
      menuItem("Overview",    tabName = "overview",    icon = icon("home")),
      menuItem("Exploration", tabName = "exploration", icon = icon("search")),
      menuItem("Regression",  tabName = "regression",  icon = icon("calculator"))
    ),
    hr(),
    div(style = "padding: 0 15px;",
        
        # Country
        selectInput("country", label = tags$span(icon("globe"), " Country"),
                    choices  = country_choices,
                    selected = "overall"),
        
        # Outcome
        radioButtons("outcome", label = tags$span(icon("bullseye"), " Outcome variable"),
                     choices = c(
                       "Gender attitude (v72)"      = "v72",
                       "Immigration attitude (v80)" = "v80"
                     ),
                     selected = "v72"),
        
        # Controls
        checkboxGroupInput("controls",
                           label = tags$span(icon("sliders-h"), " Additional controls"),
                           choices  = c("Sex"       = "sex_f",
                                        "Education" = "edu_f"),
                           selected = NULL),
        
        # Age polynomial
        numericInput("age_poly",
                     label = tags$span(icon("superscript"), " Age polynomial degree"),
                     value = 1, min = 1, max = 5, step = 1),
        
        hr(),
        
        # Download report button
        div(style = "padding: 0 5px;",
            downloadButton("download_report", "Generate HTML Report",
                           style = "width:100%; background-color:#4C6A92;
                                  color:white; border:none; border-radius:4px;")
        )
    )
  ),
  
  # Body
  dashboardBody(
    
    tags$head(tags$style(HTML("
      .content-wrapper { background-color: #F5F7FA; }
      .box { border-radius: 8px; border: none;
             box-shadow: 0 1px 3px rgba(0,0,0,0.08); }
      .box.box-primary > .box-header {
        background-color: #4C6A92 !important; color: white;
        border-radius: 8px 8px 0 0;
      }
      .box.box-info > .box-header {
        background-color: #6C7A89 !important; color: white;
      }
      .box.box-warning > .box-header {
        background-color: #A7B6C2 !important; color: #2C3E50;
      }
      .box.box-success > .box-header {
        background-color: #8FA998 !important; color: #2C3E50;
      }
      .dataTables_wrapper { font-size: 13px; }
      h4.intro { color: #4C6A92; border-bottom: 2px solid #D6DEE6;
                 padding-bottom: 6px; }
      .scale-note { background: #EEF3F7; border-left: 4px solid #4C6A92;
                    padding: 10px 14px; border-radius: 4px;
                    margin-bottom: 12px; font-size: 13px; }
    "))),
    
    tabItems(
      
      # TAB 1: OVERVIEW
      tabItem(
        tabName = "overview",
        fluidRow(
          box(
            width = 12, status = "primary", solidHeader = TRUE,
            title = tagList(icon("info-circle"), " Welcome to the EVS Data Explorer"),
            fluidRow(
              column(6,
                     h4("About this app", class = "intro"),
                     p("This interactive dashboard explores data from the",
                       strong("European Values Study (EVS) 2017,"),
                       "a large-scale cross-national survey examining values, beliefs,
                   and attitudes across Europe."),
                     p("This dashboard uses two variables of interest found in this EVS 2017 data set. The first variable (v72) is concerned with the level of agreement with the statement: Men should have more right to a job than women when jobs are scarce. The second variable (v80) is concerned with the level of agreement with the statement: Employers should give priority to nationals over immigrants when jobs are scarce. Looking at these two variables of interest provides valuable information about how these attitudes vary age, sex and education to inform policy making across Europe."),
                     br(),
                     h4("Variables of interest", class = "intro"),
                     tags$ul(
                       tags$li(strong("v72 (Gender attitude):"),
                               " This variable shows the level of agreement with the statement: Men                              should have more right to a job than women when jobs are scarce. 
                            (Variable Values Range: 1 = strongly agree, 5 = strongly                                        disagree)."),
                       tags$li(strong("v80 (Immigration attitude):"),
                               " This variable shows the level of agreement with the statement:  Employers should give priority to nationals over immigrants when jobs are scarce.
                            (Variable Values Range: 1 = strongly agree, 5 = strongly                                        disagree).")
                     ),
                     br(),
                     p(icon("database"), strong(" Data source: "),
                       "European Values Study 2017. GESIS Data Archive, ZA7500 v5.0.0. ",
                       a("europeanvaluesstudy.eu", href = "https://europeanvaluesstudy.eu",
                         target = "_blank"))
              ),
              column(6,
                     h4("How to navigate", class = "intro"),
                     tags$ul(
                       tags$li(icon("home"),       strong(" Overview:"),
                               " Summarizes the purpose of this dashboard in the 'About this app' section, explains the variables of interest in the 'Variables of interest' section, provides instructions on how to naviate this dashboard in the 'How to navigate' section, and explains the controls on the sidebar in the 'Side Bar Controls' section."),
                       tags$li(icon("search"),  strong(" Exploration:"),
                               " Provides distribution plots for the selected outcome and the
                            three control variables: age, education, sex."),
                       tags$li(icon("calculator"), strong(" Regression:"),
                               " OLS coefficient table and residuals vs. fitted plot
                            for your chosen model.")
                     ),
                     br(),
                     h4("Side Bar Controls", class = "intro"),
                     tags$table(class = "table table-bordered table-condensed",
                                tags$thead(tags$tr(tags$th("Input"), tags$th("Output"))),
                                tags$tbody(
                                  tags$tr(tags$td(icon("globe"),       " Country"),
                                          tags$td("Filter all outputs to one country, or keep 'Overall (all countries)'.")),
                                  tags$tr(tags$td(icon("bullseye"),    " Outcome"),
                                          tags$td("Switch between v72 and v80 across all tabs.")),
                                  tags$tr(tags$td(icon("sliders-h"),   " Controls"),
                                          tags$td("Add sex and/or education to the regression.")),
                                  tags$tr(tags$td(icon("superscript"), " Age poly."),
                                          tags$td("Set polynomial degree for age from 1 to 5)."))
                                )
                     )
              )
            )
          )
        )
      ),
      
      # TAB 2: EXPLORATION
      tabItem(
        tabName = "exploration",
        fluidRow(
          box(
            width = 12, status = "primary", solidHeader = TRUE,
            title = tagList(icon("search"), " Exploratory Analysis"),
            div(class = "scale-note",
                icon("info-circle"),
                " All plots reflect the country selected in the left panel or side bar.
                  Hover over the bars in the charts for exact values.")
          )
        ),
        # Outcome variable
        fluidRow(
          box(
            width = 12, status = "info", solidHeader = TRUE,
            title = uiOutput("explore_outcome_title"),
            plotlyOutput("plot_outcome", height = "320px")
          )
        ),
        # Three controls side by side
        fluidRow(
          box(width = 4, status = "warning", solidHeader = TRUE,
              title = tagList(icon("birthday-cake"),   " Age distribution"),
              plotlyOutput("plot_age", height = "260px")),
          box(width = 4, status = "warning", solidHeader = TRUE,
              title = tagList(icon("graduation-cap"), " Education level"),
              plotlyOutput("plot_edu", height = "260px")),
          box(width = 4, status = "warning", solidHeader = TRUE,
              title = tagList(icon("venus-mars"),     " Sex"),
              plotlyOutput("plot_sex", height = "260px"))
        )
      ),
      
      # TAB 3: REGRESSION
      tabItem(
        tabName = "regression",
        fluidRow(
          box(
            width = 12, status = "primary", solidHeader = TRUE,
            title = tagList(icon("calculator"), " Regression Analysis"),
            div(class = "scale-note",
                icon("info-circle"),
                " OLS regression."),
            strong("Current formula:"),
            verbatimTextOutput("formula_display")
          )
        ),
        # Coefficient table
        fluidRow(
          box(
            width = 12, status = "info", solidHeader = TRUE,
            title = tagList(icon("table"), " Regression coefficients"),
            DTOutput("reg_table")
          )
        ),
        # Residuals plot
        fluidRow(
          box(
            width = 12, status = "warning", solidHeader = TRUE,
            title = tagList(icon("chart-line"), " Residuals vs. Fitted values"),
            plotlyOutput("plot_resid", height = "400px")
          )
        )
      )
    )
  )
)

#SERVER
server <- function(input, output, session) {
  
  #Reactive: filtered data 
  df <- reactive({
    filter_data(evs, input$country)
  })
  
  #Reactive: fitted model 
  model <- reactive({
    req(nrow(df()) > 10)
    fit_model(df(), input$outcome, input$controls, input$age_poly)
  })
  
  #Dynamic titles 
  country_label <- reactive({
    if (input$country == "overall") "all countries" else input$country
  })
  
  output$explore_outcome_title <- renderUI({
    tagList(icon("bullseye"), " ", outcome_label(input$outcome),
            " — ", country_label())
  })
  
  #Exploration plots 
  output$plot_outcome <- renderPlotly({
    plot_outcome(df(), input$outcome)
  })
  
  output$plot_age <- renderPlotly({
    plot_age(df())
  })
  
  output$plot_edu <- renderPlotly({
    plot_education(df())
  })
  
  output$plot_sex <- renderPlotly({
    plot_sex(df())
  })
  
  #Regression outputs 
  output$formula_display <- renderText({
    build_formula(input$outcome, input$controls, input$age_poly)
  })
  
  output$reg_table <- renderDT({
    tidy(model(), conf.int = TRUE) %>%
      mutate(
        across(where(is.numeric), ~ round(.x, 4)),
        sig = case_when(
          p.value < 0.001 ~ "***",
          p.value < 0.01  ~ "**",
          p.value < 0.05  ~ "*",
          p.value < 0.1   ~ ".",
          TRUE            ~ ""
        )
      ) %>%
      rename(
        Term         = term,
        Estimate     = estimate,
        `Std. Error` = std.error,
        `t value`    = statistic,
        `p value`    = p.value,
        `CI 2.5%`    = conf.low,
        `CI 97.5%`   = conf.high,
        `Sig.`       = sig
      ) %>%
      datatable(
        options  = list(pageLength = 15, dom = "tp", ordering = TRUE),
        rownames = FALSE,
        class    = "stripe hover compact"
      ) %>%
      formatRound(c("Estimate", "Std. Error", "t value", "CI 2.5%", "CI 97.5%"),
                  digits = 4) %>%
      formatStyle("p value",
                  color = styleInterval(c(0.05, 0.1),
                                        c("#c0392b", "#e67e22", "#2c3e50")))
  })
  
  output$plot_resid <- renderPlotly({
    plot_residuals(model())
  })
  
  #Report download 
  output$download_report <- downloadHandler(
    filename = function() {
      paste0("evs_report_", input$country, "_", Sys.Date(), ".html")
    },
    content = function(file) {
      tmp_dir    <- tempdir()
      tmp_report <- file.path(tmp_dir, "dynamic_report.Rmd")
      file.copy("dynamic_report.Rmd", tmp_report, overwrite = TRUE)
      
      rmarkdown::render(
        tmp_report,
        output_file = file,
        params = list(
          country  = input$country,
          outcome  = input$outcome,
          controls = input$controls,
          age_poly = input$age_poly,
          data     = df()
        ),
        envir = new.env(parent = globalenv()),
        quiet = TRUE
      )
    }
  )
}


shinyApp(ui = ui, server = server)

