%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SIST. REPR. CONHECIMENTO E RACIOCINIO - Trabalho Individual

% José Nuno Martins

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SICStus PROLOG: Declaracoes iniciais
:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( single_var_warnings,off ).
:- set_prolog_flag( unknown,fail ).
:- set_prolog_flag(toplevel_print_options,[quoted(true), portrayed(true), max_depth(0)]). 

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SICStus PROLOG: definicoes iniciais

:- op( 900,xfy,'::' ).
:- dynamic '-'/1.
:- dynamic(ponto/12).
:- dynamic(aresta/2).
:- dynamic(rua/5).
:- op(  500,  fx, [ +, - ]).
:- op(  300, xfx, [ mod ]).
:- op(  200, xfy, [ ^ ]).


:- include('databasePontos.pl').
:- include('arestas.pl').
/* :- include('arestasPequeno.pl'). */
/* :- include('arestasReduce.pl'). */ 
:- include('databaseRuas.pl').
:- use_module(library(lists)).
:- use_module(library(statistics)).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
%---------------------------------  predicados auxiliares ---------
% Extensao do meta-predicado nao: Questao -> {V,F}

nao( Questao ) :-
    Questao, !, fail.
nao( Questao ).

membro(X, [X|_]).
membro(X, [_|Xs]):-
	membro(X, Xs).

membros([], _).
membros([X|Xs], Members):-
	membro(X, Members),
	membros(Xs, Members).

% Extensão do predicado solucoes   
solucoes( X,Y,Z ) :-findall( X,Y,Z ).

%concatena listas 
concat(List1, List2, Result):-
   append(List1, List2, Result).
  
remove(P) :- retract(P).
remove(P) :- assert(P),!,fail.

escrever([]).
escrever([H|T]):-write(H),nl,escrever(T). % nl é newline

escrever1([]).
escrever1([H|T]):-write(H),write(','),escrever1(T).

topN([],_).
topN(X,0).
topN([H|T],Lim):-write(H),nl,Lim1 is Lim - 1, topN(T,Lim1).

member1(D,[D|_]).
member1(D,[_|T]):-member1(D,T).

eliminaRepAux([],Acc,Acc).
eliminaRepAux([X|XS],Acc,R) :- member1(X,Acc), eliminaRepAux(XS,Acc,R).
eliminaRepAux([X|XS],Acc,R) :- eliminaRepAux(XS,[X|Acc],R).

eliminaRepetidos(X, R) :- eliminaRepAux(X,[],R), !.

%devvolve o primeiro elemento da lista                                        
primeiroElementoLista([],[]).
primeiroElementoLista([X|T],X).

%devolve o último elemento da lista                                        
ultimoElementoLista(Lista,X):-reverse(Lista,RevLista),primeiroElementoLista(RevLista,X).

%Elimina o primeiro elemento da lista
removePrimeiro([],[]).
removePrimeiro([X|T],T).

seleciona(E, [E|Xs], Xs).
seleciona(E, [X|Xs], [X|Ys]):- seleciona(E, Xs,Ys).

/* seleciona(E, [E|Xs], Xs).
seleciona(E, [X|Xs], [Y|Ys]):- seleciona(E, Xs, Ys). */

% Remove um elemento da lista
remove(X, [X|T], T).
remove(X, [H|T], [H|T1]):- remove(X,T,T1).

% distribui(L,A,B) : distribui itens de L entre A e B
distribui([],[],[]).
distribui([X],[X],[]).
distribui([X,Y|Z],[X|A],[Y|B]) :- distribui(Z,A,B). 

% intercala(A,B,L) : intercala A e B gerando L
intercala([],B,B).
intercala(A,[],A).
intercala([(L1,NrPR1)|A],[(L2,NrPR2)|B],[(L1,NrPR1)|C]) :-
NrPR2 =< NrPR1,
intercala(A,[(L2,NrPR2)|B],C).
intercala([(L1,NrPR1)|A],[(L2,NrPR2)|B],[(L2,NrPR2)|C]) :-
NrPR2 > NrPR1,
intercala([(L1,NrPR1)|A],B,C). 

% ordena(L,S) : ordena a lista L obtendo S
ordena([],[]).
ordena([X],[X]).
ordena([X,Y|Z],S) :-
distribui([X,Y|Z],A,B),
ordena(A,As),
ordena(B,Bs),
intercala(As,Bs,S).

%Para ver todos os pontos
listingP(R):-solucoes(ponto(Lat,Long,IdPonto,PRF,IdRua,IR,PRL,CR,CT,CC,CQ,CTL),ponto(Lat,Long,IdPonto,PRF,IdRua,IR,PRL,CR,CT,CC,CQ,CTL),R).
%Para ver todas as ruas
listingR(R):-solucoes(rua(IdRua,Lat,Long,Res,Qt),rua(IdRua,Lat,Long,Res,Qt),R).
%Para ver todas as arestas
listingA(R):-solucoes(aresta(P1,P2),aresta(P1,P2),R).


%Definição de garagem e Ponto de despejo--------------------------------------------------------------------------------------------------------
/* garagem(15808).
despejo(15890). */
garagem(21944).
despejo(15808).

%%ver se há conecção:
adjacente(X,Y) :- aresta(X,Y).
adjacente(X,Y) :- aresta(Y,X).

% ------------------------------------------------------------------------------------------------------------------------------------------------
% ------------------------------------------------------------------------------------------------------------------------------------------------
% -----------------------------------------------------------------------------------------------------------------------------------------------
% ------------------------------------------------------------------------------------------------------------------------------------------------
% ------------------------------------------------------------------------------------------------------------------------------------------------
% -----------------------------------------------------------------------------------------------------------------------------------------------
%-------------------------------------------CALCULAR CAMINHO ENTRE DOIS PONTOS---------------------------------------------------------------------
% Gerar os circuitos de recolha tanto indiferenciada como seletiva, caso existam, que
% cubram um determinado território;

