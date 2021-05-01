const I = Int64; const VI = Vector{I}; const SI = Set{I}; const PI = NTuple{2,I};
const TI = NTuple{3,I}; const QI = NTuple{4,I}; const VPI = Vector{PI}; const SPI = Set{PI}
const VC = Vector{Char}; const VS = Vector{String}; VB = Vector{Bool}; VVI = Vector{Vector{Int64}}
const F = Float64; const VF = Vector{F}; const PF = NTuple{2,F}

function kosarajuAdj(n::I,adj::VVI)::VI
    visited::VB = fill(false,n)
    visitedInv::VB = fill(false,n)
    s::VI = []
    adjInv::VVI = [VI() for i in 1:n]
    ssc::VI = fill(0,n)
    counter::I = 1
    for i::I in 1:n
        for j::I in adj[i]; push!(adjInv[j],i); end
    end

    function dfsFirst(u::I)
        if visited[u]; return; end
        visited[u] = true
        for x in adj[u]; dfsFirst(x); end
        push!(s,u)
    end

    function dfsSecond(u::I)
        if visitedInv[u]; return; end
        visitedInv[u] = true
        for x in adjInv[u]; dfsSecond(x); end
        ssc[u] = counter
    end

    for i::I in 1:n; if !visited[i]; dfsFirst(i); end; end
    while !isempty(s)
        nn::I = pop!(s)
        if !visitedInv[nn]; dfsSecond(nn); counter += 1; end 
    end
    return ssc
end