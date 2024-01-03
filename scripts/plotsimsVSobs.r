library(ggplot2)

# Install and load the RSQLite package
if (!require(RSQLite)) {
    install.packages("RSQLite")
    library(RSQLite)
}


# Connect to the SQLite database
con <- dbConnect(RSQLite::SQLite(), dbname = "sims_recipe/Potato.db")

# List all tables in the database
tables <- dbListTables(con)

# Print the tables
print(tables)

# Read the data from the "Potato" table into the "Potato" data frame
Potato <- dbReadTable(con, "Report")
dbDisconnect(con)

str(Potato)
library(data.table)
Potato <- as.data.table(Potato)
Potato[, Date := as.Date(Clock.Today, format = "%Y-%m-%d")]
longDT <- melt.data.table(Potato, id.vars = c("CheckpointID","SimulationID","Zone","Clock.Today", "Date"), 
                          variable.factor = FALSE, variable.name = "Variable", value.name = "Value")
unique(longDT$Variable)
longDT[,c("CheckpointID","SimulationID","Zone","Clock.Today") := NULL]
longDT[Variable %like% "Leaf.LAI|Potato.Tuber.Live\\.Wt"] |>
    fwrite("C:/Users/liu283/GitRepos/PhD/inputs/Data/APSIMsimIndian2022.csv")
