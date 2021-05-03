
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

function solveVerySmall(K::I,Q::I,A::String,L::VI,R::VI,P::VI,S::VI,E::VI)::I
    ## Use Floyd Warshall to get all of the answers, and then query them.
    ## This is too slow for the problem, but it makes a good check

    stack::VI = []; push!(stack,-1)
    other::VI = fill(0,K)
    for (i::I,c::Char) in enumerate(A)
        if c == '('; push!(stack,i)
        else; l::I = stack[end]; other[i] = l; other[l] = i; pop!(stack)
        end
    end

    inf::I = 1_000_000_000_000_000_000
    best::Array{I,2} = fill(inf,K,K)
    ## Set up the initial matrix
    for i::I in 1:K
        best[i,i] = 0
        if i > 1; best[i,i-1] = min(best[i,i-1],L[i]); end
        if i < K; best[i,i+1] = min(best[i,i+1],R[i]); end
        j = other[i]
        best[i,j] = min(best[i,j],P[i])
    end

    ## Now do the simple floyd warshall loop
    for k::I in 1:K
        for i::I in 1:K
            for j::I in 1:K
                best[i,j]  = min(best[i,j],best[i,k]+best[k,j])
            end
        end
    end
    
    ## Now for the queries
    dtot::I = 0
    for i in 1:Q
        (s,e) = S[i],E[i]
        dtot += best[s,e]
    end
    return dtot
end

function doBasicStats(K::I,A::String)::NTuple{6,VI}
    depth::VI = fill(0,K); curdepth = 0
    stack::VI = []; push!(stack,-1)
    other::VI = fill(0,K)
    left::VI = fill(0,K)
    for (i,c) in enumerate(A)
        if c == '('
            depth[i] = curdepth; curdepth += 1
            left[i] = stack[end]; push!(stack,i)
        else
            curdepth -= 1; depth[i] = curdepth
            l = stack[end]; other[i] = l; other[l] = i;
            pop!(stack); left[i] = stack[end]
        end
    end

    right::VI = fill(0,K)
    ## Calculate the right parent
    for i in K:-1:1
        c = A[i]
        if c == ')'; right[i] = stack[end]; push!(stack,i)
        else; pop!(stack); right[i] = stack[end]
        end
    end

    ## Calculate the sibling counts left & right
    cntleft::VI  = fill(0,K); cntright::VI = fill(0,K)
    q::VPI = [];  push!(q,(1,K))
    while !isempty(q)
        (l,r) = popfirst!(q)
        xl = l; cnt = 0
        while xl < r
            xr = other[xl]
            if xr-xl > 1; push!(q,(xl+1,xr-1)); end
            cntleft[xl] = cntleft[xr] = cnt; cnt += 1
            xl = xr+1
        end
        xr = r; cnt = 0
        while xr > l
            xl = other[xr]
            cntright[xl] = cntright[xr] = cnt; cnt += 1
            xr = xl-1
        end
    end
    return (depth,left,other,right,cntleft,cntright)
end

function buildDistArraySmall(K,A,depth,left,other,right,cntleft,cntright)::Array{I,4}
    dist::Array{I,4} = fill(0,K,17,2,2)
    ## Do the initial level
    for i in 1:K
        if A[i] == ')'; continue; end
        j = other[i]
        if depth[i] == 0
            dist[i,1,1,:] .= (0,i)
            dist[i,1,2,:] .= (1,j)
            dist[j,1,1,:] .= (1,i)
            dist[j,1,2,:] .= (0,j)
        else
            lp,rp = left[i],right[i]
            dist[i,1,1,:] .= (min(2*cntleft[i]+1,2*cntright[i]+3),lp)
            dist[i,1,2,:] .= (min(2*cntleft[i]+2,2*cntright[i]+2),rp)
            dist[j,1,1,:] .= (min(2*cntleft[j]+2,2*cntright[j]+2),lp)
            dist[j,1,2,:] .= (min(2*cntleft[j]+3,2*cntright[j]+1),rp)
        end
    end
    rollupDist(K,dist)
    return dist
end

