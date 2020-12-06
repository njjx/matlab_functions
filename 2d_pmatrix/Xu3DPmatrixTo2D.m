function pmatrix_2d = Xu3DPmatrixTo2D(pmatrix_3d)

if size(pmatrix_3d,1)~=3 || size(pmatrix_3d,2)~=4
    error('size of 3d pmatrix is wrong!');
end

pmatrix_2d=zeros(2,3);

pmatrix_2d(1,1)= pmatrix_3d(1,1);
pmatrix_2d(1,2)= pmatrix_3d(1,2);
pmatrix_2d(1,3)= pmatrix_3d(1,4);
pmatrix_2d(2,1)= pmatrix_3d(3,1);
pmatrix_2d(2,2)= pmatrix_3d(3,2);
pmatrix_2d(2,3)= pmatrix_3d(3,4);