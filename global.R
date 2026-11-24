rm(list = ls())

# # global.R

# Import Libraries
library(plotly)
library(data.table)
library(stringr)
library(DT)
library(dplyr)
library(shiny)
library(shinyjs)
library(shinyBS)
library(htmlwidgets)
library(readxl)
library(configr)
library(shinybusy)
library(jsonlite)
library(qs2)
library(collapsibleTree)




file_sep <- .Platform$file.sep
#conf_data_cit_nw <- read.config(file = paste(getwd(), "config", "cit_nw_conf_pmid.json", sep=file_sep), package="configr")


# 
# 
# 
# get_ranges <- function(subject, res_tag = NULL, conf = conf_data_cit_nw) {
#   s <- conf$ranges$subjects[[subject]] %||% conf$ranges$subjects[["default"]]
#   if (!is.null(res_tag)) {
#     ov <- conf$ranges$res_overrides[[subject]][[res_tag]]
#     if (!is.null(ov)) s <- ov
#   }
#   list(x = as.numeric(s$x), y = as.numeric(s$y))
# }


# cit_nw_pov_llm_cluster_choices = conf_data_cit_nw$cit_nw_pov_llm_cluster_labels
# cit_nw_pov_llm_cluster_condition <- paste0("input.cit_nw_pov_llm_cluster_option === '", cit_nw_pov_llm_cluster_choices, "'", collapse = " || ")


# cit_nw_ab_sg_cluster_choices = conf_data_cit_nw$cit_nw_ab_sg_cluster_labels
# cit_nw_ab_sg_cluster_condition <- paste0("input.cit_nw_ab_sg_cluster_option === '", cit_nw_ab_sg_cluster_choices, "'", collapse = " || ")

# cit_nw_patho_virus_alpha_resclus_choices = conf_data_cit_nw$cit_nw_patho_virus_alpha_resclus_labels
# cit_nw_patho_virus_alpha_resclus_condition <- paste0("input.cit_nw_patho_virus_alpha_resclus_option === '", cit_nw_patho_virus_alpha_resclus_choices, "'", collapse = " || ")


# cit_nw_vac_resclus_choices = conf_data_cit_nw$cit_nw_vac_resclus_labels
# cit_nw_vac_resclus_condition <- paste0("input.cit_nw_vac_resclus_option === '", cit_nw_vac_resclus_choices, "'", collapse = " || ")

########### LLM Generated cluster labels ############
cit_nw_create_llm_cluster_labels <- function(i, llm_labels_dt, title_prefix) {
  
  cit_nw_cluster_llm_label_table<- llm_labels_dt[i]
  colnames(cit_nw_cluster_llm_label_table) <- c("SME Label", "LLM Label", "LLM Reasoning")
  cit_nw_cluster_llm_label_table
}
########### End: LLM Generated cluster labels ############

##### Resolutions #####
resolutions <- c(
  "Resolution 1"  = "res_1",
  "Resolution 2"  = "res_2",
  "Resolution 5"  = "res_5",
  "Resolution 10" = "res_10",
  "Resolution 20" = "res_20"
)
##### End:Resolutions #####

##### Network Timeline: List of all the PoVs #####
cit_nw_tm_btn_pov_list <- list(
  "Virus"     = c("Ebola","Alpha", "Pox","Hanta","CCHF","Measles","Nipah","Arena","SARS","Flavivirus","HBV","Influenza","Rotavirus","HCV","Polio","RSV","Dengue","HIV","Rabies"),
  "Bacteria" = c("Burkholderia","Francisella","Streptococcus","Yersinia","Bordetella","Salmonella","Cholera","tuberculosis","Campylobacter","Haemophilus","Pseudomonas","Staphylococcus","Lyme","Neisseria","Bacillus"),
  "Parasite" = c("Plasmodium","Leishmania","Schisto"),
  "Vaccine Platform" = c("Adenovirus","DNAv","MVA","Nano","Subunit","mRNAv","VSV"),
  "Host Model Systems" = c("Patient", "Mouse","Primate","Organoid"),
  "Correlates of Protection" = c("Antibody","Tcell","Cytokine"),
  "Medical Countermeasures" = c("Antimicrobial","Vaccine")
)
##### End:Network Timeline: List of all the PoVs #####

cit_nw_subject_list<- c("Antimicrobial" , "Vaccine", "Antibody", "Tcell", "Cytokine",  "Mouse","Patient","Primate","Organoid",  "Plasmodium", "Schisto", "Leishmania",  "VSV","Adenovirus","Subunit","DNAv","MVA","Nano",   "Alpha","Arena","CCHF","Dengue","Ebola","Flavivirus",
"Hanta","HBV","HCV","HIV","Influenza","Measles","Nipah","Polio","Pox","Rabies","Rotavirus","RSV","SARS",  "Yersinia","Bordetella","Burkholderia","Campylobacter","Cholera","Francisella","Neisseria","Pseudomonas","Salmonella","Streptococcus","Staphylococcus","tuberculosis",
"Bacillus","Haemophilus","Lyme")

