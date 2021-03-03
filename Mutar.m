function [mutante,r,x]=Mutar(mutnum,vanilla)
r=zeros(mutnum,1);
x=zeros(mutnum,1);
mutante=vanilla;
for i=1:1:mutnum
    r_prov=ceil(rand*length(vanilla));
    while ismember(r_prov,r)
        r_prov=ceil(rand*length(vanilla));
    end
    r(i)=r_prov;
    x(i)=vanilla(r(i));   
end
for i=1:1:mutnum
    if i==1
       mutante(r(i))=x(mutnum); 
    else
       mutante(r(i))=x(i-1);
    end
end
end