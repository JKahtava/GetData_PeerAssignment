# Codebook for run_analysis
Jussi Kahtava  
27 August 2016  
Code book for Getting and Cleaning Data Peer Assignment on smartphone data
==========================================================================
#Study design

## Raw data

The data being processed in this project is based on smartphone data from Android devices.
The experiments were carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, the device captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The obtained dataset was randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

The dataset was acquired from the following site with R Studio.

```r
if(!file.exists("./smartphones.zip")) {
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./smartphones.zip")
}
```
The zipped dataset includes the following files:

- 'features_info.txt': Shows information about the variables used on the feature vector.

- 'features.txt': List of all features.

- 'activity_labels.txt': Links the class labels with their activity name.

- 'train/X_train.txt': Training set.

- 'train/y_train.txt': Training labels.

- 'test/X_test.txt': Test set.

- 'test/y_test.txt': Test labels.

- 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 
- 'test/subject_test.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 

All of these files were uploaded to R as a precursor to cleaning and further processing

```r
x_train <- read.table("./UCI HAR Dataset/train/X_train.txt", header = FALSE, 
                                         stringsAsFactors = FALSE)
y_train <- read.table("./UCI HAR Dataset/train/Y_train.txt", header = FALSE, 
                      stringsAsFactors = FALSE)

x_test <- read.table("./UCI HAR Dataset/test/X_test.txt", header = FALSE, 
                      stringsAsFactors = FALSE)
y_test <- read.table("./UCI HAR Dataset/test/Y_test.txt", header = FALSE, 
                     stringsAsFactors = FALSE)

features_list <- read.table("./UCI HAR Dataset/features.txt", header = FALSE, 
                            stringsAsFactors = FALSE)
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt", 
                            header = FALSE, stringsAsFactors = FALSE)
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt", 
                           header = FALSE, stringsAsFactors = FALSE)
activityLabels <- read.table("./UCI HAR Dataset/activity_labels.txt", header = FALSE, 
                              stringsAsFactors = TRUE)
```

`Features` in the raw dataset consist of 561 features which are normalized and bounded within [-1,1].

The set of variables the features columns represent fall into:

- mean(): Mean value
- std(): Standard deviation
- mad(): Median absolute deviation 
- max(): Largest value in array
- min(): Smallest value in array
- sma(): Signal magnitude area
- energy(): Energy measure. Sum of the squares divided by the number of values. 
- iqr(): Interquartile range 
- entropy(): Signal entropy
- arCoeff(): Autorregresion coefficients with Burg order equal to 4
- correlation(): correlation coefficient between two signals
- maxInds(): index of the frequency component with largest magnitude
- meanFreq(): Weighted average of the frequency components to obtain a mean frequency
- skewness(): skewness of the frequency domain signal 
- kurtosis(): kurtosis of the frequency domain signal 
- bandsEnergy(): Energy of a frequency interval within the 64 bins of the FFT of each window.
- angle(): Angle between two vectors.




# Code book

In this analysis we are only interested in the mean and standard deviation related measurements out of the complete total of 561 features. We also merge the training and testing sets, which were uploaded in `x_train.txt` and `x_test.txt`, respectively. In order to map each observation to a relevant activity, the labels are contained in `y_train.txt` and `y_test.txt`. These label numbers are further matched to specific activities in `activity_labels.txt`:

```
##   V1                 V2
## 1  1            WALKING
## 2  2   WALKING_UPSTAIRS
## 3  3 WALKING_DOWNSTAIRS
## 4  4            SITTING
## 5  5           STANDING
## 6  6             LAYING
```
The label names are contained in `activityLabels` which has two columns: `activity` for the numeric code, and `activitylabel` for the written label name.

The 30 volunteers are identified as numbers in files `subject_train.txt` and `subject_test.txt`. The processing of the raw dataset for further analysis consists of the following two main steps:

1) merge the features columns (from `x_train` and `x_test`) with activity labels ((from `y_train` and `y_test`)) and subject identifiers (from (from `subject_train` and `subject_test`)).
2) extract the features that relate to mean and standard deviation measurements and exclude the other columns

### Merging of datasets
The merging begins with combining the training and testing sets. A new dataframe called `fullDataset` is generated as a combination of `x_train` and `x_test` with `rbind`.At this stage, the variable names are unchanged and are the same as the original names in `features_list.txt`. 

The activity labels in `y_train` and `y_test` are combined with `rbind` into a new data frame called `fullLabels`. The single variable in this dataframe is renamed as `activity`.

The subject IDs in `subject_train.txt` and `subject_test.txt` are combined with `rbind` into a new data frame called `subject_table` and factorised. 

### Extracting mean and standard deviation related measurements

