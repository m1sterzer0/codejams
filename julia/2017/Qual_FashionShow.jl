using Printf

######################################################################################################
### This is really a chess puzzle in disguise
### -- The x is a rook, The + is a bishop, and the o is a queen.
### -- We need to place the {roooks,queens} so that no piece is attacking each other horizontally other
###    vertically.  We need to place the {bishops,queens} so that no piece is attacking each other
###    diagonally.  
### -- The problem is easier if we just consider rooks and bishops, and we "promote" a joint rook/bishop
###    to a queen (the scoring/promotion makes this possible)
### -- Rooks: Easy -- we pair off the unoccupied columns with the unoccupied rows.
### -- Bishops: Harder.  We have \ and / diagonals instead of rows.  Here we use bipartite matching
###    to avoid frying our brain on a greedy algorithm. 
######################################################################################################

######################################################################################################
### BEGIN MAXIMUM BIPARTITE MATCHING CODE
### Inspired by https://www.geeksforgeeks.org/maximum-bipartite-matching/
######################################################################################################

function bpm(bpGraph::Array{Int8,2}, u::Int, seen::Array{Bool,1}, matchR::Array{Int,1}, m::Int, n::Int)::Bool
    for v in 1:n
        if bpGraph[u,v] == 1 && !seen[v]
            seen[v] = true
            if matchR[v] < 0 || bpm(bpGraph, matchR[v], seen, matchR, m, n)
                matchR[v] = u
                return true
            end
        end
    end
    return false
end

function maxBPM(bpGraph::Array{Int8,2},m::Int,n::Int)
    matchR = fill(-1,n)
    seen = fill(false,n)
    result = 0
    for u in 1:m
        fill!(seen,false)
        if bpm(bpGraph,u,seen,matchR,m,n); result += 1; end
    end
    matches = Set((matchR[x],x) for x in 1:n if matchR[x] > 0)
    return result,matches
end

######################################################################################################
### END MAXIMUM BIPARTITE MATCHING CODE
### Inspired by https://www.geeksforgeeks.org/maximum-bipartite-matching/
######################################################################################################

function solveRooks(N,rooks)
    rows = Set(collect(1:N))
    cols = Set(collect(1:N))
    for r in rooks; delete!(rows,r[1]); delete!(cols,r[2]); end
    return Set(collect(zip(rows,cols)))
end

#######################################################################################
## Need to map diagonals to 1:2N-1 for the maxBPM code to work, so here is the mapping
## and inverse mapping.
## square forwardDiag k  reverseDiag l  inverse row func    inverse col func
## ------ -------------  ------------- -------------------- --------------------
## (i,j)   k = i+j-1      l = i-j+N     i = (k+l-(N-1)) ÷ 2  j = (k-l+(N+1)) ÷ 2
#####################################################################################

function solveBishops(N,bishops)
    forwardDiag = Set(collect(1:2N-1))
    reverseDiag = Set(collect(1:2N-1))
    for b in bishops
        (i,j) = b
        delete!(forwardDiag,i+j-1)
        delete!(reverseDiag,i-j+N)
    end
    arr = zeros(Int8,2N-1,2N-1)
    squares = [ (i,j) for i in 1:N for j in 1:N ]
    allowedPairs = [(i,j) for (i,j) in squares if i+j-1 ∈ forwardDiag && i-j+N ∈ reverseDiag]
    for (i,j) in allowedPairs; arr[i+j-1,i-j+N] = 1; end
    _res,matches = maxBPM(arr,2N-1,2N-1)
    ans = Set(  ( (k+l-(N-1)) ÷ 2, (k-l+(N+1)) ÷ 2 ) for (k,l) in matches )
    return ans
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N,M = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        rooks,bishops,queens = Set(),Set(),Set()
        for i in 1:M
            arr = split(rstrip(readline(infile)))
            piece = arr[1][1]
            x,y = [parse(Int64,x) for x in arr[2:3]]
            if      piece == 'x'; push!(rooks,(x,y))
            elseif  piece == '+'; push!(bishops,(x,y))
            else                ; push!(queens,(x,y))
            end
        end
        extraRooks = solveRooks(N,union(rooks,queens))
        extraBishops = solveBishops(N,union(bishops,queens))
        score = length(rooks) + length(bishops) + 2*length(queens) + length(extraRooks) + length(extraBishops)
        newQueens = union(intersect(extraRooks,extraBishops),intersect(extraRooks,bishops),intersect(rooks,extraBishops))
        newRooks = setdiff(extraRooks,newQueens)
        newBishops = setdiff(extraBishops,newQueens)
        numPieces = length(newQueens) + length(newRooks) + length(newBishops)
        print("$score $numPieces\n")
        for (i,j) in newQueens;  print("o $i $j\n"); end
        for (i,j) in newRooks;   print("x $i $j\n"); end
        for (i,j) in newBishops; print("+ $i $j\n"); end
    end
end

main()
