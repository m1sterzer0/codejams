
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

######################################## END BOILERPLATE CODE ########################################

struct SegTree; maxval::I; lazy::VI; minv::VI; end

function SegTree(maxv::I)
    a::I = 1; while a < maxv; a *= 2; end;  a *= 2
    lz::VI = fill(0,a)
    minv::VI = fill(0,a)
    return SegTree(maxv,lz,minv)
end

function _stinc(st::SegTree,idx::I,l::I,r::I,a::I,b::I,v::I)
    if a > r || b < l; return; end
    if a <= l && r <= b; st.lazy[idx] += v; return; end
    idxl::I = 2idx; idxr::I = idxl+1; m::I = (l+r)>>1
    _stinc(st,idxl,l,m,a,b,v)
    _stinc(st,idxr,m+1,r,a,b,v)
    st.minv[idx] = min(st.minv[idxl]+st.lazy[idxl],st.minv[idxr]+st.lazy[idxr])
end

function _strmq(st::SegTree,idx::I,l::I,r::I,a::I,b::I)::I
    if a > r || b < l; return 1_000_000_000_000_000_000; end
    if a <= l && r <= b; return st.minv[idx]+st.lazy[idx]; end
    idxl::I = 2idx; idxr::I = idxl+1; m::I = (l+r)>>1
    st.lazy[idxl] += st.lazy[idx]; st.lazy[idxr] += st.lazy[idx]; st.lazy[idx] = 0
    v1::I = _strmq(st,idxl,l,m,a,b)
    v2::I = _strmq(st,idxr,m+1,r,a,b)
    st.minv[idx] = min(st.minv[idxl]+st.lazy[idxl],st.minv[idxr]+st.lazy[idxr])
    return min(v1,v2)
end

stinc(st::SegTree,a::I,b::I,v::I) = _stinc(st,1,1,st.maxval,a,b,v)
strmq(st::SegTree,a::I,b::I)       = _strmq(st,1,1,st.maxval,a,b)

######################################## END SEGTREE CODE ########################################

function solveSmall(N::I, U::VI, V::VI, S::VI, C::VI)::PI
    adj::Vector{VI} = [VI() for i in 1:N]
    cost::VI = fill(0,N)
    cap::VI = fill(0,N)
    parent::VI = fill(0,N)
    nodecost::VI = fill(0,N)
    for i in 1:N-1
        push!(adj[U[i]], V[i])
        cost[V[i]] = C[i]
        cap[V[i]] = S[i]
        parent[V[i]] = U[i]
    end
    q::VPI = []
    push!(q,(0,1))
    while !isempty(q)
        (p,n) = popfirst!(q)
        nodecost[n] = p == 0 ? 0 : nodecost[p] + cost[n]
        for c in adj[n]; push!(q,(n,c)); end
    end
    nodecosts::VPI = [(nodecost[i],i) for i in 1:N]
    sort!(nodecosts)
    numski::I = 0; totcost::I = 0
    for (c,i) in nodecosts
        if i == 1; continue; end
        cc::I = 1_000_000; n::I = i
        while (n != 1); cc = min(cc,cap[n]); n = parent[n]; end
        if cc == 0; continue; end
        numski += cc; totcost += cc*c; n = i
        while (n != 1); cap[n] -= cc; n = parent[n]; end
    end
    return (numski,totcost)
end

function heavyLightDecompose(N::I,r::I,adj::Vector{VI})
    ## We do this version without recursion to avoid stack overflow.
    q::Vector{TI} = [(0,r,1)]
    order::VI = []
    parent::VI = fill(0,N)
    depth::VI  = fill(0,N)
    heavy::VI  = fill(0,N)
    nsize::VI  = fill(0,N)
    head::VI   = fill(0,N)
    pos::VI    = fill(0,N)
    while !isempty(q)
        (p::I,n::I,d::I) = popfirst!(q)
        parent[n] = p
        depth[n] = d
        push!(order,n)
        for c in adj[n]; if c != p; push!(q,(n,c,d+1)); end; end
    end
    reverse!(order)
    for n in order
        sz = 1; csz = 0; bestc = 0
        for c in adj[n]
            if c != parent[n]
                sz += nsize[c]
                if nsize[c] > csz; csz = nsize[c]; bestc = c; end
            end
        end
        heavy[n] = bestc
        nsize[n] = sz
    end
    qq::VI = [r]
    curpos = 1
    while !isempty(qq)
        n = popfirst!(qq); h = n
        while (n != 0)
            head[n] = h; pos[n] = curpos; curpos += 1
            for c in adj[n]
                if c != parent[n] && c != heavy[n]; push!(qq,c); end
            end
            n = heavy[n]
        end
    end
    return (parent,depth,heavy,head,pos)
