const I = Int64; const VI = Vector{I}; const SI = Set{I}; const PI = NTuple{2,I};
const TI = NTuple{3,I}; const QI = NTuple{4,I}; const VPI = Vector{PI}; const SPI = Set{PI}
const F = Float64; const VF = Vector{F}; const PF = NTuple{2,F}

################################################################
## BEGIN Twosat from geeks for geeks
## https://www.geeksforgeeks.org/2-satisfiability-2-sat-problem/
## https://cp-algorithms.com/graph/2SAT.html
## Assumes 1:n code the true values of the variables, and n+1:2n code the complements
################################################################
function twosat(n::Int64,m::Int64,a::Array{Int64},b::Array{Int64})
    adj = [[] for i in 1:2n]
    adjInv = [[] for i in 1:2n]
    visited = fill(false,2n)
    visitedInv = fill(false,2n)
    s = Int64[]
    scc = fill(0,2n)
    counter = 1

    function addEdges(x::Int64,y::Int64); push!(adj[x],y); end

    function addEdgesInverse(x::Int64,y::Int64); push!(adjInv[y],x); end

    function dfsFirst(u::Int64)
        if visited[u]; return; end
        visited[u] = true
        for x in adj[u]; dfsFirst(x); end
        push!(s,u)
    end

    function dfsSecond(u::Int64)
        if visitedInv[u]; return; end
        visitedInv[u] = true
        for x in adjInv[u]; dfsSecond(x); end
        scc[u] = counter
    end

    ### Start the main routine
    ### Build the impplication graph
    for i in 1:m
        na = a[i] > n ? a[i] - n : a[i] + n
        nb = b[i] > n ? b[i] - n : b[i] + n
        addEdges(na,b[i])
        addEdges(nb,a[i])
        addEdgesInverse(na,b[i])
        addEdgesInverse(nb,a[i])
    end

    ### Kosaraju 1
    for i in 1:2n
        if !visited[i]; dfsFirst(i); end
    end

    ### Kosaraju 2
    while !isempty(s)
        nn = pop!(s)
        if !visitedInv[nn]; dfsSecond(nn); counter += 1; end 
    end

    assignment = fill(false,n)
    for i in 1:n
        if scc[i] == scc[n+i]; return (false,[]); end
        assignment[i] = scc[i] > scc[n+i]
    end

    return (true,assignment)
end

################################################################
## END Twosat from geeks for geeks
################################################################