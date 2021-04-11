
using Random

mutable struct Stnode
    width::Int64
    activeWidth::Int64
    numRects::Int64
end

mutable struct hashEngine
    val::Int64
    base::Int64
    baseinv::Int64
    hist::Vector{Int64}
    p::Int64
    pv::Int64
end

function daveSort!(v::AbstractVector)
    return daveQuickSort!(v,1,length(v))
end

function daveInsertionSort!(v::AbstractVector, lo::Integer, hi::Integer)
    @inbounds for i in lo+1:hi
        j=i; x=v[i]
        while j > lo
            if x < v[j-1]; v[j] = v[j-1]; j-=1; continue; end
            break
        end
        v[j] = x
    end
    return v
end

@inline function daveSelectPivot!(v::AbstractVector, lo::Integer, hi::Integer)
    @inbounds begin
        mi = lo + ((hi-lo) >>> 0x01)
        if v[lo] < v[mi]; v[mi],v[lo]=v[lo],v[mi]; end
        if v[hi] < v[lo] 
            if v[hi] < v[mi]
                v[hi], v[lo], v[mi] = v[lo], v[mi], v[hi]
            else
                v[hi], v[lo] = v[lo], v[hi]
            end
        end
        return v[lo]
    end
end

function davePartition!(v::AbstractVector, lo::Integer, hi::Integer)
    pivot = daveSelectPivot!(v, lo, hi)
    i, j = lo, hi
    @inbounds while true
        i += 1; j -= 1
        while v[i] < pivot; i += 1; end;
        while pivot < v[j]; j -= 1; end;
        i >= j && break
        v[i], v[j] = v[j], v[i]
    end
    v[j], v[lo] = pivot, v[j]
    return j
end

function daveQuickSort!(v::AbstractVector, lo::Integer, hi::Integer)
    @inbounds while lo < hi
        hi-lo <= 20 && return daveInsertionSort!(v, lo, hi)
        j = davePartition!(v, lo, hi)
        if j-lo < hi-j
            lo < (j-1) && daveQuickSort!(v, lo, j-1)
            lo = j+1
        else
            j+1 < hi && daveQuickSort!(v, j+1, hi)
            hi = j-1
        end
    end
    return v
end

initHashEngine(base::Int64,p::Int64)::hashEngine = hashEngine(0,base,invmod(base,p),Vector{Int64}(),p,1)

function Base.push!(he::hashEngine,v::Int64)
    push!(he.hist,v)
    xx::Int64 = (he.pv * v) % he.p
    he.val = (he.val + xx) % he.p
    he.pv = (he.pv * he.base) % he.p
end

function Base.pop!(he::hashEngine)
    v::Int64 = popfirst!(he.hist)
    he.val = (he.val + he.p - v) % he.p
    he.val = (he.val * he.baseinv) % he.p
    he.pv = (he.pv * he.baseinv) % he.p
end

mutable struct myAVLDict
    numNodes::Int32
    maxNodes::Int32
    keys::Vector{Int64}
    vals::Vector{Int32}
    left::Vector{Int32}
    right::Vector{Int32}
    ht::Vector{Int8}
    scratch::Vector{Int32}
    myAVLDict() = new(0,0,[],[],[],[],[],[])
end

function init(dd::myAVLDict,maxNodes::Int64)
    dd.numNodes = 0
    dd.maxNodes = Int32(maxNodes)
    dd.keys  = fill(0,maxNodes)
    dd.vals  = fill(Int32(0),maxNodes)
    dd.left  = fill(Int32(0),maxNodes)
    dd.right = fill(Int32(0),maxNodes)
    dd.ht    = fill(Int8(0),maxNodes)
end

function reset(dd::myAVLDict)
    for i in 1:dd.numNodes
        dd.keys[i] = 0
        dd.vals[i] = Int32(0)
        dd.left[i] = Int32(0)
        dd.right[i] = Int32(0)
        dd.ht[i] = Int8(0)
    end
    dd.numNodes = 0
