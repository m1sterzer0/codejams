
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
### So there are really 2 subproblems to this main problem.
### -- How to generate a network that satifies the constraints with enough "character" to satisfactorily
###    disambiguate the nodes.
### -- How to quickly calculate the the mapping between our nodes and the ones the judge spits back
###    to us.
###
### 1) Generating the graph.  We do this pseudo-randomly.  First, we string a connection from 1-2, 2-3,
###    ... , (n-1)-n.  This accounts for n-1 of the edges.  For the other n+1 of the edges, we just
###    randomly pick 2 nodes that haven't hit their edge quota, ensure that an edge between them doesn't
###    already exist, and then add them to the network.  The routine needs enough retry/checks to 
###    account for the various ways it can get stuck.
###
### 2) Coming up with a "node signature" -- The powers p of the adjacency matrix provide the number of
###    unique paths from i->j of length p.  We sort each row of the particular power matrix and use that
###    as a signature for the node.  We try p in the range of 2:10, and we stop when we find a p
###    that produces unique signatures for a node.  If we run out at 10, we signal back to the main
###    process, and we start the graph generation all over again.
######################################################################################################

function randomlyPopulateAdjMatrix(n::I)
    done::Bool = false; 
    res = nothing
    power::I = 0
    a::Array{Int128,2} = fill(Int128(0),n,n)
    while true
        fill!(a,0)
        cnt::VI = fill(0,n)
        ## Force the graph to be connected through a chain
        for i in 1:n-1; a[i,i+1] = a[i+1,i] = 1; cnt[i] += 1; cnt[i+1] += 1; end

        ## Now we try to populate edges such that
        ## -- Every node has 4 unique connections
        ## -- No self connections
        ## -- A low power of the connectivity matrix has unique diagonal entries
        edges::SI = SI(collect(1:n))
        left = n+1
        for i in 1:100*n  ## Try a bunch
            if left == 0; break; end
            if length(edges) == 1; break; end
            x::I = rand(edges)
            y::I = x
            while (x==y); y = rand(edges); end
            if a[x,y] == 1; continue; end ## Try again, this edge is taken
            a[x,y] = a[y,x] = 1
            left -= 1; cnt[x] += 1; cnt[y] += 1
            if cnt[x] == 4; delete!(edges,x); end
            if cnt[y] == 4; delete!(edges,y); end
        end
        if left > 0; continue; end  ##Even after 100 tries
        (b,power,res) = tryPowers(a,n)
        if !b; continue; end
        return (power,res,a)
    end
end

function tryPowers(a::Array{Int128,2},n::I)
    for i in 2:10
        b::Array{Int128,2} = a^i
        d = Dict()
        for i in 1:n
            x = Tuple(sort(b[i,:]))
            d[x] = i
        end
        if length(keys(d)) == n
            return (true,i,d)
        end
    end
    return (false,0,Dict())
end

function solveMatrix(a::Array{Int128,2},power::I,res::Dict,aa::Array{Int128,2})
    n = size(aa,1)
    x = fill(0,n)
    b = aa^power
    for i in 1:n
        yy = Tuple(sort(b[i,:]))
        if !haskey(res,yy); exit(1); end
        j = res[yy]
        x[j] = i
    end
    return x
end

function solve(L::I,U::I)
    ## Generate the matrix 
    print("$L\n")
    power,res,a = randomlyPopulateAdjMatrix(L)
    for (i,j) in Iterators.product(1:L,1:L)
        if i < j && a[i,j] == 1; print("$i $j\n"); end
    end
    flush(stdout)

    ## Now we read the returned matrix
    N = gi(); if N == -1; exit(1); end
    aa::Array{Int128,2} = fill(Int128(0),N,N)
    for i in 1:2N; x,y = gis(); aa[x,y] = aa[y,x] = 1; end

    x = solveMatrix(a,power,res,aa)
    println(join(x," ")); flush(stdout)
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        L,U = gis()
        solve(L,U)
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

