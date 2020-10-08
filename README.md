# ncf_r_example
How to set up R and R Studio on NCF

1. Log into ncf using your favorite terminal empulator.
2. Start an `srun` job so you can run R
  ```
  srun -p ncf -c 1 --mem 16G --time 4:00:00 --pty /bin/bash
  ```
3. Make a new directory to keep your R pacakages (the name will make sense in a second).
  ```
  cd ~
  mkdir R_3.5.1_GCC
  ```
4. Load the modules you want.
  - The latest version of R that NCF's R Studio uses is 3.5.1.
  - We also want to use the GCC compiler
  ```
  module load gcc/7.1.0-fasrc01 R/3.5.1-fasrc01
  ```
5. Export the path to your user package directory while keeping the path to all the packages arleady installed on NCF.
  ```
  export R_LIBS_USER=~/R_3.5.1_GCC:$R_LIBS_USER
  ```
6. Check to make sure it worked as expected.
  ```
  echo $R_LIBS_USER
  ```
  - You should see something like
    ```
    /users/jflournoy/R_3.5.1_GCC:/n/helmod/apps/centos7/Core/R_packages/3.5.1-fasrc01
    ```
7. Run R:
  ```
  R
  ```
8. Install `lavaan`
  ```
  devtools::install_github('yrosseel/lavaan')
  ```
