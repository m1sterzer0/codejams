const I = Int64; const VI = Vector{I}; const SI = Set{I}; const PI = NTuple{2,I};
const TI = NTuple{3,I}; const QI = NTuple{4,I}; const VPI = Vector{PI}; const SPI = Set{PI}
const F = Float64; const VF = Vector{F}; const PF = NTuple{2,F}

######################################################################################################
### BEGIN UNION FIND
######################################################################################################

mutable struct UnionFind{T}
    parent::Dict{T,T}
    size::Dict{T,Int64}
    
    UnionFind{T}() where {T} = new{T}(Dict{T,T}(),Dict{T,Int64}())
    
    function UnionFind{T}(xs::AbstractVector{T}) where {T}
        myparent = Dict{T,T}()
        mysize = Dict{T,Int64}()
        for x in xs; myparent[xs] = xs; mysize[xs] = 1; end
        new{T}(myparent,mysize)
    end
end

function Base.push!(h::UnionFind,x) 
    ## Assume that we don't push elements on that are already in the set
    if haskey(h.parent,x); error("ERROR: Trying to push an element into UnionFind that is already present"); end
    h.parent[x]=x
    h.size[x] = 1
    return h
end

function findset(h::UnionFind,x) 
    if h.parent[x] == x; return x; end
    return h.parent[x] = findset(h,h.parent[x])
end

function joinset(h::UnionFind,x,y)
    a = findset(h,x)
    b = findset(h,y)
    if a != b
        (a,b) = h.size[a] < h.size[b] ? (b,a) : (a,b)
        h.parent[b] = a
        h.size[a] += h.size[b]
    end
end

######################################################################################################
### END UNION FIND
######################################################################################################


###########################################################################
## BEGIN UnionFindFast -- Only works with integers, but avoids dictionaries
###########################################################################

mutable struct UnionFindFast
    parent::Vector{Int64}
    size::Vector{Int64}
    n::Int64
    UnionFindFast(n::Int64) = new(collect(1:n),[1 for i in 1:n],n)
end

function findset(h::UnionFindFast,x::Int64)::Int64
    if h.parent[x] == x; return x; end
    return h.parent[x] = findset(h,h.parent[x])
end

function getsize(h::UnionFindFast,x::Int64)::Int64
    a = findset(h,x)
    return h.size[a]
end

function joinset(h::UnionFindFast,x::Int64,y::Int64)
    a = findset(h,x)
    b = findset(h,y)
    if a != b
        (a,b) = h.size[a] < h.size[b] ? (b,a) : (a,b)
        h.parent[b] = a
        h.size[a] += h.size[b]
    end
end

################################################################
## END UnionFindFast
################################################################


