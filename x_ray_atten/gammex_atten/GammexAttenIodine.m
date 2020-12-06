function atten=GammexAttenIodine(s_concentration,energy)
%atten=GammexAttenIodine(s_concentration,energy)
%s_concentration can be 2,2.5,5,7.5,10,15,or 20. 
%atten is in unit cm^{-1}

switch s_concentration
    case '2'
        row_idx=1;
    case '2.5'
        row_idx=2;  
    case '5'
        row_idx=3;
    case '7.5'
        row_idx=4;
    case '10'
        row_idx=5;
    case '15'
        row_idx=6;
    case '20'
        row_idx=7;
    otherwise
        error('No concentration was found!');
end

mu_H=XuGetAtten('H',1,energy);
mu_O=XuGetAtten('O',1,energy);
mu_C=XuGetAtten('C',1,energy);
mu_N=XuGetAtten('N',1,energy);
mu_Cl=XuGetAtten('Cl',1,energy);
mu_Ca=XuGetAtten('Ca',1,energy);
mu_Mg=XuGetAtten('Mg',1,energy);
mu_I=XuGetAtten('I',1,energy);

material_fraction=importdata('Gammex_I.txt');
atten=material_fraction(row_idx,2)*(mu_H*material_fraction(row_idx,4)+...
    mu_O*material_fraction(row_idx,5)+mu_C*material_fraction(row_idx,6)+...
    mu_N*material_fraction(row_idx,7)+mu_Cl*material_fraction(row_idx,8)+...
    mu_Ca*material_fraction(row_idx,9)+mu_Mg*material_fraction(row_idx,10)+...
    mu_I*material_fraction(row_idx,11))/100;

