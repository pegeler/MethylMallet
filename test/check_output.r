# Creating reference data -------------------------------------------------

ddir <- "data/"

files <- list.files(ddir, full.names = TRUE)
file_names <- strcapture("(GSM[0-9])_", files, proto = list(character(1)))[,1]

dat <- lapply(
  seq_along(files),
  function(x)
    read.delim(
      files[x],
      col.names = c(
        "chrom","pos","strand","mc_class","skip","skip",file_names[x]),
      colClasses = c(
        "integer","integer","character","character","NULL","NULL","integer")
    )
)
head(dat)

library(dplyr)

ref <-
  Reduce(
    function(x,y) full_join(x, y, by = c("chrom", "pos", "strand", "mc_class")),
    dat
  ) %>%
  arrange(chrom, pos, strand, mc_class) %>%
  as.data.frame


# Checking against processed data -----------------------------------------

check <- read.delim('out/new.tsv.gz', stringsAsFactors = FALSE)
check %<>%
  select(
    c("chrom", "pos", "strand", "mc_class",
      "GSM1", "GSM2", "GSM3", "GSM4", "GSM5")
  ) %>%
  arrange(chrom, pos, strand, mc_class) %>%
  as.data.frame

all.equal(check, ref)
