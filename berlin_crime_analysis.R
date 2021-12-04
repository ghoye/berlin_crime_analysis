library(sampling)
library("RColorBrewer")
library(dplyr)

### Dataset source (.csv): 
#### https://www.kaggle.com/danilzyryanov/crime-in-berlin-2012-2019 
### Import .csv file

file <- c("/Users/ghoye/Documents/Berlin_crimes.csv")
crimes <- read.csv(file)
head(crimes)

## Preprocessing

crimes$Total <- rowSums(crimes[,5:(ncol(crimes)-1)]) # ncol-1 to exclude "Local"

## Analysis on Single Variables
### Categorical Variable: Geographical Location (2012)

district_names <- row.names(table(crimes$District))
directions <- c("North", "South", "East", "West", "Central")
df_dir <- data.frame(row.names = directions, col1 = seq(1:length(directions)))
colnames(df_dir) <- c("2012")

crimes_2012 <- subset(crimes, Year == 2012) # Create subset of only crimes in 2012
df_dir[1,1] <- sum(crimes_2012$Total[crimes_2012$District==district_names[7]]) +
  sum(crimes_2012$Total[crimes_2012$District==district_names[8]])
df_dir[2,1] <- sum(crimes_2012$Total[crimes_2012$District==district_names[6]]) + 
  sum(crimes_2012$Total[crimes_2012$District==district_names[10]]) + 
  sum(crimes_2012$Total[crimes_2012$District==district_names[11]]) + 
  sum(crimes_2012$Total[crimes_2012$District==district_names[12]])
df_dir[3,1] <- sum(crimes_2012$Total[crimes_2012$District==district_names[3]]) +
  sum(crimes_2012$Total[crimes_2012$District==district_names[4]])
df_dir[4,1] <- sum(crimes_2012$Total[crimes_2012$District==district_names[1]]) +
  sum(crimes_2012$Total[crimes_2012$District==district_names[9]])
df_dir[5,1] <- sum(crimes_2012$Total[crimes_2012$District==district_names[2]]) +
  sum(crimes_2012$Total[crimes_2012$District==district_names[5]])

barplot(df_dir[,1],
        main="Crimes By Geographical Area in Berlin, 2012",
        ylim=c(0, max(df_dir[,1])+15500), names.arg = row.names(df_dir),
        las = 1, col="red")

mittens <- subset(crimes_2012, District == "Mitte") # Create subset of 2012 crimes only in Mitte
my_palette <- brewer.pal(11, "Set3")
data <- mittens$Total
slice_labels <- mittens$Location
slice_labels[11] <- "Nicht zuzuordnen"
slice_percents <- round(data/sum(data)*100)
slice_labels <- paste(slice_labels, " (", slice_percents, "%", ")", sep="")
pie(mittens$Total, labels = slice_labels, col = my_palette,
    main="Crimes in Mitte, 2012", cex=0.8)

### Numerical Variable: Robbery (2015)

crimes_2015 <- subset(crimes, Year == 2015) # Create subset of only crimes in 2015

sprintf("The total number of robberies in Berlin in 2015 was %s.", 
        prettyNum(sum(crimes_2015$Robbery), big.mark=",", scientific=FALSE))

sprintf("The mean number of robberies committed in any given area of Berlin in 2015 was %d.", round(mean(crimes_2015$Robbery), digits=0))

sprintf("The median number of robberies committed in any given area of Berlin in 2015 was %d.", median(crimes_2015$Robbery))

index_max <- which(crimes_2015$Robbery == max(crimes_2015$Robbery))
sprintf("The maximum number of robberies reported for one area in 2015 was %d, in %s in %s.", max(crimes_2015$Robbery), crimes_2015$Location[index_max], 
        crimes_2015$District[index_max])

sprintf("The standard deviation for the number of robberies in Berlin in 2015 was %.2f.", sd(crimes_2015$Robbery))

boxplot(crimes_2015$Robbery, horizontal = TRUE, col="red",
        main="Robberies in Berlin, 2015")

