# this code is related to the Samsung smart phone data in the Week 4 peer reviewed
# exercise of Getting and cleaning data.
library(dplyr)
library(tidyr)

# first let's download the data to the disk
if(!file.exists("./smartphones.zip")) {
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./smartphones.zip")
unzip("smartphones.zip")
}

#upload the train dataset
x_train <- read.table("./UCI HAR Dataset/train/X_train.txt", header = FALSE, 
                                         stringsAsFactors = FALSE)
y_train <- read.table("./UCI HAR Dataset/train/Y_train.txt", header = FALSE, 
                      stringsAsFactors = FALSE)


# upload the test dataset
x_test <- read.table("./UCI HAR Dataset/test/X_test.txt", header = FALSE, 
                      stringsAsFactors = FALSE)
y_test <- read.table("./UCI HAR Dataset/test/Y_test.txt", header = FALSE, 
                     stringsAsFactors = FALSE)

# upload the remaning files for processing
features_list <- read.table("./UCI HAR Dataset/features.txt", header = FALSE, 
                            stringsAsFactors = FALSE)
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt", 
                            header = FALSE, stringsAsFactors = FALSE)
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt", 
                           header = FALSE, stringsAsFactors = FALSE)
subject_table <- rbind(subject_train, subject_test)
subject_table$V1 <- as.factor(subject_table$V1)
names(subject_table) <- "subject"

# extract variable names from features_list
names <- features_list$V2

names(x_train) <- names(x_test) <- names

# merge training and testing sets in fullDataset
fullDataset <- rbind(x_train, x_test)

fullLabels <- rbind(y_train, y_test)
names(fullLabels) <- c("activity")

# identify the locations of mean and std measurements with grepl
mean_measurements <- grepl("[Mm]ean.)", names)
std_measurements <- grepl("[Ss]td.)", names)

# and combine them, and select a subset of data containing only on the mean and
# standard deviation of each measurement; this is assigned to reducedDataset
measurements_of_interest <- mean_measurements | std_measurements
reducedDataset <- fullDataset[, measurements_of_interest]

# add a column for labels to the reduced dataset
reducedDataset <- cbind(fullLabels, reducedDataset)
reducedDataset$activity <- as.factor(reducedDataset$activity)

activityLabels <- read.table("./UCI HAR Dataset/activity_labels.txt", header = FALSE, 
                              stringsAsFactors = TRUE)
names(activityLabels) <- c("activity", "activitylabel")
activityLabels$activity <- as.factor(activityLabels$activity)

#append the subject infomation to the reduced dataset
reducedDataset <- cbind(subject_table, reducedDataset)

# merge activityLabels to reducedDataset to create a data frame having an observation
# for each activity and subject combination for their respective measurements
reducedDataset <- merge(activityLabels,reducedDataset,  by = "activity")
reducedDataset <- reducedDataset[, -1]

# define a vector with new descriptive names for all the measurement variables
namesFull <- names <- c(
        "activitylabel",          
        "testsubject",            
        "bodyAccelerationTDMean_X",
        "bodyAccelerationTDMean_Y",
        "bodyAccelerationTDMean_Z",     
        "bodyAccelerationTDStd_X",
        "bodyAccelerationTDStd_Y",
        "bodyAccelerationTDStd_Z",
        "gravityAccelerationTDMean_X",
        "gravityAccelerationTDMean_Y",
        "gravityAccelerationTDMean_Z",
        "gravityAccelerationTDStd_X",
        "gravityAccelerationTDStd_Y",
        "gravityAccelerationTDStd_Z",
        "bodyAccelerationJerkTDMean_X",
        "bodyAccelerationJerkTDMean_Y",
        "bodyAccelerationJerkTDMean_Z",
        "bodyAccelerationJerkTDStd_X",
        "bodyAccelerationJerkTDStd_Y",
        "bodyAccelerationJerkTDStd_Z",
        "bodyGyroscopeTDMean_X",
        "bodyGyroscopeTDMean_Y",
        "bodyGyroscopeTDMean_Z",
        "bodyGyroscopeTDStd_X",
        "bodyGyroscopeTDStd_Y",
        "bodyGyroscopeTDStd_Z",
        "bodyGyroscopeJerkTDMean_X",
        "bodyGyroscopeJerkTDMean_Y",
        "bodyGyroscopeJerkTDMean_Z",
        "bodyGyroscopeJerkTDStd_X",
        "bodyGyroscopeJerkTDStd_Y",
        "bodyGyroscopeJerkTDStd_Z",
        "bodyAccelerationMagnitudeTDMean",
        "bodyAccelerationMagnitudeTDStd",
        "gravityAccelerationMagnitudeTDMean",
        "gravityAccelerationMagnitudeTDStd",
        "bodyAccelerationJerkMagnitudeTDMean",
        "bodyAccelerationJerkMagnitudeTDStd",
        "bodyGyroscopeMagnitudeTDMean",
        "bodyGyroscopeMagnitudeTDStd",
        "bodyGyroscopeJerkMagnitudeTDMean",
        "bodyGyroscopeJerkMagnitudeTDStd",
        "bodyAccelerationFDMean_X",
        "bodyAccelerationFDMean_Y",
        "bodyAccelerationFDMean_Z",
        "bodyAccelerationFDStd_X",
        "bodyAccelerationFDStd_Y",
        "bodyAccelerationFDStd_Z",
        "bodyAccelerationJerkFDMean_X",
        "bodyAccelerationJerkFDMean_Y",
        "bodyAccelerationJerkFDMean_Z",
        "bodyAccelerationJerkFDStd_X",
        "bodyAccelerationJerkFDStd_Y",
        "bodyAccelerationJerkFDStd_Z",
        "bodyGyroscopeFDMean_X",
        "bodyGyroscopeFDMean_Y",
        "bodyGyroscopeFDMean_Z",
        "bodyGyroscopeFDStd_X",
        "bodyGyroscopeFDStd_Y",
        "bodyGyroscopeFDStd_Z",
        "bodyAccelerationMagnitudeFDMean",
        "bodyAccelerationMagnitudeFDStd",
        "bodyAccelerationJerkMagnitudeFDMean",
        "bodyAccelerationJerkMagnitudeFDStd",
        "bodyGyroscopeMagnitudeFDMean",
        "bodyGyroscopeMagnitudeFDStd",
        "bodyGyroscopeJerkMagnitudeFDMean",
        "bodyGyroscopeJerkMagnitudeFDStd"
)
names(reducedDataset) <- namesFull

# generate another table that contains the average of each variable 
# for each activity and subject

averageFeatures <- reducedDataset %>% group_by(activitylabel, testsubject)%>%
        summarise_each(funs(mean))
write.csv(averageFeatures, "./meanandstd_averages.csv", row.names = FALSE)
