#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  dopar <- require(doParallel)
})

# User-entered params -----------------------------------------------------

set.seed(777)
ddir     <- Sys.getenv("DDIR")
out_file <- Sys.getenv("OUTFILE")
n_checks <- 1000L

# Process Raw Files -------------------------------------------------------

files <- list.files(ddir, pattern = '.*\\.tsv(\\.gz)?$', full.names = TRUE)
file_names <- strcapture("(GSM.*?)_", files, proto = list(character(1)))[,1]

# Process output file -----------------------------------------------------
wc_out <- system(paste("wc -l", out_file, "| awk '{print $1}'"), intern = TRUE)
n_keys <- as.integer(wc_out) # 65161486L
check_keys <- sort(sample(seq(2, n_keys), n_checks))

subset_chunk <- function(x, pos) {
  x[seq(from = pos, along.with = x) %in% check_keys]
}
capture.output({
  check_lines <- read_lines_chunked(
    out_file,
    callback = ListCallback$new(subset_chunk),
    progress = FALSE,
    chunk_size = 1e5)
  }, file = '/dev/null')

check_data <- read.csv(
  header = FALSE,
  stringsAsFactors = FALSE,
  text = unlist(check_lines))

names(check_data) <- scan(
  out_file,
  what = character(),
  sep = ",",
  nlines = 1,
  quiet = TRUE)

# Get sample lines --------------------------------------------------------
semi_join_chunk <- function(x, pos)
  semi_join(x, check_data, by = c("chrom", "pos", "strand", "mc_class"))

read_samples <- function(x) {

  col_names <- c("chrom", "pos", "strand", "mc_class", file_names[x])
  has_header <- scan(files[x], what = character(1), n = 1, quiet = TRUE) == "chrom"

  read_tsv_chunked(
      files[x],
      callback = DataFrameCallback$new(semi_join_chunk),
      chunk_size = 1e5,
      progress = FALSE,
      skip = as.integer(has_header),
      col_names = col_names,
      col_types = list(
        col_integer(),
        col_integer(),
        col_character(),
        col_character(),
        col_skip(),
        col_skip(),
        col_integer())
    )
}

if ( dopar ) {
  cluster <- makeCluster(detectCores() - 1L)
  registerDoParallel(cluster)
  dat <- foreach(
    f = seq_along(files),
    .packages = c("dplyr","readr")
  ) %dopar% { read_samples(f) }
  stopCluster(cluster)
} else {
  dat <- lapply(seq_along(files), read_samples)
}

ref <-Reduce(
    function(x,y) full_join(x, y, by = c("chrom", "pos", "strand", "mc_class")),
    dat
  ) %>%
  arrange(chrom, pos, strand, mc_class) %>%
  as.data.frame

# Check if equal ----------------------------------------------------------
check <- all.equal(check_data, ref)
cat(sprintf(
"MethylMallet Quality Control Check...
=============================================================================
  Check file name:         %s
  Number of lines checked: %i
  Result:                  %s
-----------------------------------------------------------------------------
", out_file, n_checks, ifelse(isTRUE(check), "OK", "FAIL"))
)

if ( !isTRUE(check) ) {
  print(check)
}

save(check_keys, check_data, ref, file = "qc.rda")
