#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Comparing two Prediction Models for the Efficiency (Miles per Gallon) of a Car"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            checkboxInput("naiveModel", "Show prediction for naive model", FALSE),
            checkboxInput("betterModel", "Show prediction for better model", FALSE)
        ),

        # Show a plot of the generated distribution
        mainPanel(
            h2("How to use:"),
            p("This Application builds two linear prediction models based on the", code("mtcars"),  "data set."),
            p("Both models predict the value of Miles per Gallon", code("mpg"), "."),
            p("The first", code("naive"), "model uses the formula", code("lm(mpg ~ transmission)."), "The second", code("better"), "model uses the formula", code("lm(mpg ~ transmission + hp + wt)")),
            p(strong("You may select with the checkboxes on the left, which model you would like to see predictions for.")),
            p("Note that the predicted values for the better model are, overall, indeed better. This is especially obvious in the residual plot. The blue dots
              are closer around the value 0 than the green dots (0 represents the real value in the residual plot)"),
            p("Also note that the ", code("naive"), "model only predicts two distinct values for mpg. This is because it predicts solely based
              on the transmission type of a car, which takes only two distinc values: ", code("automatic"), "and", code("manual"), "."),
            plotOutput("predict_vs_real"),
            plotOutput("residuals"))
    )
))
