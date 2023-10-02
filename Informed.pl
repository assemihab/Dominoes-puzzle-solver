searchforzero(DDList,R,C,Element):-
	nth1(R,DDList,Row),
	nth1(C,Row,Element).


put(DDList,[R,C],Result):-
	nth1(R,DDList,Row),
	NC is C+1,
	nth1(NC,Row,0),
	Result = [R,C,R,NC,0].
	
	
	
put(DDList,[R,C],Result):-
	transpose_list_of_lists(DDList, Transposed),
	nth1(C,Transposed,Col),
	NR is R+1,
	nth1(NR,Col,0),
	Result =[R,C,NR,C,1].

transpose_list_of_lists([], []).
transpose_list_of_lists([[]|_], []).
transpose_list_of_lists(ListOfLists, [TransposedRow|TransposedRest]) :-
    transpose_list_of_lists_1(ListOfLists, TransposedRow, NewListOfLists),
    transpose_list_of_lists(NewListOfLists, TransposedRest).

transpose_list_of_lists_1([], [], []).
transpose_list_of_lists_1([[X|Xs]|Rest], [X|TransposedRest], [Xs|NewListOfListsRest]) :-
    transpose_list_of_lists_1(Rest, TransposedRest, NewListOfListsRest).
	
occupyDomino(DDList,[R1,C1,R2,C2,0],Result):-
	change_value_at_position(DDList,R1,C1,2,NewDDlist),
	change_value_at_position(NewDDlist,R2,C2,3,Result).


occupyDomino(DDList,[R1,C1,R2,C2,1],Result):-
	change_value_at_position(DDList,R1,C1,4,NewDDlist),
	change_value_at_position(NewDDlist,R2,C2,5,Result).

change_value_at_position(ListOfLists, RowIndex, ColumnIndex, NewValue, NewListOfLists) :-
    nth1(RowIndex, ListOfLists, Row),
    nth1(ColumnIndex, Row, OldValue),
    replace_element_at_position(Row, ColumnIndex, NewValue, NewRow),
    replace_element_at_position(ListOfLists, RowIndex, NewRow, NewListOfLists).

replace_element_at_position(List, Index, NewElement, NewList) :-
    nth1(Index, List, _, Rest),
    nth1(Index, NewList, NewElement, Rest).


addDomino(DDList,Result):-
	searchforzero(DDList,R,C,0),
	put(DDList,[R,C],Position),
	occupyDomino(DDList,Position,Result).
	
	

getContigLengths(List, RowLen, ContigLengths) :-
    heuristic(List, [], [], RowLen, [], [], Result),
    pathLengths(Result, ContigLengths).

pathLengths([],0):-!.
pathLengths([[]],0):-!.
pathLengths(DDList, X) :-
	maplist(length, DDList, Lengths),
	maplist(floor, Lengths, HalfLengths),
	sum_list(HalfLengths, X).

floor(X, Y):- Y is X // 2 .


%The heuristics
findEmptyCell(DDlist,Closed,Empty):-
	nth1(C,DDlist,[0,C]),
	Empty=[0,C].
	%not(member(Empty,Closed))

%test heuristic "heuristic([[0,1],[1,2],[0,3],[0,4],[1,5],[0,6]],[],[],3,[],[],Result)."

heuristic(DDlist,[],Closed,RowLen,Container,ContPatches,Result):-
	(Container=[]->ThisNode=[];ThisNode=[Container]),
	append(ContPatches,ThisNode,NContPatches),
	findEmptyCell(DDlist,Closed,Dlist),
	not(member(Dlist,Closed)),!,
	heuristic(DDlist,[Dlist],Closed,RowLen,[],NContPatches,Result).

heuristic(DDlist,[],Closed,RowLen,Container,ContPatches,NContPatches):-
	append(ContPatches,[Container],NContPatches),!.

heuristic(DDlist,[CurrentNode|Rest],Closed,RowLen,Container,ContPatches,Result):-
	findValidChildren(CurrentNode,RowLen,DDlist,Rest,Closed,Children),
	append(Rest,Children,NOpen),
	append(Closed,[CurrentNode],NClosed),
	append(Container,[CurrentNode],NContainer),
	heuristic(DDlist,NOpen,NClosed,RowLen,NContainer,ContPatches,Result).
	
	
	
