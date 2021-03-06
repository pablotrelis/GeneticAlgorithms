function tspga_DNI(model)
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
close all % Cerramos todas las figuras
clearvars -except model % Se eliminan todas las variables menos model
but=0; % Flag de presionar  botón
global fig
global var
GeneraMenu(); % Generamos el menú de solicitud
while(but ~=1) % Bucle hasta presionar el botón de generación
    pause(1);
    if ishandle(findobj('Type','Figure','Name','Menu'))
    else
        return % Si se cierra el menu, finaliza la function
    end
end
% Variables seleccionadas en el meú
numberofnodes=var.numberofnodes.Value; % Número de nodos del mapa
tam=var.tam.Value; % Tamaño plot del mapa
fmode=var.mode.Value; % Modo de generación del mapa
nint=var.maxit.Value; % Número interacciones máximas
hab=var.popsize.Value; % Número de población
mut=var.mutrate.Value; % Número de mutaciones por individuo

if fmode==3
    if nargin<1
         error('Error: El modo 3 requiere introducir el modelo')
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
%Nt=npar; % # of columns in population matrix
maxit=nint; % max number of iterations
popsize=hab; % set population size / miembros de la población
mutrate=mut; % set mutation rate
selection=0.75; % fraction of population kept / fracción de miembros sobreviven 

%mutnum=floor(mutrate*popsize); % Número de mutaciones
mutnum=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%INICIALIZA LA POBLACIÓN Y VECTOR DE COSTES%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%base=(1:npar);
individuo=zeros(popsize,npar);
for i=1:1:popsize % Generamos la población inicial random
    individuo(i,:)=randperm(npar);
end
cost=tspfun(individuo,model); % Calculamos los costes 

minc(1)=min(cost); % minc contains min of population
meanc(1)=mean(cost); % meanc contains mean of population

[cost,ind]=sort(cost); % Ordenamos vector costes
pop=individuo(ind,:); % Población ordenada de mejor a peor
N=ceil(popsize*selection); % Calculo la mitad de la población
pop=pop(1:N,:); % Eliminamos la mitad peor
%sort(dist);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERO EL VECTOR DE PROBABILIDADES %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% e.g. si tengo una población de 10 individuos y solo la mitad sobreviven
% para reproducirse entonces el vector de probabilidades sería.
% Prob=[5 4 4 3 3 3 2 2 2 2 1 1 1 1 1];
Prob=repelem(N:-1:1, 1:N); % Genero vector probabilidades

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PONEMOS EL MUNDO VIRTUAL A FUNCIONAR (MAIN LOOP) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    iga=0; % Contador bucle while
    returncount=0; % Contador repeticiones para break
    figrec=figure('Name','Recorrido','Position',[800,200,500,500]); %Mapa
while iga<maxit
    iga=iga+1; % increments generation counter  
    pop=pop(1:N,:); % Eliminamos la mitad peor

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
        % Genero dos hijos para cada pareja
        [hijo1, hijo2]=HacerHijos(padre{i},madre{i});
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Mutate the population
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%-----Para 5% de la población muta-----%%%%%
        flagmutacion=0; % 1 -> muta 5%  
        if flagmutacion==1
            x=rand();
            if x<=mutrate
                hijo1=Mutar(mutnum,hijo1);
            end
            x=rand();
            if x<=mutrate
                hijo2=Mutar(mutnum,hijo2);
            end
    %%%%%-----Todos los hijos nacidos mutan-----%%%%%
        else
            hijo1=Mutar(mutnum,hijo1);
            hijo2=Mutar(mutnum,hijo2);
        end
        % Añadimos los hijos a la población
        pop=[pop ;hijo1; hijo2]; % No pillamos hijos como padres, no actualizamos Prob
    end % end de todas parejas
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Evalua el coste de la nueva población
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cost=tspfun(pop,model);
    % Sort the costs and associated parameters
    [cost,ind]=sort(cost);
    pop=pop(ind,:); %Reordenamos población con hijos

    %_______________________________________________________
    % Do statistics
    minc(iga)=min(cost); % mínimo de cada interaccion para estadísticas
    meanc(iga)=mean(cost); % media de cada interacción
    
    if mod(iga,100)==0 % Plot cada 100 interacciones
        PlotViajero(model,100,pop(1,:));
        pause(1/1e9) 
    end
    
     if iga > 2000 % A partir de 2000 iter, forzamos break con x repeticiones
        if (minc(iga)==minc(iga-1))
            returncount=returncount+1; %Contador para forzar break
        else
            returncount=0;
        end
        if returncount==5000 % Numero de veces seguidas con dmin para finalizar iter                  
            break %while
        end
    end % end -> if finalizar interacciones       
    disp(iga)
