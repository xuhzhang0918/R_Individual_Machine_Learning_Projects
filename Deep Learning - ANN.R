# Data Preprocessing
dataset <- read.csv('Churn_Modelling.csv')
dataset = dataset[4:14]
dataset$Geography = factor(dataset$Geography, levels = c('France','Germany','Spain'), labels = c(1,2,3))
dataset$Gender = factor(dataset$Gender, levels = c('Female','Male'), labels = c(1,2))
library(caTools)
set.seed(123)
split = sample.split(dataset$Exited, SplitRatio = 0.8)
training_set = subset(dataset, split == TRUE)
test_set = subset(dataset, split == FALSE)
training_set[-c(2,3,11)] = scale(training_set[-c(2,3,11)])
test_set[-c(2,3,11)] = scale(test_set[-c(2,3,11)])

# Fitting ANN to the Training set
library(h2o)
h2o.init(nthreads = -1)
classifier = h2o.deeplearning(y = 'Exited', training_frame = as.h2o(training_set), activation = 'Rectifier', hidden = c(6,6), epochs = 100, train_samples_per_iteration = -2)

# Predicting the Test set results
prob_pred = h2o.predict(classifier, newdata = as.h2o(test_set[-11]))
y_pred = (prob_pred > 0.5)
y_pred = as.vector(y_pred)
# Making the Confusion Matrix
cm = table(test_set[, 11], y_pred)