cit_nw_subject_choices <- c(
  "Plasmodium" = "Plasmodium",
  "Schisto"     = "Schisto",
  "Leishmania"    = "Leishmania",

  "Alpha" = "VEEV",
  "Arena"     = "Lassa",
  "CCHF"    = "CCHFV",
  "Dengue" = "Dengue",
  "Ebola"     = "EBOV",
  "Flavivirus"    = "Flavivirus",
  "Hanta" = "Hantavirus",
  "HBV"     = "HBV",
  "HCV"    = "HCV",
  "HIV" = "HIV",
  "Influenza"     = "Influenza",
  "Measles"    = "Measles",
  "Nipah" = "Nipah",
  "Polio"     = "Polio",
  "Pox"    = "Mpox",
  "Rabies" = "Rabies",
  "Rotavirus"     = "Rotavirus",
  "RSV"    = "RSV",
  "SARS" = "SARS-CoV-2",

  "Yersinia" = "Yersinia pestis",
  "Bordetella"     = "Bordetella",
  "Burkholderia"    = "Burk pseudomallei",
  "Campylobacter" = "Campylobacter",
  "Cholera"     = "Vibrio",
  "Francisella"    = "Francisella",
  "Neisseria"     = "Neisseria",
  "Pseudomonas"    = "Pseudomonas",
  "Salmonella" = "Salmonella",
  "Streptococcus"     = "Strep",
  "Staphylococcus"    = "Staphylococcus",
  "tuberculosis"     = "immune_dyn",
  "Bacillus"    = "Bacillus",
  "Haemophilus" = "Haemophilus",
  "Lyme"     = "Borrelia"
)


# Sort alphabetically by the displayed names
cit_nw_subject_choices <- cit_nw_subject_choices[
  order(tolower(names(cit_nw_subject_choices)))
]

cit_nw_default_choice <- unname(cit_nw_subject_choices[10])

pathogens <- data.frame(
  id   = c("sarscov2","influenzaA","mrsa","ecoli_o157","tb","candida_auris"),
  name = c("SARS-CoV-2","Influenza A","MRSA","E. coli O157:H7","M. tuberculosis","Candida auris"),
  type = c("Virus","Virus","Bacterium","Bacterium","Bacterium","Fungus"),
  transmission = c("Respiratory","Respiratory","Contact","Foodborne","Airborne","Contact"),
  risk = c("High","Medium","Medium","Medium","High","High"),
  img  = c("icons/patho_icons/sars_cov_2.png",
           "pathogens/influenzaA.png",
           "pathogens/mrsa.png",
           "pathogens/ecoli_o157.png",
           "pathogens/tb.png",
           "pathogens/candida_auris.png"),
  nick = c("sars_cov_2", "AdV"),
  full = c("Vesicular stomatitis virus", "Adenovirus"),
  stringsAsFactors = FALSE
)


# -------------------- UI helpers --------------------
pathogen_card <- function(row) {
  tags$div(
    class = "app-card",
    tabindex = "0",
    role = "button",
    `data-card-id` = row$id,
    tags$img(src = row$img, class = "card-img", alt = paste(row$name, "image")),
    tags$div(class = "card-title", row$name),
    tags$div(class = "card-subtitle", paste(row$type, "\u2022", row$transmission, "\u2022", row$risk))
  )
}

# sq_card_inline <- function(id, cls = "", img, label,
#                            size = 110,          # square size
#                            img_max_h = 0.72,    # % of tile height reserved for image
#                            text_size = 16,
#                            text_bottom = 8) {

#   div(
#     class = paste("sq-card", cls),
#     style = paste0(
#       "width:", size, "px;",
#       "height:", size, "px;",
#       "position:relative;",
#       "display:flex;",
#       "flex-direction:column;",
#       "align-items:center;",
#       "justify-content:center;",
#       "padding:6px;",
#       "box-sizing:border-box;"
#     ),
#     `data-card-id` = id,
#     tabindex = "0",
#     role = "button",

#     img(
#       src = img,  # IMPORTANT: no 'www/' prefix
#       alt = label,
#       style = paste0(
#         "max-width:92%;",
#         "max-height:", floor(size * img_max_h), "px;",
#         "object-fit:contain;"
#       )
#     ),

#     div(
#       class = "sq-text",
#       style = paste0(
#         "position:absolute;",
#         "bottom:", text_bottom, "px;",
#         "left:0; right:0;",
#         "text-align:center;",
#         "font-size:", text_size, "px;",
#         "font-weight:800;",
#         "line-height:1.05;"
#       ),
#       label
#     )
#   )
# }