function rollupDist(K::I,dist::Array{I,4})
    for j in 2:17
        for i in 1:K
            d1l = dist[i,j-1,1,1]; lmid = dist[i,j-1,1,2]
            d1r = dist[i,j-1,2,1]; rmid = dist[i,j-1,2,2]
            d2l = dist[lmid,j-1,1,1]; lend = dist[lmid,j-1,1,2]
            d2r = dist[lmid,j-1,2,1]; rend = dist[lmid,j-1,2,2]
            d3l = dist[rmid,j-1,1,1]
            d3r = dist[rmid,j-1,2,1]
            dist[i,j,1,1] = min(d1l+d2l,d1r+d3l)
            dist[i,j,1,2] = lend
            dist[i,j,2,1] = min(d1l+d2r,d1r+d3r)
            dist[i,j,2,2] = rend
        end
    end
end

function moveup(k::I,ds1::I,ls::I,ds2::I,rs::I,dist::Array{I,4})::Tuple{I,I,I,I}
    (lp,rp) = (dist[ls,k,1,2],dist[ls,k,2,2])
    (ds1,ds2) = (min(ds1+dist[ls,k,1,1],ds2+dist[rs,k,1,1]),min(ds1+dist[ls,k,2,1],ds2+dist[rs,k,2,1]))
    return (ds1,lp,ds2,rp)
end

function solve2siblingsSmall(s::I,e::I,K::I,A::String,depth::VI,other::VI,left::VI,dist::Array{I,4})::Tuple{I,I,I,I,I,I,I,I}
    if depth[e] > depth[s]; (s,e) = (e,s); end
    gap = depth[s]-depth[e]
    (ds1,ls,ds2,rs) = A[s] == '(' ? (0,s,1,other[s]) : (1,other[s],0,s)
    (de1,le,de2,re) = A[e] == '(' ? (0,e,1,other[e]) : (1,other[e],0,e)
    for k in 17:-1:1
        if 2^(k-1) > gap; continue; end
        gap -= 2^(k-1)
        (ds1,ls,ds2,rs) = moveup(k,ds1,ls,ds2,rs,dist)
    end

    ## Now we are at the same level, so now we check parents
    if left[ls] != left[le]
        for k in 17:-1:1
            if dist[ls,k,1,2] == dist[le,k,1,2]; continue; end
            (ds1,ls,ds2,rs) = moveup(k,ds1,ls,ds2,rs,dist)
            (de1,le,de2,re) = moveup(k,de1,le,de2,re,dist)
        end
    end
    return (ds1,ls,ds2,rs,de1,le,de2,re)
end

function solveSiblingsSmall(ds1::I,ls::I,ds2::I,rs::I,de1::I,le::I,de2::I,re::I,depth::VI,cntleft::VI,cntright::VI)::I
    if ls == le; return min(ds1+de1,ds2+de2); end
    if re < ls; (ds1,ls,ds2,rs,de1,le,de2,re) = (de1,le,de2,re,ds1,ls,ds2,rs); end
    mydist = ds2+de1+2*(cntright[rs]-cntright[le]-1)+1
    if depth[re] > 0; mydist=min(mydist,ds1+de2+2*cntleft[ls]+2*cntright[re]+3); end
    return mydist
end

function solveSmall(K::I,Q::I,A::String,L::VI,R::VI,P::VI,S::VI,E::VI)::I

    ## Variables:
    ##    depth:    current depth of the node
    ##    left:     location of the left parent
    ##    other:    location of the matching parenthesis
    ##    right:    location of the right parent
    ##    cntleft:  how many siblings to the left
    ##    cntright: how many siblings to the right
    ## dist[start,k,left/right,1] = distance to move up 2^(k-1) levels of hierarchy
    ## dist[start,k,left/right,2] = node we land on when moving up 2^(k-1) levels of hierarchy

    ## Calculate the depth of each node
    depth::VI,left::VI,other::VI,right::VI,cntleft::VI,cntright::VI = doBasicStats(K,A)
    dist::Array{I,4} = buildDistArraySmall(K,A,depth,left,other,right,cntleft,cntright)
    dtot::Int64 = 0
    for i in 1:Q
        s,e = S[i],E[i]
        (ds1,ls,ds2,rs,de1,le,de2,re) = solve2siblingsSmall(s,e,K,A,depth,other,left,dist)
        mydist = solveSiblingsSmall(ds1,ls,ds2,rs,de1,le,de2,re,depth,cntleft,cntright)
        dtot += mydist
    end
    return dtot
