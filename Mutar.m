function [mutante,r,x]=Mutar(mutnum,vanilla)
r=zeros(mutnum,1);
x=zeros(mutnum,1);
mutante=vanilla;
for i=1:1:mutnum
    r(i,1)=ceil(rand*length(vanilla));
    r_prov=ceil(rand*length(vanilla));
    while ismember(r_prov,r)
        r_prov=ceil(rand*length(vanilla));
    end
    r(i,2)=r_prov;
    x(i,1)=vanilla(r(i,1));
    x(i,2)=vanilla(r(i,2));
    vanilla(r(i,1))= x(i,2);
    vanilla(r(i,2))= x(i,1);
    mutante=vanilla;
end
end