
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


mutable struct SmallWall; off::I; wh::VI; end
function init(w::SmallWall,offset::I)
    w.off = offset+1; w.wh = fill(0,1+2*offset)
end
function rmq(w::SmallWall,a::I,b::I)::I
    minimum(w.wh[2*a+w.off:2*b+w.off])
end
function update(w::SmallWall,a::I,b::I,v::I)
    for i in 2a:2b
        w.wh[w.off+i] = max(w.wh[w.off+i],v)
    end
end

function solveSmall(N::I,Darr::VI,Narr::VI,Warr::VI,Earr::VI,Sarr::VI,
                    DeltaD::VI,DeltaP::VI,DeltaS::VI)::I
    events::Vector{QI} = []
    for i in 1:N
        d,n,w,e,s,dd,dp,ds = Darr[i],Narr[i],Warr[i],Earr[i],Sarr[i],DeltaD[i],DeltaP[i],DeltaS[i]
        for j in 1:Narr[i]
            push!(events,(d,s,w,e))
            d += dd; w += dp; e += dp; s += ds
        end
    end
    sort!(events)
    ans::I = 0; ww=SmallWall(0,[]); init(ww,400)
    last,le = 0,length(events)
    while (last != le)
        last += 1
        start = last
        d = events[last][1]
        while last < le && events[last+1][1] == d; last += 1; end
        for i in start:last
            rr = rmq(ww,events[i][3],events[i][4])
            if rr < events[i][2]; ans += 1; end
        end
        for i in start:last
            update(ww,events[i][3],events[i][4],events[i][2])
        end
    end
    return ans   
end

function solveLarge(N::I,Darr::VI,Narr::VI,Warr::VI,Earr::VI,Sarr::VI,
    DeltaD::VI,DeltaP::VI,DeltaS::VI,working)::I
    (st::segTreeRMQ,events::Vector{NTuple{4,Int32}},events2::Vector{NTuple{4,Int32}},
    old2new::Dict{Int32,Int32},cc::Vector{Int32}) = working
    fill!(st.tree,Int32(0))
    fill!(st.lazy,Int32(0))
    empty!(events)
    empty!(events2)
    empty!(old2new)
    empty!(cc)
    ans::I = 0
    for i in 1:N
        d,n,w,e,s,dd,dp,ds = Darr[i],Narr[i],Warr[i],Earr[i],Sarr[i],DeltaD[i],DeltaP[i],DeltaS[i]
        for j in 1:Narr[i]
            push!(events,(Int32(d),Int32(s),Int32(w),Int32(e)))
            d += dd; w += dp; e += dp; s += ds
        end
    end

    ## Coordinate compression
    for (d,s,w,e) in events; push!(cc,w); push!(cc,e); end
    unique!(sort!(cc))
    for (i,c) in enumerate(cc); old2new[c] = i; end
    for (d,s,w,e) in events; push!(events2,(d,s,old2new[w],old2new[e])); end
    sort!(events2)

    ## Shrink the segment tree
    maxc = length(cc)
    numnodes = 2*maxc-1
    st.r = numnodes

    last,le = 0,length(events2)
    while (last != le)
        last += 1
        start = last
        d = events2[last][1]
        while last < le && events2[last+1][1] == d; last += 1; end
        for i in start:last
            (_d,s,w,e) = events2[i]
            rr = rmq(st,2*w-1,2*e-1)
            if rr < s; ans += 1; end
        end
        for i in start:last
            (_d,s,w,e) = events2[i]
            update(st,2*w-1,2*e-1,s)
        end
    end
    return ans
end   

function gencase(Nmin::I,Nmax::I,nmin::I,nmax::I,Cmax::I,Delpmax::I)
    N = rand(Nmin:Nmax)
    Darr::VI = fill(0,N)
    Narr::VI = fill(0,N)
    Warr::VI = fill(0,N)
    Earr::VI = fill(0,N)
    Sarr::VI = fill(0,N)
    DeltaD::VI = fill(0,N)
    DeltaP::VI = fill(0,N)
    DeltaS::VI = fill(0,N)
    for i in 1:N
        n = rand(nmin:nmax)
        dp = rand(-Delpmax:Delpmax)
        w=0;e=0;d=0;dd=0;s=0;ds=0
        while (e<=w); w=rand(-Cmax:Cmax); e=rand(-Cmax:Cmax); end
        while dd == 0 || dd > 676060 || d + (n-1)*dd > 676060
            d = rand(0:676060); dd = rand(1:676060)
        end
        while s == 0 || s + (n-1) * ds < 1
            s = rand(1:1000000); ds = rand(-100000:100000)
        end
        Darr[i] = d; Narr[i] = n; Warr[i] = w; Earr[i] = e
        Sarr[i] = s; DeltaD[i] = dd; DeltaP[i] = dp; DeltaS[i] = ds
    end
    return (N,Darr,Narr,Warr,Earr,Sarr,DeltaD,DeltaP,DeltaS)
