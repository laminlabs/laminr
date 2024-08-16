# install.packages("rapiclient")

library(rapiclient)
library(httr)
library(tidyverse)

lamin_api <- get_api(url = "https://us-west-2.api.lamin.ai/openapi.json")
operations <- get_operations(lamin_api)
schemas <- get_schemas(lamin_api)

# instance id
instance_id <- "399387d4-feec-45b5-995d-5b5750f5542c"


# get db url:
db_url <- content(operations$generate_url_instances__instance_id__db_url_get(instance_id = instance_id))

# connect to db using url
library(RPostgreSQL)

drv <- dbDriver("PostgreSQL")
con <- dbConnect(
  dbDriver("PostgreSQL"),
  dbname = dbname,
  host = host,
  port = port,
  user = user,
  password = password
)
dbListTables(con)

# get records of 'lnschema_core_artifact'
artifacts <- dbGetQuery(con, "SELECT * FROM lnschema_core_artifact") |> as_tibble()

artifact_uid <- artifacts %>% filter(suffix == ".h5ad") %>% arrange(size) %>% .$uid %>% .[[1]]