findValidChildren(CurrentNode,RowLen,DDlist,Open,Closed,Children):-
	findall(Next,findChild(CurrentNode,RowLen,DDlist,Open,Closed,Next),Children).
	


%[V,P] represents the current node
%v stands for the value of the node(empty or not)
%p stands for the position of the node
%to test write this query" findChild([0,1],3,[[0,1],[1,2],[0,3],[0,4],[0,5],[0,6]],[[0,4]],[],Child)."


findChild([_,P],RowLen,DDlist,Open,Closed,Child):-
	Y is P mod RowLen,
	Y\=0,
	NP is P+1,
	nth1(NP,DDlist,[0,NP]),
	Child =[0,NP],
	not(member(Child,Closed)),
	not(member(Child,Open)).
findChild([_,P],RowLen,DDlist,Open,Closed,Child):-
	NP is P+RowLen,
	nth1(NP,DDlist,[0,NP]),
	Child=[0,NP],
	not(member(Child,Closed)),
	not(member(Child,Open)).
findChild([_,P],RowLen,DDlist,Open,Closed,Child):-
	NP is P-RowLen,
	nth1(NP,DDlist,[0,NP]),
	Child=[0,NP],
	not(member(Child,Closed)),
	not(member(Child,Open)).
findChild([_,P],RowLen,DDlist,Open,Closed,Child):-
	X is P+RowLen,
	Y is X mod RowLen,
	Y\=1,
	NP is P-1,
	nth1(NP,DDlist,[0,NP]),
	Child=[0,NP],
	not(member(Child,Closed)),
	not(member(Child,Open)).
	


findMax([X],X):-!.

findMax([CurrentNode|Rest],Best):-
	findMax(Rest,Temp),
	maX(CurrentNode,Temp,Best).
maX([State,ParentDoms,NumberOfDominos,H,FofX],[_,_,_,_,FofX1],[State,ParentDoms,NumberOfDominos,H,FofX]):-
	FofX>FofX1,!.
maX([_,_,_,_,_],[State,ParentDoms,NumberOfDominos,H,FofX],[State,ParentDoms,NumberOfDominos,H,FofX]).
	
	
getAllValidChildren(CurrentNode, Open, Closed, Children):-
	findall(NextStates, getNextState(CurrentNode, Open, Closed, NextStates),Children).
	


getNextState([CurrentState,ParentDoms,NumberOfDominos,H,FofX],Open,Closed,NextState):-
	addDomino(CurrentState,ResState),
	flattenArray(ResState, 0, [], 1, FlatList,RowLen),
	getContigLengths(FlatList,RowLen, HeuristicValue),
	Numdoms is NumberOfDominos+1,
	NFofX is Numdoms+HeuristicValue,
	NextState = [ResState,NumberOfDominos,Numdoms,HeuristicValue,NFofX],
	not(member(NextState,Open)),
	not(member(NextState,Closed)).



%flattenArray([Head|Tail], RowNum, MiddleList, Accumulator, ResArray).
%%Test with flattenArray([[2,3,1],[1,2,3],[2,3,0]],0, [], 1, ResArray).
flattenArray([], _, ResArray, _, ResArray).

flattenArray([], _, ResArray, _, ResArray,RowNum).

flattenArray([Head|Tail], 0, MiddleList, Accumulator, ResArray,RowNum) :-
    length(Head,RowNum),
	flattenList(Head, MiddleList, Accumulator, NewResList),
    NewAccumulator is Accumulator + RowNum,
    flattenArray(Tail, RowNum, NewResList, NewAccumulator, ResArray,RowNum),!.
flattenArray([Head|Tail], RowNum, MiddleList, Accumulator, ResArray,RowNum) :-
	flattenList(Head, MiddleList, Accumulator, NewResList),
    NewAccumulator is Accumulator + RowNum,
    flattenArray(Tail, RowNum, NewResList, NewAccumulator, ResArray,RowNum).