%Circuitos de Recolha indiferenciada
%------------------------------------------------------[Não informada]-----------------------------------------------------
%[método inefeciente]
caminho(A,B,P):-caminho1(A,[B],P).
caminho1(A,[A|P1],[A|P1]).
caminho1(A,[Y|P1],P):- adjacente(X,Y), 
                       nao(membro(X,[Y|P1])), 
                       caminho1(A,[X,Y|P1],P).

resolve_inefeciente(Cam):-garagem(G),despejo(D),caminho(G,D,Cam).

todos_inefeciente(R):-findall((Cam),resolve_inefeciente(Cam),R).
%---------------------------[em profundidade mas estado unico(conhecido estado inicial)]-----------------------------------
resolve_pp(Nodo,[Nodo|Caminho]):-
        profundidadeprimeiro1(Nodo,[Nodo],Caminho).

profundidadeprimeiro1(Nodo,_,[]):-despejo(Nodo).
profundidadeprimeiro1(Nodo,Historico,[ProxNodo|Caminho]):-
        adjacente(Nodo,ProxNodo),
        nao(membro(ProxNodo,Historico)),
        profundidadeprimeiro1(ProxNodo,[ProxNodo|Historico],Caminho).

resolve_Profundidade_1(Cam):-garagem(G),resolve_pp(G,Cam).

todos_Profundidade_1(R):-findall((Cam),resolve_Profundidade_1(Cam),R).

%-----------------------------[em profundidade multi estados]------------------------------------------------------------------------------
resolve_pp_h(NodoInicial, NodoFinal, Caminho):-
    profundidadeH(NodoInicial, NodoFinal, [NodoInicial], Caminho).

profundidadeH(Destino,Destino,H,D):- reverse(H,D).
profundidadeH(Origem, Destino, Historico, C):-
    adjacente(Origem,Prox),
    nao(membro(Prox,Historico)),
    profundidadeH(Prox,Destino, [Prox|Historico], C).

resolve_profundidade_Multi_1(Cam):-garagem(G),despejo(D),resolve_pp_h(G, D, Cam).

todos_profundidade_Multi_1(R):-findall((Cam),resolve_profundidade_Multi_1(Cam),R).

%-------------------------------[pesquisa em profundidade limitada]--------------------------------------------------------------------------
resolve_prof_lim(Nodo,Caminho,L) :- profundidade_limitada([],Nodo,InvCaminho,L),reverse(InvCaminho,Caminho).

profundidade_limitada(Caminho,Nodo,[Nodo|Caminho],_):- despejo(Nodo).
profundidade_limitada(Caminho,Nodo,S,L) :- L>0, adjacente(Nodo,NodoL), \+ member(NodoL,Caminho), L1 is L-1,
                    profundidade_limitada([Nodo|Caminho], NodoL,S,L1).

resolve_prof_lim_1(Cam,L):-garagem(G),resolve_prof_lim(G,Cam,L).

todos_prof_lim(R,L):-findall((Cam),resolve_prof_lim_1(Cam,L),R).
%--------------------------------[pesquisa em largura]------------------------------------------------------------------------------
largura(Inicio,Fim,Caminho) :-
    bfs([[Inicio]],Fim, CaminhoAux),
    reverse(CaminhoAux,Caminho). 

bfs([[Fim|Caminho]|_],Fim, [Fim|Caminho]).
bfs([Caminho1|Caminhos], Fim, Caminho) :-
    expande(Caminho1, NovosCaminhos),
    append(Caminhos, NovosCaminhos, Caminhos1),
    bfs(Caminhos1, Fim, Caminho).

expande([Nodo|Caminho], NovosCaminhos) :-
    findall([Nodo2, Nodo|Caminho],(adjacente(Nodo, Nodo2),\+ memberchk(Nodo2,[Nodo|Caminho])),NovosCaminhos),!.
expande(_,[]).

resolve_Largura_1(Cam):-garagem(G),despejo(D),largura(G,D,Cam).

todos_Largura_1(C):-findall((Cam),resolve_Largura_1(Cam),R),eliminaRepetidos(R,C).
% ------------------------------------------------------------------------------------------------------------------------------------------------
% ------------------------------------------------------------------------------------------------------------------------------------------------
% -----------------------------------------------------------------------------------------------------------------------------------------------
% ------------------------------------------------------------------------------------------------------------------------------------------------
% ------------------------------------------------------------------------------------------------------------------------------------------------
% -----------------------------------------------------------------------------------------------------------------------------------------------
% -------------------------------------------------------[ALIENA 2] -------------------------------------------------------------------------------
% Identificar quais os circuitos com mais pontos de recolha (por tipo de resíduo a recolher);

%devolve os N primeiros elementos de uma lista
nPrim(N, _, Xs) :- N =< 0, !, N =:= 0, Xs = [].
nPrim(_, [], []).
nPrim(N, [X|Xs], [X|Ys]) :- M is N-1, nPrim(M, Xs, Ys).

%total de pontos de recolha de uma determinadada rua
numeroPR_Rua(IdRua,R) :- rua(IdRua,Lat,Long,Res,Qt),length(Res,R).

%Dada uma rua, devolve a lista de pontos de recolha da mesma
listaDePontos_Rua(IdRua,R) :- findall(ponto(Lat1,Long1,Id1,PRF1,IdRua1,PRL11,PRL12,CR1,CT1,CC1,CQ1,CTL1)
                        ,(ponto(Lat1,Long1,Id1,PRF1,IdRua1,PRL11,PRL12,CR1,CT1,CC1,CQ1,CTL1), IdRua=IdRua1 ),R).

%total de pontos de recolha de um determinado residuo para uma determinada rua
numeroPR_R_Rua(IdRua,TResiduo,R):-listaDePontos_R_Rua(IdRua,L),quantosResiduoPonto(TResiduo,L,R).

%Dado um ID de uma rua, devolve a lista de residuos da mesma
listaDePontos_R_Rua(IdRua,Res) :- rua(IdRua,Lat,Long,Res,Qt). 

