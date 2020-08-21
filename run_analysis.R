# Loading the package
packages <- c("data.table", "reshape2")
sapply(packages, require, character.only=TRUE, quietly=TRUE)
path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "dataFiles.zip"))
unzip(zipfile = "dataFiles.zip")

# Loading features
label1 <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt")
                        , col.names = c("classLabels", "activityName"))
features <- fread(file.path(path, "UCI HAR Dataset/features.txt")
                  , col.names = c("index", "featureNames"))
featuresNeeded <- grep("(mean|std)\\(\\)", features[, featureNames])
measurements <- features[featuresNeeded, featureNames]
measurements <- gsub('[()]', '', measurements)

# Loading datasets
train <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, featuresNeeded, with = FALSE]
data.table::setnames(train, colnames(train), measurements)
trainActivities <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt")
                         , col.names = c("Activity"))
trainSubjects <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt")
                       , col.names = c("SubjectNum"))
train <- cbind(trainSubjects, trainActivities, train)
test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, featuresNeeded, with = FALSE]
data.table::setnames(test, colnames(test), measurements)
testActivities <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt")
                        , col.names = c("Activity"))
testSubjects <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt")
                      , col.names = c("SubjectNum"))
test <- cbind(testSubjects, testActivities, test)

# merging datasets
combined <- rbind(train, test)

# Combining and renaming labels 
combined[["Activity"]] <- factor(combined[, Activity]
                                 , levels = label1[["classLabels"]]
                                 , labels = label1[["activityName"]])

combined[["SubjectNum"]] <- as.factor(combined[, SubjectNum])
combined <- reshape2::melt(data = combined, id = c("SubjectNum", "Activity"))
combined <- reshape2::dcast(data = combined, SubjectNum + Activity ~ variable, fun.aggregate = mean)

#Writing the clean data into my txt file
data.table::fwrite(x = combined, file = "data.txt", quote = FALSE)