############ Start:Cluster Analysis ########

# Author: Ruchina Shakya
# Date: 07-29-2025
# Update: 09-14-2026
# Description: UI: Cluster Analysis (RAPTER)


##==== ui.R ====##
#######==== Cluster Analysis, Network Timeline and LLM UI ====##############
shinyUI(fluidPage(
  useShinyjs(), 
  #####==== Busy Spinner ====#####
  add_busy_spinner(spin = "cube-grid", color = "#2167d9", position = "full-page"),
  #####==== Busy Spinner ====#####
  #Linking all the required files(css,js..)
  tags$head(
    #####==== Favicon ====#####
    tags$link(rel = "icon", type = "image/png", href = "icons/favicon/cit_nw_favicon.png"),
    tags$link(rel = "stylesheet", type = "text/css", href = "cit_nw_styles.css"),
    tags$script(src = "https://unpkg.com/split.js/dist/split.min.js"),
    tags$script(src = "cit_nw_scripts.js")
  ),
  
  

  div(class="cit-nw-header", actionLink("go_home", "Citation Network based Literature Mining", class="title-link")),
  
  ##### Main layout container #####
  div(class = "cit-nw-page-wrapper",

  # IMPORTANT: create a REAL input for conditionalPanel to read
    div(style="display:none;", textInput("view", NULL, value = "home")),
      # Main content area
      div(class = "cit-nw-main-content",
          div(id = "container",
              div(
                id = "button-row",
                style = "display:flex; gap:10px; align-items:center;",
                # Action buttons for page navigation
                actionButton("cit_nw_show_pmid_cluster", "PMID Cluster Search", class = "cit-nw-css-act-btn-color"),
                actionButton("cit_nw_show_nw_timeline", "Browse Network", class = "cit-nw-css-act-btn-color"),
                tags$a(href = "docu/docu-cit-nw.html",target = "_blank",actionButton("cit_nw_document", "Documentation", class = "cit-nw-css-act-btn-color")),
                
                ),

                # --- HOME ONLY: Pathogen Explorer shows under buttons ---
              conditionalPanel(
                condition = "input.view === 'home'",
                div(
                  id = "pathogen-explorer",
                  br(),br(),br(),
                  h2("Vaccine Development Literature Explorer", style = "margin-top: 18px;"),
                  p("Click an icon to view details.", style="margin-top:-8px;"),

                  br(),br(),br(),
                  uiOutput("org_layout")  
                ),

              ),


              
    conditionalPanel(
      condition = "input.view === 'search'",
      tags$div(class="content-area",
              uiOutput("cit_nw_pmid_tab")
      )
    ),
    
    # BROWSE
    conditionalPanel(
      condition = "input.view === 'browse'",
      tags$div(class="content-area",
               uiOutput("cit_nw_tab"),
               uiOutput("cit_nw_timeline_tab"),
               uiOutput("cit_nw_clusviz_tab")
      )
    )

              )
          ),
  
 
  br(),
  br(),
 
  # FOOTER BAR
div(
  class = "cit-nw-footer-bar",
  span("Contact: "),
  tags$a (href="mailto:ruchina@lanl.gov", "RAPTER"),
  span(" | "),
  tags$a(href = "docu/docu-cit-nw.html", target = "_blank",  "Documentation"),
  span(paste0(" | © ", format(Sys.Date(), "%Y")))
),
  # div(class = "cit-nw-footer-bar",
  #     "Contact: ruchina@lanl.gov  | © 2026 RAPTER"
  # )
  )

)
)

#######End: CLuster Analysis and LLM UI##############



