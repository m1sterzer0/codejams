
using Random
infile = stdin
## Type Shortcuts (to save my wrists and fingers :))
const I = Int64; const VI = Vector{I}; const SI = Set{I}; const PI = NTuple{2,I};
const TI = NTuple{3,I}; const QI = NTuple{4,I}; const VPI = Vector{PI}; const SPI = Set{PI}
const VC = Vector{Char}; const VS = Vector{String}; VB = Vector{Bool}; VVI = Vector{Vector{Int64}}
const F = Float64; const VF = Vector{F}; const PF = NTuple{2,F}

gs()::String = rstrip(readline(infile))
gi()::Int64 = parse(Int64, gs())
gf()::Float64 = parse(Float64,gs())
gss()::Vector{String} = split(gs())
gis()::Vector{Int64} = [parse(Int64,x) for x in gss()]
gfs()::Vector{Float64} = [parse(Float64,x) for x in gss()]

######################################################################################################
### BEGIN MAXIMUM BIPARTITE MATCHING CODE
### Inspired by https://www.geeksforgeeks.org/maximum-bipartite-matching/
######################################################################################################

function bpm(bpGraph::Array{Int8,2}, u::I, seen::VB, matchR::VI, m::I, n::I)::Bool
    for v::I in 1:n
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

function maxBPM(bpGraph::Array{Int8,2},m::I,n::I)::Tuple{I,SPI}
    matchR::VI = fill(-1,n)
    seen::VB = fill(false,n)
    result::I = 0
    for u::I in 1:m
        fill!(seen,false)
        if bpm(bpGraph,u,seen,matchR,m,n); result += 1; end
    end
    matches::SPI = SPI((matchR[x],x) for x in 1:n if matchR[x] > 0)
    return result,matches
end

######################################################################################################
### END MAXIMUM BIPARTITE MATCHING CODE
### Inspired by https://www.geeksforgeeks.org/maximum-bipartite-matching/
######################################################################################################

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

function solveRooks(N::I,rooks::SPI)::SPI
    rows::SI = SI(collect(1:N))
    cols::SI = SI(collect(1:N))
    for r in rooks; delete!(rows,r[1]); delete!(cols,r[2]); end
    return SPI(collect(zip(rows,cols)))
end

#######################################################################################
## Need to map diagonals to 1:2N-1 for the maxBPM code to work, so here is the mapping
## and inverse mapping.
## square forwardDiag k  reverseDiag l  inverse row func    inverse col func
## ------ -------------  ------------- -------------------- --------------------
## (i,j)   k = i+j-1      l = i-j+N     i = (k+l-(N-1)) ÷ 2  j = (k-l+(N+1)) ÷ 2
#####################################################################################

function solveBishops(N::I,bishops::SPI)::SPI
    forwardDiag::SI = SI(collect(1:2N-1))
    reverseDiag::SI = SI(collect(1:2N-1))
    for b::PI in bishops
        (i::I,j::I) = b
        delete!(forwardDiag,i+j-1)
        delete!(reverseDiag,i-j+N)
    end
    arr::Array{Int8,2} = fill(Int8(0),2N-1,2N-1)
    squares::VPI = [ (i,j) for i in 1:N for j in 1:N ]
    allowedPairs::VPI = [(i,j) for (i,j) in squares if i+j-1 ∈ forwardDiag && i-j+N ∈ reverseDiag]
    for (i,j) in allowedPairs; arr[i+j-1,i-j+N] = 1; end
    _res,matches = maxBPM(arr,2N-1,2N-1)
    ans::SPI = SPI(  ( (k+l-(N-1)) ÷ 2, (k-l+(N+1)) ÷ 2 ) for (k,l) in matches )
    return ans
end

function solve(N::I,M::I,P::VC,X::VI,Y::VI)::VS
    rooks::SPI = SPI()
    bishops::SPI = SPI()
    for i in 1:M
        if P[i] in "ox"; push!(rooks,(X[i],Y[i])); end
        if P[i] in "o+"; push!(bishops,(X[i],Y[i])); end
    end
    extraRooks::SPI = solveRooks(N,rooks)
    extraBishops::SPI = solveBishops(N,bishops)
    score::I = length(rooks) + length(bishops) + length(extraRooks) + length(extraBishops)
    newQueens::SPI = union(intersect(extraRooks,extraBishops),intersect(extraRooks,bishops),intersect(rooks,extraBishops))
    newRooks::SPI = setdiff(extraRooks,newQueens)
    newBishops::SPI = setdiff(extraBishops,newQueens)
    numPieces::I = length(newQueens) + length(newRooks) + length(newBishops)
    ans::VS = []
    push!(ans,"$score $numPieces")
    for (i,j) in newQueens;  push!(ans,"o $i $j"); end
    for (i,j) in newRooks;   push!(ans,"x $i $j"); end
    for (i,j) in newBishops; push!(ans,"+ $i $j"); end
    return ans
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,M = gis()
        P::VC = fill('.',M)
        X::VI = fill(0,M)
        Y::VI = fill(0,M)
        for i in 1:M
            xx = gss()
            P[i] = xx[1][1]
            X[i] = parse(Int64,xx[2])
            Y[i] = parse(Int64,xx[3])
        end
        ans = solve(N,M,P,X,Y)
        for l in ans; print("$l\n"); end
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

