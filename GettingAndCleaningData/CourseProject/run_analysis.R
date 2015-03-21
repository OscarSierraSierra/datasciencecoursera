# R commands for the Course Project of Getting and Cleaning Data in
# the Data Scientist series of courses from Johns Hopkins University
# through Coursera.org.
setwd("C:/Users/Bill/Desktop/ImportantPlaces/CourseraJohnsHopkinsDataScientistSeriesClasses/GettingAndCleaningData/CourseProject")
#
# The purpose of this project is to demonstrate your ability to collect, work with,
# and clean a data set. The goal is to prepare tidy data that can be used for later
# analysis. You will be graded by your peers on a series of yes/no questions related
#to the project. You will be required to submit: 1) a tidy data set as described
# below, 2) a link to a Github repository with your script for performing the
# analysis, and 3) a code book that describes the variables, the data, and any
# transformations or work that you performed to clean up the data called CodeBook.md.
# You should also include a README.md in the repo with your scripts. This repo
# explains how all of the scripts work and how they are connected.  
#
# One of the most exciting areas in all of data science right now is wearable
# computing - see for example this article . Companies like Fitbit, Nike, and
# Jawbone Up are racing to develop the most advanced algorithms to attract new
# users. The data linked to from the course website represent data collected from
# the accelerometers from the Samsung Galaxy S smartphone. A full description is
# available at the site where the data was obtained: 
#
#   http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 
#
# Here are the data for the project: 
#
#   https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
#
# You should create one R script called run_analysis.R that does the following.
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with
#    the average of each variable for each activity and each subject.
#
#################################################################################
# 1. Merges the training and the test sets to create one data set.
#################################################################################
# set up a string that specifies the directoy just above the data
rawLocation <- "./getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/"
#Make sure we are in the correct place to run
if (!file.exists("getdata-projectfiles-UCI HAR Dataset")){
  print("This script must be run in the directory where the unzipped data is below it.")
  print("In other words, the directory it is run in must include this tree:")
  print("getdata-projectfiles-UCI HAR Dataset")
  print("See the course teaching assistant post at")
  print("https://class.coursera.org/getdata-011/forum/thread?thread_id=69")
  quit()
}
# read in all test data. Use sep="" to combine contiguous separators (blanks)
test <- read.csv(paste(rawLocation,"test/X_test.txt",sep=""),header=FALSE,sep="")
# Check that the number of columns is the same in both test and train data frames.
ncol(test)
# read in all training data. Use sep="" to combine contiguous separators (blanks)
train <- read.csv(paste(rawLocation,"train/X_train.txt",sep=""),header=FALSE,sep="")
# Check that the number of columns is the same in both test and train data frames.
ncol(train)
# Since they both have the same number of columns, we can combine the two datasets
# by putting all rows of one at the end of the other
all<-rbind(train,test)

#
#################################################################################
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
#################################################################################
#
# Read in the names of the descriptions
# Make sure the names are read in as strings, not factors,
# because factors cannot be used in string commands (text manipulation)
columns <- read.csv(paste(rawLocation,"features.txt",sep=""),header=FALSE,sep="",stringsAsFactors=FALSE)
# Check that there are 561 rows and 2 columns in this list of column names
nrow(columns)
ncol(columns)
# Find all the column names that relate to the mean or the standard deviation (std)
goodCols <- grep("-mean|-std\\(", columns$V2)
# Now goodCols is a list of the column numbers that we want so we can extract those and forget the rest.
meanAndStd <- all[,goodCols]
#
#################################################################################
# 3. Uses descriptive activity names to name the activities in the data set
#################################################################################
#
# The y_test.txt and y_train.txt files have the activity numbers for each row.
# We create one long vector containing both, then bind that onto the left hand side
# of the matrix (data frame) that we have so far.
# Then, the activity_labels.txt file has the matchup between those activity numbers
# and the their descriptions, for example it shows that 1 means Walking.
# So then we replace the activity numbers with the words that describe the activities.
# The result is a column in the data frame that labels each row.
#
# In this same step we will bind the subject data.  That is, the number of each
# subject will be bound to each row.  We will need this in step 5.
# We'll bind in the subject numbers first to give each row this form:
# Activity; subject; ... columns of data ...
subject_test<-read.csv(paste(rawLocation,"test/subject_test.txt",sep=""),header=FALSE,sep="",stringsAsFactors=FALSE)
subject_train<-read.csv(paste(rawLocation,"train/subject_train.txt",sep=""),header=FALSE,sep="",stringsAsFactors=FALSE)
subject_all<-rbind(subject_test,subject_train)