end

function fixPBottomUp(K::I,A::String,other::VI,L::VI,R::VI,P::VI)
    ## Sort pairs by size
    ppairs::VPI = []
    for i in 1:K
        if A[i] == ')'; continue; end
        push!(ppairs,(other[i]-i,i))
    end
    sort!(ppairs)
    for (_d,st) in ppairs
        en = other[st]
        x,Palt = st+1,R[st];
        while (x != en); Palt += P[x]; x = other[x]; Palt += R[x]; x += 1; end
        P[st] = min(P[st],Palt)
        x,Palt = en-1,L[en]
        while (x != st); Palt += P[x]; x = other[x]; Palt += L[x]; x -= 1; end
        P[en] = min(P[en],Palt)
    end
end

function fixPTopDown(K::I,A::String,other::VI,L::VI,R::VI,P::VI)
    ## Sort pairs by size
    ppairs::VPI = []
    for i in 1:K
        if A[i] == ')'; continue; end
        push!(ppairs,(other[i]-i,i))
    end
    sort!(ppairs,rev=true)
    for (_d,st) in ppairs
        en = other[st]
        if en-st == 1; continue; end  ## Fix the children from the top down, and this has no children
        ## Move right, look for an alternative to P[right] for child intervals
        rightLoopDelay = P[en] + R[st]; x = st+1
        while x != en; rightLoopDelay += P[x]; x = other[x]; rightLoopDelay += R[x]; x += 1; end
        leftLoopDelay = P[st] + L[en]; x = en-1
        while x != st; leftLoopDelay += P[x]; x = other[x]; leftLoopDelay += L[x]; x -= 1; end
        x = st+1
        while x != en
            y = other[x]
            newPx = min(P[x],leftLoopDelay-P[y])
            newPy = min(P[y],rightLoopDelay-P[x])
            P[x] = newPx; P[y] = newPy
            x = y+1
        end
    end
end

function buildDistArrayLargeUp(K::I,A::String,other::VI,L::VI,R::VI,P::VI)
    dist::Array{I,4} = fill(0,K,17,2,2)
    ## Need to set up the top level first
    x = 1
    while x < K
        y = other[x]
        dist[x,1,1,1] = 0;    dist[x,1,1,2] = x
        dist[x,1,2,1] = P[x]; dist[x,1,2,2] = y
        dist[y,1,1,1] = P[y]; dist[y,1,1,2] = x
        dist[y,1,2,1] = 0;    dist[y,1,2,2] = y
        x = y+1
    end
    for i in 1:K
        if A[i] == ')'; continue; end
        st,en = i,other[i]
        if en-st == 1; continue; end  ## Distances are assigned top-down

        ## Go right first
        x,d = st+1,0
        while x != en; d += P[x]; x = other[x]; d += R[x]; x += 1; end
        den = d; dst = den+P[en]
        x,d = st+1,0
        while x != en;
            dist[x,1,1,1] = dst-d; dist[x,1,1,2] = st
            dist[x,1,2,1] = den-d; dist[x,1,2,2] = en
            d += P[x]; x = other[x]
            dist[x,1,1,1] = dst-d; dist[x,1,1,2] = st
            dist[x,1,2,1] = den-d; dist[x,1,2,2] = en
            d += R[x]; x += 1;
        end

        ## Go left
        x,d = en-1,0
        while x != st; d += P[x]; x = other[x]; d += L[x]; x -= 1; end
        dst = d; den = dst+P[st]
        x,d = en-1,0
        while x != st;
            dist[x,1,1,1] = min(dist[x,1,1,1],dst-d)
            dist[x,1,2,1] = min(dist[x,1,2,1],den-d)
            d += P[x]; x = other[x]
            dist[x,1,1,1] = min(dist[x,1,1,1],dst-d)
            dist[x,1,2,1] = min(dist[x,1,2,1],den-d)
            d += L[x]; x -= 1;
        end
    end
    rollupDist(K,dist)
    return dist