end

getHt(dd::myAVLDict,n::Int32) = n == 0 ? 0 : dd.ht[n]

function updateHeight(dd::myAVLDict,n::Int32)
    if n == 0; return; end
    dd.ht[n] = 1 + max(getHt(dd,dd.left[n]),getHt(dd,dd.right[n]))
end 

function rotLeft(dd::myAVLDict,z::Int32)
    y = dd.right[z]
    (t1,t2,t3) = (dd.left[z],dd.left[y],dd.right[y])
    (dd.keys[y],dd.keys[z]) = (dd.keys[z],dd.keys[y])
    (dd.vals[y],dd.vals[z]) = (dd.vals[z],dd.vals[y])
    dd.left[y] = t1; dd.right[y] = t2
    dd.left[z] = y; dd.right[z] = t3
    updateHeight(dd,y); updateHeight(dd,z)
end

function rotRight(dd::myAVLDict,z::Int32)
    y = dd.left[z]
    (t1,t2,t3) = (dd.right[z],dd.right[y],dd.left[y])
    (dd.keys[y],dd.keys[z]) = (dd.keys[z],dd.keys[y])
    (dd.vals[y],dd.vals[z]) = (dd.vals[z],dd.vals[y])
    dd.right[y] = t1; dd.left[y] = t2
    dd.right[z] = y; dd.left[z] = t3
    updateHeight(dd,y); updateHeight(dd,z)
end

function insertKV(dd::myAVLDict,k::Int64,v::Int32)
    dd.numNodes += 1
    dd.keys[dd.numNodes] = k
    dd.vals[dd.numNodes] = v
    dd.ht[dd.numNodes] = 1
    if dd.numNodes == 1; return; end
    scratch::Vector{Int32} = dd.scratch; n::Int32 = Int32(1)
    leftFlag::Bool = true
    while true
        if k < dd.keys[n]
            if dd.left[n] > 0; push!(scratch,n); n = dd.left[n]; else; leftFlag = true; break; end
        else 
            if dd.right[n] > 0; push!(scratch,n); n = dd.right[n]; else; leftFlag = false; break; end
        end
    end
    if leftFlag; dd.left[n] = dd.numNodes; else; dd.right[n] = dd.numNodes; end
    ht::Int8 = Int8(2)
    htinc::Int8 = Int8(1)
    if dd.ht[n] >= ht; empty!(scratch); return; end
    dd.ht[n] = ht
    while !isempty(scratch)
        n = pop!(scratch)
        ht += htinc
        if dd.ht[n] >= ht; break; end
        l = dd.left[n]
        r = dd.right[n]
        lht = l == Int32(0) ? Int8(0) : dd.ht[l]
        rht = r == Int32(0) ? Int8(0) : dd.ht[r]
        if lht > rht+htinc
            l2 = dd.left[l]
            if l2 > 0 && dd.ht[l2]+htinc == lht; rotRight(dd,n); else; rotLeft(dd,l); rotRight(dd,n); end
            break
        elseif rht > lht+htinc
            r2 = dd.right[r]
            if r2 > 0 && dd.ht[r2]+htinc == rht; rotLeft(dd,n); else; rotRight(dd,r); rotLeft(dd,n); end
            break
        end
        dd.ht[n] = ht
    end
    empty!(scratch)
end

function searchKey(dd::myAVLDict,k::Int64)
    if dd.numNodes == 0; return 0; end
    n::Int32 = Int32(1)
    nz::Int32 = Int32(0)
    keys::Vector{Int64} = dd.keys
    left::Vector{Int32} = dd.left
    right::Vector{Int32} = dd.right
    while (n != nz)
        kk::Int64 = keys[n]
        if k == kk; break; end
        n = k < kk ? left[n] : right[n]
    end
    return n
end

Base.haskey(dd::myAVLDict,k::Int64) = searchKey(dd,k) != 0