%conta o numero de elementos de um determinado tipo de residuos na lista de residuos
quantosResiduoPonto(TResiduo,[],0).
quantosResiduoPonto(TResiduo,[TResiduo|T],L):- quantosResiduoPonto(TResiduo,T,N1), L is N1 + 1.
quantosResiduoPonto(TResiduo,[X|T],L):- X \=TResiduo, quantosResiduoPonto(TResiduo,T,L).


%-------------------------------------------[Pesquisa não informada em profundidade]--------------------------------------------------
%LISTA DE TODOS OS CAMINHOS E ESCOLHA DO QUE TEM MAIS PONTOS DE RECOLHA
%Dado um ponto inicial e final devolve um caminho e a quantidade de pontos de recolha do mesmo para um tipo de residuo
resolve_pp_h_PR(NodoInicial, NodoFinal,TResiduo,Caminho/NrPR):-
    profundidade_PR(NodoInicial, NodoFinal,TResiduo, [NodoInicial], Caminho, NrPR).

profundidade_PR(Destino,Destino,TResiduo,H,D,NrPR):- reverse(H,D), numeroPR_R_Rua(Destino,TResiduo,NrPR).
profundidade_PR(Origem, Destino,TResiduo,Historico, Caminho, NrPR):-
    numeroPR_R_Rua(Origem,TResiduo,NrPR1),
    adjacente(Origem,Prox),
    nao(membro(Prox,Historico)),
    profundidade_PR(Prox,Destino,TResiduo,[Prox|Historico], Caminho, NrPR2),
    NrPR is NrPR1+NrPR2.

resolve_Profundidade_2(TResiduo,Cam):-garagem(G),despejo(D),resolve_pp_h_PR(G,D,TResiduo,Cam).

%Processo para apresentar o melhor caminho
todos_Caminhos_TResiduo_Profundidade(TResiduo,X):-findall((Cam,NrPR),resolve_Profundidade_2(TResiduo,Cam/NrPR),R),eliminaRepetidos(R,X).

caminhosOrdena_TResiduo_Profundidade(TResiduo,S):-todos_Caminhos_TResiduo_Profundidade(TResiduo,R),ordena(R,S).

%Devolve o caminho com mais pontos de recolha para um determinado residuo
bestCaminho_TResiduo_Profundidade(TResiduo,Best):-caminhosOrdena_TResiduo_Profundidade(TResiduo,S),primeiroElementoLista(S,Best).


%-------------------------------[pesquisa em profundidade limitada]--------------------------------------------------------------------------
resolve_prof_lim_Res(Nodo,TResiduo,Caminho/NrPR,L) :- profundidade_limitada([],Nodo,TResiduo,InvCaminho/NrPR,L),reverse(InvCaminho,Caminho).

profundidade_limitada(Caminho,Nodo,TResiduo,[Nodo|Caminho]/NrPR,_):-despejo(Nodo),numeroPR_R_Rua(Nodo,TResiduo,NrPR).
profundidade_limitada(Caminho,Nodo,TResiduo,S/NrPR,L) :-
                numeroPR_R_Rua(Nodo,TResiduo,NrPR1),
                L>0, adjacente(Nodo,NodoL), 
                \+ member(NodoL,Caminho), 
                L1 is L-1,
                profundidade_limitada([Nodo|Caminho],NodoL,TResiduo,S/NrPR2,L1),
                NrPR is NrPR1+NrPR2.

resolve_prof_lim_2(TResiduo,L,Cam):-garagem(G),despejo(D),resolve_prof_lim_Res(G,TResiduo,Cam,L).

%Processo para apresentar o melhor caminho
todos_Caminhos_TResiduo_Prof_Lim(TResiduo,L,X):-findall((Cam,NrPR),resolve_prof_lim_2(TResiduo,L,Cam/NrPR),R),eliminaRepetidos(R,X).

caminhosOrdena_TResiduo_Prof_Lim(TResiduo,L,S):-todos_Caminhos_TResiduo_Prof_Lim(TResiduo,L,R),ordena(R,S).

%Devolve o caminho com mais pontos de recolha para um determinado residuo
bestCaminho_TResiduo_Prof_Lim(TResiduo,L,Best):-caminhosOrdena_TResiduo_Prof_Lim(TResiduo,L,S),primeiroElementoLista(S,Best).

%-------------------------------------------[Pesquisa não informada em largura]--------------------------------------------------
%LISTA DE TODOS OS CAMINHOS E ESCOLHA DO QUE TEM MAIS PONTOS DE RECOLHA
largura2(Inicio,Fim,TResiduo,Caminho/PR) :-
    numeroPR_R_Rua(Inicio,TResiduo,Estima),
    bfs2(TResiduo,[[Inicio]/Estima],Fim,CaminhoAux/PR),
    reverse(CaminhoAux,Caminho). 

bfs2(TResiduo,[[Fim|Caminho]/Pr|_],Fim, [Fim|Caminho]/Pr).
bfs2(TResiduo,[Caminho1|Caminhos], Fim, Caminho) :-
    expande(TResiduo,Caminho1, NovosCaminhos),
    append(Caminhos, NovosCaminhos, Caminhos1),
    bfs2(TResiduo,Caminhos1, Fim, Caminho).

expande(TResiduo,Caminho1, NovosCaminhos) :-
    findall(NovoCaminho,adjacenteLargura(TResiduo,Caminho1,NovoCaminho),NovosCaminhos),!.
expande(_,_,[]).

adjacenteLargura(TResiduo,[Nodo|Caminho]/PR1, [ProxNodo,Nodo|Caminho]/PRT):-
        adjacente(Nodo,ProxNodo),
        nao(membro(ProxNodo,Caminho)),
        numeroPR_R_Rua(ProxNodo,TResiduo,PRNext),
        PRT is PR1 + PRNext.

resolve_largura_2(TResiduo,R):-garagem(G),despejo(D),largura2(G,D,TResiduo,R).

%Processo para apresentar o melhor caminho
todos_Caminhos_TResiduo_Largura(TResiduo,X):-findall((Cam,NrPR),resolve_largura_2(TResiduo,Cam/NrPR),R),eliminaRepetidos(R,X).

