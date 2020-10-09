#!/bin/bash
#SBATCH -J sims_example
#SBATCH --mem 16G
#SBATCH -p ncf
#SBATCH --cpus-per-task 1
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --time 1-00:00
#SBATCH -o %x_%A.out
#SBATCH --mail-type=ALL

module load gcc/7.1.0-fasrc01
module load R/3.5.1-fasrc01

export R_LIBS_USER=/ncf/mclaughlin/users/jflournoy/R_3.5.1_GCC:$R_LIBS_USER

runme=run_simulations.R

srun -c $SLURM_CPUS_ON_NODE Rscript "${runme}"
