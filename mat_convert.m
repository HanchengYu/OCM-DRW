% This is the accompanying software of the paper "A Fast Approach to Texture-less Object Detection Based on Orientation Compressed Map and Discriminative Region Weight "(OCM-DRW)
% Authors:  Haibao Qin,Hancheng Yu and Maoting Peng

close all;
clear;
clc;

load .\offline_mat\CMT
load .\offline_mat\CMT_POPCNT
load .\offline_mat\DRW_Template
load .\offline_mat\DRW_Template_Weight

max_rr = 0;
max_T_rr = 0;
for k = 1 : 9
    Ind = 1;
    for s = 1 : 7
        C_Para(1) = single(s);
        for r = 1 : 36
            C_Para(2) = single(r*10);
            CMT_M = CMT{k}{s}{r};
            CMT_C_M = CMT_C{k}{s}{r};
            Temp_C_M = DRW_Template{k}{s}{r};
            Temp_W_M = DRW_Template_Weight{k}{s}{r};

            [CMT_V,CMT_C_V,Temp_C_V,Temp_W_V] = S_Convert(CMT_M,CMT_C_M,Temp_C_M,Temp_W_M,C_Para);
            cc = find(CMT_V~=0);
            rr = size(cc,1);
            if( max_rr < rr) 
                max_rr = rr;
            end
            
            T_cc = find(Temp_C_V~=0);
            T_rr = size(T_cc,1);
            if( max_T_rr < T_rr) 
                max_T_rr = T_rr;
            end
            
        end
    end
end

CMT_CT = int32(zeros(9,max_rr,252));
CMT_POPCNT_CT = int32(zeros(9,max_rr,252));
DRW_Template_CT = int32(zeros(9,max_T_rr,252));
DRW_Template_Weight_CT = single(zeros(9,max_T_rr,252));
for k = 1 : 9
    Ind = 1;
    for s = 1 : 7
        C_Para(1) = single(s);
        for r = 1 : 36
            C_Para(2) = single(r*10);
            CMT_M = CMT{k}{s}{r};
            CMT_C_M = CMT_C{k}{s}{r};
            Temp_C_M = DRW_Template{k}{s}{r};
            Temp_W_M = DRW_Template_Weight{k}{s}{r};

            [CMT_V,CMT_C_V,Temp_C_V,Temp_W_V] = S_Convert(CMT_M,CMT_C_M,Temp_C_M,Temp_W_M,C_Para);
            cc = find(CMT_V~=0);
            rr = size(cc,1);
            CMT_CT(k,1:rr,Ind) = CMT_V(1:rr);
            CMT_POPCNT_CT(k,1:rr,Ind) = CMT_C_V(1:rr);
            
            T_cc = find(Temp_C_V~=0);
            T_rr = size(T_cc,1);
            DRW_Template_CT(k,1:T_rr,Ind) = Temp_C_V(1:T_rr);
            DRW_Template_Weight_CT(k,1:T_rr,Ind) = Temp_W_V(1:T_rr);
            Ind = Ind +1;
        end
    end
end

save .\convert_mat\CMT_Convert CMT_CT
save .\convert_mat\CMT_POPCNT_Convert CMT_POPCNT_CT
save .\convert_mat\DRW_Template_Convert DRW_Template_CT
save .\convert_mat\DRW_Template_Weight_Convert DRW_Template_Weight_CT