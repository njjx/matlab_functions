function R=XuRSquared(x,y)

x=XuTallVector(x);
y=XuTallVector(y);

A=corrcoef(x,y);
R=A(2,1)^2;
