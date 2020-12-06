function coef=XuVectorDecom(vec,vec_1,vec_2)
coef=[vec]*[vec_1;vec_2]'*inv([vec_1;vec_2]*[vec_1;vec_2]');