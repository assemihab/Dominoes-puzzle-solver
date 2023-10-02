# Dominoes Puzzle Solver
 in this project we aim to find all possible cases where we can
 place the maximum number of dominos in given board with dimensions given from the user using optimal
 and non optimal algorithms 
 we used uninformed search for the nonoptimal Dominoes Puzzle
 and informed search for the optimal dominoes puzzle Solver

##Requirements
*Prolog version 8.4.2
*Pyswip
*numpy
*tkiter
*PIL

example for input

![image](images/inputs.jpg)



## uninformed search 

here we try all the different combination to fill the 2d space with dominoes regradless of the optimality of the dominoes placements

the only requirment of this problem is that there is no more spaces we could fill 

example:

![image](images/uninformedoutput.JPG)


## informed search

here we try all the different combination to fill the 2d space with the maximum number of dominoes that could be place on the board using A* search


### heruistic 

the area of contiguous batch/2 is a good dominant heurstic

example on the informed search:

![image](images/informedoutput.JPG)