function getValue(dd::myAVLDict,k::Int64)::Int32
    n = searchKey(dd,k); return n == 0 ? Int32(-1) : dd.vals[n]
end

function setValue(dd::myAVLDict,k::Int64,v::Int32)
    n = searchKey(dd,k)
    if n == 0; insertKV(dd,k,v); else; dd.vals[n] = v; end
end

function coordinateTransform(N::Int64,X::Vector{Int64},Y::Vector{Int64})::Tuple{Vector{Int64},Vector{Int64}}
    points::Vector{Tuple{Int64,Int64}} = []
    for i in 1:N; x = X[i]; y = Y[i]; push!(points,(x-y,x+y)); end
    sort!(points)
    XX::Vector{Int64} = fill(0,N)
    YY::Vector{Int64} = fill(0,N)
    for i in 1:N; (XX[i],YY[i]) = points[i]; end
    return(XX,YY)
end

function genLargeDataStructure()
    allrect::Vector{NTuple{4,Int32}} = fill((Int32(0),Int32(0),Int32(0),Int32(0)),2*1687*1687)
    prevrect::Vector{Int32} = fill(Int32(0),2*1687*1687)
    h::Dict{Int64,Int32} = Dict{Int64,Int32}()
    segt::Array{Int32,2} = fill(Int32(0),2048*2048*4,4)
    eq::Vector{NTuple{4,Int32}} = fill((Int32(0),Int32(0),Int32(0),Int32(0)),2*1687*1687)
    dd::myAVLDict = myAVLDict()
    init(dd,2*1687*1687)

    #allrect::Vector{NTuple{4,Int32}} = []
    #prevrect::Vector{Int32} = []
    #h::Dict{Int64,Int32} = Dict{Int64,Int32}()
    #segt::Array{Int32,2} = fill(0,16*16*4,4)
    #eq::Vector{NTuple{4,Int32}} = []
    #dd::myAVLDict = myAVLDict()
    #init(dd,2*16*16)

    return (allrect,prevrect,h,segt,eq,dd)
end

