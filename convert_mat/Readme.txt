# README#

* Author: Hancheng Yu,Haibao Qin, January 2018
.

Table of Contents

~~~~~~~~~~~~~~~~~


1. Introduction

2. Requirements
3. Usage of MEX Wrappers and Description of Files

4. Implementation steps 
5. Other notes


1. Introduction

~~~~~~~~~~~~~~~
This code repository aims at real-time texture-less object instance detection. 
This is an implementation of the method described in the paper:
"A Fast Approach to Texture-less Object Detection Based on Orientation Compressed Map and Discriminative Region Weight".
Authors: Haibao Qin,Hancheng Yu and Maoting Peng


2. Requirements
~~~~~~~~~~~~~~~
This is a C++ implementation, with an optional Matlab MEX wrapper.
OS Platform: Windows,Matlab 2014.Both 32 bit and 64 bit versions are available.

Note : If you want to run this program,you can refer to the implementation steps in the fourth part.
 
3. Usage of MEX Wrapper and Description of Files
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
First the MEX files have been compiled at the Matlab.

(1)  [CMI,CMI_POPCNT,Edge] = S1_CMI(Test_image,C_radius);

Inputs: Test_image                     Greyscale image of type uint8.
        C_radius                       Compression radius.

Outputs: CMI                           CMI (the binarized orientation compressed map of input image I).
         CMI_POPCNT                    The number of quantized gradient orientations in each location of the CMI.
         Edge                          The edge map of the input image.

(2)  S1_Match(CMI,CMT_Temp,CMI_POPCNT,CMT_Temp_C,S1_Scale,S1_Rotation,S1_Similarity);

Inputs: CMI                            The CMI.
        CMT_Temp                       The CMT (the binarized orientation compressed map of template T).
        CMI_POPCNT                     The number of quantized gradient orientations in each location of the CMI.
        CMT_Temp_C                     The number of quantized gradient orientations in each location of the CMT.
        S1_Scale,S1_Rotation           Scales and Rotations. 
        S1_Similarity                  The similarity scores for each location of the CMI.

(3)  Object_candidate_loction(Test_image,S1_Similarity,S1_Scale,S1_Rotation,S1_Para);

Inputs: Test_image                     Greyscale image of type uint8.
        S1_Similarity                  The similarity scores for each location of the CMI. 
        S1_Scale,S1_Rotation           Scales and Rotations. 
        S1_Para                        Threshold and other parameters.

(4)  DRW_Im = S2_DRW(Test_image);
     
Inputs: Test_image                     Greyscale image of type uint8.

Outputs: DRW_Im                        The quantized gradient orientations map of the input image.

(5)  S2_Match(DRW_Im,DRW_Temp,Mask_Crop,DRW_Temp_W,S2_Scale,S2_Rotation,S2_Similarity,S2_Para);

Inputs: DRW_Im                         The quantized gradient orientations map of the input image.
        DRW_Temp                       The spreading orientation  map of the template T.
        Mask_Crop                      A Mask.
        DRW_Temp_W                     A Discriminative Region Weight.              
        S2_Scale,S2_Rotation           Scales and Rotations. 
        S2_Similarity                  The similarity scores for each location of the input image.
        S2_Para                        Other parameters.

(6)  Draw_object_location(S3,S2_Similarity,S2_Scale,S2_Rotation,S3_Para); 
 Be similar to (3).

4. Implementation steps 
~~~~~~~~~~~~~~~~~~~~~~~
If you execute the project for the first time.Please refer to the following steps.

Firstly, in order to speed up computation,you will run this file ( mat_convert.m ),
converting another form of .mat file and generating four .mat format files in the directory of convert_mat.
If successful, 4 files will be generated in the directory of convert_mat. You can skip this step later.
In the following, you can execute test.m.
Finally,the detection results are achieved.

5. Other notes
~~~~~~~~~~~~~~
In the directory of offline_mat.

A matrix in CMT.mat represents a CMT. 
A matrix in CMT_POPCNT.mat is the number of quantized gradient orientations in each location of the CMT.
A matrix in DRW_Template.mat represents the spreading orientation map of the template.
A matrix in DRW_Template_Weight.mat represents the discriminative region weight of the template.

 