end

function buildDistArrayLargeDn(K::I,A::String,other::VI,L::VI,R::VI,P::VI)
    dist::Array{I,4} = fill(0,K,17,2,2)
    ## Need to set up the top level first
    x = 1
    while x < K
        y = other[x]
        dist[x,1,1,1] = 0;    dist[x,1,1,2] = x
        dist[x,1,2,1] = P[y]; dist[x,1,2,2] = y
        dist[y,1,1,1] = P[x]; dist[y,1,1,2] = x
        dist[y,1,2,1] = 0;    dist[y,1,2,2] = y
        x = y+1
    end
    for i in 1:K
        if A[i] == ')'; continue; end
        st,en = i,other[i]
        if en-st == 1; continue; end  ## Distances are assigned top-down

        ## Go right first
        den = 0; dst = P[en]; d = dst+R[st]; x = st+1
        while x != en;
            dist[x,1,1,1] = d-dst; dist[x,1,1,2] = st
            dist[x,1,2,1] = d-den; dist[x,1,2,2] = en
            d += P[x]; x = other[x]
            dist[x,1,1,1] = d-dst; dist[x,1,1,2] = st
            dist[x,1,2,1] = d-den; dist[x,1,2,2] = en
            d += R[x]; x += 1
        end

        ## Now we go left
        dst = 0; den = P[st]; d = den+L[en]; x = en-1
        while x != st;
            dist[x,1,1,1] = min(dist[x,1,1,1],d-dst)
            dist[x,1,2,1] = min(dist[x,1,2,1],d-den)
            d += P[x]; x = other[x]
            dist[x,1,1,1] = min(dist[x,1,1,1],d-dst)
            dist[x,1,2,1] = min(dist[x,1,2,1],d-den)
            d += L[x]; x -= 1
        end
    end
    rollupDist(K,dist)
    return dist
end

function solve2siblingsLarge(s::I,e::I,K::I,A::String,depth::VI,other::VI,left::VI,P::VI,sdist::Array{Int64,4},
                             edist::Array{Int64,4})::Tuple{I,I,I,I,I,I,I,I}

    (ds1,ls,ds2,rs) = A[s] == '(' ? (0,s,P[s],other[s]) : (P[s],other[s],0,s)
    (de1,le,de2,re) = A[e] == '(' ? (0,e,P[other[e]],other[e]) : (P[other[e]],other[e],0,e)
    if depth[e] > depth[s]
        gap = depth[e] - depth[s]
        for k in 17:-1:1
            if 2^(k-1) > gap; continue; end
            gap -= 2^(k-1)
            (de1,le,de2,re) = moveup(k,de1,le,de2,re,edist)
        end
    elseif depth[s] > depth[e]
        gap = depth[s] - depth[e]
        for k in 17:-1:1
            if 2^(k-1) > gap; continue; end
            gap -= 2^(k-1)
            (ds1,ls,ds2,rs) = moveup(k,ds1,ls,ds2,rs,sdist)
        end
    end

    if left[ls] != left[le]
        for k in 17:-1:1
            if sdist[ls,k,1,2] == edist[le,k,1,2]; continue; end
            (ds1,ls,ds2,rs) = moveup(k,ds1,ls,ds2,rs,sdist)
            (de1,le,de2,re) = moveup(k,de1,le,de2,re,edist)
        end
    end
    return (ds1,ls,ds2,rs,de1,le,de2,re)
end

