# Install and load required packages
library(rvest)

# Directory to save txt files
input_directory <- "C:\\Users\\kekec\\Downloads\\input_folder\\"
output_directory <- "C:\\Users\\kekec\\Downloads\\webrawlresults\\"

namemtmt = read.csv2(paste0(input_directory, "mtmt_ids.csv"))
pre_url = "https://m2.mtmt.hu/api/publication?cond=authors%3Beq%3B"
post_url = "&ty_on=1&ty_on_check=1&st_on=1&st_on_check=1&url_on=1&url_on_check=1&cite_type=2&sort=publishedYear%2Cdesc&size=5000&export=1&exportFormat=RIS_BIBL"

namemtmt$url = sapply(namemtmt$mtmt, function(x) paste0(pre_url, x, post_url))


download_ris_files <- function(urls_df, output_dir) {
  for (i in 1:nrow(urls_df)) {
    url <- urls_df$url[i]
    mtmt <- namemtmt$mtmt[i]
    filename <- paste(output_dir, mtmt, ".txt", sep="")
    download.file(url, filename, mode = "wb")
    cat("File", i, "downloaded and saved as", filename, "\n")
  }
}

# Call the function to crawl web pages and save contents to txt files
download_ris_files(namemtmt, output_directory)



output_list = list()

# Get the list of .txt files in the directory
txt_files <- list.files(output_directory, pattern = "\\.txt$", full.names = TRUE)
mtmt_from_filename = substr(txt_files, nchar(output_directory)+1, nchar(txt_files)-4)

for(i in 1:length(txt_files)){
  # Read the first .txt file
  first_txt_file <- readLines(txt_files[i])
  
  # Extract lines starting with "DO -"
  doi_lines <- grep("^DO  - ", first_txt_file, value = TRUE)
  dois <- substr(doi_lines, 7, nchar(doi_lines))
  
  # Populate output data frame
  output_dat = data.frame(mtmt = mtmt_from_filename[i], dois = dois)
  
  output_list[[i]] = output_dat
}

final_output_df = do.call(rbind, output_list)