end %iga
   
    PlotViajero(model,100,pop(1,:));
    pause(1/1e9)
    Estadisticas(); %Menú estadísticas
    res_cost.Value = min(cost);
    disp(min(cost));
    
    function [mutante]=Mutar(mutnum,vanilla)
        %INPUTS
            %mutnum: Número de mutaciones por usuario
            %vanilla: Habitante antes de mutar
        %OUTPUTS
            %mutante: Habitante mutado
        r=zeros(mutnum,1);
        x=zeros(mutnum,1);
        mutante=vanilla;
        for i=1:1:mutnum
            r(i,1)=ceil(rand*length(vanilla)); %Posición de la mutación
            r_prov=ceil(rand*length(vanilla));
            while ismember(r_prov,r) %Hacemos que la segunda pose != primera
                r_prov=ceil(rand*length(vanilla));
            end
            r(i,2)=r_prov;
            x(i,1)=vanilla(r(i,1));
            x(i,2)=vanilla(r(i,2));
            vanilla(r(i,1))= x(i,2);
            vanilla(r(i,2))= x(i,1);
            mutante=vanilla;
        end % end -> function Mutar
    end
    
    function [cost]=tspfun(pop,model)
        %model.D: distancia entre diferentes nodos del mapa
        [popsize,npar]=size(pop);
        cost=zeros(1,popsize);
        for i=1:1:popsize %Calculamos coste total de cada recorrido
            for j=1:1:npar
                if j==npar
                    cost(i)=cost(i)+model.D(pop(i,j),pop(i,1));
                else
                    cost(i)=cost(i)+model.D(pop(i,j),pop(i,j+1));
                end
            end
        end
    end % end -> function tspfun

    function PlotViajero(model,tam,tabu)
        clf 
        rec=tabu;
        hold on
        
        for i=1:1:(length(tabu))
            if i==length(tabu)
            b_x=model.x(rec(1));
            b_y=model.y(rec(1));
            else
            b_x=model.x(rec(i+1));
            b_y=model.y(rec(i+1));
            end
            a_x=model.x(rec(i));
            a_y=model.y(rec(i));
            plot([a_x b_x],[a_y b_y],'b','LineWidth',1)
        end
        set(gca,'FontSize',12) %# Fix font size of the text in the current axes 
        set(gca,'FontWeight','bold')  %# Fix Bold text in the current axes 
        plot(model.x,model.y,'o') 
        for i=1:length(model.dt.Points) %# Plot the number of each node
            text(model.dt.Points(i,1),model.dt.Points(i,2),num2str(i),'FontWeight','bold')
        end
        axis([0 tam 0 tam]) %# Fix axes representation size
        box on %# Plot all lines in the box of the figure
        xlabel('X coordenate (m)') %# Label in the x axes
        ylabel('Y coordenate (m)') %# Label in the y axes
        title('Traveler') %# Title
        hold off    
    end % end -> function PlotViajero
    
    function [hijo1,hijo2]=HacerHijos(padre,madre)
        %Introducimos madre y padre y genera dos hijos con el mismo rand,
        %el primero copia los genes del padre a partir del rand, el segundo
        %los de la madre. El resto los ordena del otro en el mismo orden
        hijos={0 0};
        r=ceil(rand*length(padre));
        for h=1:1:2
            pp=[padre padre];        
            genesp=pp(r:r+floor(length(padre)/2)-1); %Tomamaos genes copiados padre
            genesm=madre;
            for i=1:1:length(genesp)
                genesm=genesm(genesm~=genesp(i)); %Elegimos los genes restantes de la madre
            end
            hijo=[genesp genesm genesp genesm];
            hijos{h}=hijo(length(padre)-r+2:length(padre)-r+1+length(padre));
            % Recortamos el hijo
            % Cambiamos padre por madre para el hijo2
            x=padre;
            padre=madre;
            madre=x;
        end
        hijo1=hijos{1};
        hijo2=hijos{2};
        end % end -> function HacerHijos

    function [model]=generamodelo_DNI(numberofnodes,tam,mode)
            close all % Se cierran los mapas abiertos, el menu no
            %%%%%---------- Generacion inputs default ----------%%%%%
            if nargin<3
                mode=0; % Genera los nodos de forma aleatoria
            end
            if nargin<2
                tam=100; % Tamaño del mapa 100x100 m
            end
            if nargin<1
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

    function []=GeneraMenu()
    % La función GeneraMenu crea todos los elementos del uifigure que se
    % utilizan como menú para las diferentes aplicaciones. Se generan
    % diferentes label que indican que es cada elemento. Se utilizan
    % tambien cajas de números para añadir el valor deseado a las variables
    % y botones para ejecutar las correspondientes funciones.        
    %%%%%---------- Creacion uifigure principal ----------%%%%%
    fig = uifigure('Name','Menu'); %Se crea la ui figure principal y su posicion
    fig.Position = [50,500,700,200];
    fig.HandleVisibility = 'on';
    %%%%%---------- Creacion paneles para cada app ----------%%%%%
    p1 = uipanel('Parent',fig,'Position',[10,10,680,180]); %Panel Mapa
    %%%%%---------- Diferentes labels del menu ----------%%%%%
    % Submenu Generacion de mapa panel 1 Labels
    sec = uilabel('Parent',p1,'Position',[250,120, 200,30],'HorizontalAlignment','center');
    sec.FontSize = 18;
    sec.Text = 'Problema del viajero';
    inf = uilabel('Parent',p1,'Position',[30,90, 100,20]);
    inf.Text = 'Número de nodos';
    inf = uilabel('Parent',p1,'Position',[180,90, 100,20]);
    inf.Text = 'Tamaño tabla';
    inf = uilabel('Parent',p1,'Position',[330,90, 100,20]);
    inf.Text = 'Modo';
    inf = uilabel('Parent',p1,'Position',[30,40, 100,20]);
    inf.Text = 'Interacciones max';
    inf = uilabel('Parent',p1,'Position',[180,40, 100,20]);
    inf.Text = 'Tamaño población';
    inf = uilabel('Parent',p1,'Position',[330,40, 100,20]);
    inf.Text = 'Rate mutación';
    %%%%%---------- Elementos solicitud de variables ----------%%%%%
    %--- Info: Las variables solicitadas se guardan en el struct var.
    % Variables generacion de mapa: numberofnodes, tam, mode, maxit y
    % popsize
    var.numberofnodes = uieditfield(p1,'numeric','Position',[30,70, 100,20]);
    var.numberofnodes.Value = 20;
    var.tam = uieditfield(p1,'numeric','Position',[180,70, 100,20]);
    var.tam.Value = 100;
    var.mode = uidropdown(p1,'Position',[330,70, 100,20]);
    var.mode.Items = {'Aleatorio','Seleccionar','Guardado','Variable Model'};
    var.mode.ItemsData = [0 1 2 3];
    var.mode.Value=0;
    var.maxit = uieditfield(p1,'numeric','Position',[30,20, 100,20]);
    var.maxit.Value = 2000;
    var.popsize = uieditfield(p1,'numeric','Position',[180,20, 100,20]);
    var.popsize.Value = 20;
    var.mutrate = uieditfield(p1,'numeric','Position',[330,20, 100,20]);
    var.mutrate.Limits = [0 1];
    var.mutrate.Value = 0.05;
    %%%%%---------- Botones del menu ----------%%%%%
    % Botones generacion de mapa
    btn = uibutton(p1,'push','Text','Generar mapa',...
               'Position',[480, 70, 100, 20],...
               'ButtonPushedFcn', @(btn,event)btnPush());
           
    %%%%%---------- Funciones btnPush ----------%%%%%
        function btnPush()
            but=1;
        end     
    end % end -> function GeneraMenu

    function []=Estadisticas()
        statsmenu = uifigure('Name','Menu'); %Se crea la ui figure principal y su posicion
        statsmenu.Position = [50,100,700,700];
        statsmenu.HandleVisibility = 'on';       
        p1 = uipanel('Parent',statsmenu,'Position',[10,10,680,680]); %Panel Mapa
        %%%%%---------- Diferentes labels del menu ----------%%%%%
        % Submenu Generacion de mapa panel 1 Labels
        sec = uilabel('Parent',p1,'Position',[250,120, 200,30],'HorizontalAlignment','center');
        sec.FontSize = 18;
        sec.Text = 'Menú de estadísticas';
        inf = uilabel('Parent',p1,'Position',[30,90, 100,20]);
        inf.Text = 'Mapa solución';
        ax = uiaxes('Parent',p1,'Position',[20,200, 640,460],...
                'XLim',[0 tam],'YLim',[0 tam]);
        inf = uilabel('Parent',p1,'Position',[180,90, 100,20]);
        inf.Text = 'Genera gráficas min y mean';
        inf = uilabel('Parent',p1,'Position',[430,90, 100,20]);
        inf.Text = 'Coste mínimo';
        res_cost = uieditfield(p1,'numeric','Position',[430,70,150,20],...
                'Editable','off','ValueDisplayFormat','%.4f m');
        res_cost.Value = 0;

        
        %%%%%---------- Elementos solicitud de variables ----------%%%%%
        %--- Info: Las variables solicitadas se guardan en el struct var.
        % Variables generacion de mapa: numberofnodes, tam, mode, maxit y
        % popsize

 
        %%%%%---------- Botones del menu ----------%%%%%
        % Botones generacion de mapa
        recorrido = uibutton(p1,'state','Text','Generar mapa',...
                   'Position',[30, 70, 100, 20],...
                   'ValueChangedFcn', @(recorrido,event)recorridoPush());
        btnmin = uibutton(p1,'state','Text','Gráficas',...
                   'Position',[180, 70, 100, 20],...
                   'ValueChangedFcn', @(btnmin,event)minPush());
           
        %%%%%---------- Funciones btnPush ----------%%%%%
        % Boton plot del recorrido final
        function recorridoPush
            if recorrido.Value==1
                cla(ax)
                if ishandle(findobj('Type','Figure','Name','Recorrido'))
                    close (figrec)
                end
                btnmin.Value=0;
                ax.XLim=[0 tam];
                ax.YLim=[0 tam];
                hold on
                rec=pop(1,:);
                for i=1:1:(length(rec))
                    if i==length(rec)
                    b_x=model.x(rec(1));
                    b_y=model.y(rec(1));
                    else
                    b_x=model.x(rec(i+1));
                    b_y=model.y(rec(i+1));
                    end
                    a_x=model.x(rec(i));
                    a_y=model.y(rec(i));
                    plot([a_x b_x],[a_y b_y],'b','LineWidth',1,'Parent',ax)
                end    
                plot(model.x,model.y,'o','Parent',ax)
                legend('off')
                xlabel('')
                ylabel('')
                hold off 
            else
                cla(ax)
            end
        end
        % Boton plot gráficas
        function minPush()
             if btnmin.Value==1
                recorrido.Value=0;
                cla(ax)
                if ishandle(findobj('Type','Figure','Name','Recorrido'))
                    close (figrec)
                end
                ax.XLim=[0 iga];
                ax.YLim=[(min(minc)-50) max(meanc)];
                plot(minc,'Parent',ax);
                hold on
                plot(meanc,'Parent',ax);
                xlabel('Número de interacciones')
                ylabel('Distancia en metros')
                legend('Coste mínimo','Media de costes')
                hold off
             else
                cla(ax) 
             end
        end
        
    end % end -> function estadisticas

end % end -> function tspga_DNI