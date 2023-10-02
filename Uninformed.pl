% we need to determine all possible moves
%create a rule that create list of lists with # of rows R and # of columns C 
%and finally it returns the state space
%%don't forget to add input validation

%createList(R,C,List,StateSpace):-

%add the bomb while making the list version

%check on the range of the bomb
	


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



%%moves

%searchforzero([Row|Rem],RowNumber,Result):-
%	nth1(EmptyTileIndex,Row,0),
%	Result is [RowNumber

searchforzero(DDList,R,C,Element):-
	nth1(R,DDList,Row),
	nth1(C,Row,Element).

put(DDList,[R,C],Result):-
	nth1(R,DDList,Row),
	NC is C+1,
	nth1(NC,Row,0),
	Result = [R,C,R,NC,0].
%% add function find if there is vertical place avaiable around this zero and call it put vertical
put(DDList,[R,C],Result):-
	transpose_list_of_lists(DDList, Transposed),
	nth1(C,Transposed,Col),
	NR is R+1,
	nth1(NR,Col,0),
	Result =[R,C,NR,C,1].


%%revise on this function in prolog
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

% replace_element_at_position(+List, +Index, +NewElement, -NewList)
replace_element_at_position(List, Index, NewElement, NewList) :-
    nth1(Index, List, _, Rest),
    nth1(Index, NewList, NewElement, Rest).


addDomino(DDList,Result):-
	searchforzero(DDList,R,C,0),
	put(DDList,[R,C],Position),
	occupyDomino(DDList,Position,Result).

searchh([],Closed,GoalsList,GoalsList):-
	write("this branch ended!"),nl,!.

searchh(Open,Closed,GoalsList,Result):-
	getState(Open,CurrentNode,NOpen),
	getAllValidChildren(CurrentNode,Open,Closed,Children),
	getAllNonValidChildren(CurrentNode,Childs),
	append(Children,NOpen,NEWOpen),
	append(Closed,[CurrentNode],NClosed),
	%(Childs=[]->(append(GoalsList,[CurrentNode],NGoalsList));true),
	(Childs=[]->((ThisNode=[CurrentNode]),nl);ThisNode=[]),
	append(GoalsList,ThisNode,NGoalsList),
	
	searchh(NEWOpen,NClosed,NGoalsList,Result).
	
	
getState([CurrentNode|Rest],CurrentNode,Rest).

getAllValidChildren(CurrentNode, Open, Closed, Children):-
	findall(NextState, getNextState(CurrentNode, Open, Closed, NextState), Children).

getNextState(CurrentNode,Open,Closed,NextState):-
	addDomino(CurrentNode,NextState),
	not(member(NextState,Open)),
	not(member(NextState,Closed)).

getAllNonValidChildren(CurrentNode,Childs):-
	findall(Next,(getNextState(CurrentNode,Next)),Childs).
getNextState(CurrentNode,NextState):-
	addDomino(CurrentNode,NextState).

%to test it algorithm(3,3,[1,3,2,1],GoalsList).
algorithm(R,C,[R1,C1,R2,C2],GoalsList):-
	make2dlist(R,C,[R1,C1,R2,C2],Result),
	searchh([Result],[],[],GoalsList).