function solveLarge(N::Int64,D::Int64,X::Vector{Int64},Y::Vector{Int64},working)::Tuple{Int64,Int64}
    ## Significant storage
    ## Hello world in julia takes up 150M, leaving 850M for our program
    ## 64 bit words ~ 100M words
    ## 32 bit words ~ 200M words
    ## Note N^2 = 2.85M

    ## -- Nmax = 1687
    ## -- Storing all of the rectangles.  The most rectangles I can have is 1+3+5+...+2N-1+...+5+3+1 = N^2 + (N-1)^2 ~ 2N^2.
    ##    We need 4 words per rectange, so this requires 8N^2 words -- 22.7M words
    ## -- Storing all of the hash values.  If we use a tree, we will require (left,right,hash,val) = 4 words per rectangles
    ##    As an upper-bound (which you can get quite close to), we need 2N^2 values, so this requires 8N^2 words -- 22.7M words
    ## -- Grouping the rectanges into sets efficiently.  Storing the previous index of the rectangle in the same set seems
    ##    reasonably efficient.  This requires 2N^2 words == 5.7M words
    ## -- Our segment tree can be required to process N^2 rectangles at the same time.  We ASSUME that we can come close to the
    ##    upper bound of 2N^2 coordinate values.  In each element, we need to store 4 words:
    ##    (width,activeWidth0,activeWidth1,numRects).  Using the 4x upper bound for a segment tree, this requires 32N^2 words,
    ##    910M words.  However, with the current max N of 1687, we only need 2048*2048*2*2 entries, which is around 24N^2 words
    ##    ~68M words
    ## -- Finally, we need an event queue for our segment tree parsing.  We have 2N^2 events, and each event requires 4 words.
    ##    Thus, this requires 8N^2 words

    ## From this, we conclude we need (8+8+2+24+8)N^2 = 50N^2 words (absent algorithm improvement).  Thus, we need to go to
    ## 32 bit words.

    num::Int64 = 0
    denom::Int64 = 0
    DD = Int32(D)
    pts::Vector{Tuple{Int64,Int64}} = [(Int32(X[i]-Y[i]),Int32(X[i]+Y[i])) for i in 1:N]
    daveSort!(pts)

    yvals::Vector{Int32} = [];
    for (x,y) in pts; push!(yvals,y-DD); push!(yvals,y+DD); end
    unique!(daveSort!(yvals))
    he1 = initHashEngine(40000007,1000000007)
    he2 = initHashEngine(40000007,1000000033)

    (allrect::Vector{NTuple{4,Int32}}, prevrect::Vector{Int32}, h::Dict{Int64,Int32},
       segt::Array{Int32,2}, eq::Vector{NTuple{4,Int32}}, dd::myAVLDict) = working
    empty!(h)
    empty!(allrect)
    empty!(prevrect)
    empty!(eq)
    reset(dd)

    xlocs::Vector{Int32} = []; sizehint!(xlocs,2*N)

    ## Part 1
    for i in 1:length(yvals)-1
        yl = yvals[i]; yr = yvals[i+1]
        for (x,y) in pts
            if y <= yl-DD || y >= yr+DD; continue; end
            push!(eq,(x-DD,Int32(1),x,y))
            push!(eq,(x+DD,Int32(-1),x,y))
        end
        if isempty(eq); continue; end
        daveSort!(eq)
        empty!(xlocs)
        push!(xlocs,eq[1][1])
        for (xloc,t,x,y) in eq; if xlocs[end] == xloc; continue; end; push!(xlocs,xloc); end
        cnt = 0
        last = (Int32(0),Int32(0))
        for (j,xloc) in enumerate(xlocs)
            while !isempty(eq) && eq[1][1] == xloc
                (_xloc,type,x,y) = popfirst!(eq)
                if type == -1 && cnt > 1
                    pop!(he1); pop!(he2); pop!(he1); pop!(he2)
                    cnt -= 1
                elseif type == -1 && cnt == 1
                    cnt -= 1
                elseif type == 1 && cnt > 0
                    (dx,dy) = (20000001+x-last[1],20000001+y-last[2])
                    push!(he1,dx); push!(he2,dx); push!(he1,dy); push!(he2,dy)
                    last = (x,y)
                    cnt += 1
                else
                    last = (x,y)
                    cnt += 1
                end
            end
            if cnt > 0
                hashval = (1<<32)*he1.val+he2.val
                x1 = xloc - last[1]
                y1 = yl - last[2]
                x2 = x1 + (xlocs[j+1]-xlocs[j])
                y2 = y1 + (yr-yl)
                denom += Int64(x2-x1)*Int64(y2-y1)
                push!(allrect,(x1,y1,x2,y2))
                nn = Int32(length(allrect))
                #push!(prevrect, haskey(h,hashval) ? h[hashval] : Int32(0))
                #h[hashval] = nn
                push!(prevrect, haskey(dd,hashval) ? getValue(dd,hashval) : Int32(0))
                setValue(dd,hashval,nn)
            end
        end
    end
    yy::Vector{Int32} = []
    for _ii in 1:dd.numNodes
        v = dd.vals[_ii]
        empty!(yy)
        empty!(eq)
        vv = v; while vv != 0; push!(yy,allrect[vv][2]); push!(yy,allrect[vv][4]); vv = prevrect[vv]; end
        unique!(daveSort!(yy))
        vv = v
        while vv != 0
            y1 = findyidx(allrect[vv][2],yy); y2 = findyidx(allrect[vv][4],yy)
            push!(eq,(allrect[vv][1],Int32(1),y1,y2-Int32(1)))
            push!(eq,(allrect[vv][3],Int32(-1),y1,y2-Int32(1)))
            vv = prevrect[vv]
        end
        daveSort!(eq)
        stsize = 1; while stsize < length(yy)-1; stsize *= 2; end; stsize *= 2
        segt[1:stsize,:] .= 0
        initWidth(segt,yy,1,length(yy)-1,1)
        last = -1_500_000_000
        while !isempty(eq)
            if eq[1][1] != last
                num += Int64(segt[1,3]) * Int64(eq[1][1]-last)
                last = eq[1][1]
            end
            (x,inc,ya,yb) = popfirst!(eq)
            doinc(segt,1,length(yy)-1,1,inc,ya,yb)
        end
    end
    g = gcd(num,denom); num ÷= g; denom ÷= g
    return (num,denom)