end
        
function test(ntc::I,Nmin::I,Nmax::I,nmin::I,nmax::I,Cmax::I,Delpmax::I,check::Bool=true)
    tree::Vector{Int32} = fill(Int32(0),2^23)
    lazy::Vector{Int32} = fill(Int32(0),2^23)
    st::segTreeRMQ = segTreeRMQ(tree,lazy,1,4000000)
    events::Vector{NTuple{4,Int32}} =  fill((Int32(0),Int32(0),Int32(0),Int32(0)),1_000_000)
    events2::Vector{NTuple{4,Int32}} = fill((Int32(0),Int32(0),Int32(0),Int32(0)),1_000_000)
    old2new::Dict{Int32,Int32} = Dict{Int32,Int32}()
    cc::Vector{Int32} = []
    working = (st,events,events2,old2new,cc)
    pass = 0
    for ttt in 1:ntc
        (N,Darr,Narr,Warr,Earr,Sarr,DeltaD,DeltaP,DeltaS) = gencase(Nmin,Nmax,nmin,nmax,Cmax,Delpmax)
        ans2 = solveLarge(N,Darr,Narr,Warr,Earr,Sarr,DeltaD,DeltaP,DeltaS,working)
        if check
            ans1 = solveSmall(N,Darr,Narr,Warr,Earr,Sarr,DeltaD,DeltaP,DeltaS)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(N,Darr,Narr,Warr,Earr,Sarr,DeltaD,DeltaP,DeltaS)
                ans2 = solveLarge(N,Darr,Narr,Warr,Earr,Sarr,DeltaD,DeltaP,DeltaS,working)
            end
       else
           print("Case $ttt: $ans2\n")
       end
    end
    if check; print("$pass/$ntc passed\n"); end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()

    ## Setup some common data for the Large
    tree::Vector{Int32} = fill(Int32(0),2^23)
    lazy::Vector{Int32} = fill(Int32(0),2^23)
    st::segTreeRMQ = segTreeRMQ(tree,lazy,1,4000000)
    events::Vector{NTuple{4,Int32}} =  fill((Int32(0),Int32(0),Int32(0),Int32(0)),1_000_000)
    events2::Vector{NTuple{4,Int32}} = fill((Int32(0),Int32(0),Int32(0),Int32(0)),1_000_000)
    old2new::Dict{Int32,Int32} = Dict{Int32,Int32}()
    cc::Vector{Int32} = []
    working = (st,events,events2,old2new,cc)

    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        Darr::VI = fill(0,N)
        Narr::VI = fill(0,N)
        Warr::VI = fill(0,N)
        Earr::VI = fill(0,N)
        Sarr::VI = fill(0,N)
        DeltaD::VI = fill(0,N)
        DeltaP::VI = fill(0,N)
        DeltaS::VI = fill(0,N)
        for i in 1:N; Darr[i],Narr[i],Warr[i],Earr[i],Sarr[i],DeltaD[i],DeltaP[i],DeltaS[i] = gis(); end
        #ans = solveSmall(N,Darr,Narr,Warr,Earr,Sarr,DeltaD,DeltaP,DeltaS)
        ans = solveLarge(N,Darr,Narr,Warr,Earr,Sarr,DeltaD,DeltaP,DeltaS,working)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
#test(10,1,10,1,10,100,10)
#test(30,1,10,1,10,100,10)
#test(100,1,10,1,10,100,10)
#test(300,1,10,1,10,100,10)
#test(1000,1,10,1,10,100,10)
#test(20,900,1000,900,1000,1000000,100000,false)



#using Profile, StatProfilerHTML
#Profile.clear()
#@profile test(10,1,10,1,10,100,10)
#Profile.clear()
#@profilehtml test(20,900,1000,900,1000,1000000,100000,false)