sq_card_inline <- function(id, cls = "", img, label,
                           size = 110,img_max_h = 0.72, text_size = 16,text_bottom = 8) {

  tags$div(
    class = paste("sq-card", cls),
    onclick = sprintf(
      "Shiny.setInputValue('tile_click', '%s', {priority: 'event'})",
      id
    ),
    style = paste0(
      "width:", size, "px;",
      "height:", size, "px;",
      "position:relative;",
      "display:flex;",
      "flex-direction:column;",
      "align-items:center;",
      "justify-content:center;",
      "padding:6px;",
      "box-sizing:border-box;",
      "cursor:pointer;"   #  shows it's clickable
    ),

    tags$img(
      src = img,
      alt = label,
      style = "max-width:90%; max-height:70%; object-fit:contain;"
    ),

    tags$div(
      style = paste0(
        "position:absolute; bottom:8px; left:0; right:0;",
        "text-align:center;",
        "font-size:", text_size, "px;",
        "font-weight:800;"
      ),
      label
    )
  )
}


papers_df <- data.frame(
  id = c("p1","p2","p3"),
  title = c(
    "Title1",
    "Title2",
    "Title3"
  ),
  excerpt = c(
    "Citation Network..",
    "Citation Network.....",
    "Citation Network....."
  ),
  img = c(
    "papers/vision.jpg",
    "papers/funding.jpg",
    "papers/probiotic.jpg"
  ),
  url = c(
    "https://example.com/vision",
    "https://example.com/funding",
    "https://example.com/probiotic"
  ),
  stringsAsFactors = FALSE
)


# merge_pmidsearch_data_fn <- function(net_info, llm_dt, ALL_DATA) {
#   stopifnot(!is.null(net_info), !is.null(llm_dt), !is.null(ALL_DATA))
  
#   check_net <- net_info$selected_cluster_net
#   mdf <- as.data.table(net_info$subject$mdf)
#   stopifnot("pmid" %in% names(mdf), "pmid" %in% names(ALL_DATA))
  
#   ALL_DT <- as.data.table(ALL_DATA)
#   # ALL_DT[, PoV_network_cluster := paste(PoV, network, cluster, sep = "-")]
  
#   dtin <- ALL_DT[network == check_net]
#   mdf[, pmid := as.numeric(pmid)]
  
#   keep_cols <- c(
#     "pmid","abstract",
#     "labelcl1","labelcl2","labelcl5","labelcl10","labelcl20",
#     "label1","label2","label5","label10","label20","url",
#     "Cl.1","Cl.2","Cl.5","Cl.10","Cl.20" # needed for joins with llm_dt
#   )
#   keep_cols <- intersect(keep_cols, names(mdf))
  
#   df <- merge(
#     dtin,
#     mdf[, ..keep_cols],
#     by = "pmid",
#     all.x = FALSE, all.y = TRUE
#   )
  
#   an <- as.data.table(llm_dt)[network == check_net]
  
#   # Attach LLM labels for Cl.{1,2,5,10,20}
#   for (k in c(1, 2, 5, 10, 20)) {
#     res_name <- paste0("Cl.", k)
#     add <- an[res == res_name, .(network, cluster_id, label)]
#     if (res_name %in% names(df)) {
#       df <- merge(
#         df, add,
#         by.x = c("network", res_name),
#         by.y = c("network", "cluster_id"),
#         all.x = TRUE, all.y = FALSE
#       )
#       data.table::setnames(df, "label", paste0("llmlabelcl", k))
#     }
#   }
  
#   llm_lists <- lapply(
#     X = c(1, 2, 5, 10, 20),
#     FUN = function(k) {
#       out <- copy(an[res == paste0("Cl.", k)])
#       if (nrow(out)) data.table::setorder(out, -n_entries)
#       out
#     }
#   )
#   names(llm_lists) <- c("llm.1","llm.2","llm.5","llm.10","llm.20")
  
#   c(
#     list(mdf = df, x = net_info$x, paths = net_info$paths, llm = an),
#     llm_lists
#   )
# }





# # generate the URLs based on the entry
# cit_nw_generate_url <- function(entry) {
#   # Create the base URL
#   base_url <- "https://doi.org/"
#   
#   # file_sep <- .Platform$file.sep
#   # Create the full URL
#   full_url <- paste0(base_url, entry)
#   return(full_url)
# }

####==== YAML import ====####

library(yaml)
ranges_cfg <- yaml::read_yaml(file.path(getwd(), "config", "ranges.yml"))
# library(yaml)
# ranges_cfg <- read_yaml("ranges.yml")
# 
# get_ranges <- function(name, cfg = ranges_cfg) {
#   out <- cfg$subjects[[name]]
#   if (is.null(out)) out <- cfg$subjects$default
#   list(x = as.numeric(out$x), y = as.numeric(out$y))
# }