end

function initWidth(segt::Array{Int32,2},yy::Vector{Int32},l::Int64,r::Int64,idx::Int64)
    if l == r
        segt[idx,1] = yy[l+1]-yy[l]
    else 
        m = (l+r)>>1
        initWidth(segt,yy,l,m,2idx)
        initWidth(segt,yy,m+1,r,2idx+1)
        segt[idx,1] = segt[2idx,1]+segt[2idx+1,1]
    end
    segt[idx,2] = segt[idx,1]
end

function findyidx(yyy::Int32,yy::Vector{Int32})::Int32
    if yy[1] == yyy; return Int32(1); end
    if yy[end] == yyy; return Int32(length(yy)); end
    l::Int64,u::Int64 = 1,length(yy)
    while(true)
        m::Int64 = (u+l)>>1
        if yy[m] == yyy; return Int32(m); end
        if yy[m] < yyy; l = m; else; u = m; end
    end
end

function doinc(segt::Array{Int32,2},l::Int64,r::Int64,idx::Int64,inc::Int32,yl::Int32,yr::Int32)
    if yr < l || r < yl; return; end
    a::Int64 = 2*idx; b::Int64 = a+1; m::Int64 = (l+r) >> 1
    if yl <= l && r <= yr
        segt[idx,4] += inc
    else
        doinc(segt,l,m,a,inc,yl,yr)
        doinc(segt,m+1,r,b,inc,yl,yr)
    end
    ## activeWidth0
    segt[idx,2] = segt[idx,4] > 0 ? 0 : l==r ? segt[idx,1] : segt[a,2]+segt[b,2]

    ## activeWidth1                       
    segt[idx,3] = l==r ? (segt[idx,4] == 1 ? segt[idx,1] : 0) :
                    segt[idx,4] > 1 ? 0 : segt[idx,4] == 1 ? segt[a,2]+segt[b,2] : segt[a,3]+segt[b,3]
end

