# Simplex Minimization Function
SimplexMin <- function(tableau, iter_list = list(), iteration = 1) {
                                # Initialize an empty list and iteration counter (since only "tableau" is passed in the first call in app.R)
                                # If the recursive call runs, iter_list will be updated and iteration counter will have a new value (iteration+1)
  
  tab_row <- nrow(tableau) # Will just serve as a guide for number of rows
  tab_col <- ncol(tableau) # Will just serve as a guide for number of columns
  
  # Save current tableau BEFORE iteration
  iter_list[[iteration]] <- list(
    iteration = iteration,
    tableau = tableau
  )
  
  # FIND THE PIVOT ELEMENT
  last_row <- tableau[tab_row, 1:(tab_col-1)] # Get the last row of the tableau except the Solution element in the last row
  pivot_col <- which.min(last_row) # get pivot column: getting the highest negative magnitude (excluding solution column)
  
  # Check if there exists at least one positive value in the pivol column
  # Get pivot column values excluding last row
  pivot_col_values <- tableau[1:(tab_row-1), pivot_col]
  
  # Keep only positive finite values (filter out 0, -0, NaN, Inf)
  positive_rows <- pivot_col_values[!(pivot_col_values <= 0) & is.finite(pivot_col_values)]
  
  # If there are no positive values, return current state
  if (length(positive_rows) == 0) {
    # Remove the last failed iteration from iter_list
    iter_list[[iteration]] <- NULL  # don't save this iteration
    
    final_answer <- list(
      allIterations = iter_list, # only show iterations that worked
      finalTableau = NULL, # indicate no final tableau
      basicSolution = NULL, # no feasible solution
      feasible = FALSE # For telling user that solution is infeasible
    )
    return(final_answer)
  }
  
  test_ratio <- c()
  for (i in 1:(tab_row-1)) {
    test_ratio <- c(test_ratio, tableau[i, tab_col]/tableau[i, pivot_col])
  }
  
  positive_values <- test_ratio[!(test_ratio <= 0) & is.finite(test_ratio)] # only get the positive values
  
  pivot_value <- min(positive_values) # Gets the minimum/lowest positive test ratio
  pivot_row <- which(test_ratio == pivot_value)[1]  # gets the minimum of positive values, then checks and
  # return its index on the test ratio (including negatives). NOTE: If there exists a tie, pick the first (top-most) row
  pivot_element <- tableau[pivot_row, pivot_col] # get the pivot element
  
  # NORMALIZE THE PIVOT ROW
  tableau[pivot_row,] <- tableau[pivot_row, ] / pivot_element
  
  # Save NORMALIZED tableau
  iter_list[[iteration]]$normalized <- tableau
  
  # ELIMINATION
  for (i in 1:tab_row) {
    if (i == pivot_row) { # Do not include the pivot row in the loop
      next
    }
    multiplied_row <- tableau[pivot_row,] * tableau[i, pivot_col]
    tableau[i, ] <- tableau[i, ] - multiplied_row
  }
  
  # Save updated tableau
  iter_list[[iteration]]$updated <- tableau
  
  # Save basic solution for this iteration
  basic_sol <- c()
  for (i in 1:(tab_col)) {
    if (i == (tab_col-1)) next
    basic_sol <- c(basic_sol, tableau[tab_row, i])
  }
  iter_list[[iteration]]$basicSolution <- basic_sol
  
  # Get the last row again after all iteration
  new_last_row <- tableau[tab_row, 1:(tab_col-1)] # exclude the value in the Solution column
  
  # VERIFY IF THERE STILL EXISTS A NEGATIVE VALUE
  if (any(new_last_row < 0)) { # returns True if there is at least 1 element in the tableau
    # that is less than 0 (doesn't check the solution column)
    return (SimplexMin(tableau, iter_list, iteration+1)) # If true, run the function again
  } else {
    basic_sol <- c() # For the basic solution table
    for (i in 1:(tab_col)) {
      if (i == (tab_col-1)) { # If the iteration is in the Z column, skip it
        next
      }
      basic_sol <- c(basic_sol, tableau[tab_row, i])
    }
    final_answer <- list( # final answer will be stored as a list
      allIterations = iter_list,
      finalTableau = tableau,
      basicSolution = basic_sol,
      feasible = TRUE # For telling user that solution is feasible
    )
    return(final_answer)
  }
}