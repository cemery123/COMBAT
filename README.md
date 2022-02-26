# SLBug-Hunter
## [SLBug-Hunter:New Simulink Test Tool](https://github.com/xzhxfz/SLBug-Hunter/new/master?readme=1)
Matlab env dependencies:
1. Matlab 2021b
2. Simulink
***
### Datatest:
If you wish to use publicly available datasets, you can access *[third-party datasets](https://drive.google.com/drive/folders/173ik08oi3BCnPzjlZkHYhMAkp93zW-V4?usp=sharing)*. If you wish to use a random model, 
you can visit *[Dr. Shafiul's homepage](https://github.com/verivital/slsf_randgen/wiki)*. Get the latest experimental model generation tools SLFORGE/CYFUZZ

##### [SLforge: Automatically Finding Bugs in a Commercial Cyber-Physical Systems Development Tool](https://github.com/verivital/slsf_randgen/wiki#getting-slforge)
**The format of the model is divided into mdl and slx according to the Simulink standard. If you use some third-party open source models, make sure that the dependencies 
between the models and the data are loaded into your memory. We do not recommend using third-party models in unfiltered conditions, which will cause your computer
to crash abnormally. Please be careful**
***
### Hello World
Before starting, you need to set two environment variables `SLSFCORPUS` and `COVEXPXPLORE`,both of which point to your `reproduce/samplecorpus` file. In subsequent operations, you need to put the test models into 
this folder so that Simulink can quickly and accurately find the files you need

If you have questions about setting environment variables, please visit the official *[Mathworks website](https://ww2.mathworks.cn/help/matlab/ref/setenv.html?lang=en)*
***
In order to test the stability of the program, you need to test and collect the coverage information of the model in advance. You need to run this at the Matlab command line：

```covexp.covcollect```

You can change the collected configuration parameters in the file `covcfg.m` and set the maximum compile time for the model
Due to problems with some models, this process may experience program termination. 
If you wish, you can choose in the file.Replace  `@emi.preprocess_models` with `@emi.check_SLforge` . Also replace the path in the file with the absolute path where you store the model file
This will help you filter your models

***
### Test Program
**Warning: You must collect coverage information before running the compiled test program.**
You can modify the parameters of the mutation in the `cfg.m` file, including the number of variants, the rate of variants, and the choice of variant space.
Once everything is in place, you can run in the Matlab command line:

```emi.go()```

A mutation procedure for variants is performed.

****
### Test Result
The experimental results will be placed in the +emi_result file, and the information including the variants will also be written separately into the `.mat` data table of each 
variant subfile. If you want to see the overall data, you can run from the Matlab command line:
```emi.repoert```

***
**Thanks to MathWorks consultants Zouyi Yang, Lily Yan and Finao Peng for their support.**