function solveMid(N::Int64,D::Int64,X::Vector{Int64},Y::Vector{Int64})::Tuple{Int64,Int64}
    num = 0
    denom = 0
    (XX::Vector{Int64},YY::Vector{Int64}) = coordinateTransform(N,X,Y)
    xvals = Set{Int64}()
    yvals = Set{Int64}()
    for i in 1:N; push!(xvals,XX[i]-D); push!(xvals,XX[i]+D); end
    for i in 1:N; push!(yvals,YY[i]-D); push!(yvals,YY[i]+D); end
    xvals2::Vector{Int64} = sort([x for x in xvals])
    yvals2::Vector{Int64} = sort([y for y in yvals])
    signatures::Dict{Tuple{Int64,Int64},Vector{Tuple{Int64,Int64}}} = Dict{Tuple{Int64,Int64},Vector{Tuple{Int64,Int64}}}()
    for i in 1:length(xvals2)-1
        for j in 1:length(yvals2)-1
            points::Vector{Tuple{Int64,Int64}} = []
            x = xvals2[i]; x2 = xvals2[i+1]; y = yvals2[j]; y2 = yvals2[j+1]
            for k in 1:N
                xx = XX[k]; yy = YY[k]
                if xx <= x - D || xx > x + D; continue; end
                if yy <= y - D || yy > y + D; continue; end
                push!(points,(xx-x,yy-y))
            end
            if length(points) == 0; continue; end
            denom += (x2-x)*(y2-y)
            signatures[(i,j)] = points
        end
    end

    rectangles::Vector{Tuple{Int64,Int64,Int64,Int64}} = []
    for i in 1:length(xvals2)-1
        for j in 1:length(yvals2)-1
            if !haskey(signatures,(i,j)); continue; end
            info1 = signatures[(i,j)]
            (xa1,ya1,xa2,ya2) = (xvals2[i],yvals2[j],xvals2[i+1],yvals2[j+1])
            for k in 1:length(xvals2)-1
                for l in 1:length(yvals2)-1
                    if i == k && j == l; continue; end
                    if !haskey(signatures,(k,l)); continue; end
                    info2 = signatures[(k,l)]
                    if length(info1) != length(info2); continue; end
                    offset = (info2[1][1]-info1[1][1],info2[1][2]-info1[1][2])
                    good = true
                    for m in 2:length(info1)
                        if info2[m][1] - info1[m][1] != offset[1]; good = false; break; end
                        if info2[m][2] - info1[m][2] != offset[2]; good = false; break; end
                    end
                    if !good; continue; end
                    (xb1,yb1,xb2,yb2) = (xvals2[k],yvals2[l],xvals2[k+1],yvals2[l+1])
                    xc1 = xa1 + info1[1][1] - info2[1][1]
                    yc1 = ya1 + info1[1][2] - info2[1][2]
                    xc2 = xc1 + (xb2-xb1)
                    yc2 = yc1 + (yb2-yb1)

                    xi1 = max(xa1,xc1)
                    yi1 = max(ya1,yc1)
                    xi2 = min(xa2,xc2)
                    yi2 = min(ya2,yc2)
                    if xi2>xi1 && yi2>yi1
                        #print("DBG: (i,j,k,l):($i,$j,$k,$l) (xa1,ya1,xa2,ya2):($xa1,$ya1,$xa2,$ya2) (xi1,yi1,xi2,yi2):($xi1,$yi1,$xi2,$yi2)\n")
                        push!(rectangles,(xi1,yi1,xi2,yi2))
                    end
                end
            end
        end
    end

    (ds::Vector{Stnode},ymax::Int64,eq::Vector{Tuple{Int64,Int64,Int64,Int64}}) = initDs(rectangles)
    last = -1_500_000_000
    while !isempty(eq)
        if eq[1][1] != last
            w = ds[1].activeWidth
            num += w * (eq[1][1]-last)
            last = eq[1][1]
        end
        (x,inc,ya,yb) = popfirst!(eq)
        alterInterval(ds,1,1,ymax,inc,ya,yb)
    end
    num = denom-num  ## We calculated bad locations, so we need to invert to find good locations
    g = gcd(num,denom); num ÷= g; denom ÷= g
    return (num,denom)
end

function alterInterval(ds::Vector{Stnode},idx::Int64,l::Int64,r::Int64,inc::Int64,yl::Int64,yr::Int64)
    #print("DBG enter alterInterval(ds,idx:$idx,l:$l,r:$r,inc:$inc,yl:$yl,yr:$yr\n")
    if yr < l || r < yl; return; end
    a = 2*idx; b = a+1; m = (l+r) >> 1
    if yl <= l && r <= yr
        ds[idx].numRects += inc
    else
        alterInterval(ds,a,l,m,inc,yl,yr)
        alterInterval(ds,b,m+1,r,inc,yl,yr)
    end
    ds[idx].activeWidth = ds[idx].numRects > 0 ? ds[idx].width : l==r ? 0 : ds[a].activeWidth+ds[b].activeWidth
end

