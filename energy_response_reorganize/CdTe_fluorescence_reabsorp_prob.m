function output=CdTe_fluorescence_reabsorp_prob(material_thickness_in_um, photon_energy_vector_in_keV, energy_k_edge_in_keV, energy_k_fluorescence_in_keV)
%output=CdTe_fluorescence_reabsorp_prob(material_thickness_in_um, photon_energy_vector_in_keV,...
%    energy_k_edge_in_keV, energy_k_fluorescence_in_keV)
output=zeros(1,length(photon_energy_vector_in_keV));
cdte_density=6.2;

Depth=material_thickness_in_um/1000;%in mm
z=eps+[0:0.001:Depth];

phi=eps+(0:0.01:1)*pi;
phi_prob=sin(phi);
phi_prob=phi_prob/sum(phi_prob);

d1=z'*(1./cos(phi));%distance to 
d2=(Depth-z')*(1./cos(pi-phi));

distance_mat=d1.*(d1>0)+d2.*(d2>0);
%distance_matrix
%column is depth
%row is angle

distance_mat((distance_mat>5))=5;

mu_k_fluo=XuGetAtten('cdte',cdte_density,energy_k_fluorescence_in_keV);

for energy_idx=1:length(photon_energy_vector_in_keV)
    energy=photon_energy_vector_in_keV(energy_idx);
    if energy>energy_k_edge_in_keV
        mu_energy=XuGetAtten('cdte',cdte_density,energy);
        z_prob=exp(-mu_energy*z/10);
        z_prob=z_prob/sum(z_prob);
        temp1=1-exp(-mu_k_fluo*distance_mat/10);
        temp2=temp1.*repmat(phi_prob,[length(z),1]).*repmat(z_prob',[1,length(phi)]);
        temp2=sum(sum(temp2));
        output(energy_idx)=temp2;
    else
        output(energy_idx)=0;
    end
end