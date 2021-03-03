%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERACION DEL MODELO EN FUNCIÓN DE LAS INSTRUCCIONES DEL USUARIO %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
model=generamodelo_DNI(10,100,0);
fmodel=3;

x=model.x;
y=model.y;
numberofnodes=length(x);
%close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PARAMETROS DEL ALGORITMO GENÉTICO %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
npar=numberofnodes; % # of optimization variables
Nt=npar; % # of columns in population matrix
maxit=2000; % max number of iterations
popsize=20; % set population size / miembros de la población
mutrate=.05; % set mutation rate
selection=0.5; % fraction of population kept / fracción de miembros sobreviven 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%INICIALIZA LA POBLACIÓN Y VECTOR DE COSTES%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%base=(1:npar);
individuo=zeros(popsize,npar);
for i=1:1:popsize
    individuo(i,:)=randperm(npar);
end
cost=tspfun(individuo,model);

minc(1)=min(cost); % minc contains min of population
meanc(1)=mean(cost); % meanc contains mean of population
% pop=zeros(popsize,npar); % pop es la matriz de población ordenada
% dist=cost;
% for i=1:1:popsize
%     [val,pose]=min(cost);
%     pop(i,:)=individuo(pose,:);
%     %individuo(pose,:)=inf;
%     cost(pose)=inf;   
% end
[cost,ind]=sort(cost); % Ordenamos vector costes
pop=individuo(ind,:); % Población ordenada de mejor a peor
    
N=ceil(popsize/2); % Calculo la mitad de la población
pop=pop(1:N,:); % Eliminamos la mitad peor
%sort(dist);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERO EL VECTOR DE PROBABILIDADES %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% e.g. si tengo una población de 10 individuos y solo la mitad sobreviven
% para reproducirse entonces el vector de probabilidades sería.
% Prob=[5 4 4 3 3 3 2 2 2 2 1 1 1 1 1];
Prob=repelem(N:-1:1, 1:N); % Genero vector probabilidades
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PONEMOS EL MUNDO VIRTUAL A FUNCIONAR (MAIN LOOP) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    iga=0;
while iga<maxit
    iga=iga+1; % increments generation counter    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ELIJO A LOS PADRES Y MADRES %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % De entre el vector de probabilidades elijo aleatoriamente
    % a los padres y a las madres.
    for i=1:1:ceil(N/2)
        padre{i}=pop(Prob(ceil(rand*length(Prob))),:);  
        madre{i}=pop(Prob(ceil(rand*length(Prob))),:);       
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Emparejamientos y generación de los hijos %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
        [hijo1, hijo2]=HacerHijos(padre{i},madre{i});
        pop=[pop ;hijo1; hijo2]; % No pillamos hijos como padres, no actualizamos Prob
    end
  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Mutate the population
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%INTRODUCE EL TU CÓDIGO
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Evalua el coste de la nueva población
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Sort the costs and associated parameters
    [cost,ind]=sort(cost);
    pop=pop(ind,:);
    
    %_______________________________________________________
    % Do statistics
    minc(iga)=min(cost);
    meanc(iga)=mean(cost);
        
    disp(iga)