function initDs(rectangles::Vector{Tuple{Int64,Int64,Int64,Int64}})
    yvals::Vector{Int64} = []
    for (x1,y1,x2,y2) in rectangles
        push!(yvals,y1)
        push!(yvals,y2)
    end
    unique!(sort!(yvals))
    dslen = 1; while dslen < (length(yvals)-1); dslen *= 2; end; dslen *= 2
    ds::Vector{Stnode} = [Stnode(0,0,0) for i in 1:dslen]
    function _updateWidth(idx::Int64,l::Int64,r::Int64,t::Int64,v::Int64)
        ds[idx].width += v
        (a::Int64,b::Int64,m::Int64) = (2*idx,2*idx+1,(r+l)÷2)
        if r!=l && t <= m;   _updateWidth(a,l,m,t,v); end
        if r!=l && m+1 <= t; _updateWidth(b,m+1,r,t,v); end
    end
    for i in 1:length(yvals)-1; _updateWidth(1,1,length(yvals)-1,i,yvals[i+1]-yvals[i]); end

    d::Dict{Int64,Int64} = Dict{Int64,Int64}()
    for (i,v) in enumerate(yvals); d[v]=i; end
    eq::Vector{Tuple{Int64,Int64,Int64,Int64}} = []
    for (x1,y1,x2,y2) in rectangles
        push!(eq,(x1,1,d[y1],d[y2]-1))
        push!(eq,(x2,-1,d[y1],d[y2]-1))
    end
    sort!(eq)
    return (ds,length(yvals)-1,eq)
end

function test(ntc::Int64,Nmin::Int64,Nmax::Int64,Dmin::Int64,Dmax::Int64,Cmax::Int64,check::Bool=true)
    working = genLargeDataStructure()
    pass = 0
    for ttt in 1:ntc
        N = rand(Nmin:Nmax)
        D = rand(Dmin:Dmax)
        pts::Set{Tuple{Int64,Int64}} = Set{Tuple{Int64,Int64}}()
        while length(pts) < N
            x = rand(-Cmax:Cmax)
            y = rand(-Cmax:Cmax)
            push!(pts,(x,y))
        end
        lpts = [(x,y) for (x,y) in pts]
        shuffle!(lpts)
        X::Vector{Int64} = fill(0,N)
        Y::Vector{Int64} = fill(0,N)
        for i in 1:N; (X[i],Y[i]) = lpts[i]; end
        ans2 = solveLarge(N,D,X,Y,working)
        if check
            ans1 = solveMid(N,D,X,Y)
            if ans1 == ans2
                pass += 1
            else
                print("ERROR: ttt:$ttt N:$N D:$D X:$X Y:$Y ans1:$ans1 ans2:$ans2\n")
                ans1 = solveMid(N,D,X,Y)
                ans2 = solveLarge(N,D,X,Y,working)
            end
        else
            print("$ans2\n")
        end
    end
    if check; print("$pass/$ntc passed\n"); end
end
    
function main(infn="")
    working = genLargeDataStructure()
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    gs()::String = rstrip(readline(infile))
    gi()::Int64 = parse(Int64, gs())
    gf()::Float64 = parse(Float64,gs())
    gss()::Vector{String} = split(gs())
    gis()::Vector{Int64} = [parse(Int64,x) for x in gss()]
    gfs()::Vector{Float64} = [parse(Float64,x) for x in gss()]
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N,D = gis()
        X::Vector{Int64} = fill(0,N)
        Y::Vector{Int64} = fill(0,N)
        for i in 1:N; X[i],Y[i] = gis(); end
        #(num,denom) = solveMid(N,D,X,Y)
        (num,denom) = solveLarge(N,D,X,Y,working)
        print("$num $denom\n")
    end
end

Random.seed!(8675309)
main()
#test(10000,2,2,1 ,10000000,1000000)
#test(10000,2,2,1 ,10000000,1000000000)
#test(10000,2,10,1,10,20)
#test(10000,2,10,1,10000000,1000000)
#test(10000,2,10,1,10000000,1000000000)

#test(1000,2,2,1,10,10)
#test(1000,2,10,1,10,20)

#w = genLargeDataStructure()
#print("$(Base.summarysize(w))\n")

#test(6,1650,1700,1,10000000,1000000,false)
#test(100,90,100, 1,10000000,1000000,false)

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

 