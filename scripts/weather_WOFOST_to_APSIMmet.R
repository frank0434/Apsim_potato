library(ggplot2)
library(readxl)
library(data.table)
dat <- read_excel("weather/India2022_23.xlsx", skip = 11) |> 
  as.data.table()
meta <- read_excel("weather/India2022_23.xlsx", n_max = 11)

stationnm <- "IndianExpt2022"
latitude <- meta$...2[8]
longitude <-  meta$`Site Characteristics`[8]
# tav ! annual average ambient temperature
# amp ! annual amplitude in mean monthly temperature. 
# Amp is obtained by averaging the mean daily temperature of each month over the entire data period resulting in
# twelve mean temperatures, and then subtracting the minimum of these values from the maximum. Tav is
# obtained by averaging the twelve mean monthly temperatures.
# https://www.apsim.info/wp-content/uploads/2019/10/tav_amp-1.pdf

tav <- (34.6 + 21.7)/2 # from the climatological_table 1991-2020.pdf
monthly_min_max <- fread("weather/Idar1991_2020_monthly_max_min.txt")
amp <- max(monthly_min_max$max) - min(monthly_min_max$min)
row1 <- "[weather.met.weather]"

dat[, year := year(date)]
dat[, day := as.numeric(julian(date, origin = as.Date(paste0(year, "-01-01")))) + 1,
    by = year]
meta
dat[, radn := `kJ/m2/day or hours` * 0.001]
dat[, ':=' (maxt = Celsius...4,
            mint = Celsius...3)]
dat[, rain := round(mm)]
dat[, wind := round(`m/sec`)]
met_dat <- dat[,.(year, day, radn, maxt, mint, rain, wind)] 
header <- "year  day radn  maxt   mint  rain  wind"
unit <- "  ()   () (MJ/m^2) (oC) (oC)  (mm)  (m/s)"

# Open a connection to the CSV file
con <- file("weather/Indian2022_23APSIM.csv", open = "wt")

# Write the first 8 rows to the CSV file
writeLines(c(row1, stationnm, latitude, longitude, 
       paste("tav = ", tav, " (oC) ! annual average ambient temperature"),
       paste("amp = ", amp, " (oC) ! annual amplitude in mean monthly temperature"),
       header, unit), con)

# Write the data to the CSV file, starting from the 9th row
write.table(met_dat, file = con, sep = ",", row.names = FALSE, col.names = FALSE, quote = FALSE)

# Close the connection to the CSV file
close(con)
