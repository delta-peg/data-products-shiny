#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(tidyverse)
library(shiny)

data("mtcars")
mtcars <- mtcars %>%
    mutate(transmission = as.factor(mtcars$am)) %>%
    mutate(rowId = row.names(mtcars))

levels(mtcars$transmission) = c("automatic", "manual")

naive_model <- lm(mpg ~ transmission, data = mtcars)
better_model <- lm(mpg ~ transmission + hp + wt, data = mtcars)

prediction <- mtcars %>%
    mutate(prediction_mpg_naive = predict(naive_model, mtcars)) %>%
    mutate(prediction_mpg_better = predict(better_model, mtcars)) %>%
    pivot_longer(cols = c("mpg", "prediction_mpg_naive", "prediction_mpg_better"),
                 values_to = "mpg",
                 names_to = "prediction_type") %>%
    mutate(prediction_type = if_else(prediction_type == "mpg", "real", if_else(prediction_type == "prediction_mpg_naive", "naive", "better"))) %>%
    mutate(prediction_type = as.factor(prediction_type))
levels(prediction$prediction_type) = c("real", "naive", "better")

residuals <- mtcars %>%
    mutate(naive = mpg - predict(naive_model, mtcars)) %>%
    mutate(better = mpg - predict(better_model, mtcars)) %>%
    mutate(real = 0) %>%
    pivot_longer(cols = c("real", "naive", "better"),
                 values_to = "residual",
                 names_to = "prediction_type")

gg_color_hue <- function(n) {
    hues = seq(15, 375, length = n + 1)
    hcl(h = hues, l = 65, c = 100)[1:n]
}

cols = gg_color_hue(3)
plot_theme <- theme(
    text = element_text(size = 18),
    axis.text.x = element_text(angle = 90, size = 10))
plot_x_lab <- xlab("Car Model")
colours = c("real" = cols[1], "naive" = cols[2], "better" = cols[3])

shinyServer(function(input, output) {
    output$naiveModelSelected <- renderText({ input$naiveModel })
    output$betterModelSelected <- renderText({ input$betterModel })

    desired_values <- reactive({
        desired_values <- c("real")
        if(input$naiveModel){
            desired_values = append(desired_values, "naive")
        }
        if(input$betterModel){
            desired_values = append(desired_values, "better")
        }
        desired_values
    })

    prediction_data <- reactive({
        prediction %>%
            filter(prediction_type %in% desired_values())
    })

    residual_data <- reactive({
        residuals %>%
            filter(prediction_type %in% desired_values())
    })

    output$predict_vs_real <- renderPlot({
        prediction_data() %>%
            ggplot(aes(x = rowId, y=mpg, color=prediction_type)) +
            geom_point(size = 3) +
            ggtitle("Miles per Gallon: Reality vs. Prediction") +
            plot_x_lab +
            scale_color_manual(name=NULL,
                               breaks = c("real", "naive" ,"better"),
                               labels = c("real value", "naive prediction", "better prediction"),
                               values = colours) +
            plot_theme

    })


    output$residuals = renderPlot({
        residual_data() %>%
            ggplot(aes(x = rowId, y=residual, color=prediction_type)) +
            geom_point(size = 3) +
            ggtitle("Miles per Gallon: Reality vs. Prediction (Residual Plot)") +
            plot_x_lab +
            scale_color_manual(name=NULL,
                               breaks = c("real", "naive" ,"better"),
                               labels = c("real value", "naive prediction", "better prediction"),
                               values = colours) +
            plot_theme

        #plot(naive_model$residuals, main = "Residual plot for the naive model")
    })


})
