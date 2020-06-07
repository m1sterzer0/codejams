using Printf

######################################################################################################
### * Consider the paths from a particular city with that city's horse.  We can do a Dijkstra
###   search from that city and get the allowable set of destinations (with cost) from that city
###   using that horses graph.
### * If we aggregate all of these together (as time costs, not distance costs), we get a new graph
###   that no longer cares about horses (with the assumption that it never makes sense to visit the
###   same city twice with the same horse).
######################################################################################################

######################################################################################################
### BEGIN BINARY HEAP LIBRARY
### Largely copied from https://github.com/JuliaCollections/DataStructures.jl/blob/master/src/heaps/binary_heap.jl
######################################################################################################
module BinHeaps

import Base: <, <=, ==, length, isempty, iterate,
             show, dump, empty!, getindex, setindex!, get, get!,
             in, haskey, keys, merge, copy, cat, collect,
             push!, pop!, pushfirst!, popfirst!, insert!, lastindex,
             union!, delete!, similar, sizehint!, empty, append!,
             isequal, hash, map, filter, reverse, 
             first, last, eltype, getkey, values, sum,
             merge, merge!,
             #peek, lt, Ordering, ForwardOrdering, Forward, ReverseOrdering, Reverse, Lt, 
             isless, union, intersect, symdiff, setdiff, issubset,
             searchsortedfirst, searchsortedlast, in,
             eachindex, keytype, valtype, minimum, maximum, size

export AbstractHeap, compare, extract_all!
export BinaryHeap, BinaryMinHeap, BinaryMaxHeap, nlargest, nsmallest

abstract type AbstractHeap{VT} end
abstract type AbstractMutableHeap{VT,HT} <: AbstractHeap{VT} end
abstract type AbstractMinMaxHeap{VT} <: AbstractHeap{VT} end
struct LessThan; end
struct GreaterThan; end
compare(c::LessThan,    x, y) = x < y
compare(c::GreaterThan, x, y) = x > y

function _heapBubbleUp!(comp::Comp, valtree::Array{T}, i::Int) where {Comp,T}
    i0::Int = i
    v = valtree[i]
    while i > 1  # nd is not root
        p = i >> 1
        vp = valtree[p]
        if !compare(comp,v,vp); break; end
        valtree[i] = vp
        i = p
    end
    if i != i0; valtree[i] = v; end
end

function _heapBubbleDown!(comp::Comp, valtree::Array{T}, i::Int) where {Comp,T}
    v::T = valtree[i]
    swapped = true
    n = length(valtree)
    last_parent = n >> 1

    while swapped && i <= last_parent
        lc = i << 1
        if lc < n   # contains both left and right children
            rc = lc + 1
            lv = valtree[lc]
            rv = valtree[rc]
            if compare(comp, rv, lv)
                if compare(comp, rv, v)
                    valtree[i] = rv
                    i = rc
                else
                    swapped = false
                end
            else
                if compare(comp, lv, v)
                    valtree[i] = lv
                    i = lc
                else
                    swapped = false
                end
            end
        else        # contains only left child
            lv = valtree[lc]
            if compare(comp, lv, v)
                valtree[i] = lv
                i = lc
            else
                swapped = false
            end
        end
    end
    valtree[i] = v
end

function _binaryHeapPop!(comp::Comp, valtree::Array{T}) where {Comp,T}
    v = valtree[1]
    if length(valtree) == 1
        empty!(valtree)
    else
        valtree[1] = pop!(valtree)
        if length(valtree) > 1
            _heapBubbleDown!(comp, valtree, 1)
        end
    end
    return v
end

function _makeBinaryHeap(comp::Comp, xs) where {Comp}
    n = length(xs)
    valtree = copy(xs)
    for i = 2 : n
        _heapBubbleUp!(comp, valtree, i)
    end
    return valtree
end

mutable struct BinaryHeap{T,Comp} <: AbstractHeap{T}
    comparer::Comp
    valtree::Vector{T}

    BinaryHeap{T,Comp}() where {T,Comp} = new{T,Comp}(Comp(), Vector{T}())

    function BinaryHeap{T,Comp}(xs::AbstractVector{T}) where {T,Comp}
        valtree = _makeBinaryHeap(Comp(), xs)
        new{T,Comp}(Comp(), valtree)
    end
end

const BinaryMinHeap{T} = BinaryHeap{T, LessThan}
const BinaryMaxHeap{T} = BinaryHeap{T, GreaterThan}

