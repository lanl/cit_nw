
#######PMID Cluster Search server:~/Rapter_cit_nw_tools/cit_nw_cluster_analysis/server.R###########
# Author: Ruchina Shakya
# Date: 2025-08-22
# Edited: 2025-19-12
# Description:Sub graph cluster, Automate citation network clustering and LLM labeling

shinyServer(function(input, output, session) {
  
  ######## === Initialization === ########
  
  ######## === Reactive values === ########
  cit_nw_show_sub_rv <- reactiveVal(NULL)
  cit_nw_sub_selected_rv <- reactiveVal(NULL)
  cit_nw_llmcluster_sub_rv<- reactiveVal(NULL)   
  cit_nw_sub_clus_rv<- reactiveVal(NULL)  
  
  # Global observers for sub-buttons (so they don't get re-registered)
  # lapply(c("cl_sub1","cl_sub2","cl_sub3","cl_sub4","cl_sub5","cl_sub6"), function(id) {
  #   observeEvent(input[[id]], {
  #     cit_nw_llmcluster_sub_rv(if (identical(cit_nw_llmcluster_sub_rv(), id)) NULL else id)
  #   },
  #   ignoreInit = TRUE)})
  # observeEvent(input$cl_show_all, {cit_nw_llmcluster_sub_rv(NULL) }, ignoreInit = TRUE)
  
  lapply(c("cit_nw_path_clus_btn","cit_nw_cop_clus_btn","cit_nw_hms_clus_btn","cit_nw_vp_clus_btn","cit_nw_mcm_clus_btn","cit_nw_vac_clus_btn"), function(id) {
    observeEvent(input[[id]], {
      cit_nw_sub_clus_rv(if (identical(cit_nw_sub_clus_rv(), id)) NULL else id)
    }, ignoreInit = TRUE)
  })
  observeEvent(input$cit_nw_show_all, { cit_nw_sub_clus_rv(NULL) }, ignoreInit = TRUE)
  cit_nw_ab_sg_cluster_data_rv <- reactiveVal(NULL)
  # cit_nw_ab_sg_label_react <- reactiveVal(readRDS("www/data/all/splitabsg.RDS"))
  ##cit_nw_matching_pathogencluster >>>> cit_nw_matching_llmpathogencluster 
  cit_nw_matching_absgcluster <- reactiveVal(NULL)
  cit_nw_virus_veev_resclus_data_rv <- reactiveVal(NULL)
  # cit_nw_virus_veev_resclus_label_react <- reactiveVal(readRDS("www/data/all/pov_clusres/Virus-Alphavirus-resclusl.RDS"))
  ##cit_nw_matching_pathogencluster >>>> cit_nw_matching_llmpathogencluster 
  cit_nw_matching_veevrescluster <- reactiveVal(NULL)
  cit_nw_llm_cluster_data_rv <- reactiveVal(NULL)
  # cit_nw_pov_llm_label_react <- reactiveVal(readRDS("www/data/all/pov_llm_label.RDS"))
  ##cit_nw_matching_pathogencluster >>>> cit_nw_matching_llmpathogencluster 
  cit_nw_matching_llmpathogencluster <- reactiveVal(NULL)
  cit_nw_all_cluster_data_react <- reactiveVal(NULL)
  # cit_nw_pov_pmid_label_react <- reactiveVal(readRDS("www/data/all/pov_pmid_label.RDS"))
  # cit_nw_pov_pmid_label_react <- reactiveVal(readRDS("www/data/all/pov_clusres/Virus-Alphavirus-resclus.RDS"))
  # Load the RDS file with cluster keyword suggestions
  # cit_nw_pmid_llm_msg_react <- reactiveVal(readRDS("www/data/all/Alphavirus_llmoutput.RDS"))
  # cit_nw_keyword_suggestions_dt_react <- reactiveVal(readRDS("www/data/all/cluster_keywords.RDS"))
  cit_nw_matching_pathogencluster <- reactiveVal(NULL)
  cit_nw_valid_pmid <- reactiveVal(FALSE)  # Tracks whether valid PMID search result was found
  cit_nw_cluster_data_table<- reactiveVal(NULL)
  cit_nw_pmid_from_url <- reactiveVal(NULL)
  cit_nw_clus_dd<- reactiveVal(NULL)
  search_trigger <- reactiveVal(0)

  cit_nw_tree_btn_id  <- "cit_nw_tree_btn"
  cit_nw_tree_body_id <- "cit_nw_tree_body"
  selected_tile <- reactiveVal(NULL)
  rv_cit_nw <- reactiveValues(tree_open = FALSE)
  
  
  selected_cluster_llm_table <- reactiveVal(NULL)
  
  
  ######## === End:Reactive values === ########
  

observeEvent(input$go_home, {
  updateTextInput(session, "view", value = "home")
})


observeEvent(input$cit_nw_show_pmid_cluster, {
  updateTextInput(session, "view", value = "search")  # hides explorer
})

observeEvent(input$cit_nw_show_nw_timeline, {
  updateTextInput(session, "view", value = "browse")  # hides explorer
})


observeEvent(input$org_card_click, {
  showModal(modalDialog(paste("Clicked:", input$org_card_click), easyClose = TRUE))
})


# output$pathogen_cards <- renderUI({
#   cards <- lapply(seq_len(nrow(pathogens)), function(i) pathogen_card(pathogens[i, ]))
#   div(class = "card-grid", cards)
# })



# observeEvent(input$tile_click, {

#   # Use ID to determine image path
#   clicked_id <- input$tile_click

#   # Example: if ID format is area_label
#   parts <- strsplit(clicked_id, "_")[[1]]
#   label <- parts[length(parts)]

#   img_path <- paste0("org_imgs/", label, ".png")

#   showModal(
#     modalDialog(
#       title = label,
#       img(
#         src = img_path,
#         style = "width:100%; object-fit:contain;"
#       ),
#       easyClose = TRUE,
#       footer = modalButton("Close")
#     )
#   )
# })

# selected_tile <- reactiveVal(NULL)
# observeEvent(input$tile_click, {
  
#   clicked_id <- input$tile_click
#   parts <- strsplit(clicked_id, "_")[[1]]
#   label <- parts[length(parts)]
#   print(label)
#   # Step 1: activate Browse page
#   updateTextInput(session, "view", value = "browse")
  
#   # if clicking the Browse button is required in your app logic:
#   shinyjs::click("cit_nw_show_nw_timeline")
#   shinyjs::click("cit_nw_tree_btn")
  
#   #Step 2: wait briefly, then update inputs after Browse UI exists
#   later::later(function() {
#     updateSelectInput(session, "cit_nw_pov_llm_cluster_option", selected = label)
#     updateSelectInput(session, "root", selected = label)
#     updateSelectInput(session, "subject", selected = label)
#   }, delay =0.2)
  
# })





# 1) Tile click: store and switch to browse, also open relevant panels
observeEvent(input$tile_click, {
  clicked_id <- input$tile_click
  
  label <- tail(strsplit(clicked_id, "_")[[1]], 1)
  
  selected_tile(label)
  
  # switch to browse view
  updateTextInput(session, "view", value = "browse")
  
  # optionally simulate the UI button behavior so the panel opens:
  # only if your server-side code listens to those button clicks
  shinyjs::click("cit_nw_show_nw_timeline")
  shinyjs::click("cit_nw_tree_btn")
})

# 2) When the Browse button runs (panel created), update selects from stored value
#    This observer runs when the Browse button is pressed (or the tile simulated it).
observeEvent(list(input$cit_nw_show_nw_timeline, input$cit_nw_tree_btn), {
  req(selected_tile())
  
  label <- selected_tile()
  print("This label")
  print(label)
  # small delay to allow UI to finish rendering
  later::later(function() {
    # safe update attempts (won't error if input not present)
    try(updateSelectInput(session, "cit_nw_pov_llm_cluster_option", selected = label), silent = TRUE)
    try(updateSelectInput(session, "root", selected = label), silent = TRUE)
    try(updateSelectInput(session, "subject", selected = label), silent = TRUE)
  })
}, ignoreInit = TRUE)




# observeEvent(input$tile_click, {
  
#   clicked_id <- input$tile_click
#   parts <- strsplit(clicked_id, "_")[[1]]
#   label <- parts[length(parts)]
  
#   selected_tile(label)
  
#   # activate Browse page
#   updateTextInput(session, "view", value = "browse")
#   shinyjs::click("cit_nw_show_nw_timeline")
# })


# observeEvent(input$show_nw, {

#   req(selected_tile())

#   label <- selected_tile()

#   updateSelectInput(session, "cit_nw_pov_llm_cluster_option", selected = label)
#   updateSelectInput(session, "browse_pathogen_2", selected = label)
#   updateSelectInput(session, "browse_pathogen_3", selected = label)

# }, ignoreInit = TRUE)


output$org_layout <- renderUI({
  sq_card <- function(id, cls = "", img = NULL, label = NULL) {
  div(
    class = paste("sq-card", cls),
    `data-card-id` = id,
    tabindex = "0",
    role = "button",

    if (!is.null(img)) {
      img(
        src = img,
        class = "sq-img",
        alt = label
      )
    },

    if (!is.null(label)) {
      div(
        class = "sq-text",
        label
      )
    }
  )
}

  # helper: a cluster = row/area with n cards + label
  # cluster <- function(area_class, card_class, n, label = "Text") {
  #   div(
  #     class = paste("cluster", area_class),
  #     div(
  #       class = "cluster-cards",
  #       lapply(seq_len(n), function(i) sq_card(paste0(area_class, "_", i), card_class))
  #     ),
  #     div(class = paste("cluster-label", card_class), label)
  #   )
  # }


#   cluster <- function(area_class, card_class, n, label = "Text", img_prefix = NULL) {

#   div(
#     class = paste("cluster", area_class),

#     div(
#       class = "cluster-cards",
#       lapply(seq_len(n), function(i) {
#         img_path <- if (!is.null(img_prefix)) {
#           paste0("www/icons/patho_icons/", img_prefix, i, ".png")
#         } else NULL

#         sq_card(
#           id = paste0(area_class, "_", i),
#           cls = card_class,
#           img = img_path
#         )
#       })
#     ),

#     div(class = paste("cluster-label", card_class), label)
#   )
# }


# cluster <- function(area_class, card_class, labels) {

#   div(
#     class = paste("cluster", area_class),

#     div(
#       class = "cluster-cards",
#       lapply(labels, function(lbl) {

#         # Use label name as image filename
#         # img_path <- paste0("org_imgs/", lbl, ".png")
#         safe_name <- tolower(gsub("[^A-Za-z0-9]", "_", lbl))
#         img_path <- paste0("org_imgs/", safe_name, ".png")

#         sq_card(
#           id = paste0(area_class, "_", lbl),
#           cls = card_class,
#           img = img_path,
#           label = lbl
#         )
#       })
#     )
#   )
# }

cluster <- function(area_class, card_class, labels,
                           size = 110, text_size = 16) {

  div(
    class = paste("cluster", area_class),

    div(
      class = "cluster-cards",
      lapply(labels, function(nick) {

        #nick_lower <- tolower(nick)

        
        img_path <- paste0("org_imgs/", nick, ".png") 
        div(
          `data-toggle` = "tooltip",
          title = paste("Browse", nick, " Network"),
        sq_card_inline(
          id = paste0(area_class, "_", nick),
          cls = card_class,
          img = img_path,
          label = nick,
          size = size,
          text_size = text_size
        )
        )
      })
    )
  )
}




  div(
    class = "org-wrapper",
    #h2(class="org-title", "Organization"),

    div(
  class = "org-grid",

  cluster("area-red",  "c-red",
          labels = cit_nw_tm_btn_pov_list[["Correlates of Protection"]], size = 110, text_size = 16),

  cluster("area-blue", "c-blue",
          labels = cit_nw_tm_btn_pov_list[["Host Model Systems"]], size = 110, text_size = 16),

  cluster("area-blue2", "c-blue",
          labels = c("VSV","AdV"), size = 110, text_size = 16),

  cluster("area-orange", "c-orange",
          labels = c("mRNA","DNA","MVA"), size = 110, text_size = 16),

  cluster("area-pink", "c-pink",
          labels = c("Subunit","NLP","OMV","Nanosponge"), size = 110, text_size = 16),

  
div(
  class = "area-center",
  div(
    class = "center-card-row",
    sq_card_inline(
      id = "Vaccine",
      cls = "c-black",
      img = "org_imgs/vaccine.png",
      label = "Vaccine",
      size = 150,
      img_max_h = 0.78,
      text_size = 20,
      text_bottom = 10
    ),
    sq_card_inline(
      id = "Antimicrobial",
      cls = "c-black",
      img = "org_imgs/antimicrobial.png",
      label = "Antimicrobial",
      size = 150,
      img_max_h = 0.78,
      text_size = 20,
      text_bottom = 10
    )
  )
),



  # 5 green squares
  cluster("area-greenL", "c-green",
          labels = cit_nw_tm_btn_pov_list[["Virus"]][1:5], size = 110, text_size = 16),

  cluster("area-purpleR", "c-purple",
          labels = cit_nw_tm_btn_pov_list[["Bacteria"]][1:4], size = 110, text_size = 16),

  cluster("area-greenL2", "c-green",
          labels = c(cit_nw_tm_btn_pov_list[["Virus"]][6:9]), size = 110, text_size = 16),

  cluster("area-purpleR2","c-purple",
          labels = cit_nw_tm_btn_pov_list[["Bacteria"]][5:6], size = 110, text_size = 16),

  cluster("area-greenL3", "c-maroon",
          labels = c("Influenza","Dengue","HIV","Flavivirus","HBV"), size = 110, text_size = 16),

  cluster("area-purpleR3","c-olive",
          labels = c("Cholera","Tuberculosis","Campy","H.flu","Pseudomonas"), size = 110, text_size = 15),

  cluster("area-greenL4", "c-maroon",
          labels = c("HCV","Rotavirus","Polio","RSV","Rabies"), size = 110, text_size = 16),

  cluster("area-purpleR4","c-olive",
          labels = c("Staph","Lyme","Neisseria","Bacillus"), size = 110, text_size = 16),

  cluster("area-purpleR5","c-teal",
          labels = cit_nw_tm_btn_pov_list[["Parasite"]], size = 110, text_size = 16)


)





    # div(
    #   class = "org-grid",

    #   # top row clusters
    #   # cluster("area-red",    "c-red",    3),
    #   # cluster("area-blue",   "c-blue",   4),


    #   cluster("area-red","c-red",labels = c("Alpha", "Beta", "Gamma"),img_prefix = "red"),
    #   cluster("area-blue","c-blue",labels = c("Delta", "Epsilon", "Zeta", "Eta"),img_prefix = "blue"),

    #   # cluster("area-red", "c-red", 3, img_prefix = "red")
    #   # cluster("area-blue", "c-blue", 4, img_prefix = "blue")
    #   # #cluster("area-greenL", "c-green", 5, img_prefix = "green")

    #   # mid top clusters
    #   cluster("area-blue2",  "c-blue",   2),
    #   cluster("area-orange", "c-orange", 3),
    #   cluster("area-pink",   "c-pink",   4),

    #   # center single
    #   div(
    #     class = "area-center",
    #     div(class="sq-card c-black", `data-card-id`="center", tabindex="0", role="button"),
    #     div(class="cluster-label c-black", "Text")
    #   ),

    #   # bottom clusters
    #   cluster("area-greenL", "c-green",  5),
    #   cluster("area-purpleR","c-purple", 4),
    #   cluster("area-greenL2","c-green",  4),
    #   cluster("area-purpleR2","c-purple",3),
    #   cluster("area-greenL3","c-green",  3),
    #   cluster("area-purpleR3","c-purple",2)
    # )
  )
})
  
pow <- reactiveVal(list(
  title  = "Deep learning for pathogen surveillance",
  meta   = "Nature Methods (2026) • Smith et al.",
  abstract = "Short abstract/summary goes here...",
  pdf    = "papers/paper_of_week.pdf",    # put file in www/papers/
  url    = "https://example.com"          # optional external link
))

output$pow_title <- renderText(pow()$title)
output$pow_meta  <- renderText(pow()$meta)

observeEvent(input$pow_open, {
  p <- pow()
  showModal(modalDialog(
    title = p$title,
    tags$p(tags$strong("Citation: "), p$meta),
    tags$hr(),
    tags$p(p$abstract),
    tags$hr(),
    # If you have a PDF in www/papers/
    tags$a("Open PDF", href = p$pdf, target = "_blank"),
    tags$br(),
    # Optional external link
    tags$a("Publisher link", href = p$url, target = "_blank"),
    easyClose = TRUE,
    footer = modalButton("Close"),
    size = "l"
  ))
})



###Publication 


paper_card <- function(row) {
  tags$div(
    class = "paper-card",
    onclick = sprintf("Shiny.setInputValue('paper_click','%s',{priority:'event'})", row$id),

    tags$div(class="paper-img-wrap",
      tags$img(src = row$img, class="paper-img", alt = row$title)
    ),

    tags$div(class="paper-body",
      tags$div(class="paper-title-row",
        tags$a(
          class = "paper-title",
          href = row$url,
          target = "_blank",
          row$title
        ),
        tags$span(class="paper-ext", "\u2197")  # external arrow icon
      ),
      tags$p(class="paper-excerpt", row$excerpt)
    )
  )
}

output$papers_cards <- renderUI({
  cards <- lapply(seq_len(nrow(papers_df)), function(i) paper_card(papers_df[i, ]))
  tags$div(class="papers-grid", cards)
})

observeEvent(input$paper_click, {
  req(input$paper_click)
  row <- papers_df[papers_df$id == input$paper_click, , drop = FALSE][1, ]

  showModal(modalDialog(
    title = row$title,
    tags$img(src = row$img, style="width:100%; max-height:320px; object-fit:cover; border-radius:10px;"),
    tags$hr(),
    tags$p(row$excerpt),
    tags$hr(),
    tags$a("Open article", href = row$url, target = "_blank"),
    easyClose = TRUE,
    footer = modalButton("Close"),
    size = "l"
  ))
})


  # llm cluster label helper: render value as clickable link
  
  as_link <- function(label, llmlabels) {
    sprintf('<a href="#" class="dt-link" data-val="%s" data-llabels="%s">%s</a>',
            label, llmlabels, label)
  }
  # as_link <- function(x) {
  #   sprintf('<a href="#" class="dt-link" data-val="%s">%s</a>', x, x)
  # }
  # 
  # as_link <- function(code, llm_label) {
  #   sprintf(
  #     '<a href="#" class="dt-link" data-val="%s" data-llm="%s">%s</a>',
  #     code, llm_label, code
  #   )
  # }
  
  ##### --- PRELOAD all.RDS/mdf.RDS/LLMlabels.RDS/x files --- #####
  #Data
  DATA_DIR <- "www/data/new_mdf"
  
  ## Read mdf files
  # Helper: list subjects by scanning files like "<SUBJECT>.mdf.RDS"
  list_subjects <- function(dir = DATA_DIR) {
    mdf_files <- list.files(dir, pattern = "\\.mdf\\.RDS$", ignore.case = TRUE)
    # strip ".mdf.RDS"
    sub("\\.mdf\\.RDS$", "", mdf_files, ignore.case = TRUE)
  }
  
  
  # build the grouped choices from the subjects available on disk
  make_grouped_choices <- function(all_subjects) {
    # keep only subjects that exist; also make sure value==label
    groups <- lapply(cit_nw_tm_btn_pov_list, function(items) {
      present <- intersect(items, all_subjects)
      stats::setNames(present, present)
    })
    # drop empty groups
    Filter(length, groups)
  }
  
  
  # Build full paths for a given subject
  file_paths_for_subject <- function(subject) {
    list(
      mdf = file.path(DATA_DIR, sprintf("%s.mdf.RDS", subject)),
      x   = file.path(DATA_DIR, sprintf("%s.x.RDS",   subject))
    )
  }
  
  
  load_subject_data <- function(subject) {
    paths <- file_paths_for_subject(subject)
    mdf <- tryCatch(readRDS(paths$mdf), error = function(e) NULL)
    x   <- tryCatch(readRDS(paths$x),   error = function(e) NULL)
    
    if (is.null(mdf)) {
      stop(sprintf("Missing or unreadable file: %s", paths$mdf))
    }
    if (is.null(x)) {
      stop(sprintf("Missing or unreadable file: %s", paths$x))
    }
    
    list(mdf = mdf, x = x, paths = paths)
  }
  
  
  #LLM labels
  #llm.Q425.qs2>>>llm.Q325b.qs2
  cit_nw_llm_dt <- local({
    llm_path <- file.path(DATA_DIR, "llm.Q326.qs2")
    if (!file.exists(llm_path)) {
      stop(sprintf("Missing file: %s", llm_path))
    }
    llm_obj <- tryCatch(
      # readRDS(llm_path),
      qs_read(llm_path),
      error = function(e) stop("Could not read ", llm_path, ": ", conditionMessage(e))
    )
    llm_obj
  })
  # llm_dt$network_cluster <- with(mdfllm, paste(network, cluster, sep = "-"))
  print(paste0("LLM_DT"))
  print(Sys.time())
  cit_nw_llm_dt<- data.table(cit_nw_llm_dt)
  cit_nw_llm_dt$network_cluster<- paste(cit_nw_llm_dt$network, cit_nw_llm_dt$cluster, sep = "-")
  cit_nw_llm_dt$network_cluster <- gsub(":", "-", cit_nw_llm_dt$network_cluster)
  cit_nw_llm_dt$cluster_id<- as.numeric(cit_nw_llm_dt$cluster_id)
  cit_nw_llm_dt$cluster<- gsub(":", "-", cit_nw_llm_dt$cluster)
  print(paste0("LLM_DT"))
  print(Sys.time())
  
  
  
  ##### Test #####
  # split_data_dir<-  "www/new_mdf/allsplit"
  # 
  # pmid_ranges <- readRDS(file.path(split_data_dir, "pmid_ranges.RDS"))
  # load_chunk_for_pmid <- function(pmid) {
  #   # find which chunk contains this pmid
  #   pmidx <- which(pmid >= pmid_ranges$min_pmid & pmid <= pmid_ranges$max_pmid)
  #   
  #   if (length(pmidx) == 0) {
  #     return(NULL)
  #   }
  #   
  #   file_to_load <- file.path(split_data_dir, pmid_ranges$file[pmidx])
  #   
  #   # Load chunk
  #   dt <- tryCatch(
  #     readRDS(file_to_load),
  #     error = function(e) stop("Error reading chunk ", file_to_load, ": ", conditionMessage(e))
  #   )
  #   
  #   dt
  # }
  
  #####End: Test #####
  
  
  #All.df.noAbstract.RDS
  ALL_DATA <- local({
    all_path <- file.path(DATA_DIR, "All.df.noAbstract.qs2")
    if (!file.exists(all_path)) {
      stop(sprintf("Missing file: %s", all_path))
    }
    obj <- tryCatch(
      # readRDS(all_path),
      qs_read(all_path),
      error = function(e) stop("Could not read ", all_path, ": ", conditionMessage(e))
    )
    obj
  })
  
  ALL_DATA<- data.table(ALL_DATA)
  print(paste0("ALL_DATA"))
  print(Sys.time())
  
  
  
  ##Function to clean the ALL_DATA
  
  # preprocess_all_data <- function(dt_All_DATA) {
  #   dt <- as.data.table(copy(dt_All_DATA))  # don't mutate the original
  #   
  #   # build PoV_network_cluster
  #   dt[, PoV_network_cluster := paste(PoV, network, cluster, sep = "-")]
  #   
  #   # replace ":" with "-" in target columns (fixed=TRUE is faster/safer)
  #   dt[, PoV_network_cluster := gsub(":", "-", PoV_network_cluster, fixed = TRUE)]
  #   dt[, cluster              := gsub(":", "-", cluster,              fixed = TRUE)]
  #   
  #   # drop rows with any NA
  #   dt <- dt[complete.cases(dt)]
  #   
  #   dt
  # }
  
  # ALL_DATA[, PoV_network_cluster := paste(PoV, network, cluster, sep = "-")]
  # # ALL_DATA$PoV_network_cluster <- gsub(pattern = ":", replacement = "-", x = ALL_DATA$PoV_network_cluster)
  # # # Replace ":" with "-" in a specific column
  # ALL_DATA$PoV_network_cluster <- gsub(":", "-", ALL_DATA$PoV_network_cluster)
  # ALL_DATA$cluster <- gsub(":", "-", ALL_DATA$cluster)
  # ALL_DATA <- ALL_DATA[complete.cases(ALL_DATA), ]
  # print(head(ALL_DATA))
  
  
  observeEvent(input$cit_nw_chatdt_pmid_clicked, {
    req(input$cit_nw_chatdt_pmid_clicked)
    
    updateTextInput(session, "cit_nw_pmid_input", value = input$cit_nw_chatdt_pmid_clicked)
    
    # fire the same search trigger as if button was clicked
    search_trigger(search_trigger() + 1)
    
    # trigger the *visual* click after UI flush (important for dynamic UI)
    session$onFlushed(function() {
      shinyjs::click("cit_nw_search_btn")
    }, once = TRUE)
    
  })


  ov_tbl_path <- "www/data/new_mdf/overview/patho_overview_tables.xlsx"
  
  cit_nw_ov_tbl_result <- eventReactive(input$cit_nw_overview_nw_search_btn, {
    req(input$cit_nw_overview_nw_option)
    #print(input$cit_nw_overview_nw_option)
    
    #ov_tbl_path <- "tables.xlsx"
    sheets_vec <- excel_sheets(ov_tbl_path)
    #print(head(sheets))
    list(path = ov_tbl_path, sheets = sheets_vec)
  },ignoreNULL = FALSE)

  ov_selected_columns <- c("Topic", "Question", "Response", "Bullet points", "Key refs from Ratbot", "Timelines", "Key refs from Cit Net")
  
  selected_sheet_data <- reactive({
    info <- cit_nw_ov_tbl_result()          # MUST call the reactive
    req(info)                               # stops if NULL (button not clicked)
    req(input$cit_nw_overview_nw_option)    # ensure user made selection
    #print(input$cit_nw_overview_nw_option)
    sheets <- info$sheets
    #print(class(sheets))# character vector
    target_sheet <- input$cit_nw_overview_nw_option
    #print(target_sheet)
    # Optionally allow case-insensitive matching:
    ix <- which(tolower(sheets) == tolower(target_sheet))
    if (length(ix) == 1) target_sheet <- sheets[ix]
    
    shiny::validate(
      need(target_sheet %in% sheets,
           paste0("Sheet '", target_sheet, "' not found in the Excel file. Available: ",
                  paste(sheets, collapse = ", ")))
    )
    
    # #read_excel(info$path, sheet = target_sheet)
    # readxl::read_excel(
    # info$path,
    # sheet = target_sheet,
    # skip = 2)

    df <- readxl::read_excel(
    info$path,
    sheet = target_sheet,
    range = readxl::cell_rows(3:13)
  )

  df[, intersect(ov_selected_columns, names(df)), drop = FALSE]
  
    
  })
  
  
  observeEvent(cit_nw_ov_tbl_result(), {
    output$cit_nw_overview_table <- DT::renderDT({
      df <- selected_sheet_data()
      
    
      df$"Key refs from Ratbot" <- str_replace_all(
        df$"Key refs from Ratbot",
        "PMID:(\\d+)",'<a href="https://pubmed.ncbi.nlm.nih.gov/\\1/" target="_blank">PMID:\\1</a>'
      )
      
      df$Timelines <- str_replace_all(
        df$Timelines,
        "(\\b\\d{5,10}\\b)",
        '<a href="#" class="overview-pmid-link" data-pmid="\\1">\\1</a>'
      )

      df$"Key refs from Cit Net" <- str_replace_all(
        df$"Key refs from Cit Net",
        "PMID:(\\d+)",'<a href="https://pubmed.ncbi.nlm.nih.gov/\\1/" target="_blank">PMID:\\1</a>'
      )
      
      
    # df$"Key refs from Ratbot" <- str_replace_all(
    #   df$"Key refs from Ratbot",
    #   "PMID:(\\d+)",'<a href="https://pubmed.ncbi.nlm.nih.gov/\\1/" target="_blank">PMID:\\1</a>'
    # )
    # 
    # df$Timelines <- str_replace_all(
    #   df$Timelines,
    #   "(\\b\\d{5,10}\\b)",
    #   '<a href="#" class="overview-pmid-link" data-pmid="\\1">\\1</a>'
    # )
    
    datatable(df, 
              #class="row-border compact",
              rownames=FALSE,
              escape=FALSE,
              selection="none",
              options = list(#dom='t',  #with dom activated, the search control and number of rows to display disappear
                #order = list(list(0, "desc")),
                
                ordering=TRUE,
                borders=TRUE,
                paging=TRUE,
                pageLength = 1,
                scrollX = TRUE,
                #autoWidth = TRUE,
                columnDefs = list(
                  list(width = '60px',  targets = which(names(df) %in% "Topic") - 1),
                  list(width = '80px',  targets = which(names(df) %in% "Question") - 1),
                  list(width = '500px', targets = which(names(df) %in% "Response") - 1),
                  list(width = '320px', targets = which(names(df) %in% "Bullet points") - 1),
                  list(width = '160px', targets = which(names(df) %in% "Key refs from Ratbot") - 1),
                  list(width = '220px', targets = which(names(df) %in% "Timelines") - 1),
                  list(width = '220px', targets = which(names(df) %in% "Key refs from Cit Net") - 1),
                  list(width = '220px', targets = which(names(df) %in% "Key refs from Kestrel") -1))
                  
                
                #headerCallback = JS(headerCallback)
              ),
              callback = JS("
                table.on('click', 'a.overview-pmid-link', function(e) {
                e.preventDefault();
                var pmid = $(this).data('pmid');
                Shiny.setInputValue('cit_nw_chatdt_pmid_clicked', pmid, {priority: 'event'});

                $('html, body').animate({
                  scrollTop: $('#cit_nw_timeline_tab').offset().top
                }, 600);
      });
    ")
              
              
              )
  })})
  

  ##### End: Overview Tables #####
  
  
  
  
  
  split_all_llm_data <- reactive({
    req(cit_nw_llm_dt)
    # cit_nw_llm_dt <- cit_nw_llm_dt
    cit_nw_llm_dt$network_res <- paste(cit_nw_llm_dt$network, cit_nw_llm_dt$res)
    # split(cit_nw_llm_dt, cit_nw_llm_dt$network_res)
    split(cit_nw_llm_dt, cit_nw_llm_dt$network)
  })
  
  
  # Initialize the reactive store once.
  # all_data_rv <- reactiveVal(preprocess_all_data(ALL_DATA))
  all_data_rv <- reactiveVal(ALL_DATA)
  
  ##### --- End: PRELOAD all.RDS/mdf.RDS/LLMlabels.RDS/x files --- #####
  
  
  
  
  
  #----------------------------------------------------------------------------#
  #####======= ***LLM CLUSTER LABELS*** =======#####
   
  
  ######### === UI Panel Display on Button Click(LLM Cluster Labels) === #########
  observeEvent(input$cit_nw_show_llmpmid_cluster, {
    # Hide cluster panel
    # LLM cluster
    output$cit_nw_cluster_tab <- renderUI({ NULL })
    output$cit_nw_pmid_tab <- renderUI({ NULL })
    output$cit_nw_timeline_tab<- renderUI({ NULL })
    output$cit_nw_tab <- renderUI({
      req(input$view == "browse")
      selected_label <- selected_tile()

      req(split_all_llm_data())
      cit_nw_cluster_llmlabel_data<- split_all_llm_data()
      tagList(
        br(), br(),
        div(class = "cit-nw-search-container",
            actionButton("cit_nw_keyword_search_help", "?", class = "cit-nw-help-button"),
            selectInput("cit_nw_pov_llm_cluster_option", "Louvain clustering for:", choices = names(cit_nw_cluster_llmlabel_data)),
            actionButton("cit_nw_cluster_search_btn", "Search"),
        ),
        br(), br(),
        div(class = "cit-nw-main-panel-container",
            DT::dataTableOutput("cit_nw_llm_table_for_cluster"),
        ),
        br(), br()
      )
    })
  })
  ########## === End: UI Panel Display on Button Click(LLM Cluster Labels) === #########


  #####===== UI Panel: LLM Cluster Labels: Search Result Btn =====#####
  # cit_nw_search_result >>> cit_nw_llmsearch_result
  # Reactive expression that triggers when the Search button(cit_nw_cluster_search_btn"Search") is clicked
  cit_nw_llmsearch_result <- eventReactive(input$cit_nw_cluster_search_btn, {
    req(split_all_llm_data())
    cit_nw_cluster_llmlabel_data<- split_all_llm_data()
    req(input$cit_nw_pov_llm_cluster_option)
    louv_cl<- input$cit_nw_pov_llm_cluster_option
    print(input$cit_nw_pov_llm_cluster_option)
    print(paste("louclus:",louv_cl))
    matching_llmclusters<- cit_nw_cluster_llmlabel_data[louv_cl[louv_cl %in% names(cit_nw_cluster_llmlabel_data)]]
    list(
      louv_cl = louv_cl,
      matching_llmclusters = matching_llmclusters
    )
  })

  observeEvent(cit_nw_llmsearch_result(), {
    llminfo<- cit_nw_llmsearch_result()
    req(llminfo$louv_cl)
    output$cit_nw_llm_table_for_cluster<- renderDT(NULL)
    cit_nw_matching_llmpathogencluster(llminfo$matching_llmclusters)
    # Render the datatable using DT package
    output$cit_nw_llm_table_for_cluster <- DT::renderDataTable({
      req(llminfo$louv_cl)
      llmcluster_data<- llminfo$matching_llmclusters[[1]]
      llmselected_points<- llmcluster_data
      
      
      
      
      df <- data.table::data.table(
        # clusterid = llmselected_points$cluster_id,
        resid= llmselected_points$res,
        papercount = llmselected_points$n_entries,
        llmlabels = llmselected_points$llm_labels,
        llmjustifications = llmselected_points$llm_justifications,
        keywords = llmselected_points$keywords,
        label = llmselected_points$network_cluster,
        lvres = llmselected_points$network_res
        # Colormatch = llmselected_points$match_color,
        # UniqueID = llmselected_points$pmid
      )
      #print(head(df))
      # df$label <- vapply(df$label, as_link, character(1))
      
      df$label <- mapply(as_link, df$label, df$llmlabels)
      
      setnames(df, c("resid", "papercount", "llmlabels", "llmjustifications", "keywords","label","lvres"),
               c("Resolution", "#Papers", "LLM Labels", "LLM Justifications", "Keywords", "NW-Res-Clusterid","Network-Resolution"))
      # tagList(
      #   tags$h4(paste("List of papers in the Cluster: ",input$cit_nw_pmid_pathogencluster_select), style = "margin-bottom: 10px;"),
      DT::datatable(
        df,
        escape = FALSE,
        rownames = FALSE,
        extensions = c('Buttons', 'Responsive'),
        options = list(
          dom = '<"top"B>lfrtip',
          buttons = list(
            list(
              extend = 'collection',
              text = 'Export',
              buttons = c('csv', 'excel', 'pdf')
            )
          ),
          pageLength = 1,
          # order = list(list( which(colnames(df) == "#Citations") - 1, 'desc' )),
          lengthMenu = list(c(1,10, 25, 50, -1), c(1,10, 25, 50, "All")),
          columnDefs = list(
            list(visible = FALSE, targets = 6),  # Cluster(lvres)
            # # list(visible = FALSE, targets = 5),  # Authors
            # list(visible = FALSE, targets = 6),   # Unique ID
            list(className = 'dt-left', targets = 1)
          ),
          selection = 'single'
          #this is for the dropdown column(keyword) menu in the datatable
          # initComplete = JS(
          #   "function(settings, json) {",
          #   "  var column = this.api().column(5);",
          #   "  if (!column.header()) return;",
          #   "  var select = $('<select><option value=\"\">All</option></select>')",
          #   "    .appendTo($(column.header()).empty())",
          #   "    .on('change', function() {",
          #   "      var val = $.fn.dataTable.util.escapeRegex($(this).val());",
          #   "      column.search(val ? '^' + val + '$' : '', true, false).draw();",
          #   "    });",
          #   "  column.data().unique().sort().each(function(d, j) {",
          #   "    if (d != null && d !== '') {",
          #   "      select.append('<option value=\"' + d + '\">' + d + '</option>');",
          #   "    }",
          #   "  });",
          #   "}"
          # )
        ),
        selection = 'single',
        editable = FALSE,
        
#         callback = JS("
#   table.on('click', 'a.dt-link', function(e) {
#     e.preventDefault();
#     var code  = $(this).data('val');
#     var label = $(this).data('label');
# 
#     Shiny.setInputValue('clicked_row', {code: code, label_a: label}, {priority: 'event'});
#   });
# ")
        callback = JS("
        table.on('click', 'a.dt-link', function(e) {
          e.preventDefault();
          //var val = $(this).data('val');
          
          var label  = $(this).data('val');
          var llabels = $(this).data('llabels');


          Shiny.setInputValue('clicked_nw_res_clusid', {label:label, llm_labels:llabels}, {priority: 'event'});
        });
      ")
        # callback = JS(
        #   "table.on('click', 'td', function() {",
        #   "  var cell = table.cell(this);",
        #   "  var rowIndex = cell.index().row;",
        #   "  var data = table.row(rowIndex).data();",
        #   "  var abstractInfo = data[4];",
        #   "  Shiny.setInputValue('selected_row', abstractInfo, {priority: 'event'});",
        #   "});"
        # )
      )
    }, server = FALSE)
    
    
    
    
    
  })
  #####===== End: UI Panel: LLM Cluster Labels: Search Result Btn =====#####

  #####======= ***End: LLM CLUSTER LABELS*** =======#####
  #----------------------------------------------------------------------------#
  
  observeEvent(input$clicked_nw_res_clusid, {
    req(input$clicked_nw_res_clusid)
    
    payload <- input$clicked_nw_res_clusid
    
    
    code_str <- as.character(payload$label)
    llm_lbl  <- as.character(payload$llm_labels)
    
    # debug printing
    print(payload)
    print("LLM label (payload$llm_labels):")
    print(llm_lbl)
    
    # parse code_str e.g. "Ax-Cl.1-33"
    m <- regexec("^([^-]+)-Cl\\.(\\d+)-(\\d+)$", code_str)
    parts <- regmatches(code_str, m)[[1]]
    print(parts)
    
    if (length(parts) == 4) {
      llm_tbl_nw  <- parts[2]             # e.g. "Ax"
      llm_tbl_res <- paste0("res_", parts[3])  # e.g. "res_1"
      
      # update other inputs directly
      updateSelectInput(session, "subject", selected = llm_tbl_nw)
      updateRadioButtons(session, "resolution", selected = llm_tbl_res)
      # set the reactiveVal so renderUI will pick this value as selected
      selected_cluster_llm_table(llm_lbl)
      
      # optional: also immediately update the existing input (if it exists)
      # This gives immediate visual feedback without waiting for renderUI to re-run.
      updateSelectInput(session, "cit_nw_nt_select_input", selected = llm_lbl)
      
      
      ###Add smooth scroll down 
      
      shinyjs::runjs("
    var el = document.getElementById('cit_nw_llm_tbl_cluster_section');
    if (el) {
      el.scrollIntoView({behavior: 'smooth', block: 'start'});
    }
  ")
    }
  })
  
  #----------------------------------------------------------------------------#
  #####======= ***CiteNet CLUSTERS*** =======#####
  
  ##### === UI Panel Display on Button Click: CiteNet each pov louvain Clusters:(Btn CitNet Clusters) === #####
  # showSubs <- reactiveVal(TRUE)
  observeEvent(input$cit_nw_show_louv_cluster, {
    output$cit_nw_tab <- renderUI({ NULL })
    output$cit_nw_pmid_tab <- renderUI({ NULL })
    output$cit_nw_timeline_tab<- renderUI({ NULL })
    
    ###### CiteNet Cluster: button click #####
    ##### I: UI Panel Display on Button Click: Close cit_nw_cluster_tab #####
    output$cit_nw_cluster_tab <- renderUI({
    cit_nw_sub_clus_btn_click<- cit_nw_sub_clus_rv()
    # req(showSubs())
    tagList(
      if(is.null(cit_nw_sub_clus_rv())){
        div(class = "cit-nw-subgrid",
            actionButton("cit_nw_path_clus_btn", "Pathogen", class = "cit-nw-sub-btn"),
            actionButton("cit_nw_cop_clus_btn", "Correlates of Protection", class = "cit-nw-sub-btn"),
            actionButton("cit_nw_hms_clus_btn", "Host Model Systems", class = "cit-nw-sub-btn"),
            actionButton("cit_nw_vp_clus_btn", "Vaccine Platforms", class = "cit-nw-sub-btn"),
            actionButton("cit_nw_mcm_clus_btn", "Medical Contermeasures", class = "cit-nw-sub-btn"),
            actionButton("cit_nw_vac_clus_btn", "Vaccines", class = "cit-nw-sub-btn"),
            
          )
        }else{
          div(class = "cit-nw-sub-selected-row",actionButton("cit_nw_show_all", "Show all", class = "cit-nw-show-all"),
              #when one of the button is clicked, switch to show the main button clicked
              switch(cit_nw_sub_clus_rv(),
                     sub_pathogen  = actionButton("cit_nw_path_clus_btn",  "Pathogen",  class = "cit-nw-sub-btn"),
                     sub_cop  = actionButton("cit_nw_cop_clus_btn",  "Correlates of Protection",  class = "cit-nw-sub-btn"),
                     sub_hms  = actionButton("cit_nw_hms_clus_btn",  "Host Model Systems",  class = "cit-nw-sub-btn"),
                     sub_vp = actionButton("cit_nw_vp_clus_btn", "Vaccine Platforms", class = "cit-nw-sub-btn"),
                     sub_mcm  = actionButton("cit_nw_mcm_clus_btn",  "Medical Contermeasures", class = "cit-nw-sub-btn"),
                     sub_vac  = actionButton("cit_nw_vac_clus_btn",  "Vaccines", class = "cit-nw-sub-btn")
              ),
              ###### Alternate #######
              # # If you want a reactive value elsewhere:
              # selected_cluster <- reactive(selected())
              # # use selected_cluster() in other logic
              # Add the button that was clicked
              # if (cit_nw_sub_clus_btn_click == "cit_nw_path_clus_btn")
              #   actionButton("cit_nw_path_clus_btn", "Pathogen", class = "cit-nw-sub-btn"),
              # if (cit_nw_sub_clus_btn_click == "cit_nw_cop_clus_btn")
              #   actionButton("cit_nw_cop_clus_btn", "Correlates of Protection", class = "cit-nw-sub-btn"),
              # if (cit_nw_sub_clus_btn_click == "cit_nw_hms_clus_btn")
              #   actionButton("cit_nw_hms_clus_btn", "Host Model Systems", class = "cit-nw-sub-btn"),
              # if (cit_nw_sub_clus_btn_click == "cit_nw_vp_clus_btn")
              #   actionButton("cit_nw_vp_clus_btn", "Vaccine Platforms", class = "cit-nw-sub-btn"),
              # if (cit_nw_sub_clus_btn_click == "cit_nw_mcm_clus_btn")
              #   actionButton("cit_nw_mcm_clus_btn", "Medical Contermeasures", class = "cit-nw-sub-btn")
              ###### End: Alternate #######
          )
        },
      
      #UI output per button(Pathogen,CoP,HMS,VP,MCM)
      div(
        id = "content-area",
        uiOutput("cit_nw_patho_tab"),
        uiOutput("cit_nw_cop_tab"),
        uiOutput("cit_nw_hms_tab"),
        uiOutput("cit_nw_vp_tab"),
        # verbatimTextOutput("debug_query"),
        uiOutput("cit_nw_mcm_tab"),
        uiOutput("cit_nw_vac_tab")),
        
      
      )})
    ########### === End I: UI Panel Display on Button Click: Close cit_nw_cluster_tab === ##########
    
    ########### === UI II: UI Panel Display on Button Click: "Show all click" === ##########
    observeEvent(input$cit_nw_show_all, { 
      cit_nw_sub_clus_rv(NULL) 
      # cit_nw_show_sub_rv(FALSE)
      output$cit_nw_patho_tab <- renderUI(NULL)
      output$cit_nw_cop_tab <- renderUI(NULL)
      output$cit_nw_hms_tab <- renderUI(NULL)
      output$cit_nw_vp_tab <- renderUI(NULL)
      output$cit_nw_mcm_tab <- renderUI(NULL)
      output$cit_nw_vac_tab <- renderUI(NULL)
      })
    
    ########### === End:UI II: UI Panel Display on Button Click: "Show all click" === ##########
    
    ########### === UI III: UI Panel: CitNetClusters Display on Button Click: Pathogen btn click>>> Patho tab === ##########
    observeEvent(input$cit_nw_path_clus_btn, {
      cit_nw_sub_clus_rv("sub_pathogen")
      output$cit_nw_cop_tab <- renderUI({ NULL })
      output$cit_nw_hms_tab <- renderUI({ NULL })
      output$cit_nw_vp_tab <- renderUI({ NULL })
      output$cit_nw_mcm_tab <- renderUI({ NULL })
      output$cit_nw_vac_tab <- renderUI({ NULL })
      # output$cit_nw_tab <- renderUI({ NULL })
      output$cit_nw_patho_tab <- renderUI({
        # req(showSubs())
        tagList(
          div(class = "cit-nw-subgrid",
              actionButton("cit_nw_virus_clus_btn", "Virus", class = "cit-nw-sub-btn"),
              actionButton("cit_nw_bacteria_clus_btn", "Bacteria", class = "cit-nw-sub-btn"),
              actionButton("cit_nw_ref_clus_btn", "Reference", class = "cit-nw-sub-btn"),
              ),
          div(
            id = "content-area",
            uiOutput("cit_nw_virus_clus_ui"),
            # verbatimTextOutput("debug_query"),
            uiOutput("cit_nw_bacteria_clus_ui"),
            uiOutput("cit_nw_ref_clus_ui"),
            )
          )
      })
    })
    ########### === End: UI III: UI Panel Display on Button Click: Pathogen btn click>>> Patho tab === ##########
    
    ########### === UI : UI Panel Display on Button Click: Pathogen btn click>>> Patho tab; Virusbtn click >>>> Virus tab === ##########
    observeEvent(input$cit_nw_virus_clus_btn, {
      cit_nw_sub_clus_rv("sub_virus")
      output$cit_nw_bacteria_tab <- renderUI({ NULL })
      output$cit_nw_refpath_tab <- renderUI({ NULL })
      output$cit_nw_virus_clus_ui <- renderUI({
        tagList(
          div(class = "cit-nw-subgrid",
              # fluidRow( style = "padding-left:15px;",
              column(1, align="center", div(id='patho_cchfv_btn_div', tipify( actionButton( inputId="patho_cchfv_btn", class= "shared_buttons", label=img(src = "icons/patho_icons/cchfv.png", height = "75px", width = "85px")), "Crimean–Congo hemorrhagic fever virus"))),
              column(1, align="center", div(id='patho_ebola_btn_div', tipify( actionButton( inputId="patho_ebola_btn", class="shared_buttons", label=img(src = "icons/patho_icons/ebola.png", height = "75px", width = "85px")), "Ebolavirus"))),
              column(1, align="center", div(id='patho_hanta_btn_div', tipify( actionButton( inputId="patho_hanta_btn", class="shared_buttons", label=img(src = "icons/patho_icons/hanta.png", height = "75px", width = "85px")), "Hantavirus"))),
              column(1, align="center", div(id='patho_lassa_btn_div', tipify( actionButton( inputId="patho_lassa_btn", class="shared_buttons", label=img(src = "icons/patho_icons/lassa.png", height = "75px", width = "85px")), "Lassa virus"))),
              column(1, align="center", div(id='patho_measles_btn_div', tipify( actionButton( inputId="patho_measles_btn", class="shared_buttons", label=img(src = "icons/patho_icons/measles.png", height = "75px", width = "85px")), "Measles virus"))),
              column(1, align="center", div(id='patho_mpox_btn_div', tipify( actionButton( inputId="patho_mpox_btn", class="shared_buttons", label=img(src = "icons/patho_icons/mpox.png", height = "75px", width = "85px")), "Monkeypox virus"))),
              column(1, align="center", div(id='patho_nipah_btn_div', tipify( actionButton( inputId="patho_nipah_btn", class="shared_buttons", label=img(src = "icons/patho_icons/nipah.png", height = "75px", width = "85px")), "Nipah virus"))),
              column(1, align="center", div(id='patho_covid_btn_div', tipify( actionButton( inputId="patho_covid_btn", class="shared_buttons", label=img(src = "icons/patho_icons/sars_cov_2.png", height = "75px", width = "85px")), "Coronavirus"))),
              column(1, align="center", div(id='patho_veev_btn_div', tipify( actionButton( inputId="patho_veev_btn", class="shared_buttons", label=img(src = "icons/patho_icons/veev.png", height = "75px", width = "85px")), "Venezuelan equine encephalitis virus")))
              # )
              ),
          div(
            id = "content-area",
            uiOutput("cit_nw_viru_cchfv_clus_ui"),
            # verbatimTextOutput("debug_query"),
            uiOutput("cit_nw_virus_ebola_clus_ui"),
            uiOutput("cit_nw_virus_hanta_clus_ui"),
            uiOutput("cit_nw_virus_lassa_clus_ui"),
            uiOutput("cit_nw_virus_measles_clus_ui"),
            uiOutput("cit_nw_virus_mpox_clus_ui"),
            uiOutput("cit_nw_virus_nipah_clus_ui"),
            uiOutput("cit_nw_virus_covid_clus_ui"),
            uiOutput("cit_nw_virus_veev_clus_ui")
          )
        )
        })
      })
    ########### === End UI : UI Panel Display on Button Click: Pathogen btn click>>> Patho tab; Virusbtn click >>>> Virus tab === ##########
    
    ########### === UIVEEV : UI Panel Display on Button Click: Pathogen btn click>>> Patho tab: Virusbtn click >>>> Virus tab:Veevirusbtn>>>louvain  === ##########
    observeEvent(input$patho_veev_btn,{
      output$cit_nw_virus_veev_clus_ui<- renderUI({
        tagList(
          br(), br(),
          div(class = "cit-nw-search-container",
              actionButton("cit_nw_help", "?", class = "cit-nw-help-button"),
              selectInput("cit_nw_patho_virus_alpha_resclus_option", "Resolution cluster of interest:", choices = cit_nw_patho_virus_alpha_resclus_choices),
              actionButton("cit_nw_resclus_search_btn", "Search"),
          ),
          br(), br(),
          div(
            class = "cit-nw-main-panel-container",
            uiOutput("cit_nw_resclus_veev_plot_for_cluster"),
            br(), br(),br(),
            DT::DTOutput("cit_nw_resclus_veev_table_for_cluster")
          ),
          br(), br(),
          radioButtons(
            "sub_kind", "Secondary plot based on selected legend group(s):",
            c("Resolution 2" = "res_2",
              "Resolution 5" = "res_5",
              "Resolution 10" = "res_10",
              "Resolution 20" = "res_20",
              "Timeline view Resolution 1" = "tres_1",
              "Timeline view Resolution 2" = "tres_2",
              "Timeline view Resolution 5" = "tres_5",
              "Timeline view Resolution 10" = "tres_10",
              "Timeline view Resolution 20" = "tres_20"),
            inline = TRUE
          ),
          plotlyOutput("subPlot", height = "800px"),
          DTOutput("subTable")
        )
      })
      })
    ########### === End: UI::VEEV : UI Panel Display on Button Click: Pathogen btn click>>> Patho tab: Virusbtn click >>>> Virus tab:Veevirusbtn>>>louvain  === ##########
    
    ########### === UI::CoP : UI Panel Display on Button Click: CoPbtn  === ##########
    observeEvent(input$cit_nw_cop_clus_btn, {
      cit_nw_sub_clus_rv("sub_cop")
      output$cit_nw_patho_tab <- renderUI({ NULL })
      output$cit_nw_hms_tab <- renderUI({ NULL })
      output$cit_nw_vp_tab <- renderUI({ NULL })
      output$cit_nw_mcm_tab <- renderUI({ NULL })
      # output$cit_nw_tab <- renderUI({ NULL })
      output$cit_nw_cop_tab <- renderUI({
        # req(showSubs())
        tagList(
          div(class = "cit-nw-subgrid",
              actionButton("cit_nw_ab_clus_btn", "Antibody", class = "cit-nw-sub-btn"),
              actionButton("cit_nw_cyto_clus_btn", "Cytokine", class = "cit-nw-sub-btn"),
              actionButton("cit_nw_tcell_clus_btn", "T-cell", class = "cit-nw-sub-btn"),
              ),
          div(
            id = "content-area",
            uiOutput("cit_nw_ab_clus_ui"),
            # verbatimTextOutput("debug_query"),
            uiOutput("cit_nw_cyto_clus_ui"),
            uiOutput("cit_nw_tcell_clus_ui"),
          )
          )
      })
    })
    ########### ===End: UI::CoP : UI Panel Display on Button Click: CoPbtn  === ##########
    
    ########### === UI::Vaccine : UI Panel Display on Button Click: Vaccinebtn  === ##########
    observeEvent(input$cit_nw_vac_clus_btn, {
      cit_nw_sub_clus_rv("sub_vac")
      output$cit_nw_patho_tab <- renderUI({ NULL })
      output$cit_nw_hms_tab <- renderUI({ NULL })
      output$cit_nw_vp_tab <- renderUI({ NULL })
      output$cit_nw_mcm_tab <- renderUI({ NULL })
      output$cit_nw_cop_tab <- renderUI({ NULL })
      # output$cit_nw_tab <- renderUI({ NULL })
      output$cit_nw_vac_tab <- renderUI({
        # req(showSubs())
        tagList(
          div(
            id = "content-area",
            output$cit_nw_vac_clus_ui<- renderUI({
              tagList(
                br(), br(),
                div(class = "cit-nw-search-container",
                    actionButton("cit_nw_help", "?", class = "cit-nw-help-button"),
                    selectInput("cit_nw_vac_resclus_option", "Resolution cluster of interest:", choices = cit_nw_vac_resclus_choices),
                    actionButton("cit_nw_resclus_search_btn", "Search"),
                ),
                br(), br(),
                div(
                  class = "cit-nw-main-panel-container",
                  uiOutput("cit_nw_resclus_vac_plot_for_cluster"),
                  br(), br(),br(),
                  DT::DTOutput("cit_nw_resclus_vac_table_for_cluster")
                ),
                br(), br(),
                radioButtons(
                  "sub_kind", "Secondary plot based on selected legend group(s):",
                  c("Resolution 2" = "res_2",
                    "Resolution 5" = "res_5",
                    "Resolution 10" = "res_10",
                    "Resolution 20" = "res_20",
                    "Timeline view Resolution 1" = "tres_1",
                    "Timeline view Resolution 2" = "tres_2",
                    "Timeline view Resolution 5" = "tres_5",
                    "Timeline view Resolution 10" = "tres_10",
                    "Timeline view Resolution 20" = "tres_20"),
                  inline = TRUE
                ),
                plotlyOutput("subPlot_vac", height = "800px"),
                DTOutput("subTable_vac")
              )
            })
          )
        )
      })
    })
    ########### ===End: UI::Vaccine : UI Panel Display on Button Click: Vaccinebtn  === ##########
    
    
    ############ ========== Logic: Add veev resolution clusters ============ ############
    
    ######## cit_nw_resclus_search_btn: Button Reactiveness ####
    cit_nw_resclus_search_result <- eventReactive(input$cit_nw_resclus_search_btn, {
      req(cit_nw_virus_veev_resclus_label_react())
      cit_nw_virus_veev_resclus_data <- cit_nw_virus_veev_resclus_label_react()
      req(input$cit_nw_patho_virus_alpha_resclus_option)
      res_cl_alpha<- input$cit_nw_patho_virus_alpha_resclus_option
      print(paste("Resolution cluster alphavirus:",res_cl_alpha))
      matching_veevclusters<- cit_nw_virus_veev_resclus_data[res_cl_alpha[res_cl_alpha %in% names(cit_nw_virus_veev_resclus_data)]]
      list(
        res_cl_alpha = res_cl_alpha,
        matching_veevclusters = matching_veevclusters
      )})
    ######## End: cit_nw_resclus_search_btn: Button Reactiveness ####
    
    
    
    observeEvent(cit_nw_resclus_search_result(), {
      
      veevresinfo<- cit_nw_resclus_search_result()
      req(veevresinfo$res_cl_alpha)
      output$cit_nw_resclus_veev_plot_for_cluster<- renderUI(NULL)
      output$cit_nw_resclus_veev_table_for_cluster<- renderUI(NULL)
      veevcluster_data<- veevresinfo$matching_veevclusters[[1]]
      # print(head(veevcluster_data))
      #======= SG Plot ======#
      print(paste("This is veev res_clus",veevresinfo$res_cl))
      # veevcluster_data$Nyear <- as.numeric(sgcluster_data$Nyear)
      # print(head(sgcluster_data, n=2))
      ##=====uncomment later
      # keywords <- trimws(unlist(strsplit(input$cit_nw_sg_keywords, ",")))
      
      # Ensure match_color is a factor with keyword order
      # veevcluster_data$match_color <- factor(veevcluster_data$match_color, levels = keywords)
      # cit_nw_keyword_columns <- c("abstract", "title", "pmid")
      # 
      # # Initialize match_color
      # veevcluster_data$match_color <- "none"
      # 
      # for (kw in keywords) {
      #   if (nzchar(kw)) {
      #     matches <- Reduce(`|`, lapply(cit_nw_keyword_columns, function(col) {
      #       grepl(kw, veevcluster_data[[col]], ignore.case = TRUE)
      #     }))
      #     veevcluster_data$match_color[matches] <- kw
      #   }
      # }
      # 
      # 
      # # Set color palette
      # keyword_colors <- setNames(rainbow(length(unique(veevcluster_data$match_color))), unique(veevcluster_data$match_color))
      # color_palette <- c("none" = "gray", keyword_colors)
      
      ###==== end unncomment later
      
      
      ##Chheck
      ###Label changesbased on the cluster resolu
      color_col <- switch(
        input$cit_nw_patho_virus_alpha_resclus_option,
        "Virus-Alphavirus-Cl.1" = "llmlabelcl1",
        "Virus-Alphavirus-Cl.2" = "llmlabelcl2",
        "Virus-Alphavirus-Cl.5" = "llmlabelcl5",
        "Virus-Alphavirus-Cl.10" = "llmlabelcl10",
        "Virus-Alphavirus-Cl.20" = "llmlabelcl20",
        "llmlabelcl1"              # default fallback
      )
      
      # veevp<- ggplot(veevcluster_data, aes(x =x, y=y,label = title, color = llmlabelcl1))+
      veevp<- ggplot(veevcluster_data, aes(x =x, y=y,label = title, color = .data[[color_col]]))+
        geom_point(size = 0.2)+
      # veevp <- ggplot(veevcluster_data, aes(x = x, y = y , label = title)) +
      #   geom_point(aes(color = veevcluster_data$cl1,size = (sqrt(veevcluster_data$Ncits)/3+1)), alpha = 0.7) +
      #   guides(size = FALSE)+
      #   
      #   scale_color_manual(values = color_palette, guide = guide_legend(title = "Keywords Used")
      #   ) +
      #   
        
        
        labs(title = paste("Cluster:", input$cit_nw_patho_virus_alpha_resclus_option), x = "Publication Year", y = "") +
        theme(plot.title = element_text(color = "#2167d9", size = 16, face = "bold", hjust = 0.5))
      
      output$cit_nw_resclus_veev_plot_for_cluster <-renderUI({
        
        req(veevcluster_data, veevp)
        
        # plotly_obj <- plotly::ggplotly(p, tooltip = c("pmid", "title"), source = "cit_nw_pmidplotsource")
        veev_plotly_obj <- plotly::ggplotly(veevp, tooltip = c("pmid", "title"), source = tolower(input$cit_nw_patho_virus_alpha_resclus_option), height = 1000
        ) 
        tagList(
          htmlwidgets::onRender(veev_plotly_obj, "
          function(el, x) {
            el.on('plotly_click', function(d) {
              if (d.points.length > 0) {
                var url = d.points[0].customdata;
                if (url) window.open(url, '_blank');
              }
            });
            
            var gd = document.getElementById(el.id);
        var traceNames = (x.data || []).map(tr => tr.name || null);
        if (window.Shiny) Shiny.setInputValue('trace_names', traceNames, {priority:'event'});
        gd._sel = new Set();

        function applyIsolation() {
          var n = (x.data || []).length;
          var vis = new Array(n).fill('legendonly');
          if (gd._sel.size === 0) {
            vis = new Array(n).fill(true); // reset: all visible
          } else {
            gd._sel.forEach(i => { if (i<n) vis[i] = true; });
          }
          Plotly.restyle(gd, {'visible': vis});
          if (window.Shiny) {
            var names = Array.from(gd._sel).map(i => traceNames[i]).filter(Boolean);
            Shiny.setInputValue('legend_selected', names, {priority:'event'});
          }
        }

        gd.on('plotly_legendclick', function(e) {
          var i = e.curveNumber;
          if (gd._sel.has(i)) gd._sel.delete(i); else gd._sel.add(i);
          applyIsolation();
          return false; // cancel default
        });

        gd.on('plotly_legenddoubleclick', function(e) {
          gd._sel.clear();
          applyIsolation();
          return false;
        });
          }
        "),
          tags$p(
            "Note: Keywords are matched against the abstract, title, and PMID fields.
          If multiple keywords match, the most recent keyword overrides earlier ones for coloring.",
            style = "text-align: left; font-style: italic; color: #555; margin-top: 12px;"
          )
        )
      })
      
      
      selected_topics <- reactive({
        sel <- input$legend_selected
        print(sel)
        if (is.null(sel) || !length(sel)) character(0) else sel
        
      })
      
      
      # ---- helper to extract the label column ----
      resolve_label_col <- function(res_txt,
                                    allowed = c("1","2","5","10","20"),
                                    default = "1") {
        n <- sub(".*Cl\\.(\\d+).*", "\\1", res_txt)
        if (!n %in% allowed) n <- default
        paste0("llmlabelcl", n)
      }
      
      ###End: Developing a helper function to use right variable 
      label_col <- reactive({
        resolve_label_col(input$cit_nw_patho_virus_alpha_resclus_option)
      })
      
      output$subPlot <- renderPlotly({
        kind <- input$sub_kind
        sel  <- selected_topics()
        
        print(head(paste0("Selected topic:",sel)))
        
        if (!length(sel)) {
          # empty state
          p0 <- plot_ly()
          p0 <- plotly::layout(
            p0,
            title = "Select one or more legend groups above to populate this sub-plot",
            xaxis = list(visible = FALSE),
            yaxis = list(visible = FALSE),
            annotations = list(
              list(
                x = 0.5, y = 0.5, xref = "paper", yref = "paper",
                text = "Tip: click legend items like 'cancer' and 'genome'",
                showarrow = FALSE
              )
            )
          )
          return(p0)
        }
        
        req(veevresinfo)
          # df<- veevresinfo$matching_veevclusters[[1]]
        df<- veevcluster_data
          req(NROW(df) > 0)
          # print(df)
          # d <- df %>% dplyr::filter(llmlabelcl1 %in% sel)
          
          # >>> NEW: choose the label column from veevresinfo <<<
          # label_col <- label_col_from_res(veevresinfo)
          # print(label_col)
          # d <- df[df[[label_col]] %in% sel, , drop = FALSE]
          lc <- label_col()
          print(paste0("lc value", lc))
          d <- df[df[[lc]] %in% sel, , drop = FALSE]
        
        # d <- df[df$llmlabelcl1 %in% sel, , drop = FALSE]
        # print(head(d, n=2))
        
        # we'll reuse these axis settings to hide all axis paraphernalia in the sub-plot
        clean_axes <- list(
          xaxis = list(title = NULL, showticklabels = FALSE, zeroline = FALSE,showline = FALSE),
          yaxis = list(title = NULL, showticklabels = FALSE, zeroline = FALSE,showline = FALSE)
        )
        if (kind == "res_2") {
              plot_ly(d, x = ~x, y = ~y, color = ~llmlabelcl2,
                      type = "scatter", mode = "markers",
                      text = ~title,              # <-- column in your df with titles
                      hoverinfo = "text",
                      marker = list(size = 8, opacity = 0.85)
                      ) |>
                layout(title =paste(sel, collapse = ", "),
                       xaxis=clean_axes$xaxis, yaxis=clean_axes$yaxis
                       )
                
            }else if(kind == "tres_1"){
              plot_ly(d, x = ~Nyear, y = ~y1, color = ~llmlabelcl1,
                      type = "scatter", mode = "markers",
                      text = ~title,              # <-- column in your df with titles
                      hoverinfo = "text",
                      marker = list(size = 8, opacity = 0.85)
              ) |>
                layout(title =paste(sel, collapse = ", "),
                       xaxis=clean_axes$xaxis, yaxis=clean_axes$yaxis
                )
            }else if(kind == "tres_2"){
              plot_ly(d, x = ~Nyear, y = ~y2, color = ~llmlabelcl2,
                      type = "scatter", mode = "markers",
                      text = ~title,              # <-- column in your df with titles
                      hoverinfo = "text",
                      marker = list(size = 8, opacity = 0.85)
              ) |>
                layout(title =paste(sel, collapse = ", "),
                       xaxis=clean_axes$xaxis, yaxis=clean_axes$yaxis
                )
            }else if(kind == "tres_5"){
              plot_ly(d, x = ~Nyear, y = ~y5, color = ~llmlabelcl5,
                      type = "scatter", mode = "markers",
                      text = ~title,              # <-- column in your df with titles
                      hoverinfo = "text",
                      marker = list(size = 8, opacity = 0.85)
              ) |>
                layout(title =paste(sel, collapse = ", "),
                       xaxis=clean_axes$xaxis, yaxis=clean_axes$yaxis
                )
            }else if(kind == "tres_10"){
              plot_ly(d, x = ~Nyear, y = ~y10, color = ~llmlabelcl10,
                      type = "scatter", mode = "markers",
                      text = ~title,              # <-- column in your df with titles
                      hoverinfo = "text",
                      marker = list(size = 8, opacity = 0.85)
              ) |>
                layout(title =paste(sel, collapse = ", "),
                       xaxis=clean_axes$xaxis, yaxis=clean_axes$yaxis
                )
            }else if(kind == "tres_20"){
              plot_ly(d, x = ~Nyear, y = ~y20, color = ~llmlabelcl20,
                      type = "scatter", mode = "markers",
                      text = ~title,              # <-- column in your df with titles
                      hoverinfo = "text",
                      marker = list(size = 8, opacity = 0.85)
              ) |>
                layout(title =paste(sel, collapse = ", "),
                       xaxis=clean_axes$xaxis, yaxis=clean_axes$yaxis
                )
            }else if(kind == "res_5"){
              plot_ly(d, x = ~x, y = ~y, color = ~llmlabelcl5,
                      type = "scatter", mode = "markers",
                      text = ~title,              # <-- column in your df with titles
                      hoverinfo = "text",
                      marker = list(size = 8, opacity = 0.85)
              ) |>
                layout(title =paste(sel, collapse = ", "),
                       xaxis=clean_axes$xaxis, yaxis=clean_axes$yaxis
                )
            }else if(kind == "res_10"){
              plot_ly(d, x = ~x, y = ~y, color = ~llmlabelcl10,
                      type = "scatter", mode = "markers",
                      text = ~title,              # <-- column in your df with titles
                      hoverinfo = "text",
                      marker = list(size = 8, opacity = 0.85)
              ) |>
                layout(title =paste(sel, collapse = ", "),
                       xaxis=clean_axes$xaxis, yaxis=clean_axes$yaxis
                )
            }
            else {
              plot_ly(d, x = ~x, y = ~y, color = ~llmlabelcl20,
                      type = "scatter", mode = "markers",
                      text = ~title,              # <-- column in your df with titles
                      hoverinfo = "text",
                      marker = list(size = 8, opacity = 0.85)
            ) |>
                layout(title =paste(sel, collapse = ", "),
                       xaxis=clean_axes$xaxis, yaxis=clean_axes$yaxis
                )


            }
        
      })
     output$subTable <- DT::renderDT({
        kind <- input$sub_kind
        sel  <- selected_topics()
        #   
        
        # Only show the table for histogram sub-plots
        if (!length(sel) || !(kind %in% c("res_2", "res_5","res_10","res_20"))) {
          return(
            datatable(data.frame(), options = list(dom = 't'), rownames = FALSE)
          )
        }
        
        # Map each sub-plot kind to the label column you want to use
        label_for_kind <- function(kind) {
          # CHANGE these to your real column names:
          # e.g., "llmlabelcl1", "llmlabelcl2", "manual_labels", etc.
          switch(kind,
                 "res_2"  = "llmlabelcl2",     # <- sample app uses "topic"; replace as needed
                 "res_5"  = "llmlabelcl5",
                 "res_10"   = "llmlabelcl10",
                 "res_20" = "llmlabelcl20"
                                    # default/fallback
          )
        }
        
        
        label_col <- label_for_kind(kind)
        
        
        # # filter to highlighted topics
        # d <- df %>% filter(topic %in% sel)
        
        
          req(veevresinfo)
          df<- veevresinfo$matching_veevclusters[[1]]
          req(NROW(df) > 0)
          # print(df)
          # d <- df %>% dplyr::filter(llmlabelcl1 %in% sel)

          d <- df[df$llmlabelcl1 %in% sel, , drop = FALSE]
          
          d$label_current <- d[[label_col]]
        
        # ---- build the raw table of papers ----
        # keep only relevant columns
        tblres <- d %>%
          select(
            pmid,      # in your real data this might be a PMID col
            title,              # paper title
            year,               # year
            Ncits,              # citation count
            abstract,   # <-- placeholder! replace with your actual abstract column
            `LLM generated labels` = label_current # LLM labels
          )
        
        # rename columns nicely
        data.table::setDT(tblres)
        data.table::setnames(
          tblres,
          c("pmid", "title", "year", "Ncits", "abstract", "LLM generated labels"),
          c("PMID", "Title", "Year", "#Citations", "Abstract", "LLM generated labels")
        )
        
        # render
        datatable(
          tblres,
          rownames = FALSE,
          escape = FALSE,
          extensions = c("Buttons", "Responsive"),
          options   = list(pageLength = 15, autoWidth = TRUE, order = list(list(3, "desc")),
                           columnDefs = list(
                             list(visible = FALSE, targets = 4),  # Abstract
                             # list(visible = FALSE, targets = 5),  # Authors
                             # list(visible = FALSE, targets = 6),   # Unique ID
                             list(className = 'dt-left', targets = 1)
                             
                           ))
          # options = list(
          #   dom = '<"top"Bf>rt<"bottomlip"lip>',
          #   buttons = list(list(extend = "collection", text = "Export", buttons = c("csv","excel"))),
          #   pageLength = 10
          # )
        )
      })
      
      
      
      
      
      ####Select event for overall ebola plot, making the box select on the plot reactive to the table
      cit_nw_veevcluster_table_selected_event <- reactive({
        # event_data("plotly_selected", source = "cit_nw_pmidplotsource")
        event_data("plotly_selected", source = tolower(input$cit_nw_patho_virus_alpha_resclus_option))
      })
      
      
      # ======= NEW: Data table ====== #
      output$cit_nw_resclus_veev_table_for_cluster <- DT::renderDT({
        req(veevcluster_data)
        # veevclusterdt<- veevcluster_data()
        selected_veev<- cit_nw_veevcluster_table_selected_event()
        print(paste("Check", selected_veev))
        
        veev_newy_col <- switch(
          input$cit_nw_patho_virus_alpha_resclus_option,
          "Virus-Alphavirus-Cl.1" = "y1",
          "Virus-Alphavirus-Cl.2" = "y2",
          "Virus-Alphavirus-Cl.5" = "y5",
          "Virus-Alphavirus-Cl.10" = "y10",
          "Virus-Alphavirus-Cl.20" = "y20",
          "y1"              # default fallback
        )
        
        veev_llmlabel_col <- switch(
          input$cit_nw_patho_virus_alpha_resclus_option,
          "Virus-Alphavirus-Cl.1" = "llmlabelcl1",
          "Virus-Alphavirus-Cl.2" = "llmlabelcl2",
          "Virus-Alphavirus-Cl.5" = "llmlabelcl5",
          "Virus-Alphavirus-Cl.10" = "llmlabelcl10",
          "Virus-Alphavirus-Cl.20" = "llmlabelcl20",
          "llmlabelcl1"              # default fallback
        )
       
        # print(head(veev_newy_col))
        
        selected_veev_points <- if (!is.null(selected_veev) && !is.null(selected_veev$x) && !is.null(selected_veev$y)) {
          veevcluster_data[veevcluster_data$x %in% selected_veev$x & veevcluster_data$y %in% selected_veev$y, ]
        } else {
          veevcluster_data
        }
        
        # print(nrow(veevcluster_data))
        # print(head(selected_veev_points))
        
        tbl_cols <- c("pmid", "title", "year", "Ncits", "abstract", veev_llmlabel_col)
        # tbl_new_names <- c("pmid", "title", "year", "Ncits", "abstract","llm_label")
        # 
        # tbl <- setnames(
        #   selected_veev_points[, ..tbl_cols],
        #   old = tbl_cols,
        #   new = tbl_new_names
        # )
        tbl <- selected_veev_points[, ..tbl_cols]
        
        # tbl <- selected_veev_points[, c("pmid", "title", "Nyear", "Ncits", veev_llmlabel_col)]
        # linkify PMID to PubMed
        tbl$pmid <- sprintf(
          '<a href="https://pubmed.ncbi.nlm.nih.gov/%s" target="_blank">%s</a>',
          tbl$pmid, tbl$pmid
        )
        
        setnames(tbl, c("pmid", "title", "year", "Ncits", "abstract",veev_llmlabel_col),
                 c("PMID", "Title", "Year", "#Citations", "Abstract", "LLM generated labels"))
        
        # print(head(tbl, n=2))
        DT::datatable(
          tbl,
          escape    = FALSE,
          rownames  = FALSE,
          filter    = "top",
          options   = list(pageLength = 15, autoWidth = TRUE, order = list(list(3, "desc")),
                           columnDefs = list(
                             list(visible = FALSE, targets = 4),  # Abstract
                             # list(visible = FALSE, targets = 5),  # Authors
                             # list(visible = FALSE, targets = 6),   # Unique ID
                             list(className = 'dt-left', targets = 1)
                             
                           )),
          selection = 'single',
          callback = JS(
                           "var node = table.table().node();",
                           "$(node).off('click.dt').on('click.dt', 'tbody td', function(){",
                           "  var info = table.cell(this).index();",
                           "  var rowData = table.row(info.row).data();",
                           "  var clickedCol = info.column;",            
                             "  var abstractInfo = rowData[4];", 
                           "  Shiny.setInputValue('selectedveev_row', {col: clickedCol, abstract: abstractInfo}, {priority:'event'});",
                           "});")
          # callback = JS(
          #   "table.on('click', 'td', function() {",
          #   "  var cell = table.cell(this);",
          #   "  var rowIndex = cell.index().row;",
          #   "  var data = table.row(rowIndex).data();",
          #   "  var abstractInfo = data[4];",
          #   "  Shiny.setInputValue('selectedveev_row', abstractInfo, {priority: 'event'});",
          #   "});"
          # )
        )
        
        
        
        
      })
      
      
      #Click Event

      observeEvent(input$selectedveev_row, ignoreInit = TRUE, {
      req(input$selectedveev_row)
      if (input$selectedveev_row$col == 1) {  # change 0 to your target column index
        showModal(modalDialog(
          title = "Abstract:",
          div(style = "white-space: pre-wrap;", input$selectedveev_row$abstract),
          easyClose = TRUE,
          footer = NULL
        ))
      }
    })



      # observeEvent(input$selectedveev_row, {
      #   req(input$selectedveev_row)
      #   showModal(modalDialog(
      #     title = "Abstract::",
      #     div(style = "white-space: pre-wrap;", input$selectedveev_row),
      #     easyClose = TRUE,
      #     footer = NULL
      #   ))
      # })
      
      # cols      <- c("pmid", "title", "Nyear", "Ncits", v_llmlabel_col)
      # new_names <- c("pmid", "title", "Nyear", "Ncits", "llm_label")
      # 
      # tbl <- setnames(
      #   selected_veev_points[, ..cols],
      #   old = cols,
      #   new = new_names
      # )
      
      
      
    })
    
    #========== End:Add veev resolution clusters ============#
    
    
    observeEvent(input$cit_nw_vp_clus_btn, {
      
      cit_nw_sub_clus_rv("sub_pathogen")
      output$cit_nw_patho_tab <- renderUI({ NULL })
      output$cit_nw_cop_tab <- renderUI({ NULL })
      output$cit_nw_hms_tab <- renderUI({ NULL })
      output$cit_nw_mcm_tab <- renderUI({ NULL })
      
      # output$cit_nw_tab <- renderUI({ NULL })
      output$cit_nw_vp_tab <- renderUI({
        # req(showSubs())
        tagList(
          div(class = "cit-nw-subgrid",
              actionButton("cit_nw_adv_clus_btn", "Adenovirus", class = "cit-nw-sub-btn"),
              # actionButton("cit_nw_bacteria_clus_btn", "Bacteria", class = "cit-nw-sub-btn"),
              # actionButton("cit_nw_ref_clus_btn", "Reference", class = "cit-nw-sub-btn"),
              
          )
          
        )
      })
    })
    
    observeEvent(input$cit_nw_ab_clus_btn,{
      
      output$cit_nw_ab_clus_ui<- renderUI({
        tagList(
          br(), br(),
          div(class = "cit-nw-search-container",
              actionButton("cit_nw_help", "?", class = "cit-nw-help-button"),
              selectInput("cit_nw_ab_sg_option", "SG of interest:", choices = cit_nw_ab_sg_cluster_choices),
              
              textInput("cit_nw_sg_keywords", "Enter Keywords (comma-separated) to visualize the cluster plot :", placeholder = "e.g. interleukin, igg, igm, 40178639"),
              actionButton("cit_nw_sg_search_btn", "Search"),
              
          ),
          br(), br(),
          div(
            class = "cit-nw-main-panel-container",
              uiOutput("cit_nw_sg_plot_for_cluster"),
              br(), br(),br(),
            DT::DTOutput("cit_nw_sg_table_for_cluster")
             
              # DT::dataTableOutput("cit_nw_sg_table_for_cluster"),
              ),
          br(), br()
        )
      })
      
    })

    
    
    
    })
  
  
  
  
  
  
  
  
  
  ###### CiteNetClusters: Subgraph Result btn #####
  #Adding sg function #
  cit_nw_sg_search_result <- eventReactive(input$cit_nw_sg_search_btn, {

    req(cit_nw_ab_sg_label_react())
    cit_nw_ab_sglabel_data <- cit_nw_ab_sg_label_react()
    req(input$cit_nw_ab_sg_option)
    res_cl<- input$cit_nw_ab_sg_option
    print(paste("Resolution cluster:",res_cl))
    matching_sgclusters<- cit_nw_ab_sglabel_data[res_cl[res_cl %in% names(cit_nw_ab_sglabel_data)]]
    list(
      res_cl = res_cl,
      matching_sgclusters = matching_sgclusters
    )})
  ##### End: CiteNetClusters: Subgraph Result btn #####
  
  ###### CiteNetClusters: Subgraph Result ####
  observeEvent(cit_nw_sg_search_result(), {
    
    resinfo<- cit_nw_sg_search_result()
    req(resinfo$res_cl)
    output$cit_nw_sg_plot_for_cluster<- renderUI(NULL)
    sgcluster_data<- resinfo$matching_sgclusters[[1]]
    #======= SG Plot ======#
    print(paste("This is res_clus",resinfo$res_cl))
    sgcluster_data$Nyear <- as.numeric(sgcluster_data$Nyear)
      # print(head(sgcluster_data, n=2))
    keywords <- trimws(unlist(strsplit(input$cit_nw_sg_keywords, ",")))

      # Ensure match_color is a factor with keyword order
      sgcluster_data$match_color <- factor(sgcluster_data$match_color, levels = keywords)
      cit_nw_keyword_columns <- c("abstract", "title", "pmid")

      # Initialize match_color
      sgcluster_data$match_color <- "none"

      for (kw in keywords) {
        if (nzchar(kw)) {
          matches <- Reduce(`|`, lapply(cit_nw_keyword_columns, function(col) {
            grepl(kw, sgcluster_data[[col]], ignore.case = TRUE)
          }))
          sgcluster_data$match_color[matches] <- kw
        }
      }


      # Set color palette
      keyword_colors <- setNames(rainbow(length(unique(sgcluster_data$match_color))), unique(sgcluster_data$match_color))
      color_palette <- c("none" = "gray", keyword_colors)

      sgp <- ggplot(sgcluster_data, aes(x = xSG, y = ySG , label = title)) +
        geom_point(aes(color = match_color,size = (sqrt(sgcluster_data$Ncits)/3+1)), alpha = 0.7) +
        guides(size = FALSE)+

        scale_color_manual(values = color_palette, guide = guide_legend(title = "Keywords Used")
        ) +



        labs(title = paste("Cluster:", input$cit_nw_ab_sg_option), x = "Publication Year", y = "") +
        theme(plot.title = element_text(color = "#2167d9", size = 16, face = "bold", hjust = 0.5))

      output$cit_nw_sg_plot_for_cluster <-renderUI({
        
        req(sgcluster_data, sgp)
        
        # plotly_obj <- plotly::ggplotly(p, tooltip = c("pmid", "title"), source = "cit_nw_pmidplotsource")
        sg_plotly_obj <- plotly::ggplotly(sgp, tooltip = c("pmid", "title"), height = 1000, source = "cit_nw_sg_plot"
                                          ) 
        tagList(
          htmlwidgets::onRender(sg_plotly_obj, "
          function(el, x) {
            el.on('plotly_click', function(d) {
              if (d.points.length > 0) {
                var url = d.points[0].customdata;
                if (url) window.open(url, '_blank');
              }
            });
          }
        "),
          # tags$p(
          #   "Note: Keywords are matched against the abstract, title, and PMID fields.
          # If multiple keywords match, the most recent keyword overrides earlier ones for coloring.",
          #   style = "text-align: left; font-style: italic; color: #555; margin-top: 12px;"
          # )
        )
      })
      
      # ======= NEW: Data table ====== #
      output$cit_nw_sg_table_for_cluster <- DT::renderDT({
        req(sgcluster_data)

        
        tbl <- sgcluster_data[, c("pmid", "title", "Nyear", "Ncits", "match_color")]
        # linkify PMID to PubMed
        tbl$pmid <- sprintf(
          '<a href="https://pubmed.ncbi.nlm.nih.gov/%s" target="_blank">%s</a>',
          tbl$pmid, tbl$pmid
        )
        DT::datatable(
          tbl,
          escape    = FALSE,
          rownames  = FALSE,
          filter    = "top",
          options   = list(pageLength = 15, autoWidth = TRUE, order = list(list(3, "desc"))),
          callback = JS(
                  "table.on('click', 'td', function() {",
                  "  var cell = table.cell(this);",
                  "  var rowIndex = cell.index().row;",
                  "  var data = table.row(rowIndex).data();",
                  "  var abstractInfo = data[4];",
                  "  Shiny.setInputValue('selected_row', abstractInfo, {priority: 'event'});",
                  "});"
                )
        )
      })
    
  })
  ###### End: CiteNetClusters: Subgraph Result ####
  
  #####======= End: ***CiteNet CLUSTERS*** =======#####
  #----------------------------------------------------------------------------#
  
  #----------------------------------------------------------------------------#
  ######==== ***PMID CLUSTER SEARCH*** =====######
  

  
  ##### === UI Panel PMID Cluster Search Display on Button Click === #####
  observeEvent(input$cit_nw_show_pmid_cluster, {
    output$cit_nw_tab <- renderUI({ NULL })
    output$cit_nw_cluster_tab <- renderUI({ NULL })
    output$cit_nw_timeline_tab<- renderUI({ NULL })
    output$cit_nw_pmid_tab <- renderUI({
      tagList(

        br(), br(),
        tags$h4(
          "Overview",
          style = "text-align: center; font-weight: bold; font-size:30px;color:#9a9a9a;"
        ),
        
        br(), br(),
        
        div(class = "cit-nw-search-container",

            
                      selectInput("cit_nw_overview_nw_option", "Network:", choices = cit_nw_subject_choices, selected = cit_nw_default_choice),
                      actionButton("cit_nw_overview_nw_search_btn", "Search"),
                      # uiOutput("patho_overview_table_title"),
                      # uiOutput("patho_overview_table_sub_title"),
                      # br(),br(),
                      # DTOutput("patho_overview_table", width = "100%"),  #overview table for selected pathogen
                      # #uiOutput("patho_sum_table_legend_lanl"),
                      # br(), br(),
                      # fluidRow(
                      #   column( 6, offset = 0, uiOutput("patho_overview_table_display_choice_CBG"))
                      # ),
                      #
                      # br(), br(),
                      # uiOutput("patho_overview_tbl_refs_CP"),


                      # actionButton("cit_nw_keyword_search_help", "?", class = "cit-nw-help-button"),
                      # textInput("cit_nw_pmid_input", "Enter PMID", value = cit_nw_pmid_from_url()),
                      # # debug the app communication
                      # # verbatimTextOutput("debug_query"),
                      # actionButton("cit_nw_search_btn", "Search"),
                      # uiOutput("cit_nw_pmid_search_message"),
                      # shinyjs::hidden(uiOutput("cit_nw_pmid_pathogencluster_select_dd")),
                      # shinyjs::hidden(uiOutput("cit_nw_nt_llm_reasoning")),
                      # # shinyjs::hidden(uiOutput("cit_nw_llm_kw_message")),
                      # shinyjs::hidden(actionButton("cit_nw_pmid_bot_search_keywords_btn", "Plot the timeline"))
                      # ## To debug the reactive values
                      # # verbatimTextOutput("debug_reactive_vals")
                  ),
                  br(), br(),
                  div(class = "cit-nw-main-panel-container",
                      DTOutput("cit_nw_overview_table"),
                  ),
                  br(), br(),




        br(), br(),
        div(class = "cit-nw-search-container",
            actionButton("cit_nw_pmid_search_help", "?", class = "cit-nw-help-button"),
            textInput("cit_nw_pmid_input", "Enter PMID", value = cit_nw_pmid_from_url()),
            # debug the app communication
            # verbatimTextOutput("debug_query"),
            actionButton("cit_nw_search_btn", "Search"),
            uiOutput("cit_nw_pmid_search_message"),
            shinyjs::hidden(uiOutput("cit_nw_pmid_pathogencluster_select_dd")),
            shinyjs::hidden(uiOutput("cit_nw_print_lower_res")),
            shinyjs::hidden(uiOutput("cit_nw_nt_llm_reasoning")),
            shinyjs::hidden(actionButton("cit_nw_pmid_bot_search_keywords_btn", "Plot the timeline"))
            
            ## To debug the reactive values
            # verbatimTextOutput("debug_reactive_vals")
        ),
        br(), br(),
        div(class = "cit-nw-main-panel-container",
            br(),
            shinyjs::hidden(uiOutput("cit_nw_rd_nt_usr_pov_tmplot_for_cluster")),
            
        ),
        br(), br()
      )
    })
  })
  
  
  
  ##### === End: UI Panel PMID Cluster Search Display on Button Click ===#####
  
  ######### === Auto populate from another app to the search text input Logic === #########
  # Parse pmid from URL on load
  
  # Set to TRUE to enable debug output
  cit_nw_search_btn_reactive_debug_mode <- FALSE
  # auto_clicked <- reactiveVal(FALSE)
  # 
  # observe({
  #   query <- parseQueryString(session$clientData$url_search)
  #   req(!isTRUE(auto_clicked()))
  #   session$onFlushed(function() {
  #     if (!is.null(query$pmid)) {
  #       auto_clicked(TRUE)
  #       shinyjs::click("cit_nw_search_btn")
  #     }
  #   }, once = TRUE)
  # })
  
  auto_clicked <- reactiveVal(FALSE)
  observe({
    # Only run once
    if (isTRUE(auto_clicked())) return()
    
    query <- parseQueryString(session$clientData$url_search)
    output$debug_query <- renderPrint(query)
    
    if (!is.null(query$pmid) && nzchar(query$pmid)) {
      # Save PMID to reactiveVal
      cit_nw_pmid_from_url(query$pmid)
      
      # Update input box
      updateTextInput(session, "cit_nw_pmid_input", value = query$pmid)
      
      # Mark that we’ve done it once
      auto_clicked(TRUE)
      
      # Delay slightly to ensure UI/input ready, then auto-click
      shinyjs::delay(100, shinyjs::click("cit_nw_search_btn"))
    }
  })
  
  ######### === End: Auto populate from another app to the search text input Logic === ########
  
  ##### UI Panel - (PMID Cluster Search)--PMID Search Result-"PMID Search btn"(Trigger variable calculations) #####

  # Reactive expression that triggers when the Search button(cit_nw_search_btn"Search") is clicked
  cit_nw_search_result <- eventReactive(input$cit_nw_search_btn, {
    req(input$cit_nw_pmid_input) # The user must have entered a PMID
    ui_pmid <- trimws(input$cit_nw_pmid_input)
    
    cit_nw_cluster_label_data<- copy(all_data_rv())
    if (cit_nw_search_btn_reactive_debug_mode) {
      message("=== [DEBUG] Search Triggered ===")
      message("Entered PMID: ", ui_pmid)
      message("Label data contains ", length(cit_nw_cluster_label_data), " clusters.")
    }
    # Extract the title(s) matching the given PMID from the dataset
    cit_nw_title_pmid_matches <- cit_nw_cluster_label_data[["title"]][cit_nw_cluster_label_data[["pmid"]] == ui_pmid]
    
    if (cit_nw_search_btn_reactive_debug_mode) {
      if (length(cit_nw_title_pmid_matches) > 0) {
        message("Title matches found: ", paste(unique(cit_nw_title_pmid_matches), collapse = " | "))
      } else {
        message("No title matches found for PMID: ", ui_pmid)
      }
    }

    # Determine if a valid title was found (i.e., the PMID exists)
    cit_nw_ui_title_found <- length(na.omit(cit_nw_title_pmid_matches)) > 0
    # Use the first non-NA title if found, otherwise set to fallback
    cit_nw_ui_title_display <- ifelse(all(is.na(cit_nw_title_pmid_matches)), "No title available", na.omit(cit_nw_title_pmid_matches)[1])
    # Construct the PubMed URL based on the entered PMID
    cit_nw_ui_url <- paste0("https://pubmed.ncbi.nlm.nih.gov/", ui_pmid)

   # Return a structured list of results
    list(
      cit_nw_ui_title_found = cit_nw_ui_title_found,      # Was the PMID found in the data?
      ui_pmid = ui_pmid,  # Entered PMID
      cit_nw_ui_title_display = cit_nw_ui_title_display,   # Resolved title
      cit_nw_ui_url = cit_nw_ui_url,  # PubMed link
      valid = !is.na(ui_pmid) && length(cit_nw_title_pmid_matches) > 0 # Validity flag for use in UI gating
    )
  },
  ignoreInit = TRUE)

  # observeEvent(TRUE, once = TRUE, {
  #   query <- parseQueryString(session$clientData$url_search)
  #   pmid <- query$pmid
  #   if (!is.null(pmid) && nzchar(pmid)) {
  #     updateTextInput(session, "cit_nw_pmid_input", value = pmid)
  #
  #     session$onFlushed(function() {
  #       if (!isTRUE(did_click())) {
  #         did_click(TRUE)
  #         shinyjs::click("cit_nw_search_btn")   # <-- no input$ reads here
  #       }
  #     }, once = TRUE)
  #   }
  # })
  ##### End: UI Panel - (PMID Cluster Search)--PMID Search Result-"PMID Search btn"(Trigger variable calculations) #####

  ##### UI Panel - (PMID Cluster Search)--PMID Search Result-"PMID Search btn"(Debug message) ===#####
  cit_nw_search_btn_result_debug_mode<- FALSE
  # Observe changes in the search result when a user clicks the Search button
  observeEvent(cit_nw_search_result(), {
    info <- cit_nw_search_result()  # Retrieve the latest search result
    #Clear the plot and table immediately after each new user input(PMID)
    # output$cit_nw_llm_table_for_cluster <- renderDT(NULL)
    
    output$cit_nw_rd_nt_usr_pov_tmplot_for_cluster<-renderUI(NULL)
    # Debug mode #
    if (cit_nw_search_btn_result_debug_mode) {
      message("=== [DEBUG] Citation Network Processing PMID Search Result ===")
      message("PMID: ", info$ui_pmid)
      message("Title found: ", info$cit_nw_ui_title_display)
      message("PMID found in data?: ", info$cit_nw_ui_title_found)
    }
    # Case: No valid match for the entered PMID
    if (!info$cit_nw_ui_title_found) {
      message("[DEBUG] No title/cluster found for PMID: ", info$ui_pmid, " — resetting UI.")
      output$cit_nw_pmid_plot_for_cluster <- renderUI(NULL)
      output$cit_nw_pmid_table_for_cluster <- renderDT(NULL)
      # # Clear the dropdown choices
      # output$cit_nw_pmid_pathogencluster_select_dd<- renderUI(NULL)
      #updateSelectInput(session, "cit_nw_pmid_pathogencluster_select_dd", choices = character(0))
      # Reset state and disable keyword plotting
      cit_nw_valid_pmid(FALSE)
      cit_nw_matching_pathogencluster(NULL)
      
      shinyjs::hide("cit_nw_pmid_pathogencluster_select_dd")
      shinyjs::disable("cit_nw_pmid_pathogencluster_select_dd")
      shinyjs::hide("cit_nw_print_lower_res")
      #shinyjs::hidden("skills")
      shinyjs::hide("cit_nw_pmid_bot_search_keywords_btn")
      
      shinyjs::hide("cit_nw_nt_llm_reasoning")
      # shinyjs::hide("cit_nw_llm_kw_message")
      
      # shinyjs::disable("cit_nw_pmid_pathogencluster_select_dd")
      
      
      shinyjs::hide("cit_nw_rd_nt_usr_pov_tmplot_for_cluster")
      
      
      # shinyjs::disable("cit_nw_pmid_bot_search_keywords_btn")
      
    } else {
      #Case: Valid PMID with matching clusters and title
      message("[DEBUG] Valid PMID found. Updating UI.")
      # Mark as valid and save matching clusters
      cit_nw_valid_pmid(TRUE)
      
      # shinyjs::enable("cit_nw_pmid_pathogencluster_select_dd")
      # shinyjs::show("cit_nw_pmid_plot_for_cluster")
      # shinyjs::show("cit_nw_pmid_table_for_cluster")
      shinyjs::show("cit_nw_pmid_pathogencluster_select_dd")
      shinyjs::show("cit_nw_print_lower_res")
      shinyjs::show("cit_nw_nt_llm_reasoning")
      #shinyjs::show("skills")
      # shinyjs::show("cit_nw_llm_kw_message")
      shinyjs::show("cit_nw_pmid_bot_search_keywords_btn")
      shinyjs::show("cit_nw_rd_nt_usr_pov_tmplot_for_cluster")

      #Update the dropdown with new cluster options
      # updateSelectInput(
      #   session,
      #   inputId = "cit_nw_pmid_pathogencluster_select_dd",
      #   choices = info$matching_clusters,
      #   selected = info$matching_clusters[1]  # Auto-select the first match
      # )
      # Enable the keyword plotting button
      # shinyjs::enable("cit_nw_pmid_bot_search_keywords_btn")
      # shinyjs::show("cit_nw_pmid_bot_search_keywords_btn")
      
    }
  })
  ##### End: UI Panel - (PMID Cluster Search)--PMID Search Result-"PMID Search btn"(Debug message) ===#####


  # Helper: strip the PoV prefix ("Cut CoP-...-Cl.X to ...-Cl.X")
  get_selected_rescluster <- function(x) sub("^[^-]+-", "", x)

  # ---- 1) Search message ----
  output$cit_nw_pmid_search_message <- renderUI({
    req(cit_nw_search_result)      # function exists
    info <- cit_nw_search_result() # call it
    req(!is.null(info))

    if (isTRUE(info$cit_nw_ui_title_found)) {
      HTML(paste0(
        "Data found for PMID: <a href='", info$cit_nw_ui_url, "' target='_blank'>", info$ui_pmid, "</a><br>",
        "Title: ", info$cit_nw_ui_title_display
      ))
    } else {
      HTML(paste0(
        "PMID not found in the citation network dataset.<br>PubMed: <a href='",
        info$cit_nw_ui_url, "' target='_blank'>", info$ui_pmid, "</a>"
      ))
    }
  })


  ##### End:UI Panel - (PMID Cluster Search)--Render the message box after a PMID search: PMID present or not #####

  ##### UI Panel - (PMID Cluster Search)--Render the message box after a PMID search:LLM label, justification #####
  
  cit_nw_usr_filtered_pmid_cluster<- reactive({
    req(cit_nw_search_result)      # function exists
    info <- cit_nw_search_result()
    cit_nw_usr_pmid_input<- info$ui_pmid
    # req(input$cit_nw_pmid_input)
    # chatbot_pmid<- cit_nw_usr_pmid_react()
    req(all_data_rv())
    ALL_DATA<-all_data_rv()
    dtin=ALL_DATA[ALL_DATA$pmid==cit_nw_usr_pmid_input,]
    dtin

  })
  
  ##### === UI Panel - (PMID Cluster Search)-- PMID found in (pov-cluster) dropdown === #####
  output$cit_nw_pmid_pathogencluster_select_dd <- renderUI({
    req(cit_nw_usr_filtered_pmid_cluster)
    cit_nw_pmid_rd_cdt<- cit_nw_usr_filtered_pmid_cluster()
    cit_nw_chatbot_dt_pmid<- cit_nw_pmid_rd_cdt
    choices <- unique(cit_nw_chatbot_dt_pmid$PoV_network_cluster)
    regex_network_name<- sub("^[^-]+-([^-]+)-.*$", "\\1", choices)
    
    
    noi_name <- setNames(choices, regex_network_name)
    #network <- sub("^[^-]+-([^-]+)-.*$", "\\1", selected_val)
    # selectInput("cit_nw_rd_nt_select_input","PMID found in Network:",choices  = noi_name,selectize = FALSE, selected = choices[1])
    # 
    
    selectInput(
      "cit_nw_usr_nt_select_input",
      "PMID found in Network:",
      choices  = noi_name,
      selectize = FALSE,
      selected = choices[1]
    )
  })
  ##### === End: UI Panel - (PMID Cluster Search)-- PMID found in (pov-cluster) dropdown === #####
  
  
  
  # ---- LLM keyword/justification message ----
  ## merged_pmidllm_data
  
  subject_usrpmid_data <- reactive({
    req(input$cit_nw_usr_nt_select_input)
    network_data<- sub("^[^-]+-([^-]+)-.*$", "\\1", input$cit_nw_usr_nt_select_input)
    print(paste0("Network_data:", network_data))
    load_subject_data(network_data)
  })
  
  merged_pmidllm_data <- reactive({
    dat <- subject_usrpmid_data()
    mdf <- dat$mdf
    shiny::req("pmid" %in% names(mdf))
    
    req(all_data_rv())
    ALL_DATA<-all_data_rv()
    # print(dat)
    req(input$cit_nw_usr_nt_select_input)
    network_data<- sub("^[^-]+-([^-]+)-.*$", "\\1", input$cit_nw_usr_nt_select_input)
    print(paste0("Network_data:", network_data))
    dtin=ALL_DATA[network==network_data,]
    mdf$pmid=as.numeric(mdf$pmid)
    # df=merge(dtin,mdf[,c('pmid','abstract','labelcl1','labelcl2','labelcl5','labelcl10','labelcl20',
    #                      'label1','label2','label5','label10','label20','url')],by="pmid",all.x=F,all.y=T)
    dtin_sub <- dtin[, .(pmid)]
    df=merge(dtin_sub,mdf[,c('pmid','network','Cl.20','Cl.10','Cl.5','Cl.2','Cl.1','title','abstract','year','journal',
                             'authors','Nyear','Ncits','Nrefs','x','y','full','x20','y20','x10','y10','x5','y5','x2','y2',
                             'x1','y1','PoV','labelcl1','labelcl2','labelcl5','labelcl10','labelcl20','label1','label2','label5',
                             'label10','label20','url')],by="pmid",all.x=F,all.y=T)
    an=cit_nw_llm_dt[network==network_data,]
    # an=llm_dt[network==input$subject,]
    df=merge(df,an[res=='Cl.1',c("network","cluster_id","label")],by.x=c("network","Cl.1"),by.y=c("network","cluster_id"),all.x=T, all.y=F)
    colnames(df)[dim(df)[2]]="llmlabelcl1"
    df=merge(df,an[res=='Cl.2',c("network","cluster_id","label")],by.x=c("network","Cl.2"),by.y=c("network","cluster_id"),all.x=T, all.y=F)
    colnames(df)[dim(df)[2]]="llmlabelcl2"
    df=merge(df,an[res=='Cl.5',c("network","cluster_id","label")],by.x=c("network","Cl.5"),by.y=c("network","cluster_id"),all.x=T, all.y=F)
    colnames(df)[dim(df)[2]]="llmlabelcl5"
    df=merge(df,an[res=='Cl.10',c("network","cluster_id","label")],by.x=c("network","Cl.10"),by.y=c("network","cluster_id"),all.x=T, all.y=F)
    colnames(df)[dim(df)[2]]="llmlabelcl10"
    df=merge(df,an[res=='Cl.20',c("network","cluster_id","label")],by.x=c("network","Cl.20"),by.y=c("network","cluster_id"),all.x=T, all.y=F)
    colnames(df)[dim(df)[2]]="llmlabelcl20"
    llm.1=an[res=='Cl.1',] ;llm.2=an[res=='Cl.2',] ; llm.5=an[res=='Cl.5',] ; llm.10=an[res=='Cl.10',] ; llm.20=an[res=='Cl.20',]
    setorder(llm.1,-n_entries) ; setorder(llm.2,-n_entries) ; setorder(llm.5,-n_entries) ; setorder(llm.10,-n_entries) ; setorder(llm.20,-n_entries) 
    list(mdf = df, x = dat$x, paths = dat$paths, llm.1 = llm.1,llm.2 = llm.2, llm.5=llm.5,llm.10=llm.10,llm.20=llm.20, llm=an)
    })
  
  
  cit_nw_llmall_data <- reactive({
    req(input$cit_nw_usr_nt_select_input)
    cit_nw_network_data<- sub("^[^-]+-([^-]+)-.*$", "\\1", input$cit_nw_usr_nt_select_input)
    print(paste0("Network_data:", cit_nw_network_data))
    an=cit_nw_llm_dt[network==cit_nw_network_data,]
    llm.1=an[res=='Cl.1',] ;llm.2=an[res=='Cl.2',] ; llm.5=an[res=='Cl.5',] ; llm.10=an[res=='Cl.10',] ; llm.20=an[res=='Cl.20',]
    setorder(llm.1,-n_entries) ; setorder(llm.2,-n_entries) ; setorder(llm.5,-n_entries) ; setorder(llm.10,-n_entries) ; setorder(llm.20,-n_entries) 
    # list(mdf = df, x = dat$x, paths = dat$paths, llm.1 = llm.1,llm.2 = llm.2, llm.5=llm.5,llm.10=llm.10,llm.20=llm.20, llm=an)
    list(llm.1 = llm.1,llm.2 = llm.2, llm.5=llm.5,llm.10=llm.10,llm.20=llm.20, llm=an)
  })
  
  ##### Try separating resolution and the cluster#####
  
  output$cit_nw_print_lower_res <- renderUI({
    req(input$cit_nw_usr_nt_select_input)
    # req(all_data_rv())
    # cit_nw_all_data<-all_data_rv()
    
    
    ##Based on resolution pick the resolution list
    cit_nw_rd_extract_res <- as.numeric(sub(".*\\.(\\d+)-.*", "\\1", input$cit_nw_usr_nt_select_input))
    print(paste("This:", cit_nw_rd_extract_res))
    
    cit_nw_pmids_dp_res<- paste0("res_",cit_nw_rd_extract_res)
    check_vals<- unname(resolutions)
    print(check_vals)
    all_nums <- as.numeric(sub("^res_", "", check_vals))
    min_res_pmids_dp_res<- max(all_nums)
    
    
    
    keep <- if (!is.na(cit_nw_rd_extract_res) && cit_nw_rd_extract_res <= min_res_pmids_dp_res) {
      all_nums <= cit_nw_rd_extract_res
      
    } else {
      all_nums = cit_nw_rd_extract_res
      
    }  
    
    
    radioButtons("cit_nw_rb_lower_res_input",label = NULL,choices = resolutions[keep],selected = tail(resolutions[keep], 1) )
    
    
  })
  
  ##### End: Try separating resolution and the cluster#####
  
  
  
  
  ##### UI Panel - (PMID Cluster Search)--Render the message box after a PMID search:LLM label, justification #####
  output$cit_nw_nt_llm_reasoning<- renderUI({
    req(input$cit_nw_rb_lower_res_input)
    req(input$cit_nw_usr_nt_select_input)
    print(paste0("Select input:",input$cit_nw_usr_nt_select_input))
    
    
    
    low_check<- sub("-Cl\\..*$", "", input$cit_nw_usr_nt_select_input)
    #Format CoP-Antibody
    print(paste0("Lowres:",low_check))
    # check_x <- cit_nw_merged_data()
    # llm<- check_x$llm
    
    llm<-cit_nw_llmall_data()$llm
    rinput<- input$cit_nw_usr_nt_select_input
    res1input<- sub(".*\\.(\\d+)-.*", "\\1", input$cit_nw_usr_nt_select_input)
    print(paste0("Cl.",res1input))
    
    ###Stripping resolution number from the user clicked radiobox
    cit_nw_lowres_roi <- as.numeric(sub("^res_", "", input$cit_nw_rb_lower_res_input))
    cit_nw_lowres_coi<- paste0("Cl.",cit_nw_lowres_roi)
    
    ##The column for grabbing the cluster for the particular pmid 
    req(cit_nw_usr_filtered_pmid_cluster)
    
    cit_nw_pmid_lowres_rd_cdt<- cit_nw_usr_filtered_pmid_cluster()
    
    cit_nw_lowres_chatbot_dt_pmid<- cit_nw_pmid_lowres_rd_cdt
    
    cit_nw_lowres_pmid_multiple_cluster_search<- cit_nw_lowres_chatbot_dt_pmid[cit_nw_lowres_chatbot_dt_pmid$PoV_network_cluster==rinput,]
    
    
    
    #Extract the low level resolution cluster number by the column name
    cit_nw_lowres_get_lowres<- cit_nw_lowres_pmid_multiple_cluster_search[[cit_nw_lowres_coi]]
    
    print(paste("New cluster check",cit_nw_lowres_get_lowres))
    
    #Example: mdf timeline of interest in antibody
    #Plotting the timeline of the lower resolution cluster of the specific pmid
    #Paste all together into Pov_network_cluster format
    
    print(paste0(low_check,"-",cit_nw_lowres_coi,"-",cit_nw_lowres_get_lowres))
    
    cit_nw_flow_res_cluster<- paste0(low_check,"-",cit_nw_lowres_coi,"-",cit_nw_lowres_get_lowres)
    lowres_minus_pov<- sub("^[^-]+-(.*)", "\\1", cit_nw_flow_res_cluster)
    
    visualize_kw<- llm$keywords[llm$network_cluster == lowres_minus_pov & llm$res == paste0("Cl.",cit_nw_lowres_roi,sep="")]

    llm_wd<- visualize_kw
    
    # visualize_kw<- llm$keywords[llm$network_cluster == minus_pov & llm$res == paste0("Cl.",res1input,sep="")]
    just_cluster<- llm$description[llm$network_cluster == lowres_minus_pov & llm$res == paste0("Cl.",cit_nw_lowres_roi,sep="")]
    print(paste0("Justification check: ", just_cluster))
    llm_label<- llm$label[llm$network_cluster == lowres_minus_pov & llm$res == paste0("Cl.",cit_nw_lowres_roi,sep="")]
    print(paste0("Label check: ", llm_label))
    cluster_entries<- llm$n_entries[llm$network_cluster == lowres_minus_pov & llm$res == paste0("Cl.",cit_nw_lowres_roi,sep="")]
    print(paste0("Label check: ", cluster_entries))
    
    
    if (!is.na(llm_wd)) {
      suggested_keywords <- paste(llm_wd)
    } else {
      suggested_keywords <- ""
    }
    
    tagList(
    HTML(paste0(
      "<b><i>LLM Label: </i></b>", llm_label, "<br><br>",
      "<b><i>LLM Reasoning: </i></b>", just_cluster, "<br><br>",
      "<b><i>#Papers in the cluster: </i></b>", cluster_entries, "<br><br>"
    )),
    textInput(
      inputId = "cit_nw_pmid_nt_bot_keywords",
      label   = "Enter Keywords (comma-separated) to visualize the timeline of the paper in the cluster :",
      value   = suggested_keywords,
      width   = "50%"
    ))
  })
  
  ##### End: UI Panel - (PMID Cluster Search)--Render the message box after a PMID search:LLM label, justification #####
  
  
  
  ##### === UI Panel - (PMID Cluster Search) Keyword-Based Cluster Plotting === #####
  #####==== UI-Panel(PMID Cluster Search) -- Timeline Plot : Output after Search-btn====#####
  observeEvent(input$cit_nw_pmid_bot_search_keywords_btn, {
    
    ##### Variables required to generate plots and tables for "Timeline Plot"-section #####
    req(input$cit_nw_rb_lower_res_input)
    req(input$cit_nw_usr_nt_select_input)
    # req(input$cit_nw_rd_nt_pathogencluster_select_dd)
    # req(input$resolution)
    low_check<- sub("-Cl\\..*$", "", input$cit_nw_usr_nt_select_input)
    req(input$cit_nw_pmid_nt_bot_keywords)
    check_x<-merged_pmidllm_data()
    dt_x<- check_x$x
    dt_nmdf<- check_x$mdf
    llm.1<- check_x$llm.1
    llm.2<- check_x$llm.2
    llm.5<- check_x$llm.5
    llm.10<- check_x$llm.10
    llm.20<- check_x$llm.20
    llm<- check_x$llm
    
    
    #Need an algo to autopopulate the k value with respective cluster_id
    rinput<- input$cit_nw_usr_nt_select_input
    # resinput<- input$resolution
    
    ###Stripping resolution number from the user clicked radiobox
    cit_nw_lowres_roi <- as.numeric(sub("^res_", "", input$cit_nw_rb_lower_res_input))
    cit_nw_lowres_coi<- paste0("Cl.",cit_nw_lowres_roi)
    
    ##The column for grabbing the cluster for the particular pmid 
    req(cit_nw_usr_filtered_pmid_cluster)
    
    cit_nw_pmid_lowres_rd_cdt<- cit_nw_usr_filtered_pmid_cluster()
    
    cit_nw_lowres_chatbot_dt_pmid<- cit_nw_pmid_lowres_rd_cdt
    
    cit_nw_lowres_pmid_multiple_cluster_search<- cit_nw_lowres_chatbot_dt_pmid[cit_nw_lowres_chatbot_dt_pmid$PoV_network_cluster==rinput,]
    
    
    
    #Extract the low level resolution cluster number by the column name
    cit_nw_lowres_get_lowres<- cit_nw_lowres_pmid_multiple_cluster_search[[cit_nw_lowres_coi]]
    
    print(paste("New cluster check",cit_nw_lowres_get_lowres))
    
    #Example: mdf timeline of interest in antibody
    #Plotting the timeline of the lower resolution cluster of the specific pmid
    #Paste all together into Pov_network_cluster format
    
    print(paste0(low_check,"-",cit_nw_lowres_coi,"-",cit_nw_lowres_get_lowres))
    
    cit_nw_flow_res_cluster<- paste0(low_check,"-",cit_nw_lowres_coi,"-",cit_nw_lowres_get_lowres)
    lowres_minus_pov<- sub("^[^-]+-(.*)", "\\1", cit_nw_flow_res_cluster)
    
    just_cluster<- llm$description[llm$network_cluster == lowres_minus_pov & llm$res == paste0("Cl.",cit_nw_lowres_roi,sep="")]
    print(paste0("Justification check: ", just_cluster))
    llm_label<- llm$label[llm$network_cluster == lowres_minus_pov & llm$res == paste0("Cl.",cit_nw_lowres_roi,sep="")]
    print(paste0("Label check: ", llm_label))
    cluster_entries<- llm$n_entries[llm$network_cluster == lowres_minus_pov & llm$res == paste0("Cl.",cit_nw_lowres_roi,sep="")]
    print(paste0("Label check: ", cluster_entries))
    
    
    # visualize_kw<- llm$keywords[llm$network_cluster == minus_pov & llm$res == paste0("Cl.",res1input,sep="")]
    # lowres_just_cluster<- llm$description[llm$network_cluster == lowres_minus_pov & llm$res == paste0("Cl.",cit_nw_lowres_roi,sep="")]
    # print(paste0("Justification check: ", lowres_just_cluster))
    # lowres_llm_label<- llm$label[llm$network_cluster == lowres_minus_pov & llm$res == paste0("Cl.",cit_nw_lowres_roi,sep="")]
    # print(paste0("Label check: ", lowres_llm_label))
    # lowres_cluster_entries<- llm$n_entries[llm$network_cluster == lowres_minus_pov & llm$res == paste0("Cl.",cit_nw_lowres_roi,sep="")]
    # print(paste0("Label check: ", lowres_cluster_entries))
    
    
    res1input<- cit_nw_lowres_coi 
    
    
    # minus_pov<- sub("^[^-]+-(.*)", "\\1", rinput)
    # res1input <- as.numeric(sub("res_", "", input$resolution))
    
    # clusnum<-paste0("Cl.",resinput)
    lowres_clusnum<- cit_nw_lowres_coi
    visualize_cluster<- llm$cluster_id[llm$network_cluster == lowres_minus_pov & llm$res == paste0("Cl.",cit_nw_lowres_roi,sep="")]
    print(paste0("the cluster number pull ",visualize_cluster))
    print(paste(lowres_clusnum,visualize_cluster, sep = "-"))
    # just_cluster<- llm$description[llm$network_cluster == lowres_minus_pov & llm$res == paste0("Cl.",cit_nw_lowres_roi,sep="")]
    # print(paste0("Justification check: ", just_cluster))
    
    # res2input<-as.numeric(sub("res_","",input$cit_nw_nt_select_subclusterlabel_input))
    ###First Res Vs the sub cluster Res
    # resf1input<- paste0("Cl.",res1input)
    resf1input<- res1input
    
    
    # resinput<- sub(".*\\.(\\d+)-.*", "\\1", rinput)
    # res1input<- resinput
    # lowres_minus_pov<- sub("^[^-]+-(.*)", "\\1", rinput)
    # # res1input <- as.numeric(sub("res_", "", input$resolution))
    # clusnum<-paste0("Cl.",resinput)
    # visualize_cluster<- llm$cluster_id[llm$network_cluster == lowres_minus_pov & llm$res == paste0("Cl.",res1input,sep="")]
    # print(paste0("the cluster number pull ",visualize_cluster))
    # print(paste(clusnum,visualize_cluster, sep = "-"))
    # # print(head(llm, n=3))
    # just_cluster<- llm$description[llm$network_cluster == lowres_minus_pov & llm$res == paste0("Cl.",res1input,sep="")]
    # print(paste0("Justification check: ", just_cluster))
    # 
    #res2input<-as.numeric(sub("res_","",input$cit_nw_nt_select_subclusterlabel_input))
    ###First Res Vs the sub cluster Res
    
    
    #resf1input<- paste0("Cl.",res1input)
    
    #resf2input<- paste0("Cl.",res2input)
    
    # k1=7
    k1<- visualize_cluster
    
    # k1=7 ; k2=11 ; k5=159 ; k10=155 ; k20=431
    # Scluster <- dt_x[get(resf1input) == k1, unique(get(resf2input))]
    # Scluster=unique(dt_x[Cl.1==k1,Cl.5])  # ; Scluster=unique(x3[Cl.1==k1,Cl.5])
    # print(paste0("Scluster:",Scluster))
    
    # main=paste0("Cl.1:",k1," ",llm.1[cluster_id==k1,n_entries]," ",llm.1[cluster_id==k1,main]," papers.")  ; desc=llm.1[cluster_id==k1,description]
    # dt_h=dt_nmdf[Cl.1==k1,]
    dt_h <- dt_nmdf[get(resf1input) %in% k1 ]
    # wd1=llm.1[cluster_id==k1,wd1] ; wd2=llm.1[cluster_id==k1,wd2] ; wd3=llm.1[cluster_id==k1,wd3] ; wd4=llm.1[cluster_id==k1,wd4]
    # wd5=llm.1[cluster_id==k1,wd5] ; wd6=llm.1[cluster_id==k1,wd6] ; wd7=llm.1[cluster_id==k1,wd7] ; wd8=llm.1[cluster_id==k1,wd8]
    # # for (i in 1:length(Scluster)) {kk=Scluster[i]; final_h[i] <- dt_h[dt_h[Cl.5==kk,],dt_h[Cl.5==kk,]]; fh<-final_h;print(nrow(final_h))}
    # fh <- dt_h[Cl.5 %in% Scluster, ]
    # fh <- dt_h[dt_h[[resf2input]] %in% Scluster, ]
    fh<- dt_h
    
    
    # --- Parse keywords (keep duplicates & order) ---
    nt_keywords <- trimws(unlist(strsplit(input$cit_nw_pmid_nt_bot_keywords, ",")))
    nt_keywords <- nt_keywords[nzchar(nt_keywords)]
    
    # Build per-occurrence labels so duplicates are distinct in the legend
    # e.g., "cancer, therapy, cancer" -> "cancer [1]", "therapy", "cancer [2]"
    lower_keys <- tolower(nt_keywords)
    print(lower_keys)
    occ_idx <- ave(seq_along(lower_keys), lower_keys, FUN = seq_along)
    labeled_keys <- ifelse(duplicated(lower_keys) | ave(lower_keys == lower_keys, lower_keys, FUN = cumsum) > 1,
                           paste0(nt_keywords, " [", occ_idx, "]"),
                           nt_keywords)
    
    cit_nw_nt_keyword_columns <- c("abstract", "title", "pmid")
    # print(head(cit_nw_nt_keyword_columns))
    
    # --- Choose overwrite behavior ---
    # "last"  = later occurrences (to the right) override earlier ones
    # "first" = first occurrence wins, later ones don't change existing assignments
    overwrite_mode <- "last"   # <-- set to "first" if you prefer first-match-wins
    
    # --- Initialize ---
    fh$match_color <- "none"
    fh$matched_keywords <- ""
    
    # --- Assign colors by occurrence order ---
    for (i in seq_along(nt_keywords)) {
      kw <- nt_keywords[i]
      label_i <- labeled_keys[i]
      
      matches <- Reduce(`|`, lapply(cit_nw_nt_keyword_columns, function(col) {
        # fixed = TRUE to avoid regex surprises; drop if regex semantics
        #grepl(kw, fh[[col]], ignore.case = TRUE, fixed = TRUE)
        grepl(kw, fh[[col]], ignore.case = TRUE)
      }))
      
      # print(head(matches))
      
      # collect all hits 
      fh$matched_keywords[matches] <- ifelse(
        nzchar(fh$matched_keywords[matches]),
        paste0(fh$matched_keywords[matches], ", ", label_i),
        label_i
      )
      
      if (overwrite_mode == "last") {
        # later keywords/occurrences take precedence
        fh$match_color[matches] <- label_i
      } else {
        # first occurrence wins
        to_set <- matches & fh$match_color == "none"
        fh$match_color[to_set] <- label_i
      }
    }
    
    # Factor levels preserve positional order, with 'none' first
    fh$match_color <- factor(fh$match_color, levels = c("none", labeled_keys))
    
    # --- Color palette ---
    keyword_levels <- levels(fh$match_color)
    keyword_nt_colors <- setNames(rainbow(length(keyword_levels) - 1), keyword_levels[-1])
    color_palette <- c("none" = "gray", keyword_nt_colors)
    
    
    
    #for x and y col:
    
    res_col<- cit_nw_lowres_roi
    
    # --- Build dynamic columns ---
    x_col <- paste0("x", res_col)
    y_col <- paste0("y", res_col)
    
    # print(head(fh, n = 1))
    
    btn_id <- paste0("min_btn_", res1input)
    body_id <- paste0("panel_body_", res1input)
    
    ##### End - Variables required to generate plots and tables for "Timeline Plot"-section #####
    
    ##### Timeline Plot: Plot-Plotly output #####
    p_nt<-ggplot(fh, aes(x = .data[["Nyear"]], y = .data[[y_col]], label = title)) +
      # geom_point()+
      geom_point(aes(color = match_color,customdata = url,size = (sqrt(fh$Ncits)/3+1)), alpha = 0.7) +
      #geom_point(aes(color = match_color, customdata = url,size = (sqrt(cluster_data$Ncits)/3+1)), alpha = 0.7) +
      # geom_point(aes(color = match_color,size = 0.2), alpha = 0.7) +
      guides(size = FALSE)+
      labs(x = "Publication Year", y = NULL,title = paste0("Timeline of Cluster: ",llm_label, "; ",nrow(fh), " articles")) +
      
      scale_color_manual(values = color_palette, guide = guide_legend(title = NULL))+
      
      theme(
        axis.title.y = element_blank(),
        axis.text.y  = element_blank(),
        axis.line.y = element_blank(),
        axis.ticks.y = element_blank(),
        panel.background = element_rect(fill = "white", colour = NA),
        plot.background   = element_rect(fill = "white", colour = NA),
        legend.background = element_rect(fill = "white", colour = NA),   # legend box
        legend.key        = element_rect(fill = "white", colour = NA),   # legend item bg
        panel.grid = element_blank(),
        plot.title = element_text(color = "#2167d9", size = 18, face = "bold", hjust = 0.5,margin = margin(b = 24))
      )
    
    # plotly_obj <- plotly::ggplotly(p, tooltip = c("pmid", "title"), source = "cit_nw_pmidplotsource")

    plotly_nt_obj <- plotly::ggplotly(p_nt, tooltip = c("pmid", "title"), height = 1000)%>%
      layout(
        xaxis = list(
          type           = "linear",
          tickmode       = "auto",
          nticks         = 12,
          showticklabels = TRUE,
          ticks          = "outside",
          showline   = TRUE,
          linecolor  = "black",
          linewidth  = 2,
          mirror     = TRUE        # mirror across top,get full vertical box
        ),
        yaxis = list(
          showline   = TRUE,
          linecolor  = "black",
          linewidth  = 2,
          mirror     = TRUE        # ← mirror across right,get full horizontal box
        )
      )
    
    plotly_nt_obj <- htmlwidgets::onRender(plotly_nt_obj,"
            function(el, x) {
              el.on('plotly_click', function(d) {
                if (d.points.length > 0) {
                  var url = d.points[0].customdata;
                  if (url) window.open(url, '_blank');
                }
              });
            }
          ")
    ##### End - Timeline Plot: Plot-Plotly output #####
    
    ##### Timeline Plot: Data Table output #####
    output$cit_nw_nt_usr_pov_tmplot_for_cluster_dt <- renderDT({
      cit_nw_nt_tm_dt <- fh[, c("pmid", "title", "Ncits","year","abstract","match_color")]
      cit_nw_nt_tm_dt$pmid <- sprintf(
        '<a href="https://pubmed.ncbi.nlm.nih.gov/%s" target="_blank">%s</a>',
        cit_nw_nt_tm_dt$pmid, cit_nw_nt_tm_dt$pmid
      )
      setnames(cit_nw_nt_tm_dt, c("pmid", "title", "Ncits","year","abstract", "match_color"),
               c("PMID", "Title", "#Citations", "Year", "Abstract", "Keyword-Color Match"))
      
      # datatable(
      #   cit_nw_nt_tm_dt,
      #   rownames = FALSE,
      #   escape = FALSE,
      #   selection = "single",                 # <-- move OUT of options
      #   extensions = c("Buttons", "Responsive"),
      #   options = list(
      #     pageLength = 15,
      #     dom = '<"top"Bf>rt<"bottomlip"lip>',
      #     buttons = list(list(extend = "collection",
      #                         text = "Export",
      #                         buttons = c("csv", "excel"))),
      #     autoWidth = TRUE,
      #     order = list(list(3, "desc")),
      #     columnDefs = list(
      #       list(visible = FALSE, targets = 4),   # Abstract (0-based index)
      #       list(className = 'dt-left', targets = 1)
      #       # you can also name columns and use names, see note below
      #     )
      #   ),
      #   callback = JS(
      #      #get the real <table> node
      #     "var node = table.table().node();",
      #     #avoid duplicate bindings on re-render
      #     "$(node).off('click.dt').on('click.dt', 'tbody td', function(){",
      #     "  var idx = table.cell(this).index();",
      #     "  if(!idx) return;",
      #     "  var rowData = table.row(idx.row).data();",
      #     "  var abstractInfo = rowData[4];", #make sure column 4 exists
      #     "  Shiny.setInputValue('selectedpmid_row', abstractInfo, {priority:'event'});",
      #     "});"
      #   )
      # )
      
      datatable(
        cit_nw_nt_tm_dt,
        rownames = FALSE,
        escape = FALSE,
        selection = 'single',
        extensions = c("Buttons", "Responsive"),
        options   = list(pageLength = 15,
                         dom = '<"top"Bf>rt<"bottomlip"lip>',
                         buttons = list(list(extend = "collection", text = "Export", buttons = c("csv","excel"))),autoWidth = TRUE, order = list(list(3, "desc")),
                         columnDefs = list(
                           list(visible = FALSE, targets = 4),  # Abstract
                           # list(visible = FALSE, targets = 5),  # Authors
                           # list(visible = FALSE, targets = 6),   # Unique ID
                           list(className = 'dt-left', targets = 1)
                         )),callback = JS(
                           "var node = table.table().node();",
                           "$(node).off('click.dt').on('click.dt', 'tbody td', function(){",
                           "  var info = table.cell(this).index();",
                           "  var rowData = table.row(info.row).data();",
                           "  var clickedCol = info.column;",            
                             "  var abstractInfo = rowData[4];", 
                           "  Shiny.setInputValue('selectedpmid_row', {col: clickedCol, abstract: abstractInfo}, {priority:'event'});",
                           "});")
        )
    })
    ##### End - Timeline Plot: Data Table output #####
    
    #####----- PMID Search - Click Event dt for Abstract -----#####
    observeEvent(input$selectedpmid_row, ignoreInit = TRUE, {
      req(input$selectedpmid_row)
      if (input$selectedpmid_row$col == 1) {  # change 0 to your target column index
        showModal(modalDialog(
          title = "Abstract:",
          div(style = "white-space: pre-wrap;", input$selectedpmid_row$abstract),
          easyClose = TRUE,
          footer = NULL
        ))
      }
    })
    #####----- End: PMID Search - Click Event dt for Abstract -----#####
    
    ##### Timeline Plot: Render "timeline plot" output #####
    output$cit_nw_rd_nt_usr_pov_tmplot_for_cluster <- renderUI({                                       
      div(class = "cit-nw-main-panel-container cit-nw-boxed",
          div(class="cit-nw-panel-header",style = "display:flex; align-items:flex-start; gap:8px;",
              actionLink(btn_id, label = NULL, icon = icon("minus-square")),
              tags$strong(paste0("Timeline Plot")),
              br(),
              br(),),
          div(id = body_id,
              
              if (nrow(fh) <= 4000) {
                plotly_nt_obj
              } else {
                tags$em(
                  "Plot suppressed because the dataset has more than 4000 rows.",
                  style = "color:#a00;"
                )
              },
              
              #plotly_nt_obj,
              tags$p("Summary of Articles in the Cluster: ",just_cluster,style = "text-align: left; color: #555; margin-top: 12px;"),
              tags$p(
                "Note: Keywords are matched against the abstract,and title fields. ",
                "If multiple keywords match, the most recent keyword overrides earlier ones for coloring.",
                style = "text-align: left; font-style: italic; color: #555; margin-top: 12px;"
              ),
              fluidRow(column(12, DT::DTOutput("cit_nw_nt_usr_pov_tmplot_for_cluster_dt", width = "100%"))),
          )
      )
    })
    ##### End - Timeline Plot: Render "timeline plot" output #####
    
    ##### Timeline Plot: Handle the minimize box feature #####
    observeEvent(input[[btn_id]], {
      shinyjs::toggle(id = body_id, anim = TRUE, time = 2)
    }, ignoreInit = TRUE)
    ##### End - Timeline Plot: Handle the minimize box feature #####
  })
  
  
  ##### === End:UI Panel - (PMID Cluster Search) Keyword-Based Cluster Plotting === #####
  #####==== End:UI-Panel(PMID Cluster Search) -- Timeline Plot : Output after Search-btn====#####
  
  
  ######==== ***End: PMID CLUSTER SEARCH*** =====######
  #----------------------------------------------------------------------------#
  
  #----------------------------------------------------------------------------#
  ######==== ***BROWSE NETWORK*** =====######
  
  ##### === UI Panel(Browse Network) -- "Browse Network" btn click === #####
  observeEvent(input$cit_nw_show_nw_timeline, {
    #show a placeholder at the top (no default selected)
    subjects <- list_subjects()
    choices_grouped <- make_grouped_choices(subjects)
    output$cit_nw_tab <- renderUI({ NULL })
    output$cit_nw_cluster_tab <- renderUI({ NULL })
    output$cit_nw_pmid_tab <- renderUI({ NULL })
    
    req(split_all_llm_data())
    cit_nw_cluster_llmlabel_data<- split_all_llm_data()
    
    
    ##### Browse Network: Render #####
    output$cit_nw_timeline_tab <- renderUI({
      tagList(
        
        br(), br(),
        tags$h4(
          "AI Generated Cluster Label and Reasoning",
          style = "text-align: center; font-weight: bold; font-size:30px; color:#9a9a9a;"
        ),
        
        
        
        br(), br(),
        div(class = "cit-nw-search-container",
            actionButton("cit_nw_keyword_search_help", "?", class = "cit-nw-help-button"),
            selectInput("cit_nw_pov_llm_cluster_option", "Louvain clustering for:", choices = names(cit_nw_cluster_llmlabel_data)),
            actionButton("cit_nw_cluster_search_btn", "Search"),
        ),
        br(), br(),
        div(class = "cit-nw-main-panel-container",
            DT::dataTableOutput("cit_nw_llm_table_for_cluster"),
        ),
        br(), br(),
        
        div(class = "cit-nw-main-panel-container cit-nw-boxed",
            div(class="cit-nw-panel-header",style = "display:flex; align-items:flex-start; gap:8px;",
                actionLink(cit_nw_tree_btn_id,label = NULL, icon = icon("minus-square")),
                tags$strong("Citation Network Cluster Tree", style = "color:#555")),
            
            uiOutput("cit_nw_tree_body_ui")
                
        #     shinyjs::hidden(
        #     div(id = cit_nw_tree_body_id,
        # 
        #             br(), br(),
        #             selectInput("root", "Network of interest:", choices = roots, selected = "Ebola"),
        #             selectInput("res","Resolution", choices = c(1, 2, 5, 10), selected = ""),
        #             br(),br(),
        #             uiOutput("tree_title"),
        #         fluidRow(class = "no-gutters",
        #                  column(8, style="padding:0;",
        #                         div(id = "tree_scroll",style = "border:1px solid #ddd; border-radius:4px; padding:10px;
        #                             overflow-x:auto;overflow-y:auto;white-space:nowrap;",
        #                             div(
        #                             collapsibleTreeOutput(outputId = "tree", width = "2200px", height = "1000px")))),
        #                  column(4,
        #                         div(id = "cluster_details_panel",
        #                             style="border:1px solid #ddd; padding:10px;",
        #                             tags$h4("Cluster Details"),
        #                             br(), br(),
        #                             actionButton("show_full_table", "Show full table", icon = icon("table")),
        #                             br(), br(),
        #                             DT::DTOutput("node_table")))),
        #         
        #         
        #        
        #         
        #         
        # 
        #             # fluidRow(class = "no-gutters",
        #             # column(10, style="padding:0;",div(
        #             # style = "border:1px solid #ddd; border-radius:4px; padding:10px;",
        #             # collapsibleTreeOutput(outputId = "tree",width = "100%"))),
        #             # column(2,div( id = "cluster_details_panel",style="border:1px solid #ddd; padding:10px;",
        #             #              tags$h4("Cluster Details"),
        #             #              br(),br(),
        #             #              actionButton("show_full_table", "Show full table", icon = icon("table")),
        #             #              br(),br(),
        #             #              # DTOutput("node_table")
        #             #              # uiOutput("node_table")
        #             #              # in your Cluster Details panel
        #             #              DT::DTOutput("node_table")
        #             # 
        #             #              ))),
        #             # 
        # )
        #     )
        ),
        
        br(), br(),
        
        br(), br(),
        div(id = "cit_nw_llm_tbl_cluster_section",
          class = "cit-nw-search-container",
            actionButton("cit_nw_keyword_search_help", "?", class = "cit-nw-help-button"),
            selectInput(
              "subject",
              label   = "Enter network of interest:",
              # choices = list_subjects(),
              choices  = c("— Select a subject —" = "", choices_grouped),
              selected = "Ebola",
              multiple = FALSE
            ),
            br(),
            radioButtons(
              "resolution",
              label = NULL,
              choices = resolutions,
              ),
            br(),
            actionButton("cit_nw_nt_citnw_search_btn", "Network Plot"),
            br(),
            #I need a condition here, so using uiOutput instead of direct selectInput
            #Placeholder for the select input
            # uiOutput("cit_nw_nt_select_input"),
            uiOutput("cit_nw_nt_pathogencluster_select_dd"),                 # <-- must match output$dd below
            verbatimTextOutput("dbg"),  
            uiOutput("cit_nw_nt_clustertm_keywords"),
            actionButton("cit_nw_nt_search_btn", "Timeline Plot"),
            br(),
            uiOutput("cit_nw_nt_cluster_label_dd"),
            actionButton("cit_nw_subnt_search_btn", "Cluster Plot"),
        ),
        br(), br(),
        div(class = "cit-nw-main-panel-container",
            uiOutput("cit_nw_nt_plot_for_cluster"),
            br(),
            uiOutput("cit_nw_nt_pov_tmplot_for_cluster"),
            br(),
            uiOutput("cit_nw_nt_pov_plot_for_cluster"),
            br(), br(),br(),
            # DT::dataTableOutput("cit_nw_nt_pov_tm_for_cluster"),
        ),
        br(), br()
      )
    })
    
    
    
    ##### End: Browse Network: Render #####
  })
  ##### === End: UI Panel(Browse Network) -- "Browse Network" btn click === #####
  
  
  # observeEvent(input[[cit_nw_tree_btn_id]], {
  #     shinyjs::toggle(id = cit_nw_tree_body_id, anim = TRUE, time = 0.2)
  #   }, ignoreInit = TRUE)
  
  observeEvent(input[[cit_nw_tree_btn_id]], {
    rv_cit_nw$tree_open <- !isTRUE(rv_cit_nw$tree_open)
  }, ignoreInit = TRUE)
  
  
  ##### ---- Browse Network: data cleaning(All.df,mdf merge)Helper for server ----#####
  # If there are subjects, pick the first by default
  observe({
    subs <- list_subjects()
    if (length(subs) && is.null(input$subject)) {
      updateSelectInput(session, "subject", selected = subs[1])
    }
  })
  
  # Reactively load subject files
  subject_data <- reactive({
    req(input$subject)
    load_subject_data(input$subject)
  })
  
  
  print(paste0("Head merged data"))
  print(Sys.time())
  merged_data <- reactive({
    dat <- subject_data()
    mdf <- dat$mdf
    shiny::req("pmid" %in% names(mdf))
    req(all_data_rv())
    ALL_DATA<-all_data_rv()
    
    
    dtin=ALL_DATA[network==input$subject,]
    mdf$pmid=as.numeric(mdf$pmid)
    
    # df=merge(dtin,mdf[,c('pmid','abstract','labelcl1','labelcl2','labelcl5','labelcl10','labelcl20',
    #                      'label1','label2','label5','label10','label20','url')],by="pmid",all.x=F,all.y=T)
    dtin_sub <- dtin[, .(pmid)]
    df=merge(dtin_sub,mdf[,c('pmid','network','Cl.20','Cl.10','Cl.5','Cl.2','Cl.1','title','abstract','year','journal',
                         'authors','Nyear','Ncits','Nrefs','x','y','full','x20','y20','x10','y10','x5','y5','x2','y2',
                         'x1','y1','PoV','labelcl1','labelcl2','labelcl5','labelcl10','labelcl20','label1','label2','label5',
                         'label10','label20','url')],by="pmid",all.x=F,all.y=T)
    
    an=cit_nw_llm_dt[network==input$subject,]
    df=merge(df,an[res=='Cl.1',c("network","cluster_id","label")],by.x=c("network","Cl.1"),by.y=c("network","cluster_id"),all.x=T, all.y=F)
    colnames(df)[dim(df)[2]]="llmlabelcl1"
    df=merge(df,an[res=='Cl.2',c("network","cluster_id","label")],by.x=c("network","Cl.2"),by.y=c("network","cluster_id"),all.x=T, all.y=F)
    colnames(df)[dim(df)[2]]="llmlabelcl2"
    df=merge(df,an[res=='Cl.5',c("network","cluster_id","label")],by.x=c("network","Cl.5"),by.y=c("network","cluster_id"),all.x=T, all.y=F)
    colnames(df)[dim(df)[2]]="llmlabelcl5"
    df=merge(df,an[res=='Cl.10',c("network","cluster_id","label")],by.x=c("network","Cl.10"),by.y=c("network","cluster_id"),all.x=T, all.y=F)
    colnames(df)[dim(df)[2]]="llmlabelcl10"
    df=merge(df,an[res=='Cl.20',c("network","cluster_id","label")],by.x=c("network","Cl.20"),by.y=c("network","cluster_id"),all.x=T, all.y=F)
    colnames(df)[dim(df)[2]]="llmlabelcl20"
    llm.1=an[res=='Cl.1',] ;llm.2=an[res=='Cl.2',] ; llm.5=an[res=='Cl.5',] ; llm.10=an[res=='Cl.10',] ; llm.20=an[res=='Cl.20',]
    setorder(llm.1,-n_entries) ; setorder(llm.2,-n_entries) ; setorder(llm.5,-n_entries) ; setorder(llm.10,-n_entries) ; setorder(llm.20,-n_entries) 
    list(mdf = df, x = dat$x, paths = dat$paths, llm.1 = llm.1,llm.2 = llm.2, llm.5=llm.5,llm.10=llm.10,llm.20=llm.20, llm=an)
  })
  
  print(paste0("Head merged data"))
  print(Sys.time())
  ##### ---- End: Browse Network: data cleaning(All.df,mdf merge)Helper for server ----#####
  
  
 
  
  #####==== UI-Panel(Browse Network)-Select Input: Clusters found in resolution(Cluster names) ====#####
  
  # output$cit_nw_nt_pathogencluster_select_dd <- renderUI({
  #   check <- merged_data()
  #   req(check)
  #   
  #   check_mdf <- check$mdf
  #   req(input$resolution)
  #   
  #   res_num   <- as.numeric(sub("^res_", "", input$resolution))
  #   col_name  <- paste0("llmlabelcl", res_num)   # label shown in the dropdown
  #   clus_name <- paste0("labelcl",    res_num)   # paired string like "AAA-BBB-Cl.X-0"
  #   res_tag   <- paste0("Cl.", res_num)
  #   
  #   # guard: both columns must exist
  #   if (!all(c(col_name, clus_name) %in% names(check_mdf))) return(NULL)
  #   
  #   bad_pat <- paste0("-", res_tag, "-0$")
  #   
  #   # Map each dropdown label -> a representative clus string (first non-NA),
  #   # then keep only labels whose clus string does NOT end with ...-Cl.N-0
  #   lab <- check_mdf[[col_name]]
  #   clb <- check_mdf[[clus_name]]
  #   
  #   rep_clb <- tapply(clb, lab, function(x) {
  #     x <- x[!is.na(x)]
  #     if (length(x)) x[1] else NA_character_
  #   })
  #   
  #   keep_labels <- names(rep_clb)[ !grepl(bad_pat, unname(rep_clb), perl = TRUE) ]
  #   present     <- sort(unique(na.omit(lab)))
  #   choices     <- intersect(present, keep_labels)
  #   
  #   if (!length(choices)) {
  #     shinyjs::disable("cit_nw_nt_search_btn")
  #     shinyjs::disable("cit_nw_subnt_search_btn")
  #     shinyjs::disable("cit_nw_nt_cluster_label_dd")
  #     return(helpText("No eligible clusters at this resolution."))
  #   } else {
  #     shinyjs::enable("cit_nw_nt_search_btn")
  #     shinyjs::enable("cit_nw_subnt_search_btn")
  #     shinyjs::enable("cit_nw_nt_cluster_label_dd")
  #   }
  #   
  #   # Decide what should be selected:
  #   # priority: selected_cluster() if set and present in choices; otherwise choices[1]
  #   sel <- selected_cluster_llm_table()
  #   if (!is.null(sel)) {
  #     # if the selected_cluster_llm_table value is not currently in choices, optionally
  #     # add it to the front so it can be selected (prevents silent failure)
  #     if (!(sel %in% choices)) {
  #       choices <- c(sel, choices)
  #     }
  #     selected_value <- sel
  #   } else {
  #     selected_value <- choices[1]
  #   }
  #   
  #   selectInput(
  #     "cit_nw_nt_select_input",
  #     "Clusters found in resolution:",
  #     choices  = choices,
  #     selected = selected_value
  #   )
  # })
  
  
  output$cit_nw_nt_pathogencluster_select_dd <- renderUI({
    check <- merged_data()
    req(check)

    check_mdf <- check$mdf
    req(input$resolution)

    res_num   <- as.numeric(sub("^res_", "", input$resolution))
    col_name  <- paste0("llmlabelcl", res_num)   # label shown in the dropdown
    clus_name <- paste0("labelcl",    res_num)   # paired string like "AAA-BBB-Cl.X-0"
    res_tag   <- paste0("Cl.", res_num)

    # guard: both columns must exist
    if (!all(c(col_name, clus_name) %in% names(check_mdf))) return(NULL)


    bad_pat <- paste0("-", res_tag, "-0$")

    # Map each dropdown label -> a representative clus string (first non-NA),
    # then keep only labels whose clus string does NOT end with ...-Cl.N-0
    lab <- check_mdf[[col_name]]
    clb <- check_mdf[[clus_name]]

    # representative clus label per dropdown option
    rep_clb <- tapply(clb, lab, function(x) {
      x <- x[!is.na(x)]
      if (length(x)) x[1] else NA_character_
    })

    keep_labels <- names(rep_clb)[ !grepl(bad_pat, unname(rep_clb), perl = TRUE) ]
    present     <- sort(unique(na.omit(lab)))
    choices     <- intersect(present, keep_labels)

    # if (!length(choices)) {
    #   shinyjs::disable("run_btn")  # <- disable
    #   return(helpText("No eligible clusters at this resolution."))
    # }

    if (!length(choices)) {
      shinyjs::disable("cit_nw_nt_search_btn")  # <- disable
      shinyjs::disable("cit_nw_subnt_search_btn")
      shinyjs::disable("cit_nw_nt_cluster_label_dd")
      return(helpText("No eligible clusters at this resolution."))
    } else {
      shinyjs::enable("cit_nw_nt_search_btn")   # <- enable
      shinyjs::enable("cit_nw_subnt_search_btn")
      shinyjs::enable("cit_nw_nt_cluster_label_dd")
    }
    
    # ---- decide selected: prefer click-supplied value if present and valid ----
    sel_from_click <- selected_cluster_llm_table()
    selected_choice <- if (!is.null(sel_from_click) && sel_from_click %in% choices) {
      sel_from_click
    } else {
      # default when independent
      choices[1]
    }
    





    selectInput(
      "cit_nw_nt_select_input",
      "Clusters found in resolution:",
      choices  = choices,
      selected = selected_choice
    )
  })
  #####==== End: UI-Panel(Browse Network)-Select Input: Clusters found in resolution(Cluster names) ====#####

  #####----- Debug to confirm values -----#####
  # output$dbg <- renderPrint({
  #   check <- try(merged_data(), silent = TRUE)
  #   nm <- try(names(check$mdf), silent = TRUE)
  #   list(
  #     resolution_raw = input$resolution,
  #     res_num = as.numeric(sub("^res_", "", input$resolution %||% "")),
  #     col_try = paste0("llmlabel", as.numeric(sub("^res_", "", input$resolution %||% ""))),
  #     have_names = if (inherits(nm, "try-error")) "<error>" else nm
  #   )
  # })
  #####----- End: Debug to confirm values -----#####
  
  #####==== UI-Panel(Browse Network) - Select Input--Sub labels for the cluster of interest(i.e look into the different groups in a cluster) #####
  output$cit_nw_nt_cluster_label_dd <- renderUI({
    req(input$resolution)
    
    #numeric value of current resolution
    current_res <- as.numeric(gsub("\\D+", "", as.character(input$resolution)))
    
    # get numeric parts for all available resolutions
    vals     <- unname(resolutions)                     # e.g. "res_1","res_2",...
    all_nums <- as.numeric(sub("^res_", "", vals))
    max_res  <- max(all_nums, na.rm = TRUE)
    
    # keep higher ones; if already at the highest, keep only the current
    keep <- if (!is.na(current_res) && current_res >= max_res) {
      all_nums == current_res
    } else {
      all_nums > current_res
    }     
    selectInput(
      "cit_nw_nt_select_subclusterlabel_input",
      "Label the sub-group in the cluster:",
      choices  = resolutions[keep],
      selected = paste0("res_", current_res)  # ensures current stays selected
    )})
  #####==== End: UI-Panel(Browse Network) - Select Input--Sub labels for the cluster of interest(i.e look into the different groups in a cluster) #####
  
  #####==== UI-Panel(Browse Network) - Keyword suggestions input tab ====#####
  # output$cit_nw_nt_clustertm_keywords <- renderUI({
  #   req(input$cit_nw_nt_select_input)
  #   req(input$resolution)
  #   print(input$resolution)
  #   print(paste0("Select input:",input$cit_nw_nt_select_input))
  #   
  #   check_x <- merged_data()
  #   dt_x    <- check_x$x
  #   dt_nmdf <- check_x$mdf
  #   # llm.1   <- check_x$llm.1
  #   llm<- check_x$llm
  #   
  #   # k1 <-input$cit_nw_nt_select_input
  #   # Scluster <- unique(dt_x[Cl.1 == k1, Cl.5])
  #   # dt_h     <- dt_nmdf[Cl.1 == k1, ]
  #   
  #   rinput<- input$cit_nw_nt_select_input
  #   # res1input<- input$resolution
  #   res1input <- as.numeric(sub("res_", "", input$resolution))
  #   print(paste0("Cl.",res1input))
  #   visualize_kw<- llm$keywords[llm$label == rinput & llm$res == paste0("Cl.",res1input,sep="")]
  #   print(paste0("keywords:",visualize_kw))
  #   llm_wd<- visualize_kw
  #   # llm_wd   <- llm[label == k1, keywords]
  #   # 
  #   # if (!is.na(llm_wd)) {
  #   #   suggested_keywords <- paste(llm_wd)
  #   # } else {
  #   #   suggested_keywords <- ""
  #   # }
  #   
  #   if (!is.null(llm_wd) && !is.na(llm_wd)) {
  #     suggested_keywords <- paste(llm_wd)
  #   } else {
  #     suggested_keywords <- ""
  #   }
  #   
  #   
  #   textInput(
  #     inputId = "cit_nw_pmid_nt_bot_keywords",
  #     label   = "Enter Keywords (comma-separated) to visualize the timeline of the paper in the cluster :",
  #     value   = suggested_keywords,
  #     width   = "50%"
  #   )
  # })
  
  
  output$cit_nw_nt_clustertm_keywords <- renderUI({
    req(input$cit_nw_nt_select_input, input$resolution)
    
    check_x  <- merged_data()
    llm      <- check_x$llm
    
    rinput     <- input$cit_nw_nt_select_input
    res_num    <- as.numeric(sub("^res_", "", input$resolution))
    res_tag    <- paste0("Cl.", res_num)
    
    # pull matching keywords (may be 0, 1, or many)
    visualize_kw <- llm$keywords[ llm$label == rinput & llm$res == res_tag ]
    
    # normalize: character, drop NA/empty, dedupe
    visualize_kw <- unique(as.character(visualize_kw))
    visualize_kw <- visualize_kw[!is.na(visualize_kw) & nzchar(visualize_kw)]
    
    # safe default ("" if none; collapse if many)
    suggested_keywords <- if (length(visualize_kw) == 0) "" else paste(visualize_kw, collapse = ", ")
    
    textInput(
      inputId = "cit_nw_pmid_nt_bot_keywords",
      label   = "Enter Keywords (comma-separated) to visualize the timeline of the paper in the cluster:",
      value   = suggested_keywords,
      width   = "50%"
    )
  })
  
  
  
  
  
  #####==== UI-Panel(Browse Network) - Keyword suggestions input tab ====#####
  
  ##### ---- Citation Network Graph: Network Image output-Helper for server ---- #####
  img_paths <- reactive({
    req(input$subject, input$resolution)
    # extract just the digit from resolution (works for "2", "Cl2", "Resolution 2", etc.)
    res_num <- gsub("\\D+", "", as.character(input$resolution))
    if (!nzchar(res_num)) res_num <- "1"
    
    file_nm <- sprintf("%s.NW.Cl%s.png", input$subject, res_num)
    rel     <- file.path("data","new_mdf", "res_img", file_nm)   # src is relative to www/
    abs     <- file.path("www", rel)                      # filesystem check
    list(rel = rel, abs = abs, file_nm = file_nm)
  })
  
  # show_img <- reactive({
  #   p_img <- img_paths()
  #   input$subject %in% c("Antimicrobial" , "Vaccine", "Antibody", "Tcell", "Cytokine",  "Mouse","Patient","Primate","Organoid",  "Plasmodium", "Schisto", "Leishmania",  "VSV","Adenovirus","Subunit","DNAv","MVA","Nano",   "Alpha","Arena","CCHF","Dengue","Ebola","Flavivirus","Hanta","HBV","HCV","HIV","Influenza","Measles","Nipah","Polio","Pox","Rabies","Rotavirus","RSV","SARS",  "Yersinia","Bordetella","Burkholderia","Campylobacter","Cholera","Francisella","Neisseria","Pseudomonas","Salmonella","Streptococcus","Staphylococcus","tuberculosis","Bacillus","Haemophilus","Lyme") && file.exists(p_img$abs)

  # })

  show_img <- reactive({
    p_img <- img_paths()
    input$subject %in% cit_nw_subject_list && file.exists(p_img$abs)

  })
  
  ##### ---- End - Citation Network Graph: Network Image output-Helper for server ---- #####
  
  #####===== UI-Panel(Browse Network) -- Citation Network Graph : Output print after "Network-search-btn" ====####
  observeEvent(input$cit_nw_nt_citnw_search_btn,{
    ##### Variables required to generate plots and tables for "Timeline Plot"-section #####
    req(merged_data)
    check<-merged_data()
    req(input$subject)
    nw_name<- input$subject
    dt_mdf<- check$mdf
    req(input$resolution)

    cit_nw_paper_ct<- nrow(dt_mdf)
    print(paste0("cit_nw_paper_ct:",cit_nw_paper_ct))
    res1input <- as.numeric(sub("res_", "", input$resolution))
    btn_id <- paste0("min_btn_citnw", res1input)
    body_id <- paste0("panel_body_citnw", res1input)
      
    ##### End - Variables required to generate plots and tables for "Timeline Plot"-section #####
      
      ##### Citation Network Graph: Plot-Plotly output #####
      output$cit_nw_nt_plot_for_cluster_plot <- renderPlotly({
        req(!show_img())
        req(merged_data)
        check<-merged_data()
        req(input$subject)
        nw_name<- input$subject
        dt_mdf<- check$mdf
        req(input$resolution)
        req(dt_mdf)
        # pick subject config with default fallback
        subj <- as.character(input$subject)
        subj_cfg <- ranges_cfg$subjects[[subj]]
        if (is.null(subj_cfg)) subj_cfg <- ranges_cfg$subjects$`default`
        
        # extract keywords with fallback to default; coerce robustly
        get_keywords <- function(cfg, fallback_cfg) {
          kw <- cfg$keywords
          if (is.null(kw)) kw <- fallback_cfg$keywords
          kw <- unique(trimws(unlist(kw, use.names = FALSE)))
          kw[nzchar(kw)]
        }
        
        # zoomot_nt_keywords <- trimws(unlist(strsplit(input$cit_nw_pmid_nt_bot_keywords, ",")))
        # zoomot_nt_keywords<- c("Outbreak","Patient","Vaccine","Antiviral","Antibody","Cytokine","Severe","Bats")
        zoomot_nt_keywords <- get_keywords(subj_cfg, ranges_cfg$subjects$`default`)
        
        #hard fallback in case YAML has none:
        if (length(zoomot_nt_keywords) == 0) {
          zoomot_nt_keywords <- c("Outbreak","Patient","Vaccine","Antiviral","Antibody","Cytokine","Severe","Bats")
        }
        # Initialize match_color
        dt_mdf$match_color <- "none"
        # Ensure match_color is a factor with keyword order
        
        dt_mdf$match_color <- factor(dt_mdf$match_color, levels = zoomot_nt_keywords)
        cit_nw_nt_keyword_columns <- c("abstract", "title", "pmid")
        
        
        
        for (kw in zoomot_nt_keywords) {
          if (nzchar(kw)) {
            matches <- Reduce(`|`, lapply(cit_nw_nt_keyword_columns, function(col) {
              grepl(kw, dt_mdf[[col]], ignore.case = TRUE)
            }))
            dt_mdf$match_color[matches] <- kw
          }
        }
        
        keyword_nt_colors <- setNames(rainbow(length(unique(dt_mdf$match_color))), unique(dt_mdf$match_color))
        color_palette <- c("none" = scales::alpha("grey60", 0.25), keyword_nt_colors)
        
        res1input <- as.numeric(sub("res_", "", input$resolution))
        fill_res_pt1<-paste0("llmlabelcl",res1input)
        
        cit_nw_label_centroids <- dt_mdf %>%
          group_by(.data[[fill_res_pt1]]) %>%        # group by the keyword / color category
          # group_by(llmlabelcl1) %>%
          summarise(
            mean_x = mean(x, na.rm = TRUE),        # average year
            # mean_y = mean(.data[[y_col]], na.rm = TRUE), # average y-value (e.g. score)
            mean_y = mean(y, na.rm = TRUE), # average y-value (e.g. score)
            # label  = first(.data[[fill_res_label]]),               # or a custom label
            .groups = "drop"
          )
        
        #add in global.R?
        
        # pick subject block or fall back to default (no function needed)
        subj_cfg <- ranges_cfg$subjects[[as.character(input$subject)]]
        if (is.null(subj_cfg)) subj_cfg <- ranges_cfg$subjects$default
        
        # coerce, sanity, and use
        x_range <- c(sort(as.numeric(subj_cfg$x)))
        y_range <- c(sort(as.numeric(subj_cfg$y)))
        
        p <- ggplot(dt_mdf, aes(x = x, y = y)) +
          geom_point(
            aes(
              color = match_color,
              customdata = if ("url" %in% names(dt_mdf)) url else NULL,
              text = paste0("PMID: ", pmid, "<br>", "Title: ", title)
            ),
            
            size = 0.5,
            alpha = 0.85
          ) +
          geom_text(data = cit_nw_label_centroids, aes(x = mean_x, y = mean_y, label = .data[[fill_res_pt1]]),
                    # geom_text(data = cit_nw_label_centroids, aes(x = mean_x, y = mean_y, label = .data[[fill_res_pt1]],customdata = .data[[fill_res_pt1]]),
                    color = "black", fontface = "bold",size = 5.2, show.legend = FALSE, vjust = -0.5,inherit.aes = FALSE)+
          
          scale_color_manual(
            values = color_palette,
            guide = guide_legend(title = NULL,
                                 override.aes = list(size = 4, alpha = 1)),
            na.value = scales::alpha("grey60", 0.25)  # extra safety
          ) +
          guides(size = "none") +
          labs(x = NULL, y = NULL,title = paste0(nw_name, " Citation Network: ",cit_nw_paper_ct, " articles")) +
          
          
          theme_minimal(base_size = 12) +
          
          theme(
            axis.text  = element_blank(),
            axis.ticks = element_blank(),
            axis.title = element_blank(),
            axis.line  = element_blank(),
            panel.grid = element_blank(),
            plot.title = element_text(color = "#2167d9", size = 24, face = "bold", hjust = 0.5,margin = margin(b = 24))
          ) +
          coord_cartesian(xlim = x_range, ylim = y_range)
        
        #Convert to plotly
        p_plotly_obj <- plotly::ggplotly(p, tooltip = "text", height = 1000)
        p_plotly_obj
      })
      ##### End - Citation Network Graph: Plot-Plotly output #####
      
      ##### Citation Network Graph: Data Table output ##### 
      output$cit_nw_nt_plot_for_cluster_dt <- renderDT({
        req(!show_img()) 
        req(merged_data)
        check<-merged_data()
        req(input$subject)
        nw_name<- input$subject
        dt_mdf<- check$mdf
        req(input$resolution)
        req(dt_mdf)
        # pick subject config with default fallback
        subj <- as.character(input$subject)
        subj_cfg <- ranges_cfg$subjects[[subj]]
        if (is.null(subj_cfg)) subj_cfg <- ranges_cfg$subjects$`default`
        
        # extract keywords with fallback to default; coerce robustly
        get_keywords <- function(cfg, fallback_cfg) {
          kw <- cfg$keywords
          if (is.null(kw)) kw <- fallback_cfg$keywords
          kw <- unique(trimws(unlist(kw, use.names = FALSE)))
          kw[nzchar(kw)]
        }
        
        # zoomot_nt_keywords <- trimws(unlist(strsplit(input$cit_nw_pmid_nt_bot_keywords, ",")))
        # zoomot_nt_keywords<- c("Outbreak","Patient","Vaccine","Antiviral","Antibody","Cytokine","Severe","Bats")
        zoomot_nt_keywords <- get_keywords(subj_cfg, ranges_cfg$subjects$`default`)
        
        #hard fallback in case YAML has none:
        if (length(zoomot_nt_keywords) == 0) {
          zoomot_nt_keywords <- c("Outbreak","Patient","Vaccine","Antiviral","Antibody","Cytokine","Severe","Bats")
        }
        # Initialize match_color
        dt_mdf$match_color <- "none"
        # Ensure match_color is a factor with keyword order
        
        dt_mdf$match_color <- factor(dt_mdf$match_color, levels = zoomot_nt_keywords)
        cit_nw_nt_keyword_columns <- c("abstract", "title", "pmid")
        
        
        
        
        for (kw in zoomot_nt_keywords) {
          if (nzchar(kw)) {
            matches <- Reduce(`|`, lapply(cit_nw_nt_keyword_columns, function(col) {
              grepl(kw, dt_mdf[[col]], ignore.case = TRUE)
            }))
            dt_mdf$match_color[matches] <- kw
          }
        }
        
        
      
        
        keyword_nt_colors <- setNames(rainbow(length(unique(dt_mdf$match_color))), unique(dt_mdf$match_color))
        color_palette <- c("none" = scales::alpha("grey60", 0.25), keyword_nt_colors)
        
        
        
        
        
        cit_nw_nt_dt <- dt_mdf[, c("pmid", "title", "Ncits","year","abstract","match_color")]
        cit_nw_nt_dt$pmid <- sprintf(
          '<a href="https://pubmed.ncbi.nlm.nih.gov/%s" target="_blank">%s</a>',
          cit_nw_nt_dt$pmid, cit_nw_nt_dt$pmid
        )
        
        setnames(cit_nw_nt_dt, c("pmid", "title", "Ncits","year","abstract", "match_color"),
                 c("PMID", "Title", "#Citations", "Year", "Abstract", "Keyword-Color Match"))
        
        datatable(
          cit_nw_nt_dt,
          rownames = FALSE,
          escape = FALSE,
          extensions = c("Buttons", "Responsive"),
          options   = list(pageLength = 15, autoWidth = TRUE, order = list(list(3, "desc")),
                           columnDefs = list(
                             list(visible = FALSE, targets = 4),  # Abstract
                             # list(visible = FALSE, targets = 5),  # Authors
                             # list(visible = FALSE, targets = 6),   # Unique ID
                             list(className = 'dt-left', targets = 1)
                             
                           ))
          # options = list(
          #   dom = '<"top"Bf>rt<"bottomlip"lip>',
          #   buttons = list(list(extend = "collection", text = "Export", buttons = c("csv","excel"))),
          #   pageLength = 10
          # )
        )
        
      })  
      ##### End: Citation Network Graph: Data Table output ##### 
      
      ##### Citation Network Graph - Render "Citation Network Graph" output #####
      output$cit_nw_nt_plot_for_cluster <- renderUI({
        req(input$subject, input$resolution)
        if (show_img()) {
          p_img <- img_paths()
          return(
            div(class = "cit-nw-main-panel-container cit-nw-boxed",
                div(class="cit-nw-panel-header",
                    style = "display:flex; align-items:flex-start; gap:8px;",
                    actionLink(btn_id, label = NULL, icon = icon("minus-square")),
                    tags$strong("Citation Network Graph")
                ),
                div(id = body_id,
                    tags$img(src = p_img$rel, alt = p_img$file_nm,
                             style = "max-width:100%; height:auto; display:block;"),
                    tags$p(
                      "Note: Keywords are matched against the abstract and title fields. ",
                      "If multiple keywords match, the most recent keyword overrides earlier ones for coloring.",
                      style = "text-align: left; font-style: italic; color: #555; margin-top: 12px;"
                    )
                )
            )
          )
        }
        
        # Fallback UI (placeholders only; heavy renderers are defined below)
        div(class = "cit-nw-main-panel-container cit-nw-boxed",
            div(class="cit-nw-panel-header",
                style = "display:flex; align-items:flex-start; gap:8px;",
                actionLink(btn_id, label = NULL, icon = icon("minus-square")),
                tags$strong("Citation Network Graph")
            ),
            div(id = body_id,
                plotly::plotlyOutput("cit_nw_nt_plot_for_cluster_plot",
                                     height = "1000px", width = "100%"),
                tags$p(
                  "Note: Keywords are matched against the abstract and title fields. ",
                  "If multiple keywords match, the most recent keyword overrides earlier ones for coloring.",
                  style = "text-align: left; font-style: italic; color: #555; margin-top: 12px;"
                ),
                fluidRow(column(12, DT::DTOutput("cit_nw_nt_plot_for_cluster_dt", width = "100%")))
            )
        )
      })
      ##### End: Citation Network Graph - Render "Citation Network Graph" output #####
      
      ##### Citation Network Graph: Handle the minimize box feature #####
    observeEvent(input[[btn_id]], {
      shinyjs::toggle(id = body_id, anim = TRUE, time = 2)
    }, ignoreInit = TRUE)
      ##### Citation Network Graph: Handle the minimize box feature #####

  })
  #####===== End - UI-Panel(Browse Network) -- Citation Network Graph : Output print after "Network-search-btn" ====####
  
  #####==== UI-Panel(Browse Network) -- Timeline Plot : Output after Search-btn (Browse Network plot w/keywords)UI Panel Browse Network Display on Button Click====#####
  observeEvent(input$cit_nw_nt_search_btn, {
    
    ##### Variables required to generate plots and tables for "Timeline Plot"-section #####
      req(input$cit_nw_nt_select_input)
      req(input$resolution)
      req(input$cit_nw_pmid_nt_bot_keywords)
      check_x<-merged_data()
      dt_x<- check_x$x
      dt_nmdf<- check_x$mdf
      llm.1<- check_x$llm.1
      llm.2<- check_x$llm.2
      llm.5<- check_x$llm.5
      llm.10<- check_x$llm.10
      llm.20<- check_x$llm.20
      llm<- check_x$llm
      
      
      #Need an algo to autopopulate the k value with respective cluster_id
      rinput<- input$cit_nw_nt_select_input
      resinput<- input$resolution
      res1input <- as.numeric(sub("res_", "", input$resolution))
      clusnum<-paste0("Cl.",res1input)
      visualize_cluster<- llm$cluster_id[llm$label == rinput & llm$res == paste0("Cl.",res1input,sep="")]
      print(paste0("the cluster number pull ",visualize_cluster))
      print(paste(clusnum,visualize_cluster, sep = "-"))
      
      just_cluster<- llm$description[llm$label == rinput & llm$res == paste0("Cl.",res1input,sep="")]
      print(paste0("Justification check: ", just_cluster))
      
      res2input<-as.numeric(sub("res_","",input$cit_nw_nt_select_subclusterlabel_input))
      ###First Res Vs the sub cluster Res
      resf1input<- paste0("Cl.",res1input)
      resf2input<- paste0("Cl.",res2input)
      print(paste("Resf1input"))
      print(resf1input)
      # k1=7
      k1<- visualize_cluster
      print(k1)

      # k1=7 ; k2=11 ; k5=159 ; k10=155 ; k20=431
      Scluster <- dt_x[get(resf1input) == k1, unique(get(resf2input))]
      # Scluster=unique(dt_x[Cl.1==k1,Cl.5])  # ; Scluster=unique(x3[Cl.1==k1,Cl.5])
      print(paste0("Scluster:",Scluster))
      
      # main=paste0("Cl.1:",k1," ",llm.1[cluster_id==k1,n_entries]," ",llm.1[cluster_id==k1,main]," papers.")  ; desc=llm.1[cluster_id==k1,description]
      # dt_h=dt_nmdf[Cl.1==k1,]
      dt_h <- dt_nmdf[get(resf1input) %in% k1 ]
      # print(paste("DT_h"))
      # print(head(dt_h))
      # print(nrow(dt_h))
      # wd1=llm.1[cluster_id==k1,wd1] ; wd2=llm.1[cluster_id==k1,wd2] ; wd3=llm.1[cluster_id==k1,wd3] ; wd4=llm.1[cluster_id==k1,wd4]
      # wd5=llm.1[cluster_id==k1,wd5] ; wd6=llm.1[cluster_id==k1,wd6] ; wd7=llm.1[cluster_id==k1,wd7] ; wd8=llm.1[cluster_id==k1,wd8]
      # # for (i in 1:length(Scluster)) {kk=Scluster[i]; final_h[i] <- dt_h[dt_h[Cl.5==kk,],dt_h[Cl.5==kk,]]; fh<-final_h;print(nrow(final_h))}
      # fh <- dt_h[Cl.5 %in% Scluster, ]
      fh <- dt_h[dt_h[[resf2input]] %in% Scluster, ]
      # print(head(fh))
      # print(nrow(fh))
      
     
      # --- Parse keywords (keep duplicates & order) ---
      nt_keywords <- trimws(unlist(strsplit(input$cit_nw_pmid_nt_bot_keywords, ",")))
      nt_keywords <- nt_keywords[nzchar(nt_keywords)]
      
      # Build per-occurrence labels so duplicates are distinct in the legend
      # e.g., "cancer, therapy, cancer" -> "cancer [1]", "therapy", "cancer [2]"
      lower_keys <- tolower(nt_keywords)
      print(lower_keys)
      occ_idx <- ave(seq_along(lower_keys), lower_keys, FUN = seq_along)
      labeled_keys <- ifelse(duplicated(lower_keys) | ave(lower_keys == lower_keys, lower_keys, FUN = cumsum) > 1,
                             paste0(nt_keywords, " [", occ_idx, "]"),
                             nt_keywords)
      
      cit_nw_nt_keyword_columns <- c("abstract", "title", "pmid")
      # print(head(cit_nw_nt_keyword_columns))
      
      # --- Choose overwrite behavior ---
      # "last"  = later occurrences (to the right) override earlier ones
      # "first" = first occurrence wins, later ones don't change existing assignments
      overwrite_mode <- "last"   # <-- set to "first" if you prefer first-match-wins
      
      # --- Initialize ---
      # fh$match_color <- "none"
      # fh$matched_keywords <- ""
      
      dt_h$match_color <- "none"
      dt_h$matched_keywords <- ""
      
      # --- Assign colors by occurrence order ---
      for (i in seq_along(nt_keywords)) {
        kw <- nt_keywords[i]
        label_i <- labeled_keys[i]
        
        matches <- Reduce(`|`, lapply(cit_nw_nt_keyword_columns, function(col) {
          # fixed = TRUE to avoid regex surprises; drop if regex semantics
          #grepl(kw, fh[[col]], ignore.case = TRUE, fixed = TRUE)
          # grepl(kw, fh[[col]], ignore.case = TRUE)
          grepl(kw, dt_h[[col]], ignore.case = TRUE)
        }))
        
        # print(head(matches))
        
        # collect all hits 
        # fh$matched_keywords[matches] <- ifelse(
        #   nzchar(fh$matched_keywords[matches]),
        #   paste0(fh$matched_keywords[matches], ", ", label_i),
        #   label_i
        # )
        
        dt_h$matched_keywords[matches] <- ifelse(
          nzchar(dt_h$matched_keywords[matches]),
          paste0(dt_h$matched_keywords[matches], ", ", label_i),
          label_i
        )
        
        if (overwrite_mode == "last") {
          # later keywords/occurrences take precedence
          dt_h$match_color[matches] <- label_i
        } else {
          # first occurrence wins
          to_set <- matches & dt_h$match_color == "none"
          dt_h$match_color[to_set] <- label_i
        }
      }
      
      # Factor levels preserve positional order, with 'none' first
      dt_h$match_color <- factor(dt_h$match_color, levels = c("none", labeled_keys))
      
      # --- Color palette ---
      keyword_levels <- levels(dt_h$match_color)
      keyword_nt_colors <- setNames(rainbow(length(keyword_levels) - 1), keyword_levels[-1])
      color_palette <- c("none" = "gray", keyword_nt_colors)
      
      # --- Build dynamic columns ---
      x_col <- paste0("x", res1input)
      y_col <- paste0("y", res1input)
      
      # print(head(fh, n = 1))
      
      btn_id <- paste0("min_btn_", res1input)
      body_id <- paste0("panel_body_", res1input)
      
    ##### End - Variables required to generate plots and tables for "Timeline Plot"-section #####
      
      ##### Timeline Plot: Plot-Plotly output #####
      p_nt<-ggplot(dt_h, aes(x = .data[["Nyear"]], y = .data[[y_col]], label = title)) +
        # geom_point()+
        geom_point(aes(color = match_color,customdata = url,size = (sqrt(dt_h$Ncits)/3+1)), alpha = 0.7) +
        #geom_point(aes(color = match_color, customdata = url,size = (sqrt(cluster_data$Ncits)/3+1)), alpha = 0.7) +
        # geom_point(aes(color = match_color,size = 0.2), alpha = 0.7) +
        guides(size = FALSE)+
        #gsub("_", " ", input$cit_nw_nt_select_input)
      
        labs(x = "Publication Year", y = NULL,title = paste0("Timeline of Cluster: ",gsub("_", " ", input$cit_nw_nt_select_input), " - ",nrow(dt_h), " articles")) +

        scale_color_manual(values = color_palette, guide = guide_legend(title = NULL))+
        
        theme(
          axis.title.y = element_blank(),
          axis.text.y  = element_blank(),
          axis.line.y = element_blank(),
          axis.ticks.y = element_blank(),
          panel.background = element_rect(fill = "white", colour = NA),
          plot.background   = element_rect(fill = "white", colour = NA),
          legend.background = element_rect(fill = "white", colour = NA),   # legend box
          legend.key        = element_rect(fill = "white", colour = NA),   # legend item bg
          panel.grid = element_blank(),
          plot.title = element_text(color = "#2167d9", size = 18, face = "bold", hjust = 0.5,margin = margin(b = 24))
        )

      # plotly_obj <- plotly::ggplotly(p, tooltip = c("pmid", "title"), source = "cit_nw_pmidplotsource")
      plotly_nt_obj <- plotly::ggplotly(p_nt, tooltip = c("pmid", "title"), height = 1000)%>%
        layout(
          xaxis = list(
            type           = "linear",
            tickmode       = "auto",
            nticks         = 12,
            showticklabels = TRUE,
            ticks          = "outside",
            showline   = TRUE,
            linecolor  = "black",
            linewidth  = 2,
            mirror     = TRUE        # mirror across top,get full vertical box
          ),
          yaxis = list(
            showline   = TRUE,
            linecolor  = "black",
            linewidth  = 2,
            mirror     = TRUE        # ← mirror across right,get full horizontal box
          ),
          hoverlabel = list(font = list(size = 25))
        )
      
      plotly_nt_obj <- htmlwidgets::onRender(plotly_nt_obj,"
            function(el, x) {
              el.on('plotly_click', function(d) {
                if (d.points.length > 0) {
                  var url = d.points[0].customdata;
                  if (url) window.open(url, '_blank');
                }
              });
            }
          ")
      ##### End - Timeline Plot: Plot-Plotly output #####
      
      ##### Timeline Plot: Data Table output #####
      output$cit_nw_nt_pov_tmplot_for_cluster_dt <- renderDT({
        cit_nw_nt_tm_dt <- dt_h[, c("pmid", "title", "Ncits","year","abstract","match_color")]
        cit_nw_nt_tm_dt$pmid <- sprintf(
          '<a href="https://pubmed.ncbi.nlm.nih.gov/%s" target="_blank">%s</a>',
          cit_nw_nt_tm_dt$pmid, cit_nw_nt_tm_dt$pmid
        )
        setnames(cit_nw_nt_tm_dt, c("pmid", "title", "Ncits","year","abstract", "match_color"),
                 c("PMID", "Title", "#Citations", "Year", "Abstract", "Keyword-Color Match"))
        datatable(
          cit_nw_nt_tm_dt,
          rownames = FALSE,
          escape = FALSE,
          extensions = c("Buttons", "Responsive"),
          options   = list(pageLength = 15,
                           dom = '<"top"Bf>rt<"bottomlip"lip>',
                           buttons = list(list(extend = "collection", text = "Export", buttons = c("csv","excel"))),autoWidth = TRUE, order = list(list(3, "desc")),
                           columnDefs = list(
                             list(visible = FALSE, targets = 4),  # Abstract
                             # list(visible = FALSE, targets = 5),  # Authors
                             # list(visible = FALSE, targets = 6),   # Unique ID
                             list(className = 'dt-left', targets = 1)
                            )),
                            callback = JS(
                           "var node = table.table().node();",
                           "$(node).off('click.dt').on('click.dt', 'tbody td', function(){",
                           "  var info = table.cell(this).index();",
                           "  var rowData = table.row(info.row).data();",
                           "  var clickedCol = info.column;",            
                             "  var abstractInfo = rowData[4];", 
                           "  Shiny.setInputValue('selected_bc_pmid_row', {col: clickedCol, abstract: abstractInfo}, {priority:'event'});",
                           "});")
        )
        })



      observeEvent(input$selected_bc_pmid_row, ignoreInit = TRUE, {
      req(input$selected_bc_pmid_row)
      if (input$selected_bc_pmid_row$col == 1) {  # change 0 to your target column index
        showModal(modalDialog(
          title = "Abstract:",
          div(style = "white-space: pre-wrap;", input$selected_bc_pmid_row$abstract),
          easyClose = TRUE,
          footer = NULL
        ))
      }
    })
      ##### End - Timeline Plot: Data Table output #####
      
      ##### Timeline Plot: Render "timeline plot" output #####
      output$cit_nw_nt_pov_tmplot_for_cluster <- renderUI({                                       
        div(class = "cit-nw-main-panel-container cit-nw-boxed",
            div(class="cit-nw-panel-header",style = "display:flex; align-items:flex-start; gap:8px;",
                actionLink(btn_id, label = NULL, icon = icon("minus-square")),
                tags$strong(paste0("Timeline Plot")),
                br(),
                br(),),
            div(id = body_id,
                
                # ---- CONDITIONAL PLOT ----
                if (nrow(dt_h) <= 4000) {
                  plotly_nt_obj
                } else {
                  tags$em(
                    "Plot suppressed because the dataset has more than 4000 rows.",
                    style = "color:#a00;"
                  )
                },
             # plotly_nt_obj,
             tags$p("Summary of Articles in the Cluster: ",just_cluster,style = "text-align: left; color: #555; margin-top: 12px;"),
             tags$p(
            "Note: Keywords are matched against the abstract,and title fields. ",
            "If multiple keywords match, the most recent keyword overrides earlier ones for coloring.",
            style = "text-align: left; font-style: italic; color: #555; margin-top: 12px;"
          ),
          fluidRow(column(12, DT::DTOutput("cit_nw_nt_pov_tmplot_for_cluster_dt", width = "100%"))),
         )
         )})
      ##### End - Timeline Plot: Render "timeline plot" output #####
      
      ##### Timeline Plot: Handle the minimize box feature #####
      observeEvent(input[[btn_id]], {
        shinyjs::toggle(id = body_id, anim = TRUE, time = 2)
      }, ignoreInit = TRUE)
      ##### End - Timeline Plot: Handle the minimize box feature #####
     })
  ######==== End - UI-Panel(Browse Network) -- Timeline Plot : Output after Search-btn (Browse Network plot w/keywords)====######

  #####==== UI-Panel(Browse Network) -- Cluster Graph : Output after Search-btn (Resolution x3) ====#####
  observeEvent(input$cit_nw_subnt_search_btn, { 
    
    ##### Variables required to generate plots and tables for "Cluster Graph"-section #####
    check_x<-merged_data()
    req(input$cit_nw_nt_select_input)
    req(input$resolution)
    req(input$cit_nw_nt_select_subclusterlabel_input)
      
    dt_x<- check_x$x
    dt_nmdf<- check_x$mdf
    llm.1<- check_x$llm.1
    llm.2<- check_x$llm.2
    llm.5<- check_x$llm.5
    llm.10<- check_x$llm.10
    llm.20<- check_x$llm.20
    llm<- check_x$llm
      
    rinput<- input$cit_nw_nt_select_input
    # res1input<- input$resolution
    res1input <- as.numeric(sub("res_", "", input$resolution))
    res2input<-as.numeric(sub("res_","",input$cit_nw_nt_select_subclusterlabel_input))
    clusnum<-paste0("Cl.",res1input)
    visualize_cluster<- llm$cluster_id[llm$label == rinput & llm$res == paste0("Cl.",res1input,sep="")]
    print(paste0("the cluster number pull ",visualize_cluster))
    # print(paste(rinput,clusnum,visualize_cluster, sep = "-"))
    #show_cluslabel
    just_cluster<- llm$description[llm$label == rinput & llm$res == paste0("Cl.",res1input,sep="")]
    ###First Res Vs the sub cluster Res
    resf1input<- paste0("Cl.",res1input)
    resf2input<- paste0("Cl.",res2input)
    # k1=7
    k1<- visualize_cluster
    print(paste0("ref2input: check", resf2input))
    print(paste0("Subcluster Resolution:",input$cit_nw_nt_select_subclusterlabel_input))
    # k1=7
    # k1=7 ; k2=11 ; k5=159 ; k10=155 ; k20=431
    # Scluster=unique(dt_x[Cl.1==k1,Cl.5])  # ; Scluster=unique(x3[Cl.1==k1,Cl.5])
    # Scluster=unique(dt_x[resf1input==k1,resf2input])
    Scluster <- dt_x[get(resf1input) == k1, unique(get(resf2input))]
    print(paste0("Scluster:",Scluster))
    # dt_h=dt_nmdf[Cl.1==k1,]
    # dt_h=dt_nmdf[resf1input==k1,]
    dt_h <- dt_nmdf[ get(resf1input) %in% k1 ]
    # fh <- dt_h[resf2input %in% Scluster, ]
    fh <- dt_h[dt_h[[resf2input]] %in% Scluster, ]
    # Build column names dynamically
    x_col <- paste0("x", res1input)
    y_col <- paste0("y", res1input)
    fill_col <- paste0("llmlabelcl", res2input)
    # Optional: guard against missing columns
    stopifnot(all(c(x_col, y_col, fill_col) %in% names(dt_h)))
    fill_res<-paste0("llmlabelcl",res2input)
    btn_id <- paste0("min_btn_tm_clus", res1input)
    body_id <- paste0("panel_body_tm_clus", res1input)
    
    ##### End: Variables required to generate plots and tables for "Cluster Graph"-section #####
      
      ##### Cluster Plot: Plot-Plotly output #####
      p_nt<-ggplot(dt_h, aes(x = .data[[x_col]], y = .data[[y_col]], label = title))+
        geom_point(aes(color = .data[[fill_res]], fill = .data[[fill_res]]))+
                   # shape = 21, size = 2.5, stroke = 0.3) +
        labs(x = NULL, y = NULL,title = paste0("Cluster: ",input$cit_nw_nt_select_input, "; ",nrow(dt_h), " articles"),
             color = "Resolution based labels",    # <-- legend title(s) here
             fill  = "Resolution based labels") +
        guides(color = guide_legend(title = "Resolution based labels"),
               fill  = guide_legend(title = "Resolution based labels")) +
        theme_minimal(base_size = 12) +
        theme(
          axis.title = element_blank(),
          axis.text  = element_blank(),
          axis.line = element_blank(),
          axis.ticks = element_blank(),
          panel.grid = element_blank(),
          plot.title = element_text(color = "#2167d9", size = 18, face = "bold", hjust = 0.5,margin = margin(b = 24))
        ) 
      # plotly_obj <- plotly::ggplotly(p, tooltip = c("pmid", "title"), source = "cit_nw_pmidplotsource")
      plotly_fnt_obj <- plotly::ggplotly(p_nt, tooltip = c("pmid", "title"), height = 1000)
      
      ##### End - Cluster Plot: Plot-Plotly output #####
      
      ##### Cluster Graph plot: JS Legend reactiveness #####
  #     plotly_fnt_obj<- htmlwidgets::onRender(plotly_fnt_obj, "function(el, x){
  #     function sendName(ev){
  #       var cn = ev && ev.curveNumber;
  #       if(cn == null) return false;
  #       var tr = (x.data || [])[cn];
  #       if(!tr || !tr.name) return false;
  #       if(window.Shiny){
  #         Shiny.setInputValue('legend_clicked', tr.name, {priority:'event'});
  #       }
  #       // prevent default toggling; delete this 'return false' to keep Plotly's toggle behavior
  #       return false;
  #     }
  #     el.on('plotly_legendclick', sendName);
  #     el.on('plotly_legenddoubleclick', sendName);
  #   }
  # ")
      ##### End - Cluster Graph plot: JS Legend reactiveness #####
      
      ##### Adding to generate reactive legend plots on the clusters(Cluster Plot)#####
      selected_cluster_llm_table <- reactive({
         selclus<- input$clus_legend_selected
         print(paste0("Selclus",selclus))
        if (is.null(selclus) || !length(selclus)) character(0) else selclus
        })
      ##### End-Adding to generate reactive legend plots on the clusters#####
      
      ##### Cluster Plot: Data Table output #####
      output$cit_nw_nt_pov_plot_for_cluster_dt <- renderDT({
        req(fill_res)
        print(paste0("fill_res",fill_res))
        # cit_nw_nt_tmplot_dt <- fh[, c("pmid", "title", "Ncits","year","abstract","match_color",fill_res)]
        cols <- c("pmid", "title", "Ncits", "year", "abstract", fill_res)
        cit_nw_nt_tmplot_dt <- dt_h[, ..cols]
        cit_nw_nt_tmplot_dt$pmid <- sprintf(
          '<a href="https://pubmed.ncbi.nlm.nih.gov/%s" target="_blank">%s</a>',
          cit_nw_nt_tmplot_dt$pmid, cit_nw_nt_tmplot_dt$pmid
        )
        setnames(cit_nw_nt_tmplot_dt, c("pmid", "title", "Ncits","year","abstract",fill_res),
                 c("PMID", "Title", "#Citations", "Year", "Abstract","Resolution based Labels"))
        datatable(
          cit_nw_nt_tmplot_dt,
          rownames = FALSE,
          escape = FALSE,
          extensions = c("Buttons", "Responsive"),
          options   = list(pageLength = 15,
                           #position of "Export"
                           dom = '<"top"Bf>rt<"bottomlip"lip>',
                           buttons = list(list(extend = "collection", text = "Export", buttons = c("csv","excel"))),
                           autoWidth = TRUE, order = list(list(3, "desc")),
                           columnDefs = list(
                             list(visible = FALSE, targets = 4),  # Abstract
                             # list(visible = FALSE, targets = 5),  # Authors
                             # list(visible = FALSE, targets = 6),   # Unique ID
                             list(className = 'dt-left', targets = 1)
                             
                           )))
        })
      ##### End - Cluster Plot: Data Table output #####
      
      ##### Cluster Plot: Sub-Plot output #####
      output$subPlottimeline <- plotly::renderPlotly({
        vals <- sort(unique(dt_h[[fill_res]]))
        pal  <- setNames(scales::hue_pal()(length(vals)), vals)
        # req(nrow(fh) > 1000, input$legend_clicked)
        req(input$legend_clicked)
        cat_name <- as.character(input$legend_clicked)
        
        df <- dt_h[dt_h[[fill_res]] == cat_name, , drop = FALSE]

        p_sub_nt <- ggplot(
          df,
          aes(x = Nyear, y = .data[[y_col]], label = title)
        ) +
          geom_point(
            shape = 21, size = 2.8, stroke = 0.25,
            fill = pal[[cat_name]], color = pal[[cat_name]], alpha = 0.95
          ) +
          labs(x = "Publication year", y = NULL,
               title = paste0("Cluster: ", cat_name, " — ", nrow(df), " articles")) +
          theme_minimal(base_size = 12) +
          theme(
            legend.position = "none",
            axis.title.y = element_blank(),
            axis.text.y  = element_blank(),
            axis.line.y = element_blank(),
            axis.ticks.y = element_blank(),
            panel.grid = element_blank(),
            plot.title = element_text(size = 16, face = "bold",
                                      hjust = 0.5, margin = margin(b = 12))
          )

        
      plotly_fnt_sub_obj <- plotly::ggplotly(p_sub_nt, tooltip = c("pmid", "title"), height = 1000)%>%
        layout(
          xaxis = list(
            showline   = TRUE,
            linecolor  = "black",
            linewidth  = 2,
            mirror     = TRUE        # mirror across top,get full vertical box
          ),
          yaxis = list(
            showline   = TRUE,
            linecolor  = "black",
            linewidth  = 2,
            mirror     = TRUE        # ← mirror across right,get full horizontal box
          )
        )
      })  
      ##### End - Cluster Plot: Sub-Plot output #####
      
      ##### Cluster Plot: Render "cluster plot" output #####
      output$cit_nw_nt_pov_plot_for_cluster <- renderUI({
        div(class = "cit-nw-main-panel-container cit-nw-boxed",
            div(class="cit-nw-panel-header",
                style = "display:flex; align-items:flex-start; gap:8px;",
                actionLink(btn_id, label = NULL, icon = icon("minus-square")),
                tags$strong(paste0("Cluster Graph")),
                br(),
                br(),
                ),
            div(id = body_id,
                plotly_fnt_obj,
                tags$p("Summary of Articles in the Cluster: ",just_cluster,style = "text-align: left; color: #555; margin-top: 12px;"),fluidRow(column(12, DT::DTOutput("cit_nw_nt_pov_plot_for_cluster_dt", width = "100%"))),
                br(),
                br(),
                br(),
                # fluidRow(column(12, plotly::plotlyOutput("subPlottimeline", height = "800px", width = "100%"))),
                # uiOutput("subtimeline_holder"),
                # plotly::plotlyOutput("subPlottimeline", height = "800px", width = "100%")
                ))
        })
      ##### End - Cluster Plot: Render "cluster plot" output #####
    
      ##### Cluster Graph: Handle the minimize box feature #####
      observeEvent(input[[btn_id]], {
        shinyjs::toggle(id = body_id, anim = TRUE, time = 2)}, ignoreInit = TRUE)
      ##### End - Cluster Graph:Handle the minimize box feature #####
    
      
      
      
      
    ####==== End: Pov timeline plot third plot ====#
    })
  #####==== End - UI-Panel(Browse Network) -- Cluster Graph : Output after Search-btn ====#####
  
  ######==== ***End:Browse Network*** =====######
  #----------------------------------------------------------------------------#
  #####==== Show modal when help(?) button is clicked[Keyword Search ] ====#####
  observeEvent(input$cit_nw_keyword_search_help, {
    showModal(modalDialog(
          title = "How to Use Keyword Search",
          # HTML("<p>Enter keywords separated by commas to filter the cluster. The keyword search is searching in abstract,title and pmid. The first keyword entered plots first and if the second keyword is found in the same paper it overlaps on top. Thus, using the pmid number at the end highlights the paper regardless of keyword search.</p>
          #  <p><b>Example:</b> vaccine, virus, immunity</p>"),
          easyClose = TRUE,
          footer = modalButton("Done"),
          tags$div(
            tags$p("Enter one or more keywords (separated by commas) to filter the cluster data. 
             The search checks for matches in the abstract, title, and PubMedID fields."),
            tags$ul(
              tags$li("The first keyword entered will be plotted first."),
              tags$li("If a paper contains multiple keywords, it will be highlighted with the most recent keyword on top (overlapping colors)."),
              tags$li("Make sure to enter the PubMed ID at the end if you want to ensure it remains visible, especially when overlapping keywords are involved.")
            ),
            tags$p(tags$strong("Example:"), "Typing interleukin, igg, igm, 40178639 will highlight all papers that mention “interleukin”; 
                   if some also mention “igg,” those will be layered on top of interleukin. Including 40178639 at the end ensures that paper is highlighted even if covered by other keyword colors."),
            tags$p(tags$em("Note: Keyword matching is not case-sensitive."))
          )
        ))
      })
  
  #####==== End:Show modal when help button is clicked ====#####


  #####==== Show modal when help(?) button is clicked[PMID Search ] ====#####
  observeEvent(input$cit_nw_pmid_search_help, {
    showModal(modalDialog(
          title = "How to Use PMID Search",
          easyClose = TRUE,
          footer = modalButton("Done"),
          tags$div(
            tags$div(
              tags$p("Enter a PubMed ID (PMID) to search for this paper across available networks."),
              tags$ul(tags$li("Shows which network(s) contain the PMID and lets you view the network at different resolutions."),
              tags$li("Displays the cluster label and an explanation of why the paper belongs to that cluster.")
              )
              ),
              tags$p(tags$em("Note: PubMed literature related to vaccine development research."))
          )
        ))
      })
  
  #####==== End:Show modal when help button is clicked ====#####
  
  ##### Check the reactive values #####
  # output$debug_reactive_vals <- renderPrint({
  #   list(
  #     cit_nw_valid_pmid = cit_nw_valid_pmid(),
  #     matching_clusters_rv = cit_nw_matching_pathogencluster(),
  #     selected_pmid = input$cit_nw_pmid_input,
  #     selected_cluster_llm_table = input$cit_nw_pmid_pathogencluster_select_dd,
  #     search_triggered = input$cit_nw_search_btn
  #   )
  # })
  ##### End: Check the reactive values #####
  
  
  
  allclx<- readRDS("www/data/new_mdf/All.xcl.RDS")
  #allclx>>org
  org<-allclx
  roots <- sort(unique(org$network))
  ##### === UI Panel(Cluster Visualization) -- "Cluster Visualization" btn click === #####
  # observeEvent(input$cit_nw_show_nw_clusviz, {
  #   #show a placeholder at the top (no default selected)
  #   subjects <- list_subjects()
  #   choices_grouped <- make_grouped_choices(subjects)
  #   output$cit_nw_tab <- renderUI({ NULL })
  #   output$cit_nw_cluster_tab <- renderUI({ NULL })
  #   output$cit_nw_pmid_tab <- renderUI({ NULL })
  #   output$cit_nw_timeline_tab <- renderUI({ NULL })
  #   
  #   req(split_all_llm_data())
  #   cit_nw_cluster_llmlabel_data<- split_all_llm_data()
  #   
  #   ##### Browse Network: Render #####
  #   output$cit_nw_clusviz_tab <- renderUI({
  #     tagList(
  #       
  #       selectInput("root", "Network of interest:", choices = roots, selected = "Ebola"),
  #       selectInput("res","Resolution", choices = c(1, 2, 5, 10), selected = ""),
  #       uiOutput("tree_title"),
  #       fluidRow(
  #         column(8,div(
  #           style = "border:1px solid #ddd; border-radius:4px; padding:10px;",
  #           collapsibleTreeOutput(outputId = "tree",
  #                                 width = "100%",
  #                                 height = "1000px" ))
  #         ),
  #         column(4,div(style="border:1px solid #ddd; padding:10px;",
  #                      tags$h4("Cluster Details"),
  #                      tableOutput("node_table")
  #                      #DT: DTOutput("node_table")
  #         ))
  #       ),
  #       
  #       # br(), br(),
  #       # div(class = "cit-nw-search-container",
  #       #     actionButton("cit_nw_keyword_search_help", "?", class = "cit-nw-help-button"),
  #       #     selectInput("cit_nw_pov_llm_cluster_option", "Louvain clustering for:", choices = names(cit_nw_cluster_llmlabel_data)),
  #       #     actionButton("cit_nw_cluster_search_btn", "Search"),
  #       # ),
  #       br(), br(),
  #       # div(class = "cit-nw-main-panel-container",
  #       #     DT::dataTableOutput("cit_nw_llm_table_for_cluster"),
  #       # ),
  #       br(), br(),
  #       
  #       br(), br(),
  #       # div(class = "cit-nw-search-container",
  #       #     actionButton("cit_nw_keyword_search_help", "?", class = "cit-nw-help-button"),
  #       #     selectInput(
  #       #       "subject",
  #       #       label   = "Enter network of interest:",
  #       #       # choices = list_subjects(),
  #       #       choices  = c("— Select a subject —" = "", choices_grouped),
  #       #       selected = "Ebola",
  #       #       multiple = FALSE
  #       #     ),
  #       #     br(),
  #       #     radioButtons(
  #       #       "resolution",
  #       #       label = NULL,
  #       #       choices = resolutions,
  #       #     ),
  #       #     br(),
  #       #     actionButton("cit_nw_nt_citnw_search_btn", "Network Plot"),
  #       #     br(),
  #       #     #I need a condition here, so using uiOutput instead of direct selectInput
  #       #     #Placeholder for the select input
  #       #     # uiOutput("cit_nw_nt_select_input"),
  #       #     uiOutput("cit_nw_nt_pathogencluster_select_dd"),                 # <-- must match output$dd below
  #       #     verbatimTextOutput("dbg"),  
  #       #     uiOutput("cit_nw_nt_clustertm_keywords"),
  #       #     actionButton("cit_nw_nt_search_btn", "Timeline Plot"),
  #       #     br(),
  #       #     uiOutput("cit_nw_nt_cluster_label_dd"),
  #       #     actionButton("cit_nw_subnt_search_btn", "Cluster Plot"),
  #       # ),
  #       # br(), br(),
  #       # div(class = "cit-nw-main-panel-container",
  #       #     uiOutput("cit_nw_nt_plot_for_cluster"),
  #       #     br(),
  #       #     uiOutput("cit_nw_nt_pov_tmplot_for_cluster"),
  #       #     br(),
  #       #     uiOutput("cit_nw_nt_pov_plot_for_cluster"),
  #       #     br(), br(),br(),
  #       #     # DT::dataTableOutput("cit_nw_nt_pov_tm_for_cluster"),
  #       # ),
  #       br(), br()
  #     )
  #   })
  #   ##### End: Browse Network: Render #####
  # })
  ##### === End: UI Panel(Browse Network) -- "Browse Network" btn click === #####
  ##### Clust Viz
  
  
  
  table_mode <- reactiveVal("full")   # "full" or "node"
  
  # When a node is clicked, switch to node mode
  observeEvent(input$clicked_node, {
    if (!is.null(input$clicked_node)) table_mode("node")
  }, ignoreInit = TRUE)
  
  # Button switches back to full mode
  observeEvent(input$show_full_table, {
    table_mode("full")
  }, ignoreInit = TRUE)
  
  output$tree_title <- renderUI({
    tags$h3(
      paste0(input$root, " Network Cluster Tree"),
      style = "
      text-align: center;
      font-size: 50px;
      font-weight: 700;
      color:  #2167d9;
      margin: 10px 0 15px 0;
    "
    )
  })
  
  output$cit_nw_tree_body_ui <- renderUI({
    req(isTRUE(rv_cit_nw$tree_open))
    
    div(
      id = cit_nw_tree_body_id,
      
      br(), br(),
      selectInput("root", "Network of interest:", choices = roots, selected = "Ebola"),
      selectInput("res","Resolution", choices = c(1, 2, 5, 10), selected = ""),
      br(), br(),
      uiOutput("tree_title"),
      
      fluidRow(
        class = "no-gutters",
        column(
          8, style="padding:0;",
          div(
            id = "tree_scroll",
            style = "border:1px solid #ddd; border-radius:4px; padding:10px;
                   overflow-x:auto; overflow-y:auto; white-space:nowrap;",
            div(
              collapsibleTreeOutput(outputId = "tree", width = "2200px", height = "1000px")
            )
          )
        ),
        column(
          4,
          div(
            id = "cluster_details_panel",
            style="border:1px solid #ddd; padding:10px;",
            tags$h4("Cluster Details"),
            br(), br(),
            actionButton("show_full_table", "Show full table", icon = icon("table")),
            br(), br(),
            DT::DTOutput("node_table")
          )
        )
      )
    )
  })
  
  
  
  
  # output$tree_title <- renderUI({
  #   #req(input$root, current_res)
  #   tags$h3(
  #     paste0(
  #       input$root
  #     )
  #   )
  # })
  
  
  # output$tree <- renderCollapsibleTree({
  #   xorg<-org[org$network == input$root,]
  #   #print(head(xorg))
  #   current_res <- as.numeric(gsub("\\D+", "", as.character(input$res)))
  #   print(current_res)
  #   llmoi<- paste0("llmlabelcl",current_res)
  #   
  #   # allowed hierarchy levels (in increasing order)
  #   levels_allowed <- c(1, 2, 5, 10, 20)
  #   
  #   # # current_res is the selected/active resolution (e.g. 1,2,5,10,20)
  #   # current_res <- current_res  # whatever you already have
  #   
  #   # build the hierarchy column names excluding current_res,
  #   # but only keeping levels above it
  #   hierarchy_cols <- paste0("llmlabelcl", levels_allowed[levels_allowed >= current_res])
  #   
  #   paste("Hierarchu_cols")
  #   print(hierarchy_cols)
  #   
  #   # Get the highest resolution level to match entries
  #   if (length(hierarchy_cols) > 0) {
  #     highest_col <- hierarchy_cols[length(hierarchy_cols)]
  #     res_num <- as.integer(gsub("\\D", "", highest_col))
  #     nw_join_res <- paste0("Cl.", res_num)
  #     
  #     if (nw_join_res %in% names(xorg)) {
  #       # Build network_cluster key for each row
  #       xorg$network_cluster <- paste0(input$root, "-", nw_join_res, "-", xorg[[nw_join_res]])
  #       
  #       # Match to cit_nw_llm_dt to get n_entries
  #       xorg$entries <- cit_nw_llm_dt[match(xorg$network_cluster, cit_nw_llm_dt$network_cluster), n_entries]
  #       
  #       # Set NA values to 1
  #       xorg$entries[is.na(xorg$entries)] <- 1
  #       
  #       xorg$entries <- log10(xorg$entries + 1)
  #       # Set first row (root level) to default size
  #       # xorg$entries[1] <- 10
  #       
  #       # xorg$entries <- sqrt(xorg$entries/10)
  #     } else {
  #       xorg$entries <- 1
  #     }
  #   } else {
  #     xorg$entries <- 1
  #   }
  #   
  #   print(head(xorg))
  #   collapsibleTree(
  #     xorg,
  #     hierarchy = hierarchy_cols,
  #     root = input$root,
  #     collapsed = TRUE,
  #     fontSize = 16,
  #     inputId = "clicked_node",
  #     nodeSize = "entries",
  #     zoomable = FALSE,
  #     fill = "#2167d9"
  #     
  #   )
  #   
  #   
  #   
  #   
  # })
  
  
  
  
  
  
  output$tree <- renderCollapsibleTree({
    
    
    
    xorg <- org[org$network == input$root,]
    current_res <- as.numeric(gsub("\\D+", "", as.character(input$res)))
    
    cit_nw_tree_btn_id <- paste0("min_btn_", current_res)
    cit_nw_tree_body_id <- paste0("panel_body_", current_res)
    
    
    levels_allowed <- c(1, 2, 5, 10, 20)
    hierarchy_cols <- paste0("llmlabelcl", levels_allowed[levels_allowed >= current_res])
    #print(head(xorg[, hierarchy_cols, with=FALSE]))
    #Get the highest resolution level to match entries
    if (length(hierarchy_cols) > 0) {
      highest_col <- hierarchy_cols[length(hierarchy_cols)]
      res_num <- as.integer(gsub("\\D", "", highest_col))
      nw_join_res <- paste0("Cl.", res_num)
      
      if (nw_join_res %in% names(xorg)) {
        # Build network_cluster key for each row
        xorg$network_cluster <- paste0(input$root, "-", nw_join_res, "-", xorg[[nw_join_res]])
        
        # Match to cit_nw_llm_dt to get n_entries
        xorg$entries <- cit_nw_llm_dt[match(xorg$network_cluster, cit_nw_llm_dt$network_cluster), n_entries]
        
        # Set NA values to 1
        xorg$entries[is.na(xorg$entries)] <- 1
        # xorg$entries <- scales::rescale(log(xorg$entries + 1), to = c(3, 12))
        
        #print(head(xorg))
        # xorg$entries <- log10(xorg$entries+0.1)
        xorg$entries<- sqrt(xorg$entries/60+0.1)
        
      } else {
        xorg$entries <- 1
      }
    } else {
      xorg$entries <- 1
    }
    
    
    # btn_id <- paste0("cit_nw_tree_min_btn_", res1input)
    # body_id <- paste0("cit_nw_tree_panel_body_", res1input)
    
    #css_styles,
    w <- collapsibleTree(
      xorg,
      hierarchy = hierarchy_cols,
      root = input$root,
      collapsed = TRUE,
      fontSize = 14,
      tooltip = TRUE,
      inputId = "clicked_node",
      #width = NULL,
      width = "2200px", 
      height = "1000px",
      nodeSize = "leafCount",
      #height = NULL,      # <-- IMPORTANT: numeric px, not "100%"
      fill = "#2167d9",
      linkLength = 300, 
      zoomable = FALSE
    )
    # 
    # htmlwidgets::onRender(
    #   w,
    #   "function(el, x) {
    #    // let the browser finish layout, then force a resize so D3 recomputes
    #    setTimeout(function(){
    #      window.dispatchEvent(new Event('resize'));
    #    }, 30);
    #  }
    # 
    # 
    # 
    # 
    # 
    #   "
    # )
    
    
    
    w
    
    
    
  })
  
  # Observe the input from the clicked node
  output$clicked_node_info <- renderPrint({
    # input$clicked_node will be a named list of the most recently selected node 
    # and all of its parents
    if (!is.null(input$clicked_node)) {
      cat("Clicked Node Information:\n")
      print(input$clicked_node)
    } else {
      cat("Click a node to see its information here.")
    }
  })
  
  # output$node_table <- DT::renderDT({
  #   req(input$clicked_node)
  #   req(cit_nw_llm_dt)
  #   
  #   node <- input$clicked_node
  #   xorg <- org[org$network == input$root, ]
  #   
  #   col_names <- names(node)
  #   resolution_numbers <- as.integer(gsub("\\D", "", col_names))
  #   max_idx <- which.max(resolution_numbers)
  #   
  #   node_coloi <- col_names[max_idx]
  #   node_clusteroi <- node[[max_idx]]
  #   
  #   fnode_dt <- xorg[xorg[[node_coloi]] == node_clusteroi, ]
  #   if (nrow(fnode_dt) == 0) {
  #     return(DT::datatable(data.frame(Info = "No matching nodes found")))
  #   }
  #   
  #   nw_join_res <- paste0("Cl.", as.integer(gsub("\\D", "", node_coloi)))
  #   if (!nw_join_res %in% names(fnode_dt)) {
  #     return(DT::datatable(data.frame(Error = paste("Column", nw_join_res, "not found"))))
  #   }
  #   
  #   node_coloi_num <- fnode_dt[[nw_join_res]][1]
  #   if (is.na(node_coloi_num)) {
  #     return(DT::datatable(data.frame(Info = "No cluster number found")))
  #   }
  #   
  #   node_nw_cluster <- paste0(input$root, "-", nw_join_res, "-", node_coloi_num)
  #   
  #   fllmnw <- cit_nw_llm_dt[network_cluster == node_nw_cluster, llm_justifications]
  #   fentries <- cit_nw_llm_dt[network_cluster == node_nw_cluster, n_entries]
  #   
  #   if (length(fllmnw) == 0 || all(is.na(fllmnw))) {
  #     return(DT::datatable(data.frame(Info = "No justifications found for this cluster")))
  #   }
  #   
  #   # Build the table you actually want to show
  #   out <- data.frame(
  #     `#Paper`  = fentries,
  #     Cluster   = node_clusteroi,
  #     Reasoning = fllmnw,
  #     stringsAsFactors = FALSE,
  #     check.names = FALSE
  #   )
  #   
  #   DT::datatable(
  #     out,
  #     rownames = FALSE,
  #     options = list(
  #       pageLength = 5,
  #       autoWidth = TRUE,
  #       scrollX = TRUE
  #     )
  #   )
  # })
  
  
  output$node_table <- DT::renderDT({
    # ---- FULL TABLE MODE ----
    if (table_mode() == "full" || is.null(input$clicked_node)) {
      
      full <- cit_nw_llm_dt[, .(
        Network    = network,
        Cluster    = cluster,
        `# Papers` = n_entries,
        Reasoning  = llm_justifications
      )] |> as.data.frame()
      
      return(
        DT::datatable(
          full,
          rownames = FALSE,
          options = list(
            pageLength = 1,
            lengthChange = TRUE,
            scrollX = TRUE,
            autoWidth = TRUE
          )
        )
      )
    }
    
    
    # --- CASE 2: node clicked -> show the node-specific table ---
    req(input$clicked_node)
    req(cit_nw_llm_dt)
    
    node <- input$clicked_node
    xorg <- org[org$network == input$root, ]
    
    col_names <- names(node)
    resolution_numbers <- as.integer(gsub("\\D", "", col_names))
    max_idx <- which.max(resolution_numbers)
    
    node_coloi <- col_names[max_idx]
    node_clusteroi <- node[[max_idx]]
    
    fnode_dt <- xorg[xorg[[node_coloi]] == node_clusteroi, ]
    if (nrow(fnode_dt) == 0) {
      return(DT::datatable(data.frame(Info = "Click on a cluster node to display llm reasoning"), rownames = FALSE,
                           options = list(pageLength = 1, scrollX = TRUE)))
    }
    
    nw_join_res <- paste0("Cl.", as.integer(gsub("\\D", "", node_coloi)))
    if (!nw_join_res %in% names(fnode_dt)) {
      return(DT::datatable(data.frame(Error = paste("Column", nw_join_res, "not found")), rownames = FALSE,
                           options = list(pageLength = 1, scrollX = TRUE)))
    }
    
    node_coloi_num <- fnode_dt[[nw_join_res]][1]
    if (is.na(node_coloi_num)) {
      return(DT::datatable(data.frame(Info = "No cluster number found"), rownames = FALSE,
                           options = list(pageLength = 1, scrollX = TRUE)))
    }
    
    node_nw_cluster <- paste0(input$root, "-", nw_join_res, "-", node_coloi_num)
    
    fllmnw <- cit_nw_llm_dt[network_cluster == node_nw_cluster, llm_justifications]
    fentries <- cit_nw_llm_dt[network_cluster == node_nw_cluster, n_entries]
    
    if (length(fllmnw) == 0 || all(is.na(fllmnw))) {
      return(DT::datatable(data.frame(Info = "No justifications found for this cluster"), rownames = FALSE,
                           options = list(pageLength = 1, scrollX = TRUE)))
    }
    
    out <- data.frame(
      `#Paper`  = fentries,
      Cluster   = node_clusteroi,
      Reasoning = fllmnw,
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
    
    DT::datatable(
      out,
      rownames = FALSE,
      options = list(
        pageLength = 1,   # <-- show 2 rows at a time here too (if you want)
        lengthChange = TRUE,
        scrollX = TRUE,
        autoWidth = TRUE
      )
    )
  })
  
  
  
  
  
  
  
  
  
})
