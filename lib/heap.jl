using Random
## Type Shortcuts (to save my wrists and fingers :))
const I = Int64; const VI = Vector{I}; const SI = Set{I}; const PI = NTuple{2,I};
const TI = NTuple{3,I}; const QI = NTuple{4,I}; const VPI = Vector{PI}; const SPI = Set{PI}
const F = Float64; const VF = Vector{F}; const PF = NTuple{2,F}

######################################################################################################
### BEGIN MinHeapEnh -- Enhance MinHeap with decrease key implemented by just running pop again
######################################################################################################

struct MinHeapNodeEnh; n::I; v::I; end
Base.isless(a::MinHeapNodeEnh,b::MinHeapNodeEnh) = a.v < b.v

struct MinHeapEnh
    valtree::Vector{MinHeapNodeEnh}; pos::VI
    MinHeapEnh(N::I) = new([],fill(0,N))
end

function _swap(h::MinHeapEnh,i::I,j::I)
    (n1::I,n2::I) = (h.valtree[i].n,h.valtree[j].n)
    h.pos[n2],h.pos[n1] = i,j
    h.valtree[i],h.valtree[j] = h.valtree[j],h.valtree[i]
end

function _bubbleUp(h::MinHeapEnh, i::I)
    if i == 1; return; end
    j::I = i >> 1; if h.valtree[i] < h.valtree[j]; _swap(h,i,j); _bubbleUp(h,j); end
end

function _bubbleDown(h::MinHeapEnh,i::I)
    len::I = length(h.valtree); l::I = i << 1; r::I = l + 1
    res1::Bool = l > len || !(h.valtree[i] > h.valtree[l])
    res2::Bool = r > len || !(h.valtree[i] > h.valtree[r])
    if res1 && res2; return
    elseif res2 || !res1 && !(h.valtree[l] > h.valtree[r]); _swap(h,i,l); _bubbleDown(h,l)
    else; _swap(h,i,r); _bubbleDown(h,r)
    end
end

function Base.push!(h::MinHeapEnh,node::MinHeapNodeEnh)
    n::I = node.n; idx::I = h.pos[n]
    if idx == 0; push!(h.valtree,node); idx = length(h.valtree); h.pos[n] = idx
    elseif h.valtree[idx] > node; h.valtree[idx] = node
    end
    _bubbleUp(h,idx)
end

function Base.pop!(h::MinHeapEnh)
    ans::MinHeapNodeEnh = h.valtree[1]; h.pos[ans.n] = 0
    node2::MinHeapNodeEnh = pop!(h.valtree)
    if length(h.valtree) >= 1; h.pos[node2.n] = 1; h.valtree[1] = node2; _bubbleDown(h,1); end
    return ans
end

Base.isempty(h::MinHeapEnh) = isempty(h.valtree)

######################################################################################################
### END MinHeapEnh
######################################################################################################



######################################################################################################
### BEGIN MaxHeapEnh -- Enhance MinHeap with decrease key implemented by just running pop again
######################################################################################################

struct MaxHeapNodeEnh; n::I; v::I; end
Base.isless(a::MaxHeapNodeEnh,b::MaxHeapNodeEnh) = a.v < b.v

struct MaxHeapEnh
    valtree::Vector{MaxHeapNodeEnh}; pos::VI
    MaxHeapEnh(N::I) = new([],fill(0,N))
end

function _swap(h::MaxHeapEnh,i::I,j::I)
    (n1::I,n2::I) = (h.valtree[i].n,h.valtree[j].n)
    h.pos[n2],h.pos[n1] = i,j
    h.valtree[i],h.valtree[j] = h.valtree[j],h.valtree[i]
end

function _bubbleUp(h::MaxHeapEnh, i::I)
    if i == 1; return; end
    j::I = i >> 1; if h.valtree[i] > h.valtree[j]; _swap(h,i,j); _bubbleUp(h,j); end
end

function _bubbleDown(h::MaxHeapEnh,i::I)
    len::I = length(h.valtree); l::I = i << 1; r::I = l + 1
    res1::Bool = l > len || !(h.valtree[i] < h.valtree[l])
    res2::Bool = r > len || !(h.valtree[i] < h.valtree[r])
    if res1 && res2; return
    elseif res2 || !res1 && !(h.valtree[l] < h.valtree[r]); _swap(h,i,l); _bubbleDown(h,l)
    else; _swap(h,i,r); _bubbleDown(h,r)
    end
end

function Base.push!(h::MaxHeapEnh,node::MaxHeapNodeEnh)
    n::I = node.n; idx::I = h.pos[n]
    if idx == 0; push!(h.valtree,node); idx = length(h.valtree); h.pos[n] = idx
    elseif h.valtree[idx] < node; h.valtree[idx] = node
    end
    _bubbleUp(h,idx)
end

function Base.pop!(h::MaxHeapEnh)
    ans::MaxHeapNodeEnh = h.valtree[1]; h.pos[ans.n] = 0
    node2::MaxHeapNodeEnh = pop!(h.valtree)
    if length(h.valtree) >= 1; h.pos[node2.n] = 1; h.valtree[1] = node2; _bubbleDown(h,1); end
    return ans
end

Base.isempty(h::MaxHeapEnh) = isempty(h.valtree)

######################################################################################################
### END MaxHeapEnh
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
### BEGIN END CODE
######################################################################################################
