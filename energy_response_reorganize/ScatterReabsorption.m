clear all
close all
clc

fid=fopen('ScatterReabsorption.txt','w');
fclose(fid);
config=importdata('ConfigDQE.txt');
PixelSize=100; %100um
for idx=1:length(config)
    eval(char(config(idx)));
end

CdTeCS=importdata('CdTeCrossSection.txt');
muEk=exp(interp1(log(CdTeCS(:,1)),log(CdTeCS(:,7)),log(Ek/1000),'linear'));
PCdTe=PCdTe/sum(PCdTe);

KNCS=importdata('KNCrossSection.txt');

Depth=2;%2mm
z=eps+[0:0.001:Depth];


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

for E=[20:0.3:120]
    muE=exp(interp1(log(CdTeCS(:,1)),log(CdTeCS(:,7)),log(E/1000),'linear'));
    Pz=exp(-muE*6.2*z/10);
    Pz=Pz/sum(Pz);
    
    Es=E./(1+E./511.*(1-cos(phi)));
    muEs=exp(interp1(log(CdTeCS(:,1)),log(CdTeCS(:,7)),log(Es/1000),'linear'));
    
    temp1=1-exp(-repmat(muEs,[length(z),1]).*d/10.*6.2);
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
    
    plot(E,Rs,'k.');
    hold on;
    fid=fopen('ScatterReabsorption.txt','a+');
    fprintf(fid,'%d %.5f\r\n',[E,Rs]);
    fclose(fid);
end

