const I = Int64; const VI = Vector{I}; const SI = Set{I}; const PI = NTuple{2,I};
const TI = NTuple{3,I}; const QI = NTuple{4,I}; const VPI = Vector{PI}; const SPI = Set{PI}
const VC = Vector{Char}; const VS = Vector{String}; VB = Vector{Bool}; VVI = Vector{Vector{Int64}}
const F = Float64; const VF = Vector{F}; const PF = NTuple{2,F}

function kosarajuAdj(n::Int64,adj::Vector{Vector{Int64}})
    visited::Vector{Bool} = fill(false,n)
    visitedInv::Vector{Bool} = fill(false,n)
    s::Vector{Int64} = []
    adjInv::Vector{Vector{Int64}} = [Vector{Int64}() for i in 1:n]
    ssc::Vector{Int64} = fill(0,n)
    counter::Int64 = 1
    for i in 1:n
        for j in adj[i]
            push!(adjInv[j],i)
        end
    end

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
        ssc[u] = counter
    end

    for i in 1:n
        if !visited[i]; dfsFirst(i); end
    end
    while !isempty(s)
        nn = pop!(s)
        if !visitedInv[nn]; dfsSecond(nn); counter += 1; end 
    end
    return ssc
end