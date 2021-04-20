const I = Int64; const VI = Vector{I}; const SI = Set{I}; const PI = NTuple{2,I};
const TI = NTuple{3,I}; const QI = NTuple{4,I}; const VPI = Vector{PI}; const SPI = Set{PI}
const F = Float64; const VF = Vector{F}; const PF = NTuple{2,F}


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
    return result
end

######################################################################################################
### END MAXIMUM BIPARTITE MATCHING CODE
### Inspired by https://www.geeksforgeeks.org/maximum-bipartite-matching/
######################################################################################################


###########################################################################
## BEGIN: Maximum Bipartite Matching
###########################################################################

function checkMatch(adjL::Vector{Vector{Int}}, matchR::Vector{Int}, seen::Vector{Int8}, n::Int)
    for v in adjL[n]
        if seen[v] > 0; continue; end
        seen[v] = 1
        if matchR[v] == -1; matchR[v] = n; return true; end
        if checkMatch(adjL,matchR,seen,matchR[v]); matchR[v] = n; return true; end
    end
    return false
end

function maxBPM(adjL::Vector{Vector{Int}}, m::Int, n::Int)
    matchR = fill(-1,n)
    seen = fill(zero(Int8),n)
    result = 0
    for u in 1:m
        fill!(seen,0)
        if checkMatch(adjL,matchR,seen,u); result += 1; end
    end
    matches = [(matchR[x],x) for x in 1:n if matchR[x] != -1]
    return result,matches
end

###########################################################################
## END: Maximum Bipartite Matching
###########################################################################