Now subsetting the dataframe in `fullDataset` takes place. We identify all the feature variables related to mean and standard deviation though searching with regular expressions (`grepl`) for *"mean"* and *"std"*. This reduced table of features is assigned to a new data frame called `reducedDataset`. The dimensions of the dataset fall from (10299, 561) to (10299, 66).

### Combining data frames to create a tidy dataset

At this stage, `reducedDataset` only contains the features columns. The next step in the processing is to add the activity labels (from `fullLabels` with `cbind`) and factorise those values. Following this, the subject IDs are added (from `subject_table` with `cbind`). As a result, the data frame`reducedDataset` has 68 columns with the variable `activitylabel` containing the factorised variable of six activity values, and the variable `testsubject` containing the factorised variable of thirty subject IDs.

As a final step in the merging process, the activity label names from `activityLabels` are added to the respective activity label values. This is achieved through merging `activityLabels` and `reducedDataset` with `merge` by `"activity"` which is a variable in both data frames. 

After this merge, the variable holding numeric activity code (1 to 6) is redundant since we have the activity names now in the data frame. As a final step, the first column (`activity`) of `reducedDataset` is removed, leaving a data frame of dimensions (10299, 68).

### Renaming the variables

The variable names for the 66 features related to mean and standard deviation measurements are fairly obscure. They are renamed by assigning a new `names(reducedDataset)` value from a character vector `namesFull`:

```
##  [1] "activitylabel"                      
##  [2] "testsubject"                        
##  [3] "bodyAccelerationTDMean_X"           
##  [4] "bodyAccelerationTDMean_Y"           
##  [5] "bodyAccelerationTDMean_Z"           
##  [6] "bodyAccelerationTDStd_X"            
##  [7] "bodyAccelerationTDStd_Y"            
##  [8] "bodyAccelerationTDStd_Z"            
##  [9] "gravityAccelerationTDMean_X"        
## [10] "gravityAccelerationTDMean_Y"        
## [11] "gravityAccelerationTDMean_Z"        
## [12] "gravityAccelerationTDStd_X"         
## [13] "gravityAccelerationTDStd_Y"         
## [14] "gravityAccelerationTDStd_Z"         
## [15] "bodyAccelerationJerkTDMean_X"       
## [16] "bodyAccelerationJerkTDMean_Y"       
## [17] "bodyAccelerationJerkTDMean_Z"       
## [18] "bodyAccelerationJerkTDStd_X"        
## [19] "bodyAccelerationJerkTDStd_Y"        
## [20] "bodyAccelerationJerkTDStd_Z"        
## [21] "bodyGyroscopeTDMean_X"              
## [22] "bodyGyroscopeTDMean_Y"              
## [23] "bodyGyroscopeTDMean_Z"              
## [24] "bodyGyroscopeTDStd_X"               
## [25] "bodyGyroscopeTDStd_Y"               
## [26] "bodyGyroscopeTDStd_Z"               
## [27] "bodyGyroscopeJerkTDMean_X"          
## [28] "bodyGyroscopeJerkTDMean_Y"          
## [29] "bodyGyroscopeJerkTDMean_Z"          
## [30] "bodyGyroscopeJerkTDStd_X"           
## [31] "bodyGyroscopeJerkTDStd_Y"           
## [32] "bodyGyroscopeJerkTDStd_Z"           
## [33] "bodyAccelerationMagnitudeTDMean"    
## [34] "bodyAccelerationMagnitudeTDStd"     
## [35] "gravityAccelerationMagnitudeTDMean" 
## [36] "gravityAccelerationMagnitudeTDStd"  
## [37] "bodyAccelerationJerkMagnitudeTDMean"
## [38] "bodyAccelerationJerkMagnitudeTDStd" 
## [39] "bodyGyroscopeMagnitudeTDMean"       
## [40] "bodyGyroscopeMagnitudeTDStd"        
## [41] "bodyGyroscopeJerkMagnitudeTDMean"   
## [42] "bodyGyroscopeJerkMagnitudeTDStd"    
## [43] "bodyAccelerationFDMean_X"           
## [44] "bodyAccelerationFDMean_Y"           
## [45] "bodyAccelerationFDMean_Z"           
## [46] "bodyAccelerationFDStd_X"            
## [47] "bodyAccelerationFDStd_Y"            
## [48] "bodyAccelerationFDStd_Z"            
## [49] "bodyAccelerationJerkFDMean_X"       
## [50] "bodyAccelerationJerkFDMean_Y"       
## [51] "bodyAccelerationJerkFDMean_Z"       
## [52] "bodyAccelerationJerkFDStd_X"        
## [53] "bodyAccelerationJerkFDStd_Y"        
## [54] "bodyAccelerationJerkFDStd_Z"        
## [55] "bodyGyroscopeFDMean_X"              
## [56] "bodyGyroscopeFDMean_Y"              
## [57] "bodyGyroscopeFDMean_Z"              
## [58] "bodyGyroscopeFDStd_X"               
## [59] "bodyGyroscopeFDStd_Y"               
## [60] "bodyGyroscopeFDStd_Z"               
## [61] "bodyAccelerationMagnitudeFDMean"    
## [62] "bodyAccelerationMagnitudeFDStd"     
## [63] "bodyAccelerationJerkMagnitudeFDMean"
## [64] "bodyAccelerationJerkMagnitudeFDStd" 
## [65] "bodyGyroscopeMagnitudeFDMean"       
## [66] "bodyGyroscopeMagnitudeFDStd"        
## [67] "bodyGyroscopeJerkMagnitudeFDMean"   
## [68] "bodyGyroscopeJerkMagnitudeFDStd"
```
The variable names are constructed in an ordered sequence as follows:

