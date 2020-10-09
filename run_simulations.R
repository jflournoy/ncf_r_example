i_iterations <- 1000
i_test_iterations <- 10

iters <- NULL
ncpus <- NULL
is_sbatch <- NULL
#Check if we're running as an sbatch job
if(Sys.getenv('SLURM_CPUS_ON_NODE') == '') { 
  #If we are not, the environment variable SLURM_CPUS_ON_NODE will be empty.
  iters <- i_test_iterations
  ncpus <- 1
  is_sbatch <- FALSE
} else {
  #If we are, the environment variable SLURM_CPUS_ON_NODE will be set to the
  #number of CPUs we've allocated to the job.
  iters <- i_iterations
  
  #Save the number of CPUs in case we want to use it later.
  ncpus <- as.numeric(Sys.getenv('SLURM_CPUS_ON_NODE'))
  is_sbatch <- TRUE
}

#It can be helpful to send yourself little messages like this along the way.
message('Running ', iters, ' iterations using ', ncpus, ' CPUs...')

#Load the package we want to use.
#If it doesn't exist, this will just exit with an error.
library(lavaan) 

#Run some example code if we're not running as a batch job.
if(!is_sbatch){
  #Create a fairly simple model to simulate data from. It's just a regression
  #where X causes Y, and the intercept for Y is 0. We set all parameters
  #explicitly. Check out the lavaan tutorial for more info:
  #https://lavaan.ugent.be/tutorial/index.html
  simple_regression_dgp <- '
y ~ 0.5*x    #y is regressed on x with a coefficient of .5
y ~ 50*1     #set the intercept of the regression to 50
y ~~ 0.75*y  #the residual variance is 1 - .5^2 = .75 (to be on the standardized scale)
x ~ 10*1     #set the mean of x to 10
x ~~ 1*x     #variance of x is 1
'
  
  #We need a model without the parameter constraints so we can fit it to the
  #simulated data.
  simple_regression <- '
y ~ x        #estimate the effect of x on y
y ~ 1        #estimate the intercept
y ~~ y       #estimate the residual
x ~ 1        #estimate the mean of x
x ~~ x       #estimate the variance of x
'
  
  #I'm going to test one iteration of this to show how it works
  sim_data <- lavaan::simulateData(model = simple_regression_dgp, 
                                   model.type = 'sem', 
                                   meanstructure = TRUE, 
                                   sample.nobs = 500, 
                                   empirical = TRUE) 
  #"empirical" should normally be false but we want to make sure everything is working
  #correctly.
  head(sim_data)
  sapply(sim_data, mean)
  sapply(sim_data, sd)
  
  sim_fit <- lavaan::sem(model = simple_regression, data = sim_data)
  summary(sim_fit, standardize = TRUE)
  
  #How would we extract the information about the parameter of interest here?
  #First, get the parameter estimates table
  par_est <- lavaan::parameterEstimates(object = sim_fit)
  #What kind of object is it?
  class(par_est)
  par_est
  #Let's get the index of rows that correspond to the regression
  yonx_rows <- par_est$lhs == 'y' & par_est$op == '~' & par_est$rhs == 'x'
  #Finally, extract just the stats we might want to examine across all sample sizes.
  par_est_yonx <- par_est[yonx_rows, c('est', 'z', 'pvalue')]
  
  #We also want to save out whether the model converged or not -- could be an
  #issue with smaller sample sizes.
  par_est_yonx$converged <- lavaan::lavInspect(sim_fit, what = 'converged')
  par_est_yonx
}
#Let's do the simulations now!

if(!is_sbatch){
  message('Okay, now we are really going to run the test iterations...')
}

#We actually want to look at power across a range of sample sizes, so we can
#create a vector of different sample sizes we'll loop over using `lapply`.

#We'll repeat each of these enough times to create a vector with length =
#`iters`
sample_sizes <- c(50, 100, 250, 500, 1000)
N <- rep_len(sample_sizes, length.out = iters)

#I'll use lapply so our output is a nice list, and I will time this so that we
#can get an idea of how long it will take when we do it 1,000 or 10,000 times.
timing <- system.time({
  sim_results_list <- lapply(N, function(n){
    #^^^ And yes, I am saving out a variable inside the call of another function.
    #Funky but true.
    
    sim_data <- lavaan::simulateData(model = simple_regression_dgp, 
                                     model.type = 'sem', 
                                     meanstructure = TRUE, 
                                     sample.nobs = n, 
                                     empirical = FALSE)
    #note, empirical is now set to false to get the sampling variability
    
    #The below is just coppied from our test code above (which you could get rid
    #of at some point).
    sim_fit <- lavaan::sem(model = simple_regression, data = sim_data)
    par_est <- lavaan::parameterEstimates(object = sim_fit)
    yonx_rows <- par_est$lhs == 'y' & par_est$op == '~' & par_est$rhs == 'x'
    par_est_yonx <- par_est[yonx_rows, c('est', 'z', 'pvalue')]
    par_est_yonx$converged <- lavaan::lavInspect(sim_fit, what = 'converged')
    
    #We'll also save the sample size. Not crucial at this point, but makes it
    #easier to combine the results.
    par_est_yonx$N <- n
    
    #return the resulting data frame, which will be collected by `lapply` into a
    #list.
    return(par_est_yonx)
  })
})

message('Finished simulations!')

time_for_1k_in_mins <- timing['elapsed']/10*1000/60
sprintf('It would take %.1f minutes for 1k iterations.', time_for_1k_in_mins)

#Now we can combine these into a data.frame and save them to a file we can
#access later.
sim_results_df <- do.call(rbind, sim_results_list)

#Make a file name that contains the number of iterations. Be careful here, as
#this will save in whatever your working directory is. When you run this as a
#batch, it will be whatever directory you run the sbatch command from. You can
#check interactively in R Studio by running `getwd()`. You can also just specify
#an absolute full path here if you want.
save_filename <- sprintf('simulation_results_%05d.rds', iters)

message('Saving results to ', file.path(getwd(), save_filename))
saveRDS(sim_results_df, save_filename)