caminhosOrdena_TResiduo_Largura(TResiduo,S):-todos_Caminhos_TResiduo_Largura(TResiduo,R),ordena(R,S).

%Develve o caminho com mais pontos de recolha para um determinado residuo
bestCaminho_TResiduo_Largura(TResiduo,Best):-caminhosOrdena_TResiduo_Largura(TResiduo,S),primeiroElementoLista(S,Best).


%-------------------------------------------[Pesquisa informada Gulosa]--------------------------------------------------
%CAMINHO COM MAIS PONTOS DE RECOLHA COM PESQUISA INFORMADA(MAIOR NUMERO DE PONTOS DE RECOLHA)----------------------------
%NOTA: ALGORITMO IMPLEMENTADO NÃO PERMITE A PASSAGEM PELAS MESMAS RUAS
%GULOSA

%Numero total de pontos de residuo de um tipo, dado um caminho  
quantosPR_Ruas(TResiduo,[],0).
quantosPR_Ruas(TResiduo,[X|XS],Qt):- numeroPR_R_Rua(X,TResiduo,Qt2),quantosPR_Ruas(TResiduo,XS,Qt1),Qt is Qt1 + Qt2.

%soma a estima de um caminho aos seus caminhos adjacentes
aumentaEstima(Cam,[],[]).
aumentaEstima(_/Estima1, [Nodos/Estima2|Tail],[Nodos/Estima3|EstimasAumentadas]):- Estima3 is Estima2 + Estima1, aumentaEstima(_/Estima1,Tail,EstimasAumentadas).


%TResiduo -> Tipo de Residuo
%Caminho/PR -> caminho até ao ponto de Residuo / numero de pontos de recolha total de um determinado residuo para o caminho
%GULOSA GARAGEM -> PONTO DE DESPEJO
resolve_gulosa_Ida(Nodo,TResiduo,Caminho/PR):-
        numeroPR_R_Rua(Nodo,TResiduo,Estima),
        agulosa_Ida(TResiduo,[[Nodo]/Estima], InvCaminho/PR), reverse(InvCaminho,Caminho).

agulosa_Ida(TResiduo,Caminhos,Caminho):- obtem_melhor_g_Ida(Caminhos, Caminho),
                             Caminho = [Nodo|_]/_,despejo(Nodo).

agulosa_Ida(TResiduo,Caminhos,SolucaoCaminho):-
        obtem_melhor_g_Ida(Caminhos,MelhorCaminho),
        remove(MelhorCaminho,Caminhos,OutrosCaminhos),
        expande_gulosa(TResiduo,MelhorCaminho,ExpCaminhos),
        aumentaEstima(MelhorCaminho,ExpCaminhos,AltCaminhos),
        append(OutrosCaminhos,AltCaminhos,NovoCaminhos),
        agulosa_Ida(TResiduo,NovoCaminhos,SolucaoCaminho).

obtem_melhor_g_Ida([Caminho],Caminho):-!.

obtem_melhor_g_Ida([Caminho1/Est1,_/Est2|Caminhos], MelhorCaminho):- 
        Est2 =< Est1,!,
        obtem_melhor_g_Ida([Caminho1/Est1|Caminhos], MelhorCaminho).

obtem_melhor_g_Ida([_|Caminhos], MelhorCaminho):-
        obtem_melhor_g_Ida(Caminhos,MelhorCaminho).

expande_gulosa(TResiduo,Caminho, ExpCaminhos):-
        findall(NovoCaminho,adjacenteGula(TResiduo,Caminho,NovoCaminho),ExpCaminhos).


adjacenteGula(TResiduo,[Nodo|Caminho]/_, [ProxNodo,Nodo|Caminho]/Estima):-
        adjacente(Nodo,ProxNodo),
        nao(membro(ProxNodo,Caminho)),
        numeroPR_R_Rua(ProxNodo,TResiduo,Estima).


resolve_Gulosa_2(TResiduo,Cam):-garagem(G),resolve_gulosa_Ida(G,TResiduo,Cam).

%Processo para descobrir o caminho com mais pontos de recolha
todos_Caminhos_TResiduo_Gulosa(TResiduo,X):-findall((Cam,NrPR),resolve_Gulosa_2(TResiduo,Cam/NrPR),R),eliminaRepetidos(R,X).

caminhos_Ordena_TResiduo_Gulosa(TResiduo,S):-todos_Caminhos_TResiduo_Gulosa(TResiduo,X),ordena(X,S).

bestCaminho_Residuo_Gulosa(TResiduo,Best):-caminhos_Ordena_TResiduo_Gulosa(TResiduo,S),primeiroElementoLista(S,Best).


% ------------------------------------------------------------------------------------------------------------------------------------------------
% ------------------------------------------------------------------------------------------------------------------------------------------------
% -----------------------------------------------------------------------------------------------------------------------------------------------
% ------------------------------------------------------------------------------------------------------------------------------------------------
% ------------------------------------------------------------------------------------------------------------------------------------------------
% -----------------------------------------------------------------------------------------------------------------------------------------------
% -------------------------------------------------------Alinea 4 -----------------------------------------------------------------------------------------
%Escolher o circuito mais rápido (usando o critério da distância);

%distancia entre duas coordenadas
distancia(N1,N2,N3,N4,R):- N is sqrt((N3-N1)^2+(N4-N2)^2),N=R.

%distancia entre duas ruas pelos seus IDs
distanciaEntreRuas_ID(IdRua1,IdRua2,Dist):-rua(IdRua1,Lat1,Long1,Res1,Qt1),rua(IdRua2,Lat2,Long2,Res2,Qt2),distancia(Lat1,Long1,Lat2,Long2,Dist).

%distancia entre duas ruas(nodos)
distanciaEntreRuas(rua(IdRua1,Lat1,Long1,Res1,Qt1),rua(IdRua2,Lat2,Long2,Res2,Qt2),R):-distancia(Lat1,Long1,Lat2,Long2,W), R is W.

%reflete um caminho do ponto inicial ao ponto de despejo para obter o caminho de ida e volta
caminhoIdaVolta(Caminho,IV):- reverse(Caminho,CR),removePrimeiro(CR,R),concat(Caminho,R,IV).


