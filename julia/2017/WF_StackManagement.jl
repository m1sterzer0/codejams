using Printf

######################################################################################################
### We need a TON of observations to make this tractible (many of which I couldn't come up
### with on my own, even outside the time pressure of contest conditions)
###
### a) First, we ASSUME that sum(P_i*C_i) is limited to something reasonable (like 10M).  A 1GB
###    limit isn't tractible if we need to read 60k * 50k * 2 = 6B Integers.  For reference,
###    the large input in the contest had about 3.5M cards.
###
### Easy observations (these I came up with on my own)
### --------------------------------------------------
### b) If we have fewer suits than stacks, then by the pigeonhole principle, we will always have an
###    available move.  Thus, if we have fewer suits than stacks, we will win.
###
### c) Similarly, if we have more suits than stacks, than at best we end up stuck with one
###    of each suit at the end which is not good enough.  Thus, if we have fewer suits than stacks,
###    we will lose.
###
### For the rest of this, let's assume that we have the same number of suits as stacks, and lets
### refer to the maximum card of a suit as the KING and the next highest card (if it exists) as
### the QUEEN.  (The codejam solutions use KING/ACE instead of QUEEN/KING), but given the solitaire
### history in the US, the ACE is usually the starter card/lowest value card in those games, and
### the KING completes the stack, so I actually used the QUEENs and KINGs from a real deck of cards
### to explore the space.
###
### d) Once we expose a suit, it remains for the duration of the game, and the exposed card of
###    that suit can only increase in value as the game progresses.
###
### e) Note that the winning condition involves having each of the suits exposed.  This means that
###    the last move must expose a suit for the first time.  This means that a necessary condition
###    for the game to end is that there must be a "singleton" suit present with it's KING on the
###    bottom of some stack.
###
###
### Intermediate observations (these I came up with on my own, but after thinking on the problem for a night)
### -----------------------------------------------------------------------------------------------------------
###
### f) Restrict ourself to a 52-card deck of cards for simplicity Let's say we have our lone singleton KING on
###   the bottom of some stack.  One way to win is if there is a KING of a different suit above the singleton.
###   If this happens, we will always have a move (3 suits, 4 places) until we get down to the KING + 2
###   remaining kings + 1 EMPTY stack.  Then we just move the king to the empty stack, play out the remainder
###   of our stack (with the 3 KINGs exposed, we can always discard off of our singleton KING stack, and end
###   up exposing the singleton KING at the end.
###
### g) This isn't the only way we can win.  Let's say that the king of spades has our singleton king.  Consider
###    this Case (where "STUFF" contains no KINGs)
### 
###    QUEEN CLUBS   KING DIAMONDS
###    STUFF         STUFF
###    KING SPADES   KING CLUBS       MISC CARDS   MISC CARDS
###
###    Again, with the 3 suits/4 stacks, this will play down all the way to this state
###
###    QUEEN CLUBS   KING DIAMONDS
###    STUFF         STUFF
###    KING SPADES   KING CLUBS       KING HEARTS  EMPTY
###
###    After this, we move  KING OF DIAMONDS and play off the stuff down to here
###
###    QUEEN CLUBS   
###    STUFF         
###    KING SPADES   KING CLUBS       KING HEARTS  KING DIAMONDS
###
###    Now we can play the queen of clubs and play off the stuff to ultimately get to the king of spades.
###
### Harder observations (this required me to peek at the answers)
### -----------------------------------------------------------------------------------------------------------
### h) The queen conditions can "chain".  Consider this case (as was before, the KING of spades is our singleton KING)
###
###     QUEEN CLUBS     QUEEN DIAMONDS  KING HEARTS
###     stuff           stuff           stuff
###     KING SPADES     KING CLUBS      KING DIAMONDS  misc stuff
###
###     Note that we can fully play down the right state, leaving us with this
###   
###     QUEEN CLUBS     QUEEN DIAMONDS  KING HEARTS
###     stuff           stuff           stuff
###     KING SPADES     KING CLUBS      KING DIAMONDS  EMPTY
###
###     Now we move the KING of HEARTS to the empty and play down the exposed stuff leading to this state
###  
###     QUEEN CLUBS     QUEEN DIAMONDS  
###     stuff           stuff           
###     KING SPADES     KING CLUBS      KING DIAMONDS  KING HEARTS
###
###     Now we play the QUEEN DIAMONDS and play down the stuff to get us here
###
###     QUEEN CLUBS       
###     stuff                      
###     KING SPADES     KING CLUBS      KING DIAMONDS  KING HEARTS
###
###     Finally we play down the queen of clubs and the stuff underneath to win.
###
### i) The pattern here of either having a singleton bottom king with a different king on top of it, or
###    a singleton bottom king, chaining through queens --> bottom king stacks and ultimately ending on
###    a 2-king stack is a NECESSARY CONDITION (not just a sufficient condition), provided theg game was
###    not winable without having to move anything to an empty pile.  This proof starts
###    at the paragraph "At the end of a successful game...." -- I won't repeat it here.
###
### h) This sets up a graph solution.  You should be able to do this search either way, but we sets
###    the problem up as in the published solutions.  We look to "start" the search at stacks that end
###    in singleton king, and end the search at double king stacks.  Our mechanism of traversing through
###    the graph remains these (queen in my stack  --> paired king at bottom of another stack) edges. 
######################################################################################################

