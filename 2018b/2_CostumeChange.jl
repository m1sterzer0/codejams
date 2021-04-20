
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
### * There are enough costumes to fix any problems with a row or column (i.e. we aren't further
###   limited by available costumes causing cascading effect)
### * This is just a "keep the most rooks" problem for each of the 2N costume types, which we can
###   solve with bipartite matching (a GCJ favorite)
######################################################################################################

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

function findChanges(g::Array{I,2},board::Array{Int8,2},N::I,p::I)::I
    fill!(board,Int8(0))
    cnt::I = 0
    for (i,j) in Iterators.product(1:N,1:N)
        if g[i,j] == p; cnt += 1; board[i,j] = Int8(1); end
    end
    res,_matches = maxBPM(board,N,N)
    return cnt-res
end

function solve(N::I,g::Array{I,2})::I
    board::Array{Int8,2} = fill(Int8(0),N,N)
    changes::I = 0
    for i in (1:N);   changes += findChanges(g,board,N,i); end
    for i in (-N:-1); changes += findChanges(g,board,N,i); end
    return changes
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        g::Array{I,2} = fill(0,N,N)
        for i in 1:N; g[i,:] = gis(); end
        ans = solve(N,g)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