%-----------------------------[Em profundidade com destino já definido]--------------------------------------
resolve_pp_Distancia(Nodo,[Nodo|Caminho],Distancia,IdaVolta,DistanciaDupl):-
        profundidadeDistancia(Nodo,[Nodo],Caminho,Distancia),
        caminhoIdaVolta([Nodo|Caminho],IdaVolta),
        DistanciaDupl is Distancia + Distancia.

profundidadeDistancia(Nodo,_,[],0):-despejo(Nodo).
profundidadeDistancia(Nodo,Historico,[ProxNodo|Caminho],Distancia):-
        adjacenteDistancia(Nodo,ProxNodo,D1),        
        nao(membro(ProxNodo,Historico)),
        profundidadeDistancia(ProxNodo,[ProxNodo|Historico],Caminho,D2),
        Distancia is D1 + D2.

%Devolve a distancia entre dois nodos adjacentes
 adjacenteDistancia(Nodo,ProxNodo,Distancia):-
        adjacente(Nodo,ProxNodo),
        distanciaEntreRuas_ID(Nodo,ProxNodo,Distancia).

%calcula a distancia de uma aresta(Não é precisa para já)
calculaDistanciaAresta(aresta(X,Y),Dist):- 
        findall(rua(IdRua1,Lat1,Long1,Res1,Qt1),(rua(IdRua1,Lat1,Long1,Res1,Qt1), X=IdRua1 ),R),
        primeiroElementoLista(R,Rua1),
        findall(rua(IdRua1,Lat1,Long1,Res1,Qt1),(rua(IdRua1,Lat1,Long1,Res1,Qt1), Y=IdRua1 ),W),
        primeiroElementoLista(W,Rua2),
        distanciaEntreRuas(Rua1,Rua2,Dist).


minimo([(P,X)],(P,X)).
minimo([(Px,X)|L],(Py,Y)):- minimo(L,(Py,Y)), X>Y.
minimo([(Px,X)|L],(Px,X)):- minimo(L,(Py,Y)), X=<Y.

resolve_prof_Dist(CamIda,DistIda,CamIdaVolta,DistIdaVolta):-garagem(G),resolve_pp_Distancia(G,CamIda,DistIda,CamIdaVolta,DistIdaVolta).

melhor_prof_Distancia(Cam,Distancia):-findall((Iv, Dist2), resolve_prof_Dist(Ca, Dist, Iv, Dist2), L), minimo(L,(Cam,Distancia)).


%escolher caminho mais rápido [pesquisa informada] -> Gulosa---------------------------------------------------
resolve_gulosa(Nodo,Caminho/Dist):-
        agulosa([[Nodo]/0/0], InvCaminho/Dist/_), reverse(InvCaminho,Caminho).


agulosa(Caminhos, Caminho):- obtem_melhor_g(Caminhos, Caminho),
                             Caminho = [Nodo|_]/_/_,despejo(Nodo).

agulosa(Caminhos,SolucaoCaminho):-
        obtem_melhor_g(Caminhos,MelhorCaminho),
        seleciona(MelhorCaminho,Caminhos,OutrosCaminhos),
        expande_gulosa(MelhorCaminho,ExpCaminhos),
        append(OutrosCaminhos,ExpCaminhos,NovoCaminhos),
        agulosa(NovoCaminhos,SolucaoCaminho).

obtem_melhor_g([Caminho],Caminho):-!.

obtem_melhor_g([Caminho1/Dist1/Est1,_/Dist2/Est2|Caminhos], MelhorCaminho):- 
        Est1 =< Est2,!,
        obtem_melhor_g([Caminho1/Dist1/Est1|Caminhos], MelhorCaminho).

obtem_melhor_g([_|Caminhos], MelhorCaminho):-
        obtem_melhor_g(Caminhos,MelhorCaminho).

expande_gulosa(Caminho, ExpCaminhos):-
        findall(NovoCaminho,adjacente_Gulosa_Dist(Caminho,NovoCaminho), ExpCaminhos).


adjacente_Gulosa_Dist([Nodo|Caminho]/Dist/_, [ProxNodo,Nodo|Caminho]/NovaDist/Distancia):-
        adjacenteDistancia(Nodo,ProxNodo,Distancia), \+ member(ProxNodo,Caminho),
        NovaDist is Dist + Distancia.


resolve_gulosa_Dist(Cam,Distancia):-garagem(G),resolve_gulosa(G,Cam/Distancia).

resolve_gulosa_Dist_IV(Cam,Distancia):- resolve_gulosa_Dist(Cam1,Distancia1), caminhoIdaVolta(Cam1,Cam), Distancia is Distancia1 + Distancia1.

%Processo para descobrir o caminho mais rápido
todos_Caminhos_Gulosa_Dist(X):-findall((Cam,Dist),resolve_gulosa_Dist(Cam,Dist),R),eliminaRepetidos(R,X).

caminhosOrdenaGulosaDist(S):-todos_Caminhos_Gulosa_Dist(X),ordena(X,S).

bestCaminho_Gulosa_Dist(Best):-caminhosOrdenaGulosaDist(S),ultimoElementoLista(S,Best).


%escolher caminho(Garagem->Despejo) mais rápido [pesquisa informada] -> A Estrela (A*)---------------------------------------------------
estima(Nodo,Estima):-despejo(R),distanciaEntreRuas_ID(Nodo,R,Estima).

resolve_estrela_Dist(Nodo,Caminho/Distancia):-
        estima(Nodo,Estima),
        aestrela_Dist([[Nodo]/0/Estima], InvCaminho/Distancia/_), 
        reverse(InvCaminho,Caminho).


aestrela_Dist(Caminhos, Caminho):- obtem_melhor_g_estrela_Dist(Caminhos, Caminho),
                                   Caminho = [Nodo|_]/_/_,despejo(Nodo).

