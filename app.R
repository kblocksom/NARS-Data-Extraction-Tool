#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
source('global.r')

# Define UI for application that draws a histogram
ui <- fluidPage(
  tags$html(class = "no-js", lang="en"),
  tags$head(
    tags$title('NARS Data Extraction|US EPA'),
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css"),
    includeHTML("www/header.html")),

   shinyjs::useShinyjs(),
   # Application title
   navbarPage("NARS Data Extraction & Reporting Tool for Desktop (v. 2.1.3)",
              # Instructions and About ----
              tabPanel(span('About',title='How to use this Shiny app'),
                       fluidRow(column(2, imageOutput("narsLogo")),
                                column(6,h2(strong('Tool Overview')), offset=1,
                                       p('The NARS Rapid Data Extraction and Reporting Tool expedites data availability
                                                            to field crews and offers preliminary end-of-day site reports to landowners to 
                                         promote survey awareness and continued sampling support.'),
                                       br(),
                                       p('After completing all sampling and sample processing, crews submit data from the app to ',
                                         span(strong('NARS IM.')),'At that point, all of the .JSON files from that site visit
                                                            and collected on that iPad will be attached to an email to NARS IM. 
                                                            The crew can copy that email to other
                                                            addresses and later save those .JSON files (and any from other iPads 
                                                            used at that site) to a folder containing all of the data collected 
                                                            from an individual site visit. This tool parses and compiles the data 
                                                            from .JSON files into spreadsheet formats to 
                                                            promote data utility and offers and optional site report based on 
                                                            field-collected data, such as field parameters and lists of fish 
                                                            species collected, to be sent by the team lead to the landowner shortly 
                                                            after sampling.'),
                                       br(),
                                ),
                                column(1)), hr(), br(),
                       fluidRow(column(1), column(10, h3(strong('Instructions')),
                                                  p('After compiling all of the .JSON files for a site visit into a single directory, 
                                                  users are ready to extract and organize the data. On the Data Upload and Extraction 
                                                  tab, users first select the survey app used to collect the data (NRSA 2018-19, 
                                                  NLA 2017, NLA 2022, NCCA 2020, or NWCA 2021), then select the directory where their data is saved 
                                                    to upload .JSON files to the app for processing. Once the data is uploaded to 
                                                    the app, click the',
                                                    span(strong('Parse data in selected files')), 'button. Then users will have 
                                                            the option to save the data as a .zip file containing individual .csv 
                                                            files or a single MS Excel spreadsheet containing worksheets of each dataset.',
                                                    span(strong('If data outputs do not look as expected, make sure you have selected the 
                                                            correct survey app. Only valid sample types will be processed for each survey, 
                                                            so if data are missing, that is a possible reason.'))),
                                                  br(),
                                                  p('After uploading the data, if users want to generate a basic site report for their 
                                                            records or to distribute to the landowner, they may navigate to the Field
                                                            Visit Summary tab and follow the on screen prompts to save an
                                                            autogenerated HTML file based on their input site data.')
                       ),
                       column(1))),
  # Data Upload and Extraction Tab ----            
              tabPanel(span('Data Upload and Extraction',title="Select data to upload and extract"),
                       
                       sidebarPanel(radioButtons('survey',"Select survey app used (select one):",
                                                 choices = c('NRSA 2018-19/2023-24' = 'nrsa1819',
                                                             'NLA 2017' = 'nla17',
                                                             'NLA 2022' = 'nla22',
                                                             'NCCA 2020/2025' = 'ncca20',
                                                             'NWCA 2021' = 'nwca21'),
                                                 select = ''),
                                    h4(strong('Instructions')),
                                    p('1) Select all the .JSON files associated with a single site visit by clicking on the ‘Browse’
                                      button below.  In the directory window that appears, locate the folder in which the files are
                                      saved, select one or multiple files, and upload them by clicking on the ‘Open’ button.  Note 
                                      that multiple files may be selected at once by holding down the Ctrl key.  Upon success, a 
                                      blue ‘Upload complete’ bar appears along with the number of files uploaded.  The uploaded 
                                      file names will also be listed in the window to the right.'),
                                    fileInput(inputId='directory', buttonLabel='Browse...', 
                                              label='Please select files within a folder, holding down Ctrl key to select multiple files.',
                                              multiple=TRUE, accept=c('json','JSON')), 
                                    p('2) Click on the ‘Parse data’ button below to prepare the uploaded files for conversion to .xlsx and .csv format.'),
                                    shinyjs::disabled(actionButton('parseFiles','Parse data')),
                                    br(), hr(),
                                    p('3) To download and save the .JSON data in .xlsx or .csv file formats, click on the appropriate
                                      ‘Save Results’ button below.  A directory window will appear allowing you to choose where to 
                                      save the files. Note: .xlsx files will save as one file with each .JSON file in a separate 
                                      tab while .csv files will save as a .zip file with each .JSON file saved as an individual 
                                      .csv file.'), 
                                    br(),
                                    
                                    downloadButton("downloadxlsx","Save Results as .xlsx"),
                                    downloadButton("downloadcsv","Save Results as .csv")),
                       bsTooltip('directory','Select files for site visit',trigger='hover'),
                       bsTooltip('parseFiles','Click here to parse and organize data',trigger='hover'),
                       bsTooltip('downloadxlsx','Save data to worksheets in an Excel file.',trigger='hover'),
                       bsTooltip('downloadcsv','Save data to comma-delimited files in a .zip file.',trigger='hover'),
                       mainPanel(
                         h5('Uploaded file name(s)'),
                         tableOutput('preview'))),
  # Field Visit Summary Tab ----
              tabPanel(span('Field Visit Summary', title='Create a basic report on field activities'),
                       sidebarPanel(p('This tool creates a basic report in html format based on data collected 
                       during a field visit to a site. It can be saved for crew records or provided to the landowner, 
                                          either via email or printed and mailed. At a minimum, the', 
                                      span(strong('verification form')), 
                                      '(or PV-1 and AA-1 for NWCA) must be submitted.')),
                       mainPanel(
                         shinyjs::disabled(downloadButton('report','Generate Field Visit Summary (HTML)'))))),
  # Site Footer ----
  includeHTML("www/footer.html") # END fluidPage
)

# Start of Server -----
# Define server logic required to draw a histogram
server <- function(input, output, session) {
  # render stream image
  output$narsLogo <- renderImage({
    filename <- normalizePath(file.path('./www',
                                        paste('NARS_logo_sm.jpg')))

    # Return list containing the filename and alt text
    list(src = filename, alt='NARS logo')
  },
  deleteFile=FALSE)

  observeEvent(input$survey, {
    shinyjs::enable('parseFiles')
  })

  observeEvent(input$parseFiles, {
    shinyjs::enable('report')
  })

  # Reactive Value to store all user data
  userData <- reactiveValues()


  # Bring in user data when they select directory
  # volumes <- getVolumes()
  path1 <- reactive({
    path_list <- as.vector(input$directory$datapath)
  })

  filesInDir <- reactive({
    name_list <- as.vector(input$directory$name)
  })

  # Files in directory preview for UI - This works
  output$preview <- renderTable({
    req(filesInDir())
    filesInDir() },colnames=FALSE)

  # The user data
  observeEvent(input$parseFiles, {
    userData$finalOut <- narsOrganizationShiny(input$survey, as.vector(input$directory$datapath), as.vector(input$directory$name))  })


  # Don't let user click download button if no data available
  observe({ shinyjs::toggleState('downloadxlsx', length(userData$finalOut) != 0  )  })
  observe({ shinyjs::toggleState('downloadcsv', length(userData$finalOut) != 0  )  })


  # Download Excel File -----
  output$downloadxlsx<- downloadHandler(filename = function() {
    paste(unique(userData$finalOut[[1]][[1]]$UID),
          "summary.xlsx", sep='_')},
    content = function(file) {
      write_xlsx(narsWriteShiny(input$survey, as.vector(input$directory$name), userData$finalOut), path = file)}
  )


  # Download CSV ----

  output$downloadcsv <- downloadHandler( filename = function() {
    paste(unique(userData$finalOut[[1]][[1]]$UID),
          "csvFiles.zip", sep="_")
  },
  content = function(fname) {
    fs <- c()
     z <- narsWriteShiny(input$survey, as.vector(input$directory$name), userData$finalOut)

    for (i in 1:length(z)) {

      path <- paste0(unique(userData$finalOut[[1]][[1]]$UID), "_",
                     names(z)[[i]], ".csv")
      fs <- c(fs, path)
      write.csv(data.frame(z[[i]]), path, row.names=F)
    }

    zip::zipr(zipfile=fname, files=fs)

    for(i in 1:length(fs)){
      file.remove(fs[i])
    }
  },
  contentType = "application/zip"
  )


  # RMarkdown Section-------

  # Send input data to html report

  output$report <- downloadHandler(filename = function(){
    paste(unique(userData$finalOut[[1]][[1]]$UID),
          "FieldVisitSummary.html",sep="_")
    },
    content= function(file){
      switch(input$survey,
             'nrsa1819' = {reportName <- 'nrsaLandownerReport_fromApp.Rmd'},
             'nla17' = {reportName <- 'nlaLandownerReport_fromApp.Rmd'},
             'ncca20' = {reportName <- 'nccaLandownerReport_fromApp.Rmd'},
             'nwca21' = {reportName <- 'nwcaLandownerReport_fromApp.Rmd'},
             'nla22' = {reportName <- 'nlaLandownerReport_fromApp22.Rmd'}
      )
      
      switch(input$survey,
             'nrsa1819' = {logoName <- 'NRSA_logo_sm.jpg'},
             'nla17' = {logoName <- 'NLA_logo_sm.jpg'},
             'ncca20' = {logoName <- 'NCCA_logo_sm.jpg'},
             'nwca21' = {logoName <- 'NWCA_logo_sm.jpg'},
             'nla22' = {logoName <- 'NLA_logo_sm.jpg'})
      tempReport <- normalizePath(reportName)
      imageToSend1 <- normalizePath(logoName)  # choose image name
      owd <- setwd(tempdir())
      on.exit(setwd(owd))
      file.copy(tempReport, reportName)
      file.copy(imageToSend1, logoName) # same image name

      params <- list(userDataRMD=userData$finalOut)

      rmarkdown::render(tempReport,output_file = file,
                        params=params,envir=new.env(parent = globalenv()))})


#  session$onSessionEnded(function() {
#    stopApp()
#  })

}

# Run the application
shinyApp(ui = ui, server = server)
