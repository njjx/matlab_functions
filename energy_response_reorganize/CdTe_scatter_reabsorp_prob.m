function output=CdTe_scatter_reabsorp_prob(material_thickness_in_um, photon_energy_vector_in_keV)

output=zeros(1,length(photon_energy_vector_in_keV));

CdTeCS=importdata('CdTeCrossSection.txt');

Depth=material_thickness_in_um/1000;%convert to mm
z=eps+[0:0.001:Depth];

cdte_density = 6.2;

phi=eps+(0:0.01:1)*pi;
PphiC=(1+cos(phi).^2).*sin(phi);
PphiC=PphiC/sum(PphiC);


phi=eps+(0:0.01:1)*pi;
AtomicFormFactor=importdata('CdTeAtomicFormFactor.txt');
AtomicFormFactor(1)=eps;
AtomicFormFactor(:,2)=1/2*(AtomicFormFactor(:,2)+AtomicFormFactor(:,3));


d1=z'*(1./cos(phi));
d2=(Depth-z')*(1./cos(pi-phi));

d=d1.*(d1>0)+d2.*(d2>0);
d(find(d>5))=5;

for energy_idx=1:length(photon_energy_vector_in_keV)
    
    E = photon_energy_vector_in_keV(energy_idx);
    muE=exp(interp1(log(CdTeCS(:,1)),log(CdTeCS(:,7)),log(E/1000),'linear'));
    Pz=exp(-muE*cdte_density*z/10);
    Pz=Pz/sum(Pz);
    
    Es=E./(1+E./511.*(1-cos(phi)));
    muEs=exp(interp1(log(CdTeCS(:,1)),log(CdTeCS(:,7)),log(Es/1000),'linear'));
    
    temp1=1-exp(-repmat(muEs,[length(z),1]).*d/10.*cdte_density);
    temp2=temp1.*repmat(PphiC,[length(z),1]).*repmat(Pz',[1,length(phi)]);
    temp2=sum(sum(temp2));
    
    Lambda=12.4/E;
    AtomicFormFactorInterp=exp(interp1(log(AtomicFormFactor(:,1)),log(AtomicFormFactor(:,2)),log(sin(phi/2)/Lambda),'linear'));
    PphiR=(1+cos(phi).^2).*sin(phi).*AtomicFormFactorInterp;
    PphiR=PphiR/sum(PphiR);
    
    temp3=1-exp(-repmat(muE,[length(z),1]).*d/10.*6.2);
    temp4=temp3.*repmat(PphiR,[length(z),1]).*repmat(Pz',[1,length(phi)]);
    temp4=sum(sum(temp4));
    
    muER=exp(interp1(log(CdTeCS(:,1)),log(CdTeCS(:,2)),log(E/1000),'linear'));
    muEC=exp(interp1(log(CdTeCS(:,1)),log(CdTeCS(:,3)),log(E/1000),'linear'));
    Rs=muEC/(muER+muEC)*temp2+muER/(muER+muEC)*temp4;
    
    output(energy_idx) = Rs;
end