aestrela_Dist(Caminhos,SolucaoCaminho):-
        obtem_melhor_g_estrela_Dist(Caminhos,MelhorCaminho),
        seleciona(MelhorCaminho,Caminhos,OutrosCaminhos),
        expande_estrela_Dist(MelhorCaminho,ExpCaminhos),
        append(OutrosCaminhos,ExpCaminhos,NovoCaminhos),
        aestrela_Dist(NovoCaminhos,SolucaoCaminho).

obtem_melhor_g_estrela_Dist([Caminho],Caminho):-!.

obtem_melhor_g_estrela_Dist([Caminho1/Distancia1/Est1,_/Distancia2/Est2|Caminhos], MelhorCaminho):- 
        Est1 + Distancia1 =< Est2 + Distancia2,!,
        obtem_melhor_g_estrela_Dist([Caminho1/Distancia1/Est1|Caminhos], MelhorCaminho).

obtem_melhor_g_estrela_Dist([_|Caminhos], MelhorCaminho):-
        obtem_melhor_g_estrela_Dist(Caminhos,MelhorCaminho).

expande_estrela_Dist(Caminho, ExpCaminhos):-
        findall(NovoCaminho,adjacenteEstrela_Dist(Caminho,NovoCaminho), ExpCaminhos).

adjacenteEstrela_Dist([Nodo|Caminho]/Distancia/_, [ProxNodo,Nodo|Caminho]/NovaDistancia/Est):-
        adjacenteDistancia(Nodo,ProxNodo,PassoDistancia), \+ member(ProxNodo,Caminho),
        NovaDistancia is Distancia + PassoDistancia,
        estima(ProxNodo,Est).

resolveEstrela(Cam,Dist):- garagem(G),resolve_estrela_Dist(G,Cam/Dist),!. %Como é ideal já dá o melhor caminho

melhorIdaVolta_Estrela(Cam,Dist):- resolveEstrela(Cam1,Dist1), caminhoIdaVolta(Cam1,Cam), Dist is Dist1 + Dist1.

% ------------------------------------------------------------------------------------------------------------------------------------------------
% ------------------------------------------------------------------------------------------------------------------------------------------------
% -----------------------------------------------------------------------------------------------------------------------------------------------
% ------------------------------------------------------------------------------------------------------------------------------------------------
% ------------------------------------------------------------------------------------------------------------------------------------------------
% -----------------------------------------------------------------------------------------------------------------------------------------------
% -------------------------------------------------------[Alinea 3]--------------------------------------------------------------------------------
% Comparar circuitos de recolha tendo em conta os indicadores de produtividade;
     %-> A distância média percorrida entre pontos de recolha.



%[profundidade]---------------------------------------------------------------------------------------------------------------------------------
resolve_Profundidade_3(CamIdaVolta,DistIdaVolta,Media):-
        resolve_prof_Dist(CamIda,DistIda,CamIdaVolta,DistIdaVolta),length(CamIdaVolta,NrP),Media is DistIdaVolta/(NrP-1). 

melhorProfundidadeMedia(Cam,Dist,Media):- findall(((Iv,Dist),Media),resolve_Profundidade_3(Iv,Dist,Media),L),ordena(L,S),primeiroElementoLista(S,((Cam,Dist),Media)).




%[gulosa]-----------------------------------------------------------------------------------------------------------------------------------------

resolve_Gulosa_3(IV,Distancia,Media):-
        resolve_gulosa_Dist(Cam,Dist),
        caminhoIdaVolta(Cam,IV),
        length(IV,NrP),
        Distancia is Dist + Dist,
        Media is Distancia/(NrP-1).

melhorGulosa3(Cam,Distancia,Media):- findall(((Cam,Dist),Media),resolve_Gulosa_3(Cam,D,Media),L),ordena(L,S),primeiroElementoLista(S,((Cam,Distancia),Media)).


%[A*]-----------------------------------------------------------------------------------------------------------------------------------------

resolve_Estrela_3(IV,Distancia,Media):-
        resolveEstrela(Cam,Dist),
        caminhoIdaVolta(Cam,IV),
        length(IV,NrNodos),
        Distancia is Dist + Dist,
        Media is Distancia/(NrNodos-1).


% ------------------------------------------------------------------------------------------------------------------------------------------------
% ------------------------------------------------------------------------------------------------------------------------------------------------
% -----------------------------------------------------------------------------------------------------------------------------------------------
% ------------------------------------------------------------------------------------------------------------------------------------------------
% ------------------------------------------------------------------------------------------------------------------------------------------------
% -----------------------------------------------------------------------------------------------------------------------------------------------
% -------------------------------------------------------Alinea 5 --------------------------------------------------------------------------------
% Escolher o circuito mais eficiente (usando um critério de eficiência à escolha)



%Devolve a quantidade de lixo a recolher numa rua dado o seu ID
quantoLixo_IdRua(IdRua,Qt):-rua(IdRua,Lat,Long,Res,Qt).

quantoLixo_Ruas([],0).
quantoLixo_Ruas([X|XS],Qt):-quantoLixo_Ruas(XS,Qt1),quantoLixo_IdRua(X,Qt2),Qt is Qt1 + Qt2.


%-------------------------------------------[Pesquisa não informada em largura]------------------------------------------------------------------
%LISTA DE TODOS OS CAMINHOS E ESCOLHA DO QUE RECOLHE MAIS QUANTIDADE LIXO (EM Menos nós)
largura5(Inicio,Fim,Caminho/Qt) :-
    quantoLixo_IdRua(Inicio,Estima), 
    bfs5([[Inicio]/Estima],Fim,CaminhoAux/Qt),
    reverse(CaminhoAux,Caminho). 

bfs5([[Fim|Caminho]/Qt|_],Fim, [Fim|Caminho]/Qt).
bfs5([Caminho1|Caminhos], Fim, Caminho) :-
    expande_5(Caminho1, NovosCaminhos),
    append(Caminhos, NovosCaminhos, Caminhos1),
    bfs5(Caminhos1, Fim, Caminho).

expande_5(Caminho1, NovosCaminhos) :-
    findall(NovoCaminho,adjacenteLargura_5(Caminho1,NovoCaminho),NovosCaminhos),!.
