# LIP_Caltech_NDT

This project deals with binned data from the LIP Caltech project. The psth files are split into multiple files based on the number of neuron units. The resulting files are then converted into binned files suitable for NDT, which are then decoded using NDT.

The code requires NDT.                   


# Base path
LIP_Caltech_NDT_settings.m code contains information about the base path. This code is invented for the convenience of different users. 


# Converting a file to multiple 
LIP_Caltech_NDT__one_run_mat_into_individual_files.m code converts a single mat file (such as GU_20110126_1-01.psth.mat) into multiple mat-files based on the number of neuron units. 

input:                                                                                                                     
mat-files: such as GU_20110126_1-01.psth.mat                        

output:                                                                                          
mat-files: sach as GU_20110126_R01a1_1_binned_data_forNDT.mat                                                     