1. body acceleration/gyroscope or gravity accelaration
2. Jerk or Magnitude appended where relevant
3. time domain (TD), or frequency domain (FD)
4. mean (Mean) or standard deviation (Std)
5. axial direction (X, Y, Z) where relevant

This completes the processing on the `reducedDataset` data frame.

```r
head(reducedDataset[1:4])
```

```
##   activitylabel testsubject bodyAccelerationTDMean_X
## 1       WALKING          28                0.3079548
## 2       WALKING          28                0.1683027
## 3       WALKING          28                0.3430729
## 4       WALKING          28                0.3099743
## 5       WALKING          28                0.1695621
## 6       WALKING          28                0.3361759
##   bodyAccelerationTDMean_Y
## 1             -0.006165101
## 2             -0.018619489
## 3             -0.027223321
## 4             -0.043633369
## 5             -0.008864070
## 6              0.022230031
```

```r
str(reducedDataset[1:4])
```

```
## 'data.frame':	10299 obs. of  4 variables:
##  $ activitylabel           : Factor w/ 6 levels "LAYING","SITTING",..: 4 4 4 4 4 4 4 4 4 4 ...
##  $ testsubject             : Factor w/ 30 levels "1","2","3","4",..: 28 28 28 28 28 28 28 28 28 28 ...
##  $ bodyAccelerationTDMean_X: num  0.308 0.168 0.343 0.31 0.17 ...
##  $ bodyAccelerationTDMean_Y: num  -0.00617 -0.01862 -0.02722 -0.04363 -0.00886 ...
```

# Creating a tidy data set for average feature values

The outcome of the previous round of processing, `reducedDataset` is taken as the basis for a further step, where the averages of all the 66 feature variables are store for each activity (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING ) and each subject (1 to 30).

This new data frame, called `averageFeatures` is generated from `reducedDataset` with dplyr tools of:

- group-by `activitylabel` and `testsubject`
- summarise_each by `mean`

The names of the variables are unchanged from `reducedDataset`.


```r
head(averageFeatures[1:3])
```

```
## Source: local data frame [6 x 3]
## Groups: activitylabel [1]
## 
##   activitylabel testsubject bodyAccelerationTDMean_X
##          <fctr>      <fctr>                    <dbl>
## 1        LAYING           1                0.2215982
## 2        LAYING           2                0.2813734
## 3        LAYING           3                0.2755169
## 4        LAYING           4                0.2635592
## 5        LAYING           5                0.2783343
## 6        LAYING           6                0.2486565
```

Finally, the tidy dataset of feature averages for each activity and subject is stored as a csv-file in `meanandstd_averages.txt`.



# Software version and hardware information
All the processing was done under the following session parameters:

```
## R version 3.3.1 (2016-06-21)
## Platform: x86_64-w64-mingw32/x64 (64-bit)
## Running under: Windows 7 x64 (build 7601) Service Pack 1
## 
## locale:
## [1] LC_COLLATE=English_United Kingdom.1252 
## [2] LC_CTYPE=English_United Kingdom.1252   
## [3] LC_MONETARY=English_United Kingdom.1252
## [4] LC_NUMERIC=C                           
## [5] LC_TIME=English_United Kingdom.1252    
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] dplyr_0.5.0
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_0.12.6     digest_0.6.10   assertthat_0.1  R6_2.1.2       
##  [5] DBI_0.4-1       formatR_1.4     magrittr_1.5    evaluate_0.9   
##  [9] stringi_1.1.1   lazyeval_0.2.0  rmarkdown_1.0   tools_3.3.1    
## [13] stringr_1.0.0   yaml_2.1.13     htmltools_0.3.5 knitr_1.14     
## [17] tibble_1.1
```
