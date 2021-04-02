using Printf

######################################################################################################
### a) One key observation is that every square x is limited by min(B(vi) + D(vi,x)) where D is the
###    Manhattan distance.  This is a necessary condition.
### b) It isn't too hard to see that if all of the fixed values are consistent with this minimum
###    (i.e. they are limited by this brightness value), then the necessary condition is also a
###    sufficient condition, for the condition guarantees that adjacent squared cannot differ by
###    more than D.
### c) For the small, we merely need to check the pairs to see if they are compatible, and then we
###    construct the array of distances.  O(R*C*N)
### d) We can improve on the runetime by computing a "min distance" from a root node, where each fixed
###    cell has its distance fixed and the edge cost to adjacent cells is D.  This is functionaly
###    equivalent to the other approach, but it is slightly more efficient using Dijkstra
######################################################################################################


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
### END MINHEAP CODE
######################################################################################################
            
MOD = 1000000007
function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        R,C,N,D = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        RR = fill(zero(Int64),N)
        CC = fill(zero(Int64),N)
        BB = fill(zero(Int64),N)
        for i in 1:N
            RR[i],CC[i],BB[i] = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        end
        ans = 0
        ansarr = fill(-1,R,C)
        mh = MinHeap{Tuple{Int64,Int64,Int64}}()
        for i in 1:N; push!(mh,(BB[i],RR[i],CC[i])); end
        while !isempty(mh)
            (d,i,j) = pop!(mh)
            if ansarr[i,j] >= 0; continue; end
            ansarr[i,j] = d
            ans = (ans + d) % 1_000_000_007
            if i > 1; push!(mh,(d+D,i-1,j)); end
            if i < R; push!(mh,(d+D,i+1,j)); end
            if j > 1; push!(mh,(d+D,i,j-1)); end
            if j < C; push!(mh,(d+D,i,j+1)); end
        end
        good = true
        for idx in 1:N
            (i,j,v) = (RR[idx],CC[idx],BB[idx])
            if ansarr[i,j] == v; continue; end
            good = false
            break
        end
        if good
            print("$ans\n")
            for i in 1:R
                row = join([@sprintf("%2d",ansarr[i,j]) for j in 1:C], " ")
                println(row)
            end
        else
            print("IMPOSSIBLE\n")
        end
    end
end

main()
