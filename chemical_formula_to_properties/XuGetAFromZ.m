function a=XuGetAFromZ(z)
%mass = XuGetAFromZ(atomic number)
%example 16 = XuGetAFromZ(8)
z_and_a=importdata('z_and_a.txt');
a=z_and_a(round(z),2);