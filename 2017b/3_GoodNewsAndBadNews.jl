
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
### a) Since we can tolerate negative weights, we can consider the graph as undirected and we can
###    decide the direction by convention.
### 
### b) We split the graph up into connected components.
###
### c) In each graph, we need degrees of freedom to balance, so we pick out a spanning tree and we
###    randomize the rest.
###
### d) Then we just balance the nodes and see if it works.  We just try it a ton of times, and
###    if it doesn't work, we "guess" it is "IMPOSSIBLE" 
######################################################################################################

function solve(F::I,P::I,A::VI,B::VI)::String
    ## Unify the edges
    undirEdges::SPI = SPI()
    dirEdges::SPI = SPI()
    for i in 1:P
        push!(dirEdges,(A[i],B[i]))
        push!(undirEdges,(min(A[i],B[i]),max(A[i],B[i])))
    end

    ## Build the adjacency structure
    adjl::Vector{SI} = [SI() for i in 1:F]
    for (a,b) in undirEdges; push!(adjl[a],b); push!(adjl[b],a); end
    adjv::Array{I,2} = fill(0,F,F)

    ## Iterate through the nodes
    visited::VB = fill(false,F)
    spanning::VPI = []
    function dfs(par::I,n::I)
        if visited[n]; return; end
        visited[n] = true
        push!(spanning,(par,n))
        for c::I in adjl[n]; dfs(n,c); end
    end
    for i in 1:F; dfs(-1,i); end

    F2::I = F*F
    zeroWeight::Bool,unbalanced::Bool,extremeWeight::Bool = false,false,false

    for i in 1:1000
        zeroWeight,unbalanced,extremeWeight = false,false,false
        weights = vcat(collect(1:F),collect(-1:-1:-F))
        for (a,b) in undirEdges
            w::I = rand(weights)
            adjv[a,b] = w
            adjv[b,a] = -w
        end
        for (a::I,b::I) in reverse(spanning)
            rs::I = 0
            for n::I in adjl[b]; rs += adjv[b,n]; end
            if a == -1; 
                if rs != 0; unbalanced = true; end
            else
                adjv[b,a] -= rs
                adjv[a,b] += rs
                if (adjv[b,a] == 0) && ((a,b) ∉ dirEdges || (b,a) ∉ dirEdges); zeroWeight = true; end
                if abs(adjv[b,a]) > F2; extremeWeight = true; end
            end
        end
        if !zeroWeight && !unbalanced && !extremeWeight; break; end
    end

    if zeroWeight || unbalanced || extremeWeight; return "IMPOSSIBLE"; end
    ans::VI = []
    for i in 1:P
        a,b = A[i],B[i]
        if (b,a) ∉ dirEdges; push!(ans,adjv[a,b])
        elseif adjv[a,b] == 0; push!(ans,1)
        elseif a < b
            push!(ans, adjv[a,b] == -F2 ? -F2+1 : adjv[a,b] == 1  ? 2 : adjv[a,b]-1)
        else
            push!(ans, adjv[b,a]== -F2 ? 1      : adjv[b,a] == 1  ? 1 : -1 )
        end
    end
    return join(ans," ")
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        F,P = gis()
        A::VI = fill(0,P)
        B::VI = fill(0,P)
        for i in 1:P; A[i],B[i] = gis(); end
        ans = solve(F,P,A,B)
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

