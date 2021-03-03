function tspga_DNI(fmodel,model)
% fucntion tspga_DNI(fmode,model)
% Función que utiliza algoritmos genéticos para resolver el problema del
% viajante (Travel Sales Problem TSP)
% INPUTS
    % mode: indica el modo de generación los nodos del modelo
    %       está función llamará a la función generamodelo_DNI creada en la
    %       primera práctica
    %    modo=0; % los nodos se genera aleatoriamente
    %    modo=1; % los nodos los indica el usuario manualmente
    %    modo=2; % utilizar los nodos almacenados
    %    mode=3; % la estructura del modelo se introduce como una variable
    % model: estructura generada previamente con generamodelo_DNI.m
% OUPUTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERACION DEL MODELO EN FUNCIÓN DE LAS INSTRUCCIONES DEL USUARIO %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<1
    fmode=0;
end
numberofnodes=20;
tam=10;
if fmode==3
    if nargin<2
         disp('Error: El modo 3 requiere introducir el modelo')
    end
end
if fmode<3
    model=generamodelo_DNI(numberofnodes,tam,fmode);
end
x=model.x;
y=model.y;
numberofnodes=length(x);
close all

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
cost=zeros(1,popsize);
for i=1:1:popsize
    for j=1:1:npar
        if j==npar
            cost(i)=cost(i)+model.D(individuo(i,j),individuo(i,1));
        else
            cost(i)=cost(i)+model.D(individuo(i,j),individuo(i,j+1));
        end
    end
end
minc(1)=min(cost); % minc contains min of population
meanc(1)=mean(cost); % meanc contains mean of population
ordenada=zeros(popsize,npar);
for i=1:1:popsize
    [val,pose]=min(cost);
    ordenada(i,:)=individuo(pose,:);
    cost(pose)=inf;
end
pob=ordenada(1:popsize/2,:);


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
end % end -> function tspga_DNI