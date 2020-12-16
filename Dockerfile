#start previous docker setup
#FROM rocker/r-ver:3.6.3

#RUN apt-get update && apt-get install -y \
#    sudo \
#    gdebi-core \
#    pandoc \
#    pandoc-citeproc \
#    libcurl4-gnutls-dev \
#    libcairo2-dev \
#    libxt-dev \
#    xtail \
#    wget

#end previous docker settup 

#start new composite docker setup

FROM rocker/shiny:3.6.3

RUN apt-get update && apt-get install -y \
    lbzip2 \
    libfftw3-dev \
    libgdal-dev \
    libgeos-dev \
    libgsl0-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libhdf4-alt-dev \
    libhdf5-dev \
    libjq-dev \
    liblwgeom-dev \
    libpq-dev \
    libproj-dev \
    libprotobuf-dev \
    libnetcdf-dev \
    libsqlite3-dev \
    libssl-dev \
    libudunits2-dev \
    netcdf-bin \
    postgis \
    protobuf-compiler \
    sqlite3 \
    tk-dev \
    unixodbc-dev \
    libssh2-1-dev \
    r-cran-v8 \
    libv8-dev \
    net-tools \
    libsqlite3-dev \
    libxml2-dev

#end new composite docker setup


# Download and install shiny server
RUN wget --no-verbose https://download3.rstudio.org/ubuntu-14.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb && \
    . /etc/environment && \
    #start init shiny server with markdown
    #R -e "install.packages(c('shiny', 'rmarkdown'), repos='https://cran.rstudio.com/')" && \
    #end start init shiny-server with markdown
    #trying using cran instead of mran
    #R -e "install.packages(c('shiny', 'rmarkdown'), repos='$MRAN')" && \
    #start install all no vers
    #R -e "install.packages(pkgs=c('data.table', 'DBI', 'dplyr', 'DT', 'rgeos', 'dygraphs', 'forcats', 'glue', 'htmltools', 'leaflet','leaflet.minicharts', 'lubridate', 'maptools', 'mapview', 'pool', 'rbokeh', 'RColorBrewer', 'rintrojs', 'RPostgreSQL', 'sf', 'shinydashboard', 'shinyjs', 'shinyTime', 'shinyWidgets', 'sp', 'stringr'), repos='https://cran.rstudio.com/')" && \
    #install all with versions
    R -e "install.packages('renv')"

COPY renv.lock renv.lock

RUN R -e "renv::restore()"

RUN cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/ && \
    chown shiny:shiny /var/lib/shiny-server

#expose docker port
EXPOSE 3838

#add created shiny server file to running stuff
COPY shiny-server.sh /usr/bin/shiny-server.sh

COPY custom.config /etc/shiny-server/shiny-server.conf

CMD ["/usr/bin/shiny-server.sh"]
