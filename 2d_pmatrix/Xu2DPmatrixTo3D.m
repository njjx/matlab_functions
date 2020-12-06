function pmatrix3d = Xu2DPmatrixTo3D(pmatrix2d)

pmatrix3d = zeros(3,4);

pmatrix3d(1,1) = pmatrix2d(1,1);
pmatrix3d(1,2) = pmatrix2d(1,2);
pmatrix3d(1,4) = pmatrix2d(1,3);

pmatrix3d(2,3) = 1;

pmatrix3d(3,1) = pmatrix2d(2,1);
pmatrix3d(3,2) = pmatrix2d(2,2);
pmatrix3d(3,4) = pmatrix2d(2,3);


