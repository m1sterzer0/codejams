using Printf
using Profile

######################################################################################################
### 1) We can always jump to a planet and immediately jump back, so the S constraint really just
###    applies if we get stuck on an asteroid and can't jump.  For this case, we just split the nodes
### 2) We do a binary search on the distance    
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

function calcIt(dist,x::Float64,y::Float64,z::Float64,vx::Float64,vy::Float64,vz::Float64)::Tuple{Float64,Float64}
    ### Quadratic is (x+vx*t)^2 + (y+vy*t)^2 + (z+vz*t)^2 == d^2
    a = vx^2 + vy^2 + vz^2
    if a < 1e-6
        return x*x+y*y+z*z <= dist*dist ? (-1e9,1e9) : (-1e0,-1e0)
    end
    b = 2 * (x*vx+y*vy+z*vz)
    c = x^2+y^2+z^2-dist^2
    disc = b*b-4*a*c
    if disc < 0; return (-1e0,-1e0); end
    sqrtdisc = sqrt(disc)
    oneover2a = 0.5/a
    return (oneover2a*(-b-sqrtdisc),oneover2a*(-b+sqrtdisc))
end

mutable struct Asteroid
    idx::Int64
    numSubnodes::Int64
    subnodeIntervals::Array{Tuple{Float64,Float64},1}
    arcs::Array{Array{Tuple{Float64,Float64,Int64},1},1}
end

Asteroid() = Asteroid(-1,0,Array{Tuple{Float64,Float64},1}(),Array{Array{Tuple{Float64,Float64,Int64},1},1}())


function tryIt(dist::Float64,N::Int64,S::Int64,x0::Array{Float64,1},y0::Array{Float64,1},z0::Array{Float64,1},
               vx::Array{Float64,1},vy::Array{Float64,1},vz::Array{Float64,1})
    ## Step1: For each pair of planets, need to calculate the interval of time in which they are within
    ##        dist of each other.
    arcs::Array{Array{Tuple{Float64,Float64,Int64},1},1} = [ Array{Tuple{Float64,Float64,Int64},1}() for i in 1:N ]
    for i in 1:N-1
        for j in i+1:N
            op = calcIt(dist,x0[j]-x0[i],y0[j]-y0[i],z0[j]-z0[i],vx[j]-vx[i],vy[j]-vy[i],vz[j]-vz[i])
            if op[2] <= 0; continue; end
            push!(arcs[i],(op[1],op[2],j))
            push!(arcs[j],(op[1],op[2],i))            
        end
    end

    ## Step2: We need to split the nodes that are isolated with the S gaps.  This won't create edges, but
    ##        it could explode the node count to O(V^2).
    gr::Array{Asteroid} = [Asteroid() for x in 1:N]
    for i in 1:N
        a = arcs[i]
        if length(a) == 0; continue; end
        sort!(a)  ## Prob worst line in here
        ii = 1
        while(ii <= length(a))
            jj = ii
            si = max(0.0,a[ii][1])
            ei = a[ii][2]+S
            while (jj < length(a))
                if a[jj+1][1] > ei; break; end
                ei = max(ei,a[jj+1][2]+S)
                jj += 1
            end
            gr[i].numSubnodes += 1
            push!(gr[i].arcs,a[ii:jj])
            push!(gr[i].subnodeIntervals,(si,ei))
            ii = jj+1
        end
    end

    ## Quick check to make sure we can actually lauch off of planet 1
    if gr[1].numSubnodes < 1; return false; end
    if gr[1].subnodeIntervals[1][1] > S; return false; end
    gr[1].subnodeIntervals[1] = (0.0,gr[1].subnodeIntervals[1][2])
    
    ## Step3: Run a modified Dijkstra's to find the minimum time we arrive at each node of the graph
    b = BinaryMinHeap{Tuple{Float64,Int64}}()
    push!(b,(0.0,1))
    while !isempty(b)
        (t::Float64,n::Int64) = pop!(b)
        if n == 2; return true; end
        ast::Asteroid = gr[n]
        if ast.idx > 0 && ast.subnodeIntervals[ast.idx][2] >= t; continue; end
        if ast.idx < 0; gr[n].idx = 1; end
        while t > ast.subnodeIntervals[ast.idx][2]; ast.idx += 1; end
        #println(ast.arcs)
        #println("HERE")
        #println("HERE2")
        #println(ast.idx)
        #println(ast.arcs[ast.idx])

        for arc in ast.arcs[ast.idx]
            if t > arc[2]; continue; end
            launchTime::Float64 = max(t,arc[1])
            push!(b,(launchTime,arc[3]))
        end
    end
    return false
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N,S = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        x0 = fill(0.0,N) 
        y0 = fill(0.0,N)
        z0 = fill(0.0,N)
        vx = fill(0.0,N)
        vy = fill(0.0,N)
        vz = fill(0.0,N)
        for i in 1:N
            x0[i],y0[i],z0[i],vx[i],vy[i],vz[i] = [parse(Float64,x) for x in split(rstrip(readline(infile)))]; end
        lb = 0.000
        ub = 1000*sqrt(3)
        while (ub-lb) > 1.8e-4 && 0.5 * (ub-lb) / (lb+1e-99) > 0.9e-4
            mid = 0.5 * (ub+lb)
            (lb,ub) = tryIt(mid,N,S,x0,y0,z0,vx,vy,vz) ? (lb,mid) : (mid,ub)
        end
        @printf("%.6f\n",0.5*(lb+ub))
    end
end

function mainLoop(n,f)
    for i in 1:n
        main(f)
    end
end

main()
#using ProfileView
#@profview main("C.in2")
#@profview main("C.in2")
#Profile.print(format=:flat)