BinaryMinHeap(xs::AbstractVector{T}) where T = BinaryMinHeap{T}(xs)
BinaryMaxHeap(xs::AbstractVector{T}) where T = BinaryMaxHeap{T}(xs)

length(h::BinaryHeap)  = length(h.valtree)
isempty(h::BinaryHeap) = isempty(h.valtree)

function push!(h::BinaryHeap, v)
    valtree = h.valtree
    push!(valtree, v)
    _heapBubbleUp!(h.comparer, valtree, length(valtree))
    return h
end
function sizehint!(h::BinaryHeap, s::Integer)
    sizehint!(h.valtree, s)
    return h
end

@inline top(h::BinaryHeap) = h.valtree[1]

pop!(h::BinaryHeap{T}) where {T} = _binaryHeapPop!(h.comparer, h.valtree)

##################################################################
###  Generic functions for all heaps
##################################################################

Base.eltype(::Type{<:AbstractHeap{T}}) where T = T
function extract_all!(h::AbstractHeap{VT}) where VT
    n = length(h)
    r = Vector{VT}(undef, n)
    for i in 1 : n
        r[i] = pop!(h)
    end
    return r
end

function extract_all_rev!(h::AbstractHeap{VT}) where VT
    n = length(h)
    r = Vector{VT}(undef, n)
    for i in 1 : n
        r[n + 1 - i] = pop!(h)
    end
    return r
end

# Array functions using heaps

function nextreme(comp::Comp, n::Int, arr::AbstractVector{T}) where {T, Comp}
    if n <= 0
        return T[] # sort(arr)[1:n] returns [] for n <= 0
    elseif n >= length(arr)
        return sort(arr, lt = (x, y) -> compare(comp, y, x))
    end

    buffer = BinaryHeap{T,Comp}()

    for i = 1 : n
        @inbounds xi = arr[i]
        push!(buffer, xi)
    end

    for i = n + 1 : length(arr)
        @inbounds xi = arr[i]
        if compare(comp, top(buffer), xi)
            # This could use a pushpop method
            pop!(buffer)
            push!(buffer, xi)
        end
    end

    return extract_all_rev!(buffer)
end

function nlargest(n::Int, arr::AbstractVector{T}) where T
    return nextreme(LessThan(), n, arr)
end
function nsmallest(n::Int, arr::AbstractVector{T}) where T
    return nextreme(GreaterThan(), n, arr)
end

end
######################################################################################################
### End binary heaps
### Largely copied from https://github.com/JuliaCollections/DataStructures.jl/blob/master/src/heaps/binary_heap.jl
######################################################################################################
using .BinHeaps

function doDijkstraAdjMatrix(D::Array{Int64,2}, n::Int64)
    (R,C) = size(D)
    ans = fill(typemax(Int64),R)
    hp = BinaryMinHeap(Array{Tuple{Int64,Int64},1}())
    push!(hp,(0,n))
    while !isempty(hp)
        (d,n2) = pop!(hp)
        if ans[n2] <= d; continue; end
        ans[n2] = d
        for i in 1:R
            if i == n2 || D[n2,i] < 0; continue; end
            push!(hp,(d+D[n2,i],i))
        end
    end
    return ans
end

function doFloydWarshallAdjMatrix(Dnew::Array{Float64,2})
    (R,C) = size(Dnew)
    ans = copy(Dnew)
    for i in 1:R; ans[i,i] = 0; end
    for k in 1:R
        for i in 1:R
            for j in 1:R
                ans[i,j] = min(ans[i,j],ans[i,k]+ans[k,j])
            end
        end
    end
    return ans
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")

        ### Read input
        N,Q = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        E = zeros(Int64,N)
        S = zeros(Int64,N)
        for i in 1:N
            E[i],S[i] = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        end
        D = zeros(Int64,N,N)
        for i in 1:N
            D[i,:] = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        end
        U = zeros(Int64,Q)
        V = zeros(Int64,Q)
        for i in 1:Q
            U[i],V[i] = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        end

        ### First, we run a dijkstra from each city
        Dnew = fill(Inf,N,N)
        for i in 1:N
            arcs = doDijkstraAdjMatrix(D,i)
            for j in 1:N
                if j == i || arcs[j] == typemax(Int64); continue; end
                if arcs[j] > E[i]; continue; end
                Dnew[i,j] = Float64(arcs[j]) / Float64(S[i])
            end
        end
        anskey = doFloydWarshallAdjMatrix(Dnew)
        answers = [anskey[u,v] for (u,v) in zip(U,V)]
        ansstr = join([@sprintf("%.8f",x) for x in answers], " ")
        print("$ansstr\n")
    end
end

main()