function checkAfterInitialMoves(Parr,PP,N,C)
    B = fill((-1,-1),N,C)
    for i in 1:N; B[i,:] = Parr[PP[i]+1]; end
    bestPerSuit = fill((-1,-1),50000)
    emptyCount = 0
    moveCount = 0
    for i in 1:N
        (a,b) = B[i,1]
        bestPerSuit[b] = max(bestPerSuit[b],(a,i))
    end
    moves = []
    for i in 1:N
        (a,b) = B[i,1]
        if (a,i) < bestPerSuit[b]; push!(moves,i); end
    end

    idx = fill(1,N)
    while !isempty(moves)
        i = pop!(moves)
        if i < 0; continue; end
        moveCount += 1
        idx[i] += 1
        if idx[i] > C; emptyCount += 1; continue; end
        (a,b) = B[i,idx[i]]
        if (a,i) > bestPerSuit[b]
            push!(moves,bestPerSuit[b][2])
            bestPerSuit[b] = (a,i)
        elseif (a,i) < bestPerSuit[b]
            push!(moves,i)
        end
    end

    if moveCount == N*C-N; return 1; end
    if emptyCount == 0; return -1; end
    return 0
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    P = parse(Int64,readline(infile))
    Parr = [[] for i in 1:P]
    for i in 1:P
        X = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        Parr[i] = collect(zip(X[2:2:end],X[3:2:end]))
    end
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N,C = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        PP = [parse(Int64,x) for x in split(rstrip(readline(infile)))]

        kingPerSuit  = fill(-1,50000)
        queenPerSuit = fill(-1,50000)

        ## First pass to identify the functional kings/queens
        for i in 1:N
            stk = Parr[PP[i]+1]
            for (v,s) in stk
                if v > kingPerSuit[s]
                    queenPerSuit[s] = kingPerSuit[s]
                    kingPerSuit[s] = v
                elseif v > queenPerSuit[s]
                    queenPerSuit[s] = v
                end
            end
        end

        ## Intermediate step to see how many suits we are dealing with and
        ## exit early if it doesn't match N
        totSuits = sum([1 for i in 1:50000 if kingPerSuit[i] > 0])
        if totSuits < N; print("POSSIBLE\n"); continue; end
        if totSuits > N; print("IMPOSSIBLE\n"); continue; end

        res = checkAfterInitialMoves(Parr,PP,N,C)
        if res == 1; print("POSSIBLE\n"); continue; end
        if res == -1; print("IMPOSSIBLE\n"); continue; end  ## Don't think we really need this, but not hard

        ## Second pass to identify
        ## * stacks with a bottom card that is a signleton of its suit
        ## * stacks with a king at the bottom and another king in the stack
        ## * suits whose king is on the bottom of the stack (and the stack which it is on the bottom of)
        ## * for stacks with bottom kings, a list of the suits of the queens present in that stack
        bottomSingletonStacks::Set{Int64} = Set()
        kingKingStacks::Set{Int64} = Set()
        suitsWithBottomKing::Vector{Int64} = fill(-1,50000)
        queensPerStack::Array{Array{Int64,1},1} = [[] for i in 1:N]

        for i in 1:N
            stk = Parr[PP[i]+1]
            (v,s) = stk[end]
            if kingPerSuit[s] == v
                suitsWithBottomKing[s] = i
                if queenPerSuit[s] == -1; push!(bottomSingletonStacks,i); end
                for (a,b) in stk[1:end-1]
                    if a == kingPerSuit[b];  push!(kingKingStacks,i); end
                    if a == queenPerSuit[b]; push!(queensPerStack[i],b); end
                end
            end
        end

        ## TO avoid stack overflow on windows, I'm doing the recursion in a loop 
        foundSolution = false
        visited = fill(false,N)
        for i in bottomSingletonStacks
            q = [i]
            while !isempty(q)
                x = pop!(q)
                if x < 0; continue; end
                if x in kingKingStacks; foundSolution = true; break; end
                for qSuit in queensPerStack[x]
                    push!(q,suitsWithBottomKing[qSuit])
                end
            end
            if foundSolution; break; end
        end
        if foundSolution; print("POSSIBLE\n");
        else;             print("IMPOSSIBLE\n");
        end
    end
end

main()