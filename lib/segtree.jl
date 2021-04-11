const I = Int64; const VI = Vector{I}; const SI = Set{I}; const PI = NTuple{2,I};
const TI = NTuple{3,I}; const QI = NTuple{4,I}; const VPI = Vector{PI}; const SPI = Set{PI}
const VC = Vector{Char}; const VS = Vector{String}; VB = Vector{Bool}; VVI = Vector{Vector{Int64}}
const F = Float64; const VF = Vector{F}; const PF = NTuple{2,F}

################################################################################
## BEGIN: segTreeRMQ with a max combine function
################################################################################

mutable struct segTreeRMQ; tree::Vector{Int32}; lazy::Vector{Int32}; l::I; r::I; end
function updateLazy(h::segTreeRMQ,idx::I,l::I,r::I)
    h.tree[idx] = max(h.tree[idx],h.lazy[idx])
    if r > l
        ii = 2idx
        h.lazy[ii]   = max(h.lazy[idx],h.lazy[ii])
        h.lazy[ii+1] = max(h.lazy[idx],h.lazy[ii+1])
    end
    h.lazy[idx] = 0
end

function rmq(h::segTreeRMQ,idx::I,l::I,r::I,x::I,y::I)::Int32 
    if h.lazy[idx] != 0; updateLazy(h,idx,l,r); end
    ans::Int32 = Int32(1_000_000_000)
    if r < x || y < l
        1
    elseif x <= l && r <= y
        ans = h.tree[idx]
    else
        m::I = (l+r)>>1
        v1 = rmq(h,2idx,l,m,x,y)
        v2 = rmq(h,2idx+1,m+1,r,x,y)
        h.tree[idx] = min(h.tree[2idx],h.tree[2idx+1])
        ans = min(v1,v2)
    end
    return ans
end
rmq(h::segTreeRMQ,x::I,y::I)::Int32 = rmq(h,1,h.l,h.r,x,y) 

function update(h::segTreeRMQ,idx::I,l::I,r::I,x::I,y::I,v::Int32)
    if h.lazy[idx] != 0; updateLazy(h,idx,l,r); end
    if r < x || y < l
        1
    elseif x <= l && r <= y
        h.tree[idx] = max(h.tree[idx],v)
        if r > l
            h.lazy[2idx] = max(h.lazy[2idx],v)
            h.lazy[2idx+1] = max(h.lazy[2idx+1],v)
        end
    else
        m::I = (l+r)>>1
        update(h,2idx,l,m,x,y,v)
        update(h,2idx+1,m+1,r,x,y,v)
        h.tree[idx] = min(h.tree[2idx],h.tree[2idx+1])
    end
end
update(h::segTreeRMQ,x::I,y::I,v::Int32) = update(h,1,h.l,h.r,x,y,v) 

################################################################################
## END: segTreeRMQ with a max combine function
################################################################################



################################################################################
## BEGIN: segTreeRMQ with a increment function
################################################################################

mutable struct segTreeRMQInc; tree::VI; lazy::VI; l::I; r::I; end

function segTreeRMQInc(l::I,r::I)
    stsize = 1; while stsize < (r-l+1); stsize *= 2; end; stsize *= 2
    return segTreeRMQInc(fill(0,stsize),fill(0,stsize),l,r)
end

function updateLazy(h::segTreeRMQInc,idx::I,l::I,r::I)
    h.tree[idx] = h.tree[idx] += h.lazy[idx]
    if r > l
        ii = 2idx
        h.lazy[ii]   = h.lazy[idx] + h.lazy[ii]
        h.lazy[ii+1] = h.lazy[idx] + h.lazy[ii+1]
    end
    h.lazy[idx] = 0
end

function rmq(h::segTreeRMQInc,idx::I,l::I,r::I,x::I,y::I)::Int32 
    if h.lazy[idx] != 0; updateLazy(h,idx,l,r); end
    ans::Int32 = Int32(1_000_000_000)
    if r < x || y < l
        1
    elseif x <= l && r <= y
        ans = h.tree[idx]
    else
        m::I = (l+r)>>1
        v1 = rmq(h,2idx,l,m,x,y)
        v2 = rmq(h,2idx+1,m+1,r,x,y)
        h.tree[idx] = min(h.tree[2idx],h.tree[2idx+1])
        ans = min(v1,v2)
    end
    return ans
end
rmq(h::segTreeRMQInc,x::I,y::I)::Int32 = rmq(h,1,h.l,h.r,x,y) 

function inc(h::segTreeRMQInc,idx::I,l::I,r::I,x::I,y::I,v::I)
    if h.lazy[idx] != 0; updateLazy(h,idx,l,r); end
    if r < x || y < l
        return
    elseif x <= l && r <= y
        h.tree[idx] += v
        if r > l
            h.lazy[2idx] += v
            h.lazy[2idx+1] += v
        end
    else
        m::I = (l+r)>>1
        inc(h,2idx,l,m,x,y,v)
        inc(h,2idx+1,m+1,r,x,y,v)
        h.tree[idx] = min(h.tree[2idx],h.tree[2idx+1])
    end
end
inc(h::segTreeRMQInc,x::I,y::I,v::I) = inc(h,1,h.l,h.r,x,y,v) 

################################################################################
## END: segTreeRMQ with a max combine function
################################################################################







######################################## END BOILERPLATE CODE ########################################

struct SegTree
    maxval::II
    lazy::VI
    minv::VI
end

function SegTree(maxv::II)
    a::II = 1; while a < maxv; a *= 2; end;  a *= 2
    lz::VI = fill(0,a)
    minv::VI = fill(0,a)
    return SegTree(maxv,lz,minv)
end

function _stinc(st::SegTree,idx::II,l::II,r::II,a::II,b::II,v::II)
    if a > r || b < l; return; end
    if a <= l && r <= b; st.lazy[idx] += v; return; end
    idxl::II = 2idx; idxr::II = idxl+1; m::II = (l+r)>>1
    _stinc(st,idxl,l,m,a,b,v)
    _stinc(st,idxr,m+1,r,a,b,v)
    st.minv[idx] = min(st.minv[idxl]+st.lazy[idxl],st.minv[idxr]+st.lazy[idxr])
end

function _strmq(st::SegTree,idx::II,l::II,r::II,a::II,b::II)::II
    if a > r || b < l; return 1_000_000_000_000_000_000; end
    if a <= l && r <= b; return st.minv[idx]+st.lazy[idx]; end
    idxl::II = 2idx; idxr::II = idxl+1; m::II = (l+r)>>1
    st.lazy[idxl] += st.lazy[idx]; st.lazy[idxr] += st.lazy[idx]; st.lazy[idx] = 0
    v1::II = _strmq(st,idxl,l,m,a,b)
    v2::II = _strmq(st,idxr,m+1,r,a,b)
    st.minv[idx] = min(st.minv[idxl]+st.lazy[idxl],st.minv[idxr]+st.lazy[idxr])
    return min(v1,v2)
end

stinc(st::SegTree,a::II,b::II,v::II) = _stinc(st,1,1,st.maxval,a,b,v)
strmq(st::SegTree,a::II,b::II)       = _strmq(st,1,1,st.maxval,a,b)

######################################## END SEGTREE CODE ########################################