y_test<-read.csv(paste(rawLocation,"test/y_test.txt",sep=""),header=FALSE,sep="",stringsAsFactors=FALSE)
y_train<-read.csv(paste(rawLocation,"train/y_train.txt",sep=""),header=FALSE,sep="",stringsAsFactors=FALSE)
y_all<-rbind(y_test,y_train)

#Now our list of activity numbers is as long as the number of rows in meanAndStd.
# So we can add y_all as a new column on meanAndStd.
meanAndStd <- cbind(y_all, subject_all, meanAndStd)

#Next read in the factor table and use it to label the rows in meanAndStd.
factorTable<-read.csv(paste(rawLocation,"activity_labels.txt",sep=""),header=FALSE,sep="",stringsAsFactors=FALSE)
meanAndStd$V1<-factor(meanAndStd$V1,labels=factorTable$V2)
#
# NOW we have each row of the dataframe labeled with the name of its activity!
#
#################################################################################
# 4. Appropriately labels the data set with descriptive variable names.
#################################################################################
#
# What this means is to put the labels at the top of each column.
# We had the labels in the file features.txt
# And we know which ones are in our current dataframe named meanAndStd
# are stored in goodCols.
# Plus we have one more column that we can call "Activity".
# We can apply these things in order to put a descriptive label on each column.
names(meanAndStd)[]<-c("Activity","Subject",columns$V2[goodCols])
head(meanAndStd,1)
# DONE!
#################################################################################
# 5. From the data set in step 4, creates a second, independent tidy data set with
#    the average of each variable for each activity and each subject.
#################################################################################
#
# We start this step with a dataframe called meanAndStd which has 10299 rows.
# Each row has an Activity label (text), a Subject column (1 through 30), and
# 79 columns of data.
# Each column of data is labeled with the appropriate feature name from features.txt.
# I have included the "meanFreq" data columns because they are included in the
# list of signals in the "feature_info.txt" file.
# I did not include the "angle" columns because this is not "mean" of anything,
# instead it is the relationship between different sets of "means".
#
# Careate a new empty data frame that is sized to hold our new data.
# It will have a column of Activity names, a column of subject numers,
# and 79 columns of data, like our meanAnStd dataframe.
# But it will only have 180 rows: one for each subject/activity combination.
df<-data.frame(matrix(NA, nrow = 30*6, ncol = 81))
for (s in 1:30) {
    for (a in 1:6) {
      df[((s-1)*6)+a,80]<-factorTable$V2[a] #set the Activity for this row
      df[((s-1)*6)+a,81]<-s  #set the Subject for this row
      # logical vector of TRUE/FALSE for rows that meet this criteria
      temp<-meanAndStd$Subject == s & meanAndStd$Activity == factorTable$V2[a]
        for (i in 1:79) { #calculate the mean() for each column,
          # for all the rows that match the current subject and activity
          df[((s-1)*6)+a,i]<-mean(meanAndStd[temp,i+2],na.rm=TRUE)
        }
    }
}
names(df)<-c(names(meanAndStd)[3:81],names(meanAndStd)[1:2])  #label the columns
write.table(df,paste(rawLocation,"FinalTidyData.txt",sep=""),row.name=FALSE) #write the result to a file
