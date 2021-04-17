
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
### BEGIN MINHEAP CODE
######################################################################################################

function _bubbleUpMinHeap(vt::AbstractVector{T},i::Int64) where {T}
    if i == 1; return; end
    j::Int64 = i >> 1
    if vt[j] > vt[i]; vt[i],vt[j] = vt[j],vt[i]; _bubbleUpMinHeap(vt,j); end
end

function _bubbleDownMinHeap(vt::AbstractVector{T},i::Int64) where {T}
    len::Int64 = length(vt)
    l::Int64 = i << 1; r::Int64 = l + 1
    res1::Bool = l > len || vt[i] <= vt[l]
    res2::Bool = r > len || vt[i] <= vt[r]
    if res1 && res2; return;
    elseif res1; vt[i],vt[r] = vt[r],vt[i]; _bubbleDownMinHeap(vt,r)
    elseif res2; vt[i],vt[l] = vt[l],vt[i]; _bubbleDownMinHeap(vt,l)
    elseif vt[l] <= vt[r]; vt[i],vt[l] = vt[l],vt[i]; _bubbleDownMinHeap(vt,l)
    else   vt[i],vt[r] = vt[r],vt[i]; _bubbleDownMinHeap(vt,r)
    end
end

function _minHeapify(vt::AbstractVector{T}) where {T}
    len = length(vt)
    for i in 2:len; _bubbleUpMinHeap(vt,i); end
end

mutable struct MinHeap{T}
    valtree::Vector{T}
    MinHeap{T}() where {T} = new{T}(Vector{T}())
    function MinHeap{T}(xs::AbstractVector{T}) where {T}
        valtree = copy(xs)
        _minHeapify(valtree)
        new{T}(valtree)
    end
end
Base.length(h::MinHeap)  = length(h.valtree)
Base.isempty(h::MinHeap) = isempty(h.valtree)
top(h::MinHeap{T}) where {T} = h.valtree[1]
function Base.sizehint!(h::MinHeap{T},s::Integer) where {T}
    sizehint!(h.valtree,s); return h
end

function Base.push!(h::MinHeap{T},v::T) where {T} 
    push!(h.valtree,v)
    _bubbleUpMinHeap(h.valtree,length(h.valtree))
    return h
end

function Base.pop!(h::MinHeap{T}) where {T}
    v = h.valtree[1]
    xx = pop!(h.valtree)
    if length(h.valtree) >= 1
        h.valtree[1] = xx
        _bubbleDownMinHeap(h.valtree,1)
    end
    return v
end

######################################################################################################
### BEGIN END CODE
######################################################################################################

mutable struct Asteroid
    idx::I
    numSubnodes::I
    subnodeIntervals::Vector{Tuple{F,F}}
    arcs::Vector{Vector{Tuple{F,F,I}}} 
end
Asteroid() = Asteroid(-1,0,[],[])

function calcIt(dist::F,x::F,y::F,z::F,vx::F,vy::F,vz::F)::Tuple{F,F}
    ### Quadratic is (x+vx*t)^2 + (y+vy*t)^2 + (z+vz*t)^2 == d^2
    a::F = vx^2 + vy^2 + vz^2
    if a < 1e-6
        return x*x+y*y+z*z <= dist*dist ? (-1e9,1e9) : (-1e0,-1e0)
    end
    b::F = 2 * (x*vx+y*vy+z*vz)
    c::F = x^2+y^2+z^2-dist^2
    disc::F = b*b-4*a*c
    if disc < 0; return (-1e0,-1e0); end
    sqrtdisc::F = sqrt(disc)
    oneover2a::F = 0.5/a
    return (oneover2a*(-b-sqrtdisc),oneover2a*(-b+sqrtdisc))
end

function tryIt(dist::F,N::I,S::I,x0::VF,y0::VF,z0::VF,vx::VF,vy::VF,vz::VF)::Bool
    ## Step1: For each pair of planets, need to calculate the interval of time in which they are within
    ##        dist of each other.
    arcs::Vector{Vector{Tuple{F,F,I}}} = [ Vector{Tuple{F,F,I}}() for i in 1:N ]
    for i::I in 1:N-1
        for j::I in i+1:N
            op::Tuple{F,F} = calcIt(dist,x0[j]-x0[i],y0[j]-y0[i],z0[j]-z0[i],vx[j]-vx[i],vy[j]-vy[i],vz[j]-vz[i])
            if op[2] <= 0; continue; end
            push!(arcs[i],(op[1],op[2],j))
            push!(arcs[j],(op[1],op[2],i))            
        end
    end

    ## Step2: We need to split the nodes that are isolated with the S gaps.  This won't create edges, but
    ##        it could explode the node count to O(V^2).
    gr::Vector{Asteroid} = [Asteroid() for x in 1:N]
    for i::I in 1:N
        a::Vector{Tuple{F,F,I}} = arcs[i]
        if length(a) == 0; continue; end
        sort!(a)  ## Prob worst line in here
        ii::I = 1
        while(ii <= length(a))
            jj::I = ii
            si::F = max(0.0,a[ii][1])
            ei::F = a[ii][2]+S
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
    b = MinHeap{Tuple{F,I}}()
    push!(b,(0.0,1))
    while !isempty(b)
        (t::Float64,n::Int64) = pop!(b)
        if n == 2; return true; end
        ast::Asteroid = gr[n]
        if ast.idx > 0 && ast.subnodeIntervals[ast.idx][2] >= t; continue; end
        if ast.idx < 0; gr[n].idx = 1; end
        while t > ast.subnodeIntervals[ast.idx][2]; ast.idx += 1; end

        for arc in ast.arcs[ast.idx]
            if t > arc[2]; continue; end
            launchTime::Float64 = max(t,arc[1])
            push!(b,(launchTime,arc[3]))
        end
    end
    return false
end

######################################################################################################
### 1) We can always jump to a planet and immediately jump back, so the S constraint really just
###    applies if we get stuck on an asteroid and can't jump.  For this case, we just split the nodes
### 2) We do a binary search on the distance    
######################################################################################################

function solve(N::I,S::I,x0::VF,y0::VF,z0::VF,vx::VF,vy::VF,vz::VF)::F
    lb::F,ub::F = 0.0,1000.0*sqrt(3.0)
    while (ub-lb) > 1e-4
        mid = 0.5*(ub+lb)
        if tryIt(mid,N,S,x0,y0,z0,vx,vy,vz); ub = mid; else lb = mid; end
    end
    return 0.5*(ub+lb)
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,S = gis()
        x0::VF = fill(0.0,N)
        y0::VF = fill(0.0,N)
        z0::VF = fill(0.0,N)
        vx::VF = fill(0.0,N)
        vy::VF = fill(0.0,N)
        vz::VF = fill(0.0,N)
        for i in 1:N
            x0[i],y0[i],z0[i],vx[i],vy[i],vz[i] = gfs()
        end
        ans = solve(N,S,x0,y0,z0,vx,vy,vz)
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


