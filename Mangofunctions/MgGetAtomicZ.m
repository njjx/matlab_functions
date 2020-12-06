function Z = MgGetAtomicZ(atom)
% Get the atomic number of element.
% atom: e.g. "H", "O", "Ca"

switch atom
    case "H"
        Z = 1;
    case "He"
        Z = 2;
    case "Li"
        Z = 3;
    case "Be"
        Z = 4;
    case "B"
        Z = 5;
    case "C"
        Z = 6;
    case "N"
        Z = 7;
    case "O"
        Z = 8;
    case "F"
        Z = 9;
    case "Ne"
        Z = 10;
    case "Na"
        Z = 11;
    case "Mg"
        Z = 12;
    case "Al"
        Z = 13;
    case "Si"
        Z = 14;
    case "P"
        Z = 15;
    case "S"
        Z = 16;
    case "Cl"
        Z = 17;
    case "Ar"
        Z = 18;
    case "K"
        Z = 19;
    case "Ca"
        Z = 20;
    case "Sc"
        Z = 21;
    case "Ti"
        Z = 22;
    case "V"
        Z = 23;
    case "Cr"
        Z = 24;
    case "Mn"
        Z = 25;
    case "Fe"
        Z = 26;
    case "Co"
        Z = 27;
    case "Ni"
        Z = 28;
    case "Cu"
        Z = 29;
    case "Zn"
        Z = 30;
    case "Ga"
        Z = 31;
    case "Ge"
        Z = 32;
    case "As"
        Z = 33;
    case "Se"
        Z = 34;
    case "Br"
        Z = 35;
    case "Kr"
        Z = 36;
    case "Rb"
        Z = 37;
    case "Sr"
        Z = 38;
    case "Y"
        Z = 39;
    case "Zr"
        Z = 40;
    case "Nb"
        Z = 41;
    case "Mo"
        Z = 42;
    case "Tc"
        Z = 43;
    case "Ru"
        Z = 44;
    case "Rh"
        Z = 45;
    case "Pd"
        Z = 46;
    case "Ag"
        Z = 47;
    case "Cd"
        Z = 48;
    case "In"
        Z = 49;
    case "Sn"
        Z = 50;
    case "Sb"
        Z = 51;
    case "Te"
        Z = 52;
    case "I"
        Z = 53;
    case "Xe"
        Z = 54;
    case "Cs"
        Z = 55;
    case "Ba"
        Z = 56;
    case "La"
        Z = 57;
    case "Ce"
        Z = 58;
    case "Pr"
        Z = 59;
    case "Nd"
        Z = 60;
    case "Pm"
        Z = 61;
    case "Sm"
        Z = 62;
    case "Eu"
        Z = 63;
    case "Gd"
        Z = 64;
    case "Tb"
        Z = 65;
    case "Dy"
        Z = 66;
    case "Ho"
        Z = 67;
    case "Er"
        Z = 68;
    case "Tm"
        Z = 69;
    case "Yb"
        Z = 70;
    case "Lu"
        Z = 71;
    case "Hf"
        Z = 72;
    case "Ta"
        Z = 73;
    case "W"
        Z = 74;
    case "Re"
        Z = 75;
    case "Os"
        Z = 76;
    case "Ir"
        Z = 77;
    case "Pt"
        Z = 78;
    case "Au"
        Z = 79;
    case "Hg"
        Z = 80;
    case "Tl"
        Z = 81;
    case "Pb"
        Z = 82;
    case "Bi"
        Z = 83;
    case "Po"
        Z = 84;
    case "At"
        Z = 85;
    case "Rn"
        Z = 86;
    case "Fr"
        Z = 87;
    case "Ra"
        Z = 88;
    case "Ac"
        Z = 89;
    case "Th"
        Z = 90;
    case "Pa"
        Z = 91;
    case "U"
        Z = 92;
    case "Np"
        Z = 93;
    case "Pu"
        Z = 94;
    case "Am"
        Z = 95;
    case "Cm"
        Z = 96;
    case "Bk"
        Z = 97;
    case "Cf"
        Z = 98;
    case "Es"
        Z = 99;
    case "Fm"
        Z = 100;
    case "Md"
        Z = 101;
    case "No"
        Z = 102;
    case "Lr"
        Z = 103;
    case "Rf"
        Z = 104;
    case "Db"
        Z = 105;
    case "Sg"
        Z = 106;
    case "Bh"
        Z = 107;
    case "Hs"
        Z = 108;
    case "Mt"
        Z = 109;
    case "Ds"
        Z = 110;
    case "Rg"
        Z = 111;
    case "Cn"
        Z = 112;
    case "Nh"
        Z = 113;
    case "Fl"
        Z = 114;
    case "Mc"
        Z = 115;
    case "Lv"
        Z = 116;
    case "Ts"
        Z = 117;
    case "Og"
        Z = 118;
    otherwise
        error("Unknown element '%s'\n", atom);
        
end

end