expande_5(_,_,[]).

adjacenteLargura_5([Nodo|Caminho]/Qt1, [ProxNodo,Nodo|Caminho]/Qt):-
        adjacente(Nodo,ProxNodo),
        nao(membro(ProxNodo,Caminho)),
        quantoLixo_IdRua(ProxNodo,QtNext),
        Qt is Qt1 + QtNext.


resolve_largura_5(R):-garagem(G),despejo(D),largura5(G,D,R).

%MELHOR CAMINHO COSNIDERENADO MAIOR QUANTIDADE RECOLHIDA NO TOTAL
%Processo para apresentar o melhor caminho
todos_Caminhos_Qt_Largura(X):-findall((Cam,Qt),resolve_largura_5(Cam/Qt),R),eliminaRepetidos(R,X).

caminhosOrdena_Qt_Largura(S):-todos_Caminhos_Qt_Largura(R),ordena(R,S).

%Develve o caminho com mais quantidade recolhida
bestCaminho_Qt_Largura(Best):-caminhosOrdena_Qt_Largura(S),primeiroElementoLista(S,Best).



%MELHOR CAMINHO CONSIDERANDO A QUANTIDADE RECOLHIDA MÉDIA POR NODO
%Processo para apresentar o melhor caminho
todos_Caminhos_Qt_Largura_Media(X):-findall((Cam,Media),(resolve_largura_5(Cam/Qt),length(Cam,NrNodos),Media is Qt/NrNodos),R),eliminaRepetidos(R,X).

caminhosOrdena_Qt_Largura_Media(S):-todos_Caminhos_Qt_Largura_Media(R),ordena(R,S).

%Develve o caminho com mais quantidade recolhida media por cada nó
bestCaminho_Qt_Largura_Media(Best):-caminhosOrdena_Qt_Largura_Media(S),primeiroElementoLista(S,Best).


%-------------------------------[pesquisa em profundidade limitada]--------------------------------------------------------------------------
resolve_prof_lim_Qt(Nodo,Caminho/Qt,L) :- profundidade_limitada_Qt([],Nodo,InvCaminho/Qt,L),reverse(InvCaminho,Caminho).

profundidade_limitada_Qt(Caminho,Nodo,[Nodo|Caminho]/Qt,_):-despejo(Nodo),quantoLixo_IdRua(Nodo,Qt).
profundidade_limitada_Qt(Caminho,Nodo,S/Qt,L) :-
                quantoLixo_IdRua(Nodo,Qt1),
                L>0, adjacente(Nodo,NodoL), 
                \+ member(NodoL,Caminho), 
                L1 is L-1,
                profundidade_limitada_Qt([Nodo|Caminho],NodoL,S/Qt2,L1),
                Qt is Qt1+Qt2.

resolve_prof_lim_5(L,Cam):-garagem(G),despejo(D),resolve_prof_lim_Qt(G,Cam,L).

%MELHOR CAMINHO COSNIDERENADO MAIOR QUANTIDADE RECOLHIDA NO TOTAL
%Processo para apresentar o melhor caminho
todos_Caminhos_Qt_Prof_Lim(L,X):-findall((Cam,Qt),resolve_prof_lim_5(L,Cam/Qt),R),eliminaRepetidos(R,X).

caminhosOrdena_Qt_Prof_Lim(L,S):-todos_Caminhos_Qt_Prof_Lim(L,R),ordena(R,S).

%Devolve o caminho com mais quantidade recolhida
bestCaminho_Qt_Prof_Lim(L,Best):-caminhosOrdena_Qt_Prof_Lim(L,S),primeiroElementoLista(S,Best).


%MELHOR CAMINHO CONSIDERANDO A QUANTIDADE RECOLHIDA MÉDIA POR NODO
%Processo para apresentar o melhor caminho
todos_Caminhos_Qt_Prof_Lim_Media(L,X):-findall((Cam,Media),(resolve_prof_lim_5(L,Cam/Qt),length(Cam,NrNodos),Media is Qt/NrNodos),R),eliminaRepetidos(R,X).

caminhosOrdena_Qt_Prof_Lim_Media(L,S):-todos_Caminhos_Qt_Prof_Lim_Media(L,R),ordena(R,S).

%Devolve o caminho com mais quantidade recolhida media por rua
bestCaminho_Qt_Prof_Lim_Media(L,Best):-caminhosOrdena_Qt_Prof_Lim_Media(L,S),primeiroElementoLista(S,Best).



%CAMINHO COM MAIS QUANTIDADE RECOLHIDA COM PESQUISA INFORMADA------------------------------------------------------------------------------------------
%GULOSA
resolve_gulosa_Qt(Nodo,Caminho/Qt):-
        quantoLixo_IdRua(Nodo,Estima),
        agulosa_Qt([[Nodo]/Estima], InvCaminho/_), reverse(InvCaminho,Caminho),
        quantoLixo_Ruas(Caminho,Qt).


agulosa_Qt(Caminhos, Caminho):- obtem_melhor_g_Qt(Caminhos, Caminho),
                             Caminho = [Nodo|_]/_,despejo(Nodo).

agulosa_Qt(Caminhos,SolucaoCaminho):-
        obtem_melhor_g_Qt(Caminhos,MelhorCaminho),
        seleciona(MelhorCaminho,Caminhos,OutrosCaminhos),
        expande_gulosa_Qt(MelhorCaminho,ExpCaminhos),
        aumentaEstima(MelhorCaminho,ExpCaminhos,AltCaminhos),
        append(OutrosCaminhos,AltCaminhos,NovoCaminhos),
        agulosa_Qt(NovoCaminhos,SolucaoCaminho).

obtem_melhor_g_Qt([Caminho],Caminho):-!.

obtem_melhor_g_Qt([Caminho1/Est1,_/Est2|Caminhos], MelhorCaminho):- 
        Est1 >= Est2,!,
        obtem_melhor_g_Qt([Caminho1/Est1|Caminhos], MelhorCaminho).

obtem_melhor_g_Qt([_|Caminhos], MelhorCaminho):-
        obtem_melhor_g_Qt(Caminhos,MelhorCaminho).

