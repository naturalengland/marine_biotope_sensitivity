## install.packages("devtools")
## install.packages("DBI2)
## install.packages("Rcpp")
##  install.packages("RPostgreSQL")
## install.packages("dbplyr")

#library(RPostgreSQL)
library(RPostgres)
library(DBI)
library(Rcpp)
library(dbplyr)
library(tidyverse)


#drv <- dbDriver("PostgreSQL")
#con <- dbConnect(drv, dbname="postgres")

# current location:
#dbname='postgis_24_sample' host=localhost port=5432 sslmode=disable key='id' srid=4326 type=MultiPolygon table="marine habitat"."sbgr_input_bsh_polys_wgs84_internal" (the_geom) sql=

#with RPOSTRGRE
#define password
pw <- {
  "password"
}
#connect to PostrgreSQL database
con <- dbConnect(RPostgres::Postgres()
                 , host='localhost'
                 , port='5432'
                 , dbname='postgis_24_sample'
                 #, table='marine habitat'.'sbgr_input_bsh_polys_wgs84_internal'
                 , user='postgres'
                 , password=pw)

#rm(pw) # removes the password


#with RPostgreSQL
drv <- dbDriver('PostgreSQL')  
db <- 'habitat sensitivity'  
host_db <- 'localhost'  
db_port <- '5432'  
db_user <- 'postgres'  
db_password <- 'password'

con <- DBI::dbConnect(drv, dbname=db, host=host_db, port=db_port, user=db_user, password=db_password)
#rm(drv,db,host_db,db_port,db_user,db_password)

dbListTables(conn = con)
#dbReadTable(conn = con, name = "sbgr_input_bsh_polys_wgs84_internal")

dbExistsTable(conn = con, "sbgr_input_bsh_polys_wgs84_internal")


dbSendQuery(conn = con, statement = "SELECT * FROM sbgr_input_bsh_polys_wgs84_internal")#SELECT * FROM "marine habitat".sbgr_input_bsh_polys_wgs84_internal

dbGetQuery(con,
           "SELECT sbgr_input_bsh_polys_wgs84_internal FROM information_schema.tables
                   WHERE table_schema='marine habitat'")

dbDisconnect(conn = con)


tbl(con, "sbgr_input_bsh_polys_wgs84_internal")