end

function solveLarge(N::I, U::VI, V::VI, S::VI, C::VI)
    adj::VVI = [VI() for i in 1:N]
    cost::VI = fill(0,N)
    cap::VI = fill(0,N)
    parent::VI = fill(0,N)
    nodecost::VI = fill(0,N)
    for i in 1:N-1
        push!(adj[U[i]], V[i])
        cost[V[i]] = C[i]
        cap[V[i]] = S[i]
        parent[V[i]] = U[i]
    end
    cap[1] = 1_000_000_000_000_000_000
    q::VPI = []
    push!(q,(0,1))
    while !isempty(q)
        (p,n) = popfirst!(q)
        nodecost[n] = p == 0 ? 0 : nodecost[p] + cost[n]
        for c in adj[n]; push!(q,(n,c)); end
    end
    nodecosts::VPI = [(nodecost[i],i) for i in 1:N]
    sort!(nodecosts)

    (_parent::VI,depth::VI,heavy::VI,head::VI,pos::VI) = heavyLightDecompose(N,1,adj)
    st = SegTree(N)
    for i in 1:N; n = pos[i]; stinc(st,n,n,cap[i]); end

    numski = 0; totcost = 0
    for (c,i) in nodecosts
        if i == 1; continue; end
        cc = pathQuery(st,i,pos,head,parent)
        if cc == 0; continue; end
        numski += cc; totcost += cc*c; n = i
        pathUpdate(st,i,-cc,pos,head,parent)
    end
    return (numski,totcost)
end

function pathQuery(st::SegTree,n::I,pos::VI,head::VI,parent::VI)
    ans = 1_000_000_000_000_000_000
    while n != 0
        h = head[n]
        v = strmq(st,pos[h],pos[n])
        ans = min(ans,v)
        n = parent[h]
    end
    return ans
end

function pathUpdate(st::SegTree,n::I,inc::I,pos::VI,head::VI,parent::VI)
    while n != 0
        h = head[n]
        stinc(st,pos[h],pos[n],inc)
        n = parent[h]
    end
end

function gencase(Nmin::I,Nmax::I,Smax::I,Cmax::I)
    N = rand(Nmin:Nmax)
    V = collect(2:N)
    shuffle!(V)
    S = rand(1:Smax,N-1)
    C = rand(-Cmax:Cmax,N-1)
    parents = [1]
    U = fill(0,N-1)
    for i in 1:N-1; U[i] = rand(parents); push!(parents,V[i]); end
    return (N,U,V,S,C)
end

function test(ntc::I,Nmin::I,Nmax::I,Smax::I,Cmax::I,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (N::I,U::VI,V::VI,S::VI,C::VI) = gencase(Nmin,Nmax,Smax,Cmax)
        ans2 = solveLarge(N,U,V,S,C)
        if check
            ans1 = solveSmall(N,U,V,S,C)
            if ans1 == ans2
                pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(N,U,V,S,C)
                ans2 = solveLarge(N,U,V,S,C)
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
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        U::VI = fill(0,N-1)
        V::VI = fill(0,N-1)
        S::VI = fill(0,N-1)
        C::VI = fill(0,N-1)
        for i in 1:N-1; U[i],V[i],S[i],C[i] = gis(); end
        #ans = solveSmall(N,U,V,S,C)
        ans = solveLarge(N,U,V,S,C)
        print("$(ans[1]) $(ans[2])\n")
    end
end

Random.seed!(8675309)
main()
#test(1000,2,10,10,10)
#test(1000,900,1000,100000,100000)
#test(20,100000-1,100000,100000,100000,false)



#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

