i_iterations <- 10000
i_test_iterations <- 10

iters <- NULL
ncpus <- NULL
#Check if we're running as an sbatch job
if(Sys.getenv('SLURM_CPUS_ON_NODE') == '') { 
  #If we are not, the environment variable SLURM_CPUS_ON_NODE will be empty.
  iters <- i_test_iterations
  ncpus <- 1
} else {
  #If we are, the environment variable SLURM_CPUS_ON_NODE will be set to the
  #number of CPUs we've allocated to the job.
  iters <- i_iterations
  
  #Save the number of CPUs in case we want to use it later.
  ncpus <- as.numeric(Sys.getenv('SLURM_CPUS_ON_NODE'))
}

#It can be helpful to send yourself little messages like this along the way.
message('Running ', iters, ' iterations using ', ncpus, ' CPUs...')

#Load the package we want to use.
#If it doesn't exist, this will just exit with an error.
library(lavaan) 
