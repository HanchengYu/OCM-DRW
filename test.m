% This is the accompanying software of the paper "A Fast Approach to Texture-less Object Detection Based on Orientation Compressed Map and Discriminative Region Weight"(OCM-DRW)
% Authors:  Hancheng Yu, Haibao Qin and Maoting Peng
%%%% Note: If you execute the project for the first time, you will run this file ( mat_convert.m ) firstly.
%%%% In addition, you can refer to README.md about this project. . 

close all;
clear;
clc;

%&&% Load template trained (the CMT and the second template) 
load .\convert_mat\CMT_Convert 
load .\convert_mat\CMT_POPCNT_Convert
load .\convert_mat\DRW_Template_Convert 
load .\convert_mat\DRW_Template_Weight_Convert
load .\offline_mat\DRW_Mask

scales = single([0.9,0.85,0.8,0.75,0.7,0.65,0.6]);  
S1_T = [0.32,0.25,0.27,0.30,0.36,0.29,0.35,0.24,0.30];
S2_T = [0.60,0.65,0.65,0.65,0.75,0.65,0.65,0.60,0.58]; 
C_radius = single(6);   % Compression radius

% Read image
Num_model = 3;  %change indexing (1-9)
Num_test = 3;   % change indexing (1-11)
Modelfile_name = sprintf('image\\model\\model_0%d.png',Num_model-1);
Testfile_name = sprintf('image\\test\\test0%d.jpg',Num_test);
model_image  =  imread(Modelfile_name);
Test_image  =  imread(Testfile_name); 
[m,n,l] = size(model_image);
[m_s,n_s,l_s] = size(Test_image);
if ( l_s == 3 )
    Test_image = rgb2gray((Test_image));
end

%%%%%   The first stage  (S1_)   %%%%%%%%

tic;

% Achieve the CMI and the number of quantized gradient orientations in each location of CMI
[CMI,CMI_POPCNT,Edge] = S1_CMI(Test_image,C_radius);

S1_Similarity = single(zeros(size(CMI)));
S1_Scale = single(zeros(size(CMI)));
S1_Rotation = single(zeros(size(CMI)));

CMT_Temp(:,:) = CMT_CT(Num_model,:,:);
CMT_Temp_C(:,:) = CMT_POPCNT_CT(Num_model,:,:);

% The similarity measure for each position in the CMI by using 252 CMTs.
% Generate object candidate locations in the first stage.
S1_Match(CMI,CMT_Temp,CMI_POPCNT,CMT_Temp_C,S1_Scale,S1_Rotation,S1_Similarity);
S1_time = toc  

S1_Para(1) = max(max(S1_Similarity(:))*0.8,S1_T(Num_model));
S1_Para(2) = C_radius;
S1_Para(3) = single(n);
S1_Para(4) = single(m); 

% Extract object candidate locations
Object_candidate_loction(Test_image,S1_Similarity,S1_Scale,S1_Rotation,S1_Para);

%%%%%   The second stage  (S2_) %%%%%%%%

% Achieve scale and rotation of each object candidate locaton.
[Candidate_i,Candidate_j] = find(S1_Similarity > 0);
Candidate_num = size(Candidate_i);
for n1 = 1 : Candidate_num
    Candidate_s(n1) = S1_Scale( Candidate_i(n1),Candidate_j(n1));
    Candidate_r(n1) = S1_Rotation( Candidate_i(n1),Candidate_j(n1));
end

% Compute quantized orientation map of the test image
DRW_Im = S2_DRW(Test_image); 

% Compute the similarity score of each object candidate location 
% According to the rotation and scale of each candidate location, the left and right extensions are carried out based on the angle and scale.
S2_Similarity = single(zeros(size(DRW_Im)));
S2_Scale = single(zeros(size(DRW_Im)));
S2_Rotation = single(zeros(size(DRW_Im)));
for n_1 = 1 : Candidate_num(1)
    c = find(scales == Candidate_s(n_1));
    s_min = int32((max(1, c - 1))) ;
    s_max = int32(min(7, c + 1)) ;
    for s = s_min : s_max     
        S2_Para(1) = scales(s);
        r_min = Candidate_r(n_1)/10 - 1;
        r_max = Candidate_r(n_1)/10 + 1;
        for r = r_min : r_max
            if ( r < 0 ) 
                rr = r + 36;
            elseif ( r >= 36 ) 
                rr = r - 36;
            else
                rr = r;
            end

            rr_1 = rr + 1;
            S2_Para(2) = single(rr) * 10;    
            S2_Para(4) = single(int32(Candidate_i(n_1) * (2*C_radius+1)*0.5)); 
            S2_Para(3) = single(int32(Candidate_j(n_1) * (2*C_radius+1)*0.5));
            S2_Para(5) = single(11); % object candidate region. Take the object candidate location as the center, radius is 11.

            index = single(s-1)*single(36)+single(rr_1);
            Mask_Crop = DRW_Mask{Num_model}{s}{rr_1};
            DRW_Temp = DRW_Template_CT(Num_model,:,index);
            DRW_Temp_W = DRW_Template_Weight_CT(Num_model,:,index);
            S2_Match(DRW_Im,DRW_Temp,Mask_Crop,DRW_Temp_W,S2_Scale,S2_Rotation,S2_Similarity,S2_Para);
        end
    end 
end

S3_Para(1) = max(max(S2_Similarity(:)),S2_T(Num_model));
S3_Para(2) = 1.0;
S3_Para(3) = single(n) * 0.5;
S3_Para(4) = single(m) * 0.5; 
S3 = imresize(Test_image, 0.5);

% Extract object location and draw the location on the image
Draw_object_location(S3,S2_Similarity,S2_Scale,S2_Rotation,S3_Para);
S2_time = toc

% Display images
figure('NumberTitle', 'off', 'Name', 'Original Image'), imshow(uint8(Test_image));
figure('NumberTitle', 'off', 'Name', 'Model Image'), imshow(model_image);
figure('NumberTitle', 'off', 'Name', 'Detected object'), imshow(uint8(S3));











