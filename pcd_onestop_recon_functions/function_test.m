clear all
close all
clc

XuOneStopRecon('config_fbp.jsonc', 'config_preprocessing.jsonc');

XuOneStopBoneCorr('config_fbp.jsonc','config_fpj.jsonc',...
    'config_bone_corr.jsonc','config_preprocessing.jsonc');