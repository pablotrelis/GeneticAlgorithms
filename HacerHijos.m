        function [hijo1,hijo2,r]=HacerHijos(padre,madre)
        hijos={0 0};
        r=ceil(rand*length(padre));
        for h=1:1:2
            pp=[padre padre];         
            genesp=pp(r:r+floor(length(padre)/2)-1);
            genesm=madre;
            for i=1:1:length(genesp)
                genesm=genesm(genesm~=genesp(i));
            end
            hijo=[genesp genesm genesp genesm];
            hijos{h}=hijo(length(padre)-r+2:length(padre)-r+1+length(padre));
            x=padre;
            padre=madre;
            madre=x;
        end
        hijo1=hijos{1};
        hijo2=hijos{2};
        end % end -> function HacerHijos