flattenList([], ResList, _, ResList).

flattenList([Head|Tail], MiddleList, Accumulator, ResList) :-
    append(MiddleList, [[Head, Accumulator]], PositionTuple),
    NewAccumulator is Accumulator + 1,
    flattenList(Tail, PositionTuple, NewAccumulator, ResList).
	
%%remove the NNOpen
% to test addtoGoals([[[0,1,1,0],[1,1,1,1]],0,0,3,3],[],Children).
addtoGoals(BestNode,[],NGoals):-
	[State,_,_,_,Max]=BestNode,
	getAllNonValidChildren(BestNode,Children),
	(Children=[]->ThisNode=BestNode;ThisNode=[]),
	(ThisNode=[]->TThisStateNode=[],TThisMaxNode=[];TThisStateNode=[[State]],TThisMaxNode=[Max]),
	append(TThisStateNode,TThisMaxNode,NGoals).

addtoGoals([State,_,Numberofdom,_,MMax],Goals,NGoals):-
	[States,Max]=Goals,
	
	(Numberofdom=Max->ThisNode=State;ThisNode=[]),
	(not(member(State,States))->TThisNode=State;TThisNode=[]),
	(ThisNode=TThisNode->TTThisNode=[ThisNode];TTThisNode=[]),
	append(States,TTThisNode,NStates),
	NGoals=[NStates,Max].
	
getAllNonValidChildren(CurrentNode,Childs):-
	findall(Next,getNextState(CurrentNode,Next),Childs).
getNextState([State|_],NextState):-
	addDomino(State,NextState).
	

	
	
%test case search([[[[0,0]],0,0,3,3]],[],[],Result).
%another test case search([[[[0,0,1],[1,0,0],[0,0,0]],0,0,3,3]],[],[],Result).

search([],Closed,[GoalsLists,GoalsMax],GoalsLists):-!,
	writeln('I am done').
%%remove from open all the G(n) less than the max
search(Open, Closed,Goals,Result):-
	%%modify the getBestState predicate
	getBestState(Open, BestNode, Rest),
	%%modify getall valid children predicate
	getAllValidChildren(BestNode, Rest, Closed, NextStates),
	append(Rest, NextStates, NOpen), 
	addtoGoals(BestNode,Goals,NGoals),
	append(Closed, [BestNode], NewClosed),
	search(NOpen, NewClosed, NGoals, Result).

getBestState([State],State,[]):-!.
getBestState(Open, BestNode, Rest):-
	findMax(Open,BestNode),
	delete(Open,BestNode,Rest).
	


make1dlist(R,C,Result):-
	addcolumn(R,C,[],Result).

addcolumn(R,0,List,List):-!.
addcolumn(R,C,List,NewList):-
		
		append(List,[0],Appended),
		NC is C-1,
		addcolumn(R,NC,Appended,NewList).



addrow(0,_,DDList,DDList):-!.
addrow(R,C,DDList,Result):-
	make1dlist(R,C,Row),
	append(DDList,[Row],NewDDlist),
	NR is R-1,
	addrow(NR,C,NewDDlist,Result).
	
make2dlist(R,C,[R1,C1,R2,C2],Result):-

	addrow(R,C,[],DDList),
	change_value_at_position(DDList,R1,C1,1,NewDDlist),
	change_value_at_position(NewDDlist,R2,C2,1,Result).


%search([[[[0,0]],0,0,3,3]],[],[],Result).
%[State,ParentDoms,NumberOfDominos,H,FofX]
%% to test the function write this query informedAlgorithm(3,3,[1,3,2,1],Result).
algorithm(R,C,[R1,C1,R2,C2],GoalsLists):-
	make2dlist(R,C,[R1,C1,R2,C2],Result),
	flattenArray(Result, 0, [], 1, FlatList,RowLen),
	getContigLengths(FlatList,RowLen, HeuristicValue),
	InitialOpenList = [[Result,0,0,HeuristicValue,HeuristicValue]],
	search(InitialOpenList,[],[],GoalsLists).