districts_short <- row.names(table(crimes_2015$District))
robberies_districts <- numeric(length=length(district_names))
for (x in 1:length(districts_short)) { # Calculate total robberies for each district
  robberies_districts[x] <- 
    sum(crimes_2015$Robbery[crimes_2015$District==districts_short[x]])
}
for (y in 1:length(districts_short)) { # Modify districts_short for use in barplot
  if (grepl("-", districts_short[y]) == TRUE) {
    districts_short[y] <- gsub("\\-.*","",districts_short[y])
  }
}

barplot(robberies_districts, col=c("red"), cex.names = 0.6, las=3,
        names.arg=districts_short, ylim=c(0, max(robberies_districts)+160),
        ylab="Number of Robberies", main="Robberies By District in Berlin, 2015")

## Analysis on Sets of Variables
### Set: Street_robbery and Agg_assault (2018)

crimes_2018 <- subset(crimes, Year == 2018)

plot(crimes_2018$Street_robbery, crimes_2018$Agg_assault,
     main="Street Robberies and Aggravated Assaults in Berlin, 2018",
     ylab="Aggravated Assaults",
     xlab="Street Robberies",
     pch=c(5, 10),
     col=c("dodgerblue4", "red"))
legend("topleft", pch=c(5,10), col=c("dodgerblue4", "red"), 
       c("Street Robberies", "Aggravated Assaults"), bty="o")
abline(lm(crimes_2018$Agg_assault ~ crimes_2018$Street_robbery, 
          data = crimes_2018), col = "gray47")

high_rob <- which(crimes_2018$Street_robbery == max(crimes_2018$Street_robbery))
sprintf("The highest number of street robberies reported for one area in 2018 was %d, in %s in %s.",
        max(crimes_2018$Street_robbery), crimes_2018$Location[high_rob], 
        crimes_2018$District[high_rob])

high_agg <- which(crimes_2018$Agg_assault == max(crimes_2018$Agg_assault))
sprintf("The highest number of aggravated assaults reported for one area in 2018 was %d, in %s in %s.",
        max(crimes_2018$Agg_assault), crimes_2018$Location[high_agg], 
        crimes_2018$District[high_agg])

low_rob <- which(crimes_2018$Street_robbery == 
                   min(crimes_2018$Street_robbery[which(crimes_2018$Street_robbery > 0)]))
sprintf("The lowest (non-zero) number of street robberies reported for one area in 2018 was %d, in %s in %s.",
        crimes_2018$Street_robbery[low_rob], crimes_2018$Location[low_rob], 
        crimes_2018$District[low_rob])

low_agg <- which(crimes_2018$Agg_assault == 
                   min(crimes_2018$Agg_assault[which(crimes_2018$Agg_assault > 0)]))
sprintf("The lowest (non-zero) number of aggravated assaults reported for one area in 2018 was %d, in %s in %s.",
        crimes_2018$Agg_assault[low_agg], crimes_2018$Location[low_agg], 
        crimes_2018$District[low_agg])

boxplot(crimes_2018$Agg_assault, crimes_2018$Street_robbery,
        main="Street Robberies and Aggravated Assaults in Berlin, 2018",
        col=c("red", "dodgerblue4"), horizontal = TRUE)

summary(crimes_2018$Street_robbery)
summary(crimes_2018$Agg_assault)

street_robs <- numeric(length=length(district_names))
for (x in 1:length(district_names)) { # Calculate total robberies for each district
  street_robs[x] <- 
    sum(crimes_2018$Street_robbery[crimes_2018$District==district_names[x]])
}
agg_assaults <- numeric(length=length(district_names))
for (x in 1:length(district_names)) { # Calculate total robberies for each district
  agg_assaults[x] <- 
    sum(crimes_2018$Agg_assault[crimes_2018$District==district_names[x]])
}

