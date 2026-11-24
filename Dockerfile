# Dockerfile

# #The custom base image
# FROM cit_nw_pmid_search_img

# Shiny server image as the base
FROM rocker/shiny:latest


# WORKDIR /srv


RUN R -e "install.packages(c('shiny','stringr', 'DT','dplyr','shinyjs','shinyBS','htmlwidgets','configr','shinybusy','data.table'), repos='https://cloud.r-project.org')"
# Install additional R packages
RUN R -e "install.packages('jsonlite', repos = 'https://cran.r-project.org')"
RUN R -e "install.packages('plotly',lib='/usr/local/lib/R/site-library', repos='https://cloud.r-project.org')"


# make directory to not collide with the original path
# the default would collide with the home/landing page
# additional path is necessary
# Create a new app directory inside shiny-server
RUN mkdir -p /srv/shiny-server/

# # Remove default example apps (optional, for cleanliness)
# RUN rm -rf /srv/shiny-server/sample-apps \
#            /srv/shiny-server/index.html \
#            /srv/shiny-server/01_hello \
#            /srv/shiny-server/02_text \
#            /srv/shiny-server/03_reactivity \
#            /srv/shiny-server/04_mpg \
#            /srv/shiny-server/05_sliders \
#            /srv/shiny-server/06_tabsets \
#            /srv/shiny-server/07_widgets \
#            /srv/shiny-server/09_upload \
#            /srv/shiny-server/10_download \
#            /srv/shiny-server/11_timer

# # Copy shared renv environment and lockfile
# COPY ./renv /srv/renv
# COPY ./renv.lock /srv/renv.lock
# COPY .Rprofile /srv/.Rprofile
# If using a custom Shiny Server config, copy it
# (optional — only if you're actually customizing ports, logging, etc.)
COPY shiny-server/shiny-server.conf /etc/shiny-server/shiny-server.conf

# Copy the app (evth) into the Shiny Server directory
COPY shiny-server/ /srv/shiny-server/



# Make the app readable by the Shiny server
RUN chown -R shiny:shiny /srv/shiny-server
# && \
#     # mkdir -p /var/log/shiny-server/app1 /var/log/shiny-server/app2 && \
#     mkdir -p /var/log/shiny-server/cit_nw_pmid_search
#     chown -R shiny:shiny /var/log/shiny-server/


# # Install renv and restore packages
# RUN R -e "install.packages('renv', repos = 'https://cloud.r-project.org')"
# RUN R -e "renv::restore(confirm = FALSE)"

#Port 3838 is used in another app
# Expose the Shiny server port
EXPOSE 3333

# Start Shiny server
CMD ["/usr/bin/shiny-server"]















