function coef=XuVector3Decom(vec,vec_1,vec_2,vec_3)
coef=[vec]*[vec_1;vec_2;vec_3]'*inv([vec_1;vec_2;vec_3]*[vec_1;vec_2;vec_3]');