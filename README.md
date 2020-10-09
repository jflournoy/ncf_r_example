Here are some [introductory slides](https://docs.google.com/presentation/d/1u9QSS6pNZYpxPMIqVZbyqU2lxGA2OK4QX7bDIpE32Yw/edit?usp=sharing).

# Getting R and R Studio set up on NCF

1. Log into NCF using your favorite terminal emulator.
2. Clone this repository to your home directory
    ```
    cd ~
    git clone https://github.com/jflournoy/ncf_r_example.git
    ```
3. Start an `srun` job so you can run R
    ```
    srun -p ncf -c 1 --mem 16G --time 4:00:00 --pty /bin/bash
    ```
    You should see something like:
    ```
    srun: job 4348303 queued and waiting for resources
    srun: job 4348303 has been allocated resources
    ```
4. Make a new directory to keep your R pacakages (the name will make sense in a second).
    ```
    cd ~
    mkdir R_3.5.1_GCC
    ```
5. Load the modules you want.
  - The latest version of R that NCF's R Studio uses is 3.5.1.
  - We also want to use the GCC compiler
    ```
    module load gcc/7.1.0-fasrc01 R/3.5.1-fasrc01
    ```
6. Export the path to your user package directory while keeping the path to all the packages arleady installed on NCF.
    ```
    export R_LIBS_USER=~/R_3.5.1_GCC:$R_LIBS_USER
    ```
7. Check to make sure it worked as expected.
    ```
    echo $R_LIBS_USER
    ```
    You should see something like
    ```
    /users/jflournoy/R_3.5.1_GCC:/n/helmod/apps/centos7/Core/R_packages/3.5.1-fasrc01
    ```
8. Run R:
    ```
    R
    ```
9. Install `lavaan`
    ```
    devtools::install_github('yrosseel/lavaan')
    ```
  
I use `devtools` here to install the most recent development version of `lavaan` directly from the github repository. You could just as easily use `install.packages`. You may have noticed that during the install some parts of the package were compiled using gcc:
```
gcc -I/n/helmod/apps/centos7/Core/curl/7.45.0-fasrc01/include -I/n/helmod/apps/centos7/Core/bzip2/1.0.6-fasrc01/include -I -I/n/helmod/apps/centos7/Core/pcre/8.37-fasrc02/include -I/n/helmod/apps/centos7/Core/readline/6.3-fasrc02/include -L/n/helmod/apps/centos7/Core/bzip2/1.0.6-fasrc01/lib -L/n/helmod/apps/centos7/Core/pcre/8.37-fasrc02/lib -L/n/helmod/apps/centos7/Core/curl/7.45.0-fasrc01/lib -L/n/helmod/apps/centos7/Core/readline/6.3-fasrc02/lib64 -std=gnu99 -I"/n/helmod/apps/centos7/Core/R_core/3.5.1-fasrc01/lib64/R/include" -DNDEBUG   -I/usr/local/include   -fpic  -g -O2  -c mnormt_init.c -o mnormt_init.o
```
This is why it's important to specify the compiler too. Sometimes if you try to use a package that was compiled with a different version or type of compiler, it won't work.

After install `lavaan` you can quit R, and exit the `srun` job, which will look something like this:
```
> q()
Save workspace image? [y/n/c]: n
 jflournoy@holy7c22412:~
[7289]exit
exit
 jflournoy@ncflogin6:~
[7287]
```

Check out what's now in your personal package directory:
```
 jflournoy@ncflogin6:~
[7287]ls ~/R_3.5.1_GCC/
lavaan	mnormt	numDeriv  pbivnorm  tmvnsim
```

This is the package library we want to use for our R Studio instance, which I describe [here](README.r_studio.md).
