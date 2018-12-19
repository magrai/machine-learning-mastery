
# Objetive ----------------------------------------------------------------

# Scrape all blog entries from https://machinelearningmastery.com/blog
# Save entries to Excel sheet
# Save information on date, title, category, and url



# Preparatory settings ----------------------------------------------------

library(rvest)
library(dplyr)
library(xlsx)
url_template <- "https://machinelearningmastery.com/blog"
page_max <- 64
pages <- c("", paste0("/page/", seq(2, page_max)))



# Scrape blog -------------------------------------------------------------

dat <- c()
for (i in pages) {
  
  print(i)
  
  url_temp <- paste0(url_template, i, "/")
  
  webpage <- read_html(url_temp)
  
  titles <- 
    webpage %>% 
    html_nodes("[rel='bookmark']") %>% 
    html_text()
  
  urls <- 
    webpage %>% 
    html_nodes("h2 a") %>% 
    html_attr('href')
  
  dates <- 
    webpage %>% 
    html_nodes("div abbr") %>% 
    html_text() %>% 
    as.Date("%B %d, %Y")
  
  tags <- 
    webpage %>% 
    html_nodes("[class='categories']") %>% 
    html_text()
  
  dat_temp <- 
    data.frame(
      date = dates, 
      title = titles, 
      tag = tags,
      url = urls)
  
  dat_temp <- arrange(dat_temp, desc(date))
  
  dat <- rbind(dat, dat_temp)
}




# Save data ---------------------------------------------------------------

dat_export <- createWorkbook()
dat_export_sheet <- createSheet(dat_export, "mlm blog entries")
dat_export_rows <- createRow(dat_export_sheet, 1:nrow(dat))
dat_export_cells <- createCell(dat_export_rows, colIndex=1:5)
addDataFrame(dat, dat_export_sheet, row.names = FALSE)
for(i in 1:nrow(dat)) {
  addHyperlink(dat_export_cells[[i+1,4]], as.character(dat$url[i]))
}

saveWorkbook(dat_export, "machine-learning-mastery_blog.xlsx")
shell.exec("machine-learning-mastery_blog.xlsx")