end %iga

        function [cost]=tspfun(pop,model) 
            [popsize,npar]=size(pop);
            cost=zeros(1,popsize);
            for i=1:1:popsize
                for j=1:1:npar
                    if j==npar
                        cost(i)=cost(i)+model.D(pop(i,j),pop(i,1));
                    else
                        cost(i)=cost(i)+model.D(pop(i,j),pop(i,j+1));
                    end
                end
            end
        end

        function [hijo1,hijo2]=HacerHijos(padre,madre)
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

        function [model]=generamodelo_DNI(numberofnodes,tam,mode);
            close all % Se cierran los mapas abiertos, el menu no
            %%%%%---------- Generacion inputs default ----------%%%%%
            if nargin<3
                mode=0; % Genera los nodos de forma aleatoria
            end
            if nargin<2
                tam=100; % Tamaño del mapa 100x100 m
            end
            if nargin<1, 
                numberofnodes=10; % 10 nodos deffault
            end
            %%%%%---------- Generacion de nodos segun el modo ----------%%%%%
            if mode==0 % Se generan los nodos de forma aleatoria
                if numberofnodes<3 % Para menos de 3 nodos, no es posible model
                    error('Seleccione un número de nodos válido mayor o igual que 3')
                end
                x=tam*rand(numberofnodes,1); % Rand entre 0-1, multiplicamos por tam para
                y=tam*rand(numberofnodes,1); % ajustarnos a la escala del mapa (tam x tam)
            elseif mode==1 % Se solicita por pantalla las posiciones de los nodos
                figure('Position',[800,150,600,500]);
                axis([0 tam 0 tam]) % Se genera un plot vacío del tamaño tam
                title({'\fontsize{10}Click izquierdo para seleccionar nodo,',...
                    'click derecho para seleccionar el último nodo y cerrar'})
                [x,y]=getpts; % Se solicita y guarda en x,y las posiciones de los nodos
                if numberofnodes ~=length(x) % Warning de reajuste de numero de nodos
                    warning('Se ha reajustado el número de nodos de: %d a: %d',...
                        numberofnodes,length(x))
                end
                numberofnodes=length(x); % Recalculamos el valor del número de nodos
                close all % Se cierra la figura de solicitud de nodos
            elseif mode==2 % Se carga el modelo guardado en mapas.mat
                load('mapas.mat');
                numberofnodes=length(model.x);
                x=model.x;
                y=model.y;
            else % Error si mode es diferente de 0,1 o 2
                error('Error: Modo no válido, introduce un número entre 0,1 o 2') 
            end % end -> if de modos
            %%%%%---------- Generacion estructura delaunayTriangulation ----------%%%%%
            dt=delaunayTriangulation(x,y);
            % Con delaunayTriangulation generamos una estructura con:
            % dt.Points: es una matriz numberofnodes x 2 que genera en cada fila las
            % coord de cada nodo.
            % dt.ConectivityList: matriz Nx3 donde N es el número de triángulos que
            % tenemos, en cada fila encontramos los 3 nodos que representan los
            % vértices de cada triángulo.
            %%%%%---------- Calculo matriz distancias entre nodos D ----------%%%%%
            for i = 1:1:numberofnodes
                for j = 1:1:numberofnodes
                    D(i,j)= sqrt((dt.Points(i,1)-dt.Points(j,1))^2+(dt.Points(i,2)-dt.Points(j,2))^2);
                end 
            end
            % Se recorre una matriz generando la distancia entre los diferentes 
            % nodos, donde D(1,2) es la distancia entre los nodos 1 y 2.
            %%%%%---------- Calculo nodos vecinos ----------%%%%%
            for i = 1:1:numberofnodes % Se recorren los x nodos comprobando si estan conectados
                for j = 1:1:numberofnodes
                    neiM(i,j)=isConnected(dt,i,j);
                % Matriz de valores lógicos que indica si dos nodos estan conec
                % o no, neiM(1,2)=0 indica que los nodos 1 y 2 no son vecinos.
                % neiM(1,2)=1 indica que los nodos 1 y 2 son vecinos.
                end
                nei{i}=find(neiM(i,:)); % Se genera el vector con los vecinos de cada nodo
                clear neiM % No se necesita la matriz binaria
            end
            %%%%%---------- Generacion outputs struct model. ----------%%%%%
            model.dt=dt; % Struct dt contiene estructura triangulacion
            model.x=x; % Vector de posiciones x de nodos
            model.y=y; % Vector posiciones y de nodos
            model.D=D; % Matriz de distancias entre nodos
            model.nei=nei; % Vector de vecinos de cada nodo
            %%%%%---------- Plot output ----------%%%%%
            MapaPlot(model,tam)   
        end % end -> function generamodelo_DNI
        function []=MapaPlot(model,tam) % Funcion crea el plot del mapa 
        figure('Position',[800,150,600,500]); % Posición y tamaño de fig
        set(gca,'FontSize',12) %# Fix font size of the text in the current axes 
        set(gca,'FontWeight','bold')  %# Fix Bold text in the current axes 
        plot(model.x,model.y,'x') 
        triplot(model.dt,'r');  %# Plot the Delaunay triangulation
        for i=1:length(model.dt.Points) %# Plot the number of each node
            text(model.dt.Points(i,1),model.dt.Points(i,2),num2str(i),'FontWeight','bold')
        end
        axis([0 tam 0 tam]) %# Fix axes representation size
        box on %# Plot all lines in the box of the figure
        xlabel('X coordenate (m)') %# Label in the x axes
        ylabel('Y coordenate (m)') %# Label in the y axes
        title('Generated model') %# Title
    end % end -> function MapaPlot