expande_gulosa_Qt(Caminho, ExpCaminhos):- findall(NovoCaminho,adjacente_Qt(Caminho,NovoCaminho), ExpCaminhos).
        /* findall(NovoCaminho,adjacente_Qt(Caminho,NovoCaminho), ExpCaminhos),escreverT(ExpCaminhos). */


adjacente_Qt([Nodo|Caminho]/_, [ProxNodo,Nodo|Caminho]/Est):-
        adjacente(Nodo, ProxNodo), \+ member(ProxNodo,Caminho),
        quantoLixo_IdRua(ProxNodo,Est).


resolve_gul_Qt(Caminho,Qt):-garagem(G),resolve_gulosa_Qt(G,Caminho/Qt).


%MELHOR CAMINHO CONSIDERANDO MAIOR QUANTIDADE RECOLHIDA NO TOTAL
%Processo para descobrir o caminho com mais Quantidade recolhida
todos_Caminhos_Qt_Gulosa(X):-findall((Cam,Qt),resolve_gul_Qt(Cam,Qt),R),eliminaRepetidos(R,X).
%Talvez neste pudesse descartar aqueles que tivessem um quantidade recolhida maior que 15000

caminhosOrdenaGulosa_Qt(S):-todos_Caminhos_Qt_Gulosa(X),ordena(X,S).

bestCaminho_Qt_Gulosa(Best):-caminhosOrdenaGulosa_Qt(S),primeiroElementoLista(S,Best).



%MELHOR CAMINHO CONSIDERANDO A QUANTIDADE RECOLHIDA MÉDIA POR NODO
todos_Caminhos_Qt_Gulosa_Media(X):-findall((Cam,Media),(resolve_gul_Qt(Cam,Qt),length(Cam,NrNodos),Media is Qt/NrNodos),R),eliminaRepetidos(R,X).
%Talvez neste pudesse descartar aqueles que tivessem um quantidade recolhida maior que 15000

caminhosOrdenaGulosa_Qt_Media(S):-todos_Caminhos_Qt_Gulosa_Media(X),ordena(X,S).

bestCaminho_Qt_Gulosa_Media(Best):-caminhosOrdenaGulosa_Qt_Media(S),primeiroElementoLista(S,Best).




% ------------------------------------------------------------------------------------------------------------------------------------------------
% ------------------------------------------------------------------------------------------------------------------------------------------------
% -----------------------------------------------------------------------------------------------------------------------------------------------
% ------------------------------------------------------------------------------------------------------------------------------------------------
% ------------------------------------------------------------------------------------------------------------------------------------------------
% -----------------------------------------------------------------------------------------------------------------------------------------------
% -------------------------------------------------------[Extra-Alineas] -------------------------------------------------------------------------

%escolher caminho(Despejo->Garagem) mais rápido [pesquisa informada] -> A Estrela (A*)---------------------------------------------------
estimaV(Nodo,Estima):-garagem(G),distanciaEntreRuas_ID(Nodo,G,Estima).

resolve_estrela_DistV(Nodo,Caminho/Distancia):-
        estimaV(Nodo,Estima),
        aestrela_DistV([[Nodo]/0/Estima], InvCaminho/Distancia/_), 
        reverse(InvCaminho,Caminho).


aestrela_DistV(Caminhos, Caminho):- obtem_melhor_g_estrela_DistV(Caminhos, Caminho),
                                   Caminho = [Nodo|_]/_/_,garagem(Nodo).

aestrela_DistV(Caminhos,SolucaoCaminho):-
        obtem_melhor_g_estrela_DistV(Caminhos,MelhorCaminho),
        seleciona(MelhorCaminho,Caminhos,OutrosCaminhos),
        expande_estrela_DistV(MelhorCaminho,ExpCaminhos),
        append(OutrosCaminhos,ExpCaminhos,NovoCaminhos),
        aestrela_DistV(NovoCaminhos,SolucaoCaminho).

obtem_melhor_g_estrela_DistV([Caminho],Caminho):-!.

obtem_melhor_g_estrela_DistV([Caminho1/Distancia1/Est1,_/Distancia2/Est2|Caminhos], MelhorCaminho):- 
        Est1 + Distancia1 =< Est2 + Distancia2,!,
        obtem_melhor_g_estrela_DistV([Caminho1/Distancia1/Est1|Caminhos], MelhorCaminho).

obtem_melhor_g_estrela_DistV([_|Caminhos], MelhorCaminho):-
        obtem_melhor_g_estrela_DistV(Caminhos,MelhorCaminho).

expande_estrela_DistV(Caminho, ExpCaminhos):-
        findall(NovoCaminho,adjacenteEstrela_DistV(Caminho,NovoCaminho), ExpCaminhos).

adjacenteEstrela_DistV([Nodo|Caminho]/Distancia/_, [ProxNodo,Nodo|Caminho]/NovaDistancia/Est):-
        adjacenteDistancia(Nodo,ProxNodo,PassoDistancia), \+ member(ProxNodo,Caminho),
        NovaDistancia is Distancia + PassoDistancia,
        estimaV(ProxNodo,Est).

resolveEstrelaV(Cam,Dist):- despejo(D),resolve_estrela_DistV(D,Cam/Dist),!. %Como é ideal já dá o melhor caminho

resolveEstrelaV2(Nodo,Cam,Dist):- resolve_estrela_DistV(Nodo,Cam/Dist),!.

%DADO UM QQ CAMINHO COMO ARGUMENTO DESDE A GARAGEM PARA O PONTO DE DESPEJO, RETORNA TODO O MELHOR CAMINHO DE VOLTA À GARAGEM TENDO EM CONTA A DISTANCIA

volta([],[]).
volta(Caminho,CaminhoVolta/Dist,CaminhoTotal):-
                ultimoElementoLista(Caminho,Nodo),
                resolveEstrelaV2(Nodo,CaminhoVolta,Dist),
                removePrimeiro(CaminhoVolta,CV),
                concat(Caminho,CV,CaminhoTotal).