comp_matrix <- matrix(c(street_robs, agg_assaults), ncol=2,
                      dimnames = list(districts_short,
                                      c("Street Robberies", "Aggravated Assaults")))

barplot(t(comp_matrix), beside=TRUE, col=c("dodgerblue4", "red"), 
        main="Street Robberies and Aggravated Assaults in Berlin, 2018",
        ylim=c(0, 2200), cex.names = 0.6, las=3, legend.text = TRUE)

tempelhof_crime <- subset(crimes, District == "Tempelhof-Schöneberg" 
                          & Year != 2019)
plot(tempelhof_crime$Street_robbery, tempelhof_crime$Agg_assault,
     main="Street Robberies & Aggravated Assaults in Tempelhof, 2012-2018",
     ylab="Aggravated Assaults",
     xlab="Street Robberies",
     pch=c(5, 10),
     col=c("dodgerblue4", "red"))
legend("topleft", pch=c(5,10), col=c("dodgerblue4", "red"), 
       c("Street Robberies", "Aggravated Assaults"), bty="o")
abline(lm(tempelhof_crime$Agg_assault ~ tempelhof_crime$Street_robbery, 
          data = tempelhof_crime), col = "gray47")

tempel_areas <- names(table(tempelhof_crime$Location))
target_years <- seq(from=2012, to=2018)
tempelhof_matrix <- matrix(nrow=length(tempel_areas), ncol=length(target_years),
                           dimnames=list(tempel_areas, target_years))

for (a in 1:length(tempel_areas)){
  for (t in 1:length(target_years)){
    index <- which((tempelhof_crime$Year == target_years[t] & 
                      tempelhof_crime$Location==tempel_areas[a]))
    tempelhof_matrix[a,t] <- tempelhof_crime$Street_robbery[index]
  }
}

rownames(tempelhof_matrix)[1] <- "Nicht zuzuordnen"
my_palette2 <- brewer.pal(7, "Accent")
x <- barplot(t(tempelhof_matrix), beside=TRUE, ylim=c(0, 150), col=my_palette2, 
             legend.text = TRUE, xaxt="n", main="Street Robberies in Tempelhof, 2012-2018")
text(cex=0.65, colMeans(x), y=y-35, labels=rownames(tempelhof_matrix), xpd=TRUE, srt=45)

# Lichtenrade population source: https://www.citypopulation.de/en/germany/berlin/admin/tempelhof_sch%C3%B6neberg/B0706__lichtenrade/
sprintf("The rate of street robberies per 1,000 residents in Lichtenrade in 2018 was %.2f%%.",
        ((tempelhof_matrix["Lichtenrade", "2018"]/52000)*1000))

### Set: All crimes (2015-2019)

time_span <- seq(from=2015, to=2019)
crime_names <- colnames(crimes[,c(5:9,11:19)])
all_crimes <- matrix(nrow=length(crime_names), ncol=length(time_span),
                     dimnames = list(crime_names, time_span))
for (n in 1:length(crime_names)) {
  for (y in 1:length(time_span)) {
    all_crimes[n,y] <- sum(subset(crimes[crime_names[n]], crimes$Year == time_span[y]))
  }
}
rownames(all_crimes)[2] <- "Street Robbery"
rownames(all_crimes)[4] <- "Agg. Assault"
rownames(all_crimes)[7] <- "From Car"

set.seed(100)
n <- 60
qual_col_pals <- brewer.pal.info[brewer.pal.info$category == 'qual',]
col_vector <- unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))
my_palette3 <- col_vector[1:5]
barplot(t(all_crimes), col=my_palette3, beside=TRUE, cex.names=0.6, las=3,
        main="Total Crimes By Type in Berlin, 2015-2019", legend.text=TRUE,
        args.legend = list(x = "topright", inset = c(-0.02, 0)))

## Distribution of Numerical Variable: Theft

breaks <- seq(from=0, to=14000, by=1000)
hist(crimes$Theft, xlab="Number of Reports", ylim=c(0, 600), 
     breaks=breaks, 
     col="darkseagreen", 
     main="Incidents of Theft in Berlin, 2012-2019")

