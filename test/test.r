ddir <- "../dat/"

files <- list.files(ddir, full.names = TRUE)
GSM_names <- strcapture("(GSM.*?)_", files, proto = list(character(1)))[,1]

dat <- read.delim(
  files[1],
  col.names = c(
    "chrom",
    "pos",
    "strand",
    "mc_class",
    "skip",
    "skip",
    GSM_names[1]),
  colClasses = c(
    "integer",
    "integer",
    "character",
    "character",
    "NULL",
    "NULL",
    "integer"),
  nrows = 1000
  )

head(dat)



master <- read.csv(
  "working/out.csv",
    col.names = c(
    "chrom",
    "pos",
    "strand",
    "mc_class",
    GSM_names[1],
    rep("skip", 3)),
  colClasses = c(
    "integer",
    "integer",
    "character",
    "character",
    "integer",
    "NULL",
    "NULL",
    "NULL"),
  nrows = 2000
)

head(master)

library(dplyr)

dat %>%
  full_join(master, by = c("chrom", "pos", "strand", "mc_class"))
