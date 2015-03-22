# datasciencecoursera
The analysis script for Week 3 of the Getting and Cleaning data is called run_analysis.R.

First it checks if the data is present.  If not, it prints messages telling where they should be, and quits.

Then it reads in the test and trial data and uses rbind to clip them together.
Next it isolates the columns that are for mean or standard deviation data.
It does this by find the numbers and names of those columns in features.txt

In step 3 it matches up the activity numbers in y_trains.txt and y_test.txt to the rows in the dataframe, then uses the activity numbers and names in activity_labels.txt to label each row with its activities. In this step it also clips on the subject number for each row using subject_train.txt and subject_test.txt.

In step 4 it again uses the features.txt file and the numbers of the mean and std columns to label the columns of the data frame.

In step 5 it builds a new data frame DF that contains the mean for each combination of activity and subject.  For example if Subject 1 has 50 rows of waling data, they are summarized into the mean of each column, resulting in one row for subject 1 walking. And so on for the other activities and the other subjects.  The data frameis written out as a txt file created with write.table() using row.name=FALSE.