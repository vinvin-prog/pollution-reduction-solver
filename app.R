library(shiny)
library(shinydashboard)

# "importing"/loading of the Simplex function file
source("SimplexMinimization.R")

# Load data
# Read CSV files para sa projects at targets
# check.names = FALSE para hindi mabago yung column names tulad ng "PM2.5"
projects <- read.csv("projects.csv", check.names = FALSE)
targets  <- read.csv("targets.csv", check.names = FALSE)

ui <- dashboardPage(
  skin = "green", # Built-in theme ng RShiny
  # Header sa taas ng dashboard
  dashboardHeader(
    title = tagList( # tagList groups multiple HTML tags or UI elements together para maging one object
      tags$img(src = "logo.png", height = "30px", style = "margin-right:10px;"), # Logo sa left ng title (adjust size via height)
      span("Greenvale Pollution Reduction Planner", style = "font-weight: bold; font-size: 20px;")
    )
  ),
  
  # Sidebar panel sa left side
  dashboardSidebar(
    collapsed = TRUE, # Kapag inopen yung app, closed yung navigation bar
    sidebarMenu(
      id = "sidebar_nav",  # Ito yung magiging basis kung anong tab ang naka-open
      menuItem(tagList(icon("home"), span("Dashboard", style = "margin-left: 8px;")),
               tabName = "dashboard"),  # Home page
      menuItem(tagList(icon("list"), span("Choose Projects", style = "margin-left: 8px;")),
               tabName = "choose"),  # Page na may project selection
      menuItem(tagList(icon("calculator"), span("Computation", style = "margin-left: 8px;")),
               tabName = "computation"), # Simplex iterations
      menuItem(tagList(icon("table"), span("Final Solution", style = "margin-left: 8px;")),
               tabName = "final"), # Last table output (summary)
      menuItem(tagList(icon("book"), span("App Navigation", style = "margin-left: 8px;")),
               tabName = "guide") # Guide kung paano gamitin yung app
    )
  ),
  
  # Main content area ng dashboard
  dashboardBody(
    # Custom CSS para sa formatting, design, and button alignment
    tags$head(
      tags$style(HTML("
        /* Global font for dashboard */
        body, .box, .panel, h2, h4, p {
            font-family: 'Roboto', 'Open Sans', sans-serif;
        }
        
        /* Headings stand out more */
        h2, h4 {
            font-family: 'Montserrat', sans-serif;
            font-weight: 700;
        }
        
        /* Dashboard card desings */
        .dashboard-card {
          background-color: #f9f9f9;
          border-radius: 8px;
          padding: 15px;
          margin-bottom: 20px;
          text-align: center;
          box-shadow: 0 4px 8px rgba(0,0,0,0.08);
          transition: transform 0.2s, box-shadow 0.2s;
        }
        .dashboard-card:hover {
          transform: translateY(-5px);
          box-shadow: 0 8px 16px rgba(0,0,0,0.15);
        }
        
        /* Formatting for tab titles for more emphasis */
        .tab-title {
          font-family: 'Montserrat', sans-serif;
          font-weight: 700;
          font-size: 26px;
          margin-top: 10px;
          margin-bottom: 20px;
          padding-bottom: 8px;
          border-bottom: 3px solid #28a745;
          color: #1b5e20;
        }
        
        /* Style Reset and Check All buttons */
        #reset_btn, #select_all, #solve_btn {
          padding: 8px 15px;           /* Space between button's border and text; will adjust height of the buttons */
          font-size: 14px;             /* Slightly larger text */
          border-radius: 6px;          /* Rounded corners */
          margin-top: 5px;             /* Spacing from checkbox list */
          margin-right: 10px;          /* Space between buttons */
          font-weight: bold;
          color: white !important;     /* Text color white; */
          /* !important Overrides RShiny default (like telling the browser to ignore other designs, I want this style) */ 
          transition: all 0.2s ease;            /* Smooth hover effect */
        }
        
        /* Hover effects */
        #reset_btn:hover {
          background-color: #c82333 !important; /* Darker red */
          color: white !important;
        }
        
        #select_all:hover {
          background-color: #218838 !important; /* Darker green */
          color: white !important;
        }
        
        #solve_btn:hover {
          background-color: #007bff !important; /* Vibrant Shade of blue */
          color: white !important;
        }
        
        /* Will prevent table overflowing in Computation; gradient background */ 
        .panel-body {
          background: #f0fdf4; /* soft green tint */
          border-radius: 8px;
          box-shadow: 2px 2px 6px #ccc;
          overflow-x: auto;
        }
        
        /* For Computation tab design */
        .panel-default > .panel-heading {
          background-color: #00a65a !important;
          color: white !important;
          font-weight: bold;
          border-color: #00a65a !important;
        }
        
        .panel-default {
          border-color: #00a65a !important;
          box-shadow: none;
        }
        
        .panel-title a:hover {
          text-decoration: underline;
          color: #d2f5e3 !important;
        }
        
        /* Box headers */
        .box-header.with-border {
          background-color: #28a745 !important; /* soft green */
          color: white !important;
          font-weight: bold;
        }
        
        /* Box bodies */
        .box {
          background-color: #f9f9f9 !important; /* light gray */
          border-radius: 6px;
          box-shadow: 1px 1px 5px #d0d0d0;
          margin-bottom: 20px;
        }
      
        /* Table styling */
        table {
          width: auto !important;
          max-width: none !important;
          border-collapse: collapse;
        }
        
        table tr:nth-child(even) {
          background-color: #f2f2f2;
        }
        
        table tr:hover {
          background-color: #d1f2d1;
        }
        
        th {
          background-color: #e9f5ec; /* light green */
          font-weight: bold;
          padding: 6px 10px;
        }
        td {
          padding: 6px 10px;
          border-bottom: 1px solid #ddd;
        }
        
        /* App Guide Formatting */
        .guide-card {
          background: #ffffff;
          border-radius: 10px;
          padding: 25px 30px;
          margin-bottom: 30px;
          box-shadow: 0 4px 10px rgba(0,0,0,0.08);
        }
        
        .guide-card h4 {
          margin-top: 0;
          font-weight: 700;
          color: #1b5e20;
        }
        
        .guide-img {
          display: block;
          margin: 18px auto 25px auto;
          border-radius: 8px;
          box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        
        .guide-spacer {
          margin-top: 30px;
        }
        
        /* Section label bubbles */
        .guide-section-label {
          background: #e8f5e9;
          color: #2e7d32;
          padding: 6px 14px;
          border-radius: 20px;
          display: inline-block;
          font-weight: 600;
          font-size: 16px;
          margin-bottom: 10px;
        }
      "))
    ),
    
    tabItems(
      
      # Dashboard tab
      tabItem(tabName = "dashboard",
        div(style = "max-width: 1200px; margin: auto; padding-left: 20px; padding-right: 20px;",
            h2(class = "tab-title", "Welcome to the Greenvale Pollution Reduction Planner"),
            p("This dashboard helps you select and optimize pollution reduction projects for Greenvale."),
            
            # Add info boxes summarizing counts / instructions (optional)
            fluidRow(
              column(4,
                     div(class="dashboard-card",
                         icon("list", style="font-size:40px;color:#28a745;"),
                         h4("Step 1: Choose Projects"),
                         p("Select the projects you want to implement.")
                     )
              ),
              column(4,
                     div(class="dashboard-card",
                         icon("cogs", style="font-size:40px;color:#007bff;"),
                         h4("Step 2: Solve"),
                         p("Run the optimization to determine the Solution and Cost Breakdown of Projects selected.")
                     )
              ),
              column(4,
                     div(class="dashboard-card",
                         icon("table", style="font-size:40px;color:#ffc107;"),
                         h4("Step 3: Review Results"),
                         p("Check the computed allocations and costs in the Final Solution tab.")
                     )
              )
            ),
            
            br(),
            p("Use the sidebar to navigate through the app. If you are a new user, it is recommended to first open the App Guide for instructions on how to use the application.")
        )
      ),
      
      # Choose Projects tab
      tabItem(tabName = "choose",
        div(style = "max-width: 1200px; margin: auto; padding-left: 20px; padding-right: 20px;", # "div" groups UI elements together as one object
            h2(class = "tab-title", "Select Projects to Implement"),
            # box() para gumawa ng card-style container.
            # Parang card sya where both left and right sections are grouped together
            box(
              width = NULL,  # makes the box auto-size
              title = "Project Selection",  # Title ng card
              status = "success",  # Green color ("success" ay green theme)
              solidHeader = TRUE,  # Para solid yung header color
              
              # TWO-COLUMN LAYOUT SA LOOB NG BOX
              fluidRow(
                
                # LEFT COLUMN (Selection controls)
                column(
                  width = 5,  # Mas maliit ng konti yung left side
                  
                  # Checkbox list ng projects
                  # Nilipat ko lang sa left column (same content, same comments)
                  checkboxGroupInput(
                    inputId = "proj_select",
                    label = "Available Projects:",
                    choices = setNames(projects$ProjectID, projects$ProjectName)
                  ),
                  
                  # Reset button para alisin lahat ng nakacheck
                  div(style = "width: 48%; display: inline-block; margin-right: 2%;",
                      actionButton("reset_btn", label = tagList(icon("undo"), "Reset"), class = "btn-danger", style = "width:100%;")
                  ),
                  # display         # icon              # button color
                  # Check all option para hindi isa-isahin
                  div(style = "width: 48%; display: inline-block;",
                      actionButton("select_all", label = tagList(icon("check"), "All"), class = "btn-success", style = "width:100%;")
                  ),
                  
                  # Solve button para sa pagsolve using Simplex Minimization
                  div(style = "margin-top: 10px;",
                      actionButton("solve_btn", label = tagList(icon("cogs"), "Solve"), class = "btn-primary", style = "width:100%;")
                  )
                ),
                
                
                # RIGHT COLUMN (Selected data outputs)
                column(
                  width = 7,  # Mas malaki yung right para sa table
                  
                  # Display ng Project IDs na sinelect
                  h4("Selected Project IDs"),
                  div(style = "padding: 6px 10px; background-color: #f9f9f9; border-radius: 6px; border: 1px solid #d0d0d0; font-family: 'Roboto', sans-serif;",
                      verbatimTextOutput("selected_ids")
                  ),
                  
                  # Display ng table ng selected projects
                  h4("Selected Projects (with cost)"),
                  tableOutput("selected_table")
                )
              ) # end ng fluidRow (2 column layout inside the box)
            ) # end ng box
        ) # end of div
      ), # tabItem end
      
      # Solution tab (Simplex iterations)
      tabItem(tabName = "computation",
        div(style = "max-width: 1200px; margin: auto; padding-left: 20px; padding-right: 20px;",
          h2(class = "tab-title", "Computations"),
  
          # Initial Tableau Toggle
          tags$div(
            class = "panel panel-default",
            tags$div(
              class = "panel-heading",
              tags$h4(
                class = "panel-title",
                tags$a(
                  href = "#initialTableauPanel",
                  `data-toggle` = "collapse",
                  "Show Initial Tableau"
                )
              )
            ),
            tags$div(
              id = "initialTableauPanel",
              class = "panel-collapse collapse",
              tags$div(
                class = "panel-body",
                tableOutput("initial_tableau")
              )
            )
          ),
          
          uiOutput("iteration_panels") # dynamic iteration boxes
        )
      ),
      
      # Final solution tab
      tabItem(tabName = "final",
        div(style = "max-width: 1200px; margin: auto; padding-left: 20px; padding-right: 20px;",
            h2(class = "tab-title", "Final Solution"),
            
            # Optimized Cost
            box(
              width = NULL,
              title = "Optimized Cost",
              status = "success",
              solidHeader = TRUE,
              h4(textOutput("optimal_cost_text"))
            ),
            
            # Cost breakdown by project
            box(
              width = NULL,
              title = "Project Allocation and Costs",
              status = "success",
              solidHeader = TRUE,
              tableOutput("final_table")
            )
        )
      ),
      
      # User manual tab
      tabItem(tabName = "guide",
        div(style = "max-width: 1200px; margin: auto; padding-left: 20px; padding-right: 20px;",
          h2(class = "tab-title", "User Guide"),
          
          # For Dashboard tab guide
          div(class = "guide-card",
              div(class = "guide-section-label", "1. Dashboard"),
              
              p("The Dashboard serves as your starting point in the Greenvale Pollution Reduction Planner. 
              It provides a clear overview of the three main steps you will follow to use the app efficiently."),
              
              tags$img(
                src = "dashboard_steps.png", # Dashboard direction picture
                width = "80%", class = "guide-img"
              ),
              
              p("Each card represents an essential phase of the process:"),
              tags$ul(
                tags$li(tags$b("Step 1 – Choose Projects:"), " Select pollution-reduction projects you want to evaluate."),
                tags$li(tags$b("Step 2 – Solve:"), " Run the optimization to compute allocations and cost-efficient solutions."),
                tags$li(tags$b("Step 3 – Review Results:"), " View the computed final allocation and project-specific costs.")
              ),
              p("Use the sidebar on the left to navigate through each step.")
          ),
          
          # For Choose Projects tab guide
          div(class = "guide-card",
              div(class = "guide-section-label", "2. Choose Projects"),
              
              p("Select one or more projects from the list. Use '✓ All' to select all or 'Reset' to clear selections. Once ready, click 'Solve' to start optimization."),
              
              tags$img(
                src = "select_projects.png", # Choose Projects section picture
                width = "100%", class = "guide-img"
              ),
              
              tags$img(
                src = "select_projects_btn.png", # Choose Project Buttons picture
                width = "60%", class = "guide-img"
              )
          ),
          
          # For Computation tab guide
          div(class = "guide-card",
              div(class = "guide-section-label", "3. Computation"),
              
              p("This tab displays the step-by-step Simplex iterations. You can expand each iteration to see the updated tableau and basic solution after each iteration."),
              
              # Unexpanded example
              h4("• Unexpanded Example"),
              tags$img(
                src = "unexpanded_computation.png", # Unexpanded Computation pivture
                width = "100%", class = "guide-img"
              ),
              
              # Expanded example
              h4("• Expanded Example"),
              tags$img(
                src = "expanded_computation.png", # Expanded Computation picture
                width = "100%", class = "guide-img"
              )
          ),
          
          # For Final Solution tab guide
          div(class = "guide-card",
              div(class = "guide-section-label", "4. Final Solution"),
              
              p("This tab shows the final optimal allocation of project units and the total cost. Only projects contributing to the solution are displayed."),
              
              # Feasible final solution example
              h4("• Feasible Final Solution"),
              tags$img(
                src = "feasible_solution.png", # Feasible Solution picture
                width = "100%", class = "guide-img"
              ),
              
              # Infeasible Final solution Exmaple
              h4("• Infeasible Final Solution"),
              tags$img(
                src = "infeasible_solution.png", # Infeasible Solution picyure
                width = "100%", class = "guide-img"
              )
          ),
          
          # --- Section 5: Tips ---
          div(class = "guide-card",
              div(class = "guide-section-label", "Tips & Notes"),
              tags$ul(
                tags$li("Ensure at least one project is selected before clicking 'Solve'."),
                tags$li("If the solution is infeasible, check project selections or target reductions."),
                tags$li("Hover over buttons to see visual cues: green for select all, red for reset, blue for solving.")
              ),
              p("For more information about each pollutant and project, refer to the input CSV files in the project directory (folder).")
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  
  # reactiveVal to know if state is all checked or all are unchecked
  select_all_state <- reactiveVal(FALSE)
  
  # Reset button clear all selected checkboxes
  observeEvent(input$reset_btn, {
    updateCheckboxGroupInput(session, "proj_select", selected = character(0))
    updateActionButton(session, "select_all", label = "All")
    select_all_state(FALSE) # Set the state to False (all are unselected) even if user clic
  })
  
  # Check all using the button
  # Toggle style para bawat click mag-aalternate sya (check all / clear all)
  observeEvent(input$select_all, {
    # Tuwing iclick yung button, i-flip yung state
    new_state <- !select_all_state() # Change the state
    select_all_state(new_state) # Update the state of the buttons outside this event listener
    
    if (new_state) {
      # Kapag ON state, meaning gusto ni user i-check lahat
      updateCheckboxGroupInput(session, "proj_select", selected = as.character(projects$ProjectID))
      updateActionButton(session, "select_all", label = "Uncheck")  # Palitan ko label para malinaw
    } else {
      # Kapag OFF naman, alisin lahat ng selection
      updateCheckboxGroupInput(session, "proj_select", selected = character(0))
      updateActionButton(session, "select_all", label = "All")
    }
  })
  
  # Text output ng selected project IDs
  output$selected_ids <- renderPrint({
    if (length(input$proj_select) == 0) {
      cat("None selected")  # Wala pang pinipili
    } else {
      cat(as.integer(input$proj_select))  # Convert to integer para malinis tingnan
    }
  })
  
  # Table output ng selected projects
  output$selected_table <- renderTable({
    req(input$proj_select)  # Para hindi mag-error pag walang selection
    
    selected_ids <- as.integer(input$proj_select)
    
    # Filter yung projects na kasama sa selection
    selected_projects <- subset(projects, ProjectID %in% selected_ids)
    
    # Columns na lalabas sa table
    selected_projects[, c("ProjectID","ProjectName","Cost")]
    
  }, rownames = FALSE)
  
  # This will hold the result of the simplex minimization which will be used for displaying
  simplex_result <- eventReactive(input$solve_btn, { # Error handling (input validation)
    if (is.null(input$proj_select) || length(input$proj_select) == 0) {
      return(NULL)
    }
    
    # Filter chosen projects of user (base sa checklist)
    selected_ids <- as.integer(input$proj_select)
    sel <- subset(projects, ProjectID %in% selected_ids)
    if (nrow(sel) == 0) { # Error handling (input validation)
      showNotification("No valid projects selected.", type = "error")
      return(NULL)
    }
    
    # Extract pollutant coefficients (from targets csv file)
    pollutants_name <- targets$Pollutants # Get Pollutant names
    target_vec <- targets$TargetMin # Get target minimum for all pollutants
    
    # Get values of all pollutants that each selected project reduces
    proj_pol_reduce <- as.matrix(sel[, pollutants_name]) # n x 10
    costs <- sel$Cost # Get cost of each selected projects
    max_units <- sel$maxUnit # Get max unit of each selected projects
    
    # For column names y_CO2 to y_N2O, x1 to xn, y1 to yn, Z, Solution (where n = number of inputs)
    pollutant_vars <- c()
    for (i in 1:length(pollutants_name)) {
      pollutant_vars <- c(pollutant_vars, paste0("S", i))
    }
    maxUnit_vars <- paste0("x", sel$ProjectID) # for column name ng maxUnit constraint
    slack_vars <- paste0("y", sel$ProjectID) # for column name ng slack variables
    col_names <- c(pollutant_vars, maxUnit_vars, slack_vars, "Z", "Solution") # creates a vector of names for all columns
    
    n <- nrow(proj_pol_reduce) # for generating the values of x (maxUnit) and y (slacks)
    tableau_rows <- list() # initialize an empty list for each row that will be generated
    
    for (i in 1:n) {
      # Get values of all pollutants that the current project (i) reduces
      pollutant_vals <- proj_pol_reduce[i, ]
      
      # w (maxUnit) column -1 in position i, 0 the rest
      w_col <- rep(0, n)
      w_col[i] <- -1
      
      # s (Slacks) column +1 in position i, 0 the rest
      s_col <- rep(0, n)
      s_col[i] <- 1
      
      # Z and Solution (Cost)
      z_val <- 0
      solution <- costs[i]
      
      # Combine full row
      row <- c(pollutant_vals, w_col, s_col, z_val, solution)
      tableau_rows[[i]] <- row # Add it to the list
    }
    
    # Create the objective function row (bottom of the tableau)
    obj_pols <- -target_vec # convert the target vectors to negative
    obj_x <- max_units # for maxUnits
    obj_y <- rep(0, n) # initialize slacks to 0
    obj_row <- c(obj_pols, obj_x, obj_y, 1, 0) # generate the objective row
    
    # Combine all rows using rbind
    tableau_matrix <- do.call(rbind, tableau_rows) # do.call calls the "rbind" function and does it to the next arguement (tableau_rows)
    tableau_matrix <- rbind(tableau_matrix, obj_row) # bind the objective row
    
    colnames(tableau_matrix) <- col_names # name each column
    
    SimplexMin(tableau_matrix) # after setting up the initial tableau, proceed to computation (Simplex Minimization)
  })
  
  # When user clicks the solve button
  observeEvent(input$solve_btn, {
    if (is.null(input$proj_select) || length(input$proj_select) == 0) { # Error handling (input validation)
      showNotification("Please select at least one project before solving.", type = "error")
      return(NULL)
    }
    
    result <- simplex_result()
    iterations <- result$allIterations
    
    if (!is.null(result$feasible) && !result$feasible) {
      showNotification("Solution is INFEASIBLE: target reduction not met/exceeded.", type = "error")
    } else {
      showNotification("Solution is FEASIBLE: Check the Computation tab for iterations and Final Solution tab for the final answer.", type = "message")
    }
    
    # Initial Tableau panel
    output$initial_tableau <- renderTable({
      # Show first iteration's tableau if initialTableau not explicitly stored
      first_iteration <- iterations[[1]]
      as.data.frame(first_iteration$tableau %||% first_iteration$normalized %||% first_iteration$updated)
    }, rownames = FALSE)
    
    # Generate dynamic collapsible panels for each iteration
    output$iteration_panels <- renderUI({
      
      # Create a list of collapsible panels, one for each iteration
      panels <- lapply(seq_along(iterations), function(i) {
        
        current_iteration <- iterations[[i]] # get data for this iteration
        panel_id <- paste0("iter", i) # unique ID for collapse panel
        table_id <- paste0("table_", i) # unique id for tableau table output
        basic_id <- paste0("basic_", i) # unique id for basic solution table output
        
        # Build HTML panel structure using bootstrap classes
        tags$div(
          class = "panel panel-default", # panel container
          tags$div(
            class = "panel-heading", # panel header section
            tags$h4(
              class = "panel-title", # panel title styling
              tags$a(
                href = paste0("#", panel_id), # link to collapse panel
                `data-toggle` = "collapse", # enable bootstrap collapse behavior
                paste("Show Iteration", i) # display iteration number
              )
            )
          ),
          tags$div(
            id = panel_id, # panel body id
            class = "panel-collapse collapse", # collapse by default
            tags$div(
              class = "panel-body", # panel body container
              h4("Tableau After Iteration"), # heading for tableau
              tableOutput(table_id), # Shiny output placeholder for tableau
              h4("Basic Solution"),  # heading for basic solution
              tableOutput(basic_id) # Shiny output placeholder for basic solution
            )
          )
        )
      })
      
      tagList(panels) # wrap all panels as a single tagList for renderUI
    })
    
    # Render tables for each iteration
    lapply(seq_along(iterations), function(i) {
      local({ # local ensures each iteration variable 'k' is captured correctly
        k <- i
        step <- iterations[[k]] # current iteration's data
        
        # Render tableau for this iteration
        output[[paste0("table_", k)]] <- renderTable({
          # Use updated tableau if available, else normalized, else original
          tbl <- step$updated %||% step$normalized %||% step$tableau
          as.data.frame(tbl) # convert matrix to data frame for display
        }, rownames = FALSE)
        
        # Render basic solution table for this iteration
        output[[paste0("basic_", k)]] <- renderTable({
          bs <- step$basicSolution # get basic solution vector
          if (is.null(bs)) { # skip if no solution
            return(NULL)
          }
          
          vars <- colnames(step$updated) # get variable names
          L <- min(length(bs), length(vars)) # match length to avoid mismatch
          
          # single-row data frame, round values for display
          df <- as.data.frame(t(round(bs[1:L], 6)))
          colnames(df) <- vars[1:L] # assign variable names as column headers
          df 
        }, rownames = FALSE)
      })
    })
  })
  
  # To display optimal cost (total cost of the projects)
  output$optimal_cost_text <- renderText({
    result <- simplex_result() # This contains the final tableau, basic solution, feasibility flag, etc.
    req(result) # ensures that result is not NULL before continuing
    
    # If the simplex concluded that no feasible solution exists
    if (!result$feasible) {
      return("INFEASIBLE SOLUTION")
    }
      
    # The optimized cost is the RIGHTMOST value of basicSolution
    total_cost <- result$basicSolution[length(result$basicSolution)]
    
    paste0("The cost of this optimal mitigation project is $", round(total_cost, 2))
  })
  
  # final solution table
  output$final_table <- renderTable({
    result <- simplex_result() # This contains the final tableau, basic solution, feasibility flag, etc.
    req(result) # ensures that result is not NULL before continuing
    
    # If the simplex concluded that no feasible solution exists
    if (!result$feasible) {
      return(data.frame(Message = "INFEASIBLE. No final result available."))
    }
    
    basic_solution <- as.numeric(result$basicSolution) # Extract the basic solution vector from the final simplex tableau
    variable_names <- colnames(result$finalTableau)     # Get the names of the variables in the final tableau columns
    
    selected_ids <- as.integer(input$proj_select) # Convert the user-selected project IDs (character) into numeric values
    selected_projects <- subset(projects, ProjectID %in% selected_ids)     # Filter the 'projects' dataset para selected rows lang makukuha
    
    y_names <- paste0("y", selected_projects$ProjectID) # Build the names of the slack variables connected to each project
    
    # Create a numeric vector that will hold the y-values in the same order as y_names
    y_values <- numeric(length(y_names))
    
    # Loop through all y-variable names and find their values from the basic solution by matching column names in the final tableau
    for (i in seq_along(y_names)) {
      y_name <- y_names[i]   # Get current y-variable name
      
      # Find the column index of this y-variable in the final tableau
      index <- which(variable_names == y_name)
      
      # If the y-variable is not found, assign zero
      if (length(index) == 0) {
        y_values[i] <- 0
      } else { # if y-variable is found, pick its value from the basic solution
        y_values[i] <- basic_solution[index]
      }
    }
    
    # Identify which y-values are non-zero and filter them out
    tolerance <- 1e-9
    nonzero_indices <- which(abs(y_values) > tolerance)
    
    # If no y-variables are non-zero, the solution essentially uses zero units of all selected projects (simply return a message)
    if (length(nonzero_indices) == 0) {
      return(data.frame(Message = "All y variables are zero."))
    }
    
    # Keep only the projects whose y-value is non-zero
    final_projects <- selected_projects[nonzero_indices, ]
    final_y_values <- y_values[nonzero_indices]

    # Compute for the Cost of each project    
    # Prepare a numeric vector for the computed individual project costs
    project_costs <- numeric(length(final_y_values))
    
    # Multiply each final y-value by its corresponding project cost
    for (i in seq_along(final_y_values)) {
      project_costs[i] <- final_y_values[i] * final_projects$Cost[i]
    }
    
    # Build and return the final output table
    output_table <- data.frame(
      "Mitigation Project" = final_projects$ProjectName,
      "Number of Project Units" = final_y_values,
      "Cost ($)" = project_costs,
      check.names = FALSE # Prevent R from altering column names
    )
    
    # Return the finished table (para madisplay ng RShiny)
    return(output_table)
    
  }, rownames = FALSE)
}

# Start ng Shiny app
shinyApp(ui, server)