sprintf("The mean of 'Theft' is %f.", mean(crimes$Theft))
sprintf("The standard deviation of 'Theft' is %f.", sd(crimes$Theft))

## Random Sampling with the Central Limit Theorem

last_four <- 9294
set.seed(last_four)

pop <- crimes$Theft
n_samples = 400
sample_size = c(10,20,30,40)

par(mfrow=c(2,2)) 
orig <- TRUE

for(n in sample_size){
  
  xbar <- numeric(n_samples)
  
  for(i in 1:n_samples){ 
    x<-sample(x=pop, size=n, replace=FALSE)
    xbar[i]<-mean(x)
  }
  
  hist(xbar, main=paste("Sample Size =", n), col="darkseagreen")
  
  if (orig==TRUE) {
    cat("Orig.Distribution", " Mean = ", mean(pop), " SD = ", sd(pop), "\n")
  }
  orig <- FALSE
  cat("Sample Size = ", n, " Mean = ", round(mean(xbar),4),
      " SD = ", round(sd(xbar),4), "\n")
}

## Sampling Methods
### Method: Simple Random Sampling Without Replacement

set.seed(last_four)

sample <- 50
SRS <- srswor(sample, nrow(crimes))
srs_c <- crimes[SRS==1, ]
# srs_c

table(srs_c$District)
round(prop.table(table(srs_c$District)),3)

### Method: Systematic Sampling

# set.seed(last_four)

N <- nrow(crimes)
n <- 50
k <- ceiling(N / n)
r <- sample(k, 1)
s <- seq(r, by = k, length = n)
sys_c <- crimes[s, ]
# sys_c

table(sys_c$District)
round(prop.table(table(sys_c$District)),3)

### Method: Inclusion Probabilities

# set.seed(last_four)

sample <- 50
c <- inclusionprobabilities(crimes$Theft, sample)
inc_samp <- UPsystematic(c)
inc_c <- crimes[inc_samp==1, ]
# inc_c

table(inc_c$District)
round(prop.table(table(inc_c$District)),3)

### Method: Stratified Sampling

# set.seed(last_four)

crimes_sorted <- arrange(crimes, District)
sample <- 50
strat_sample <- round(prop.table(table(crimes_sorted$District))*sample)
samp_strat <- strata(crimes_sorted, "District", strat_sample, method="srswor")
strat_c <- crimes_sorted[samp_strat$ID_unit,]
# strat_c

table(strat_c$District)
round(prop.table(table(strat_c$District)),3)

num_samps <- seq(1:5)
samp_names <- c("Original Distribution", "SRSWOR", "Systematic", 
                "Inclusion Probs", "Stratified")
samp_means <- c(round(mean(crimes$Theft)),
                round(mean(srs_c$Theft)), 
                round(mean(sys_c$Theft)), 
                round(mean(inc_c$Theft)),
                round(mean(strat_c$Theft)))

for (s in num_samps) {
  if (s == 1) {
    print(sprintf("%-28s Mean: %d", samp_names[s], samp_means[s]))
  }
  if (s != 1) {
    print(sprintf("Method: %-20s Mean: %d", samp_names[s], samp_means[s]))
  }
}

## Visualization of Total Crimes as Heatmap

years <- seq(from=2012, to=2019)
total_matrix <- matrix(nrow=length(district_names), ncol=length(years),
                       dimnames = list(districts_short, years))

for (n in 1:length(district_names)) {
  for (y in 1:length(years)) {
    indexes <- which((crimes$Year == years[y] & crimes$District==district_names[n]))
    total_matrix[n,y] <- sum(crimes$Total[indexes])
  }
}

heatmap(total_matrix, Rowv=NA, Colv=NA, scale="row",
        main="Total Crimes By District in Berlin, 2012-2019", 
        margins = c(10,10)) # Create heatmap, scaled by rows