function solveInterval(l::I,r::I,v::Vector,A::String,other::VI,L::VI,R::VI,P::VI,wraparound::Bool)::Int64
    ans = [1_000_000_000_000_000_000 for vv in v]
    dlookup::Dict{I,I} = Dict{I,I}()
    darr::VI = []

    ## Do the left to right pass first
    x = l; d=0; idx=1
    while x <= r
        dlookup[x] = idx; idx += 1; push!(darr,d); d += P[x]; x = other[x]
        dlookup[x] = idx; idx += 1; push!(darr,d); d += R[x]; x += 1
    end
    if wraparound
        d += P[x]; x = other[x]; d += R[x]; x += 1
        while x <= r
            push!(darr,d); d += P[x]; x = other[x]
            push!(darr,d); d += R[x]; x += 1
        end
    end
    idx -= 1

    for (i,vv) in enumerate(v)
        (ds1,ls,ds2,rs,de1,le,de2,re) = vv
        if rs == re;
            ans[i] = min(ds1+de1,ds2+de2,ds1+P[ls]+de2,ds2+P[rs]+de1)
        elseif rs < re
            ans[i] = min(ans[i],ds1+de1+darr[dlookup[le]]-darr[dlookup[ls]])
            ans[i] = min(ans[i],ds1+de2+darr[dlookup[re]]-darr[dlookup[ls]])
            ans[i] = min(ans[i],ds2+de1+darr[dlookup[le]]-darr[dlookup[rs]])
            ans[i] = min(ans[i],ds2+de2+darr[dlookup[re]]-darr[dlookup[rs]])
        elseif wraparound
            ans[i] = min(ans[i],ds1+de1+darr[idx+dlookup[le]]-darr[dlookup[ls]])
            ans[i] = min(ans[i],ds1+de2+darr[idx+dlookup[re]]-darr[dlookup[ls]])
            ans[i] = min(ans[i],ds2+de1+darr[idx+dlookup[le]]-darr[dlookup[rs]])
            ans[i] = min(ans[i],ds2+de2+darr[idx+dlookup[re]]-darr[dlookup[rs]])
        end
    end

    ## Now do the right to left pass
    x = r; d=0; idx=1; empty!(dlookup); empty!(darr)
    while x >= l
        dlookup[x] = idx; idx += 1; push!(darr,d); d += P[x]; x = other[x]
        dlookup[x] = idx; idx += 1; push!(darr,d); d += L[x]; x -= 1
    end
    if wraparound
        d += P[x]; x = other[x]; d += L[x]; x -= 1
        while x >= l
            push!(darr,d); d += P[x]; x = other[x]
            push!(darr,d); d += L[x]; x -= 1
        end
    end
    idx -= 1

    for (i,vv) in enumerate(v)
        (ds1,ls,ds2,rs,de1,le,de2,re) = vv
        if rs > re
            ans[i] = min(ans[i],ds1+de1+darr[dlookup[le]]-darr[dlookup[ls]])
            ans[i] = min(ans[i],ds1+de2+darr[dlookup[re]]-darr[dlookup[ls]])
            ans[i] = min(ans[i],ds2+de1+darr[dlookup[le]]-darr[dlookup[rs]])
            ans[i] = min(ans[i],ds2+de2+darr[dlookup[re]]-darr[dlookup[rs]])
        elseif rs < re && wraparound
            #print("DBG: A:$A l:$l r:$r ls:$ls rs:$rs le:$le re:$re darr:$darr dlookup:$dlookup\n")
            ans[i] = min(ans[i],ds1+de1+darr[idx+dlookup[le]]-darr[dlookup[ls]])
            ans[i] = min(ans[i],ds1+de2+darr[idx+dlookup[re]]-darr[dlookup[ls]])
            ans[i] = min(ans[i],ds2+de1+darr[idx+dlookup[le]]-darr[dlookup[rs]])
            ans[i] = min(ans[i],ds2+de2+darr[idx+dlookup[re]]-darr[dlookup[rs]])
        end
    end
    return sum(ans)
end

function solveLarge(K::I,Q::I,A::String,L::VI,R::VI,P::VI,S::VI,E::VI)::I
    depth::VI,left::VI,other::VI,right::VI,cntleft::VI,cntright::VI = doBasicStats(K,A)
    PP::VI = copy(P)
    fixPBottomUp(K,A,other,L,R,PP)
    fixPTopDown(K,A,other,L,R,PP)
    sdist = buildDistArrayLargeUp(K,A,other,L,R,PP)
    edist = buildDistArrayLargeDn(K,A,other,L,R,PP)
    dd::Dict{I,Vector{Tuple{I,I,I,I,I,I,I,I}}} = Dict{I,Vector{Tuple{I,I,I,I,I,I,I,I}}}()
    for i in 1:Q
        s,e = S[i],E[i]
        (ds1,ls,ds2,rs,de1,le,de2,re) = solve2siblingsLarge(s,e,K,A,depth,other,left,PP,sdist,edist)
        lpar = left[ls]
        if !haskey(dd,lpar); dd[lpar] = []; end
        push!(dd[lpar],(ds1,ls,ds2,rs,de1,le,de2,re))
    end
    dtot::Int64 = 0
    for (k,v) in dd
        mydist = 0
        if k == -1; mydist = solveInterval(1,K,v,A,other,L,R,PP,false)
        else;       mydist = solveInterval(k+1,other[k]-1,v,A,other,L,R,PP,true)
        end
        dtot += mydist
    end
    return dtot
end

####################################################################################################
#####  TESTING CODE 
####################################################################################################

function gencase(Kmax::I,Qmax::I,Dmax::I)
    K::I = 2 * rand(1:Kmax÷2)
    Q::I = rand(1:Qmax)
    maxDepth = rand(1:Kmax÷2)
    AA::VC = fill('.',K); depth = 0
    dprob = [rand() for i in 1:maxDepth]
    for i in 1:K
        if depth == 0; AA[i] = '('; depth = 1
        elseif depth == maxDepth || K-i+1 == depth; AA[i] = ')'; depth -= 1
        elseif rand() < dprob[depth]; AA[i] = '('; depth += 1
        else; AA[i] = ')'; depth -= 1
        end
    end
    A = join(AA,"")
    S::VI = [rand(1:K) for i in 1:Q]
    E::VI = [rand(1:K) for i in 1:Q]
    L::VI = [rand(1:Dmax) for i in 1:K]
    R::VI = [rand(1:Dmax) for i in 1:K]
    P::VI = [rand(1:Dmax) for i in 1:K]
    return (K,Q,A,L,R,P,S,E)
end

function test1(ntc::I,Kmax::I,Qmax::I,Dmax::I,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (K,Q,A,L,R,P,S,E) = gencase(Kmax,Qmax,Dmax)
        ans2 = solveSmall(K,Q,A,L,R,P,S,E)
        if check
            ans1 = solveVerySmall(K,Q,A,L,R,P,S,E)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveVerySmall(K,Q,A,L,R,P,S,E)
                ans2 = solveSmall(K,Q,A,L,R,P,S,E)
            end
       else
           print("Case $ttt: $ans2\n")
       end
    end
    if check; print("$pass/$ntc passed\n"); end
end

function test2(ntc::I,Kmax::I,Qmax::I,Dmax::I,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (K,Q,A,L,R,P,S,E) = gencase(Kmax,Qmax,Dmax)
        ans2 = solveLarge(K,Q,A,L,R,P,S,E)
        if check
            ans1 = solveVerySmall(K,Q,A,L,R,P,S,E)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveVerySmall(K,Q,A,L,R,P,S,E)
                ans2 = solveLarge(K,Q,A,L,R,P,S,E)
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
        K,Q = gis()
        A = gs()
        L = gis()
        R = gis()
        P = gis()
        S = gis()
        E = gis()
        #ans = solveSmall(K,Q,A,L,R,P,S,E)
        ans = solveLarge(K,Q,A,L,R,P,S,E)
        println(ans)
    end
end

Random.seed!(8675309)
main()

## Small Testing
#test1(100000,10,2,1,true)
#test1(100,100,100000,1,true)
#test1(1000,100,100000,1,true)
#test1(20,100000,100000,1,false)
#test1(100,1000,1000,1,false)

## Large Testing
#for i in 1:100; test2(10000,10,5,10,true); end
#for i in 1:10;  test2(1000,100,100000,10,true); end
#for i in 1:10;  test2(1000,100,100000,1000000,true); end
#test2(1000,10,2,5,true)
#test2(1000,100,100000,10,true)
#test2(1000,100,100000,1000000,true)
#test2(20,100000,100000,1000000,false)
#test2(100,1000,1000,1000000,false)

# Profiling
#using Profile, StatProfilerHTML
#Profile.clear()
#@profile test2(1,100000,100000,1,false)
#Profile.clear()
#@profilehtml test2(100,100000,100000,1000000,false)
