# Getting and Cleaning Data Peer Assignment
Jussi Kahtava  
28 August 2016  
Getting and Cleaning Data - Peer Assignment on smartphone data
==============================================================

This repository holds the following files for the Getting and Cleaning Data project:


1. run_analysis.R
2. CodeBook.md
3. Readme.md (this file)

## The purpose of the files
`run_analysis.R` contains all the script for

- downloading raw data from a website
- unzip and store the files into "./UCI HAR Dataset" folder
- uploading the files to R
- combining source data frames to create one data frame that holds activity names, subject IDs and feature variables for mean and standard deviation related measurements
- creating another tidy dataset where the averages of all the mean and standard deviation related measurements are reposted for each activity and subject ID

`CodeBook.md` gives more detailed explanation on how the process of reading in and transforming the data takes place.

## Using the files
In order to reproduce the data processing steps:


1. clone this repository
2. move `run_analysis.R` to your working directory (the folder `"/UCI HAR Dataset"` will be created under this working directory)
3. run `source("run_analysis.R")`
4. find the final, tidy dataset in the working directory as `"meanandstd_averages.csv"`


