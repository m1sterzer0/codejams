
using Random

function solveVerySmall(K::Int64,Q::Int64,A::String,
                        L::Vector{Int64},R::Vector{Int64},P::Vector{Int64},
                        S::Vector{Int64},E::Vector{Int64})::Int64
    ## Use Floyd Warshall to get all of the answers, and then query them.
    ## This is too slow for the problem, but it makes a good check

    ## Need to steal the "other" code from the small solution
    ## Calculate the depth of each node
    stack::Vector{Int64} = []; push!(stack,-1)
    other::Vector{Int64} = fill(0,K)
    for (i,c) in enumerate(A)
        if c == '('; push!(stack,i)
        else; l = stack[end]; other[i] = l; other[l] = i; pop!(stack)
        end
    end

    inf = 1_000_000_000_000_000_000
    best = fill(inf,K,K)
    ## Set up the initial matrix
    for i in 1:K
        best[i,i] = 0
        if i > 1; best[i,i-1] = min(best[i,i-1],L[i]); end
        if i < K; best[i,i+1] = min(best[i,i+1],R[i]); end
        j = other[i]
        best[i,j] = min(best[i,j],P[i])
    end

    ## Now do the simple floyd warshall loop
    for k in 1:K
        for i in 1:K
            for j in 1:K
                best[i,j]  = min(best[i,j],best[i,k]+best[k,j])
            end
        end
    end
    
    ## Now for the queries
    dtot::Int64 = 0
    for i in 1:Q
        (s,e) = S[i],E[i]
        dtot += best[s,e]
    end
    return dtot
end

function doBasicStats(K::Int64,A::String)::Tuple{Vector{Int64},Vector{Int64},Vector{Int64},Vector{Int64},Vector{Int64},Vector{Int64}}
    depth::Vector{Int64} = fill(0,K); curdepth = 0
    stack::Vector{Int64} = []; push!(stack,-1)
    other::Vector{Int64} = fill(0,K)
    left::Vector{Int64} = fill(0,K)
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


    right::Vector{Int64} = fill(0,K)
    ## Calculate the right parent
    for i in K:-1:1
        c = A[i]
        if c == ')'; right[i] = stack[end]; push!(stack,i)
        else; pop!(stack); right[i] = stack[end]
        end
    end

    ## Calculate the sibling counts left & right
    cntleft  = fill(0,K)
    cntright = fill(0,K)
    q::Vector{Tuple{Int64,Int64}} = []
    push!(q,(1,K))
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

function rollupDist(K::Int64,dist::Array{Int64,4})
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

function buildDistArraySmall(K,A,depth,left,other,right,cntleft,cntright)::Array{Int64,4}
    dist::Array{Int64,4} = fill(0,K,17,2,2)
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

function moveup(k::Int64,ds1::Int64,ls::Int64,ds2::Int64,rs::Int64,dist::Array{Int64,4})::Tuple{Int64,Int64,Int64,Int64}
    (lp,rp) = (dist[ls,k,1,2],dist[ls,k,2,2])
    (ds1,ds2) = (min(ds1+dist[ls,k,1,1],ds2+dist[rs,k,1,1]),min(ds1+dist[ls,k,2,1],ds2+dist[rs,k,2,1]))
    return (ds1,lp,ds2,rp)
end

function solve2siblingsSmall(s::Int64,e::Int64,K::Int64,A::String,depth::Vector{Int64},
                             other::Vector{Int64},left::Vector{Int64},
                             dist::Array{Int64,4})::Tuple{Int64,Int64,Int64,Int64,Int64,Int64,Int64,Int64}
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

function solveSiblingsSmall(ds1::Int64,ls::Int64,ds2::Int64,rs::Int64,de1::Int64,le::Int64,
                            de2::Int64,re::Int64,depth::Vector{Int64},cntleft::Vector{Int64},
                            cntright::Vector{Int64})::Int64
    if ls == le; return min(ds1+de1,ds2+de2); end
    if re < ls; (ds1,ls,ds2,rs,de1,le,de2,re) = (de1,le,de2,re,ds1,ls,ds2,rs); end
    mydist = ds2+de1+2*(cntright[rs]-cntright[le]-1)+1
    if depth[re] > 0; mydist=min(mydist,ds1+de2+2*cntleft[ls]+2*cntright[re]+3); end
    return mydist
end

function fixPBottomUp(K::Int64,A::String,other::Vector{Int64},
    L::Vector{Int64},R::Vector{Int64},P::Vector{Int64})
    ## Sort pairs by size
    ppairs::Vector{Tuple{Int64,Int64}} = []
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

function fixPTopDown(K::Int64,A::String,other::Vector{Int64},L::Vector{Int64},R::Vector{Int64},P::Vector{Int64})
    ## Sort pairs by size
    ppairs::Vector{Tuple{Int64,Int64}} = []
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

function buildDistArrayLargeUp(K::Int64,A::String,other::Vector{Int64},
    L::Vector{Int64},R::Vector{Int64},P::Vector{Int64})
    dist::Array{Int64,4} = fill(0,K,17,2,2)
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

function buildDistArrayLargeDn(K::Int64,A::String,other::Vector{Int64},
    L::Vector{Int64},R::Vector{Int64},P::Vector{Int64})
    dist::Array{Int64,4} = fill(0,K,17,2,2)
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

function solve2siblingsLarge(s::Int64,e::Int64,K::Int64,A::String,depth::Vector{Int64},
    other::Vector{Int64},left::Vector{Int64},P::Vector{Int64},
    sdist::Array{Int64,4},edist::Array{Int64,4})::Tuple{Int64,Int64,Int64,Int64,Int64,Int64,Int64,Int64}

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

function solveInterval(l::Int64,r::Int64,v::Vector,A::String,other::Vector{Int64},
    L::Vector{Int64},R::Vector{Int64},P::Vector{Int64},wraparound::Bool)::Int64
    ans = [1_000_000_000_000_000_000 for vv in v]
    dlookup::Dict{Int64,Int64} = Dict{Int64,Int64}()
    darr::Vector{Int64} = []

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

function solveSmall(K::Int64,Q::Int64,A::String,
    L::Vector{Int64},R::Vector{Int64},P::Vector{Int64},
    S::Vector{Int64},E::Vector{Int64})::Int64

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
    depth,left,other,right,cntleft,cntright = doBasicStats(K,A)
    dist = buildDistArraySmall(K,A,depth,left,other,right,cntleft,cntright)
    dtot::Int64 = 0
    for i in 1:Q
        s,e = S[i],E[i]
        (ds1,ls,ds2,rs,de1,le,de2,re) = solve2siblingsSmall(s,e,K,A,depth,other,left,dist)
        mydist = solveSiblingsSmall(ds1,ls,ds2,rs,de1,le,de2,re,depth,cntleft,cntright)
        dtot += mydist
    end
    return dtot
end

function solveLarge(K::Int64,Q::Int64,A::String,
    L::Vector{Int64},R::Vector{Int64},P::Vector{Int64},
    S::Vector{Int64},E::Vector{Int64})::Int64

    depth,left,other,right,cntleft,cntright = doBasicStats(K,A)
    PP::Vector{Int64} = copy(P)
    fixPBottomUp(K,A,other,L,R,PP)
    fixPTopDown(K,A,other,L,R,PP)
    sdist = buildDistArrayLargeUp(K,A,other,L,R,PP)
    edist = buildDistArrayLargeDn(K,A,other,L,R,PP)
    dd::Dict{Int64,Vector{Tuple{Int64,Int64,Int64,Int64,Int64,Int64,Int64,Int64}}} = 
        Dict{Int64,Vector{Tuple{Int64,Int64,Int64,Int64,Int64,Int64,Int64,Int64}}}()
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

function test(ntc,Kmax,Qmax,Dmax,check)
    pass = 0
    for ttt in 1:ntc
        K::Int64 = 2*rand(1:Kmax÷2)
        Q::Int64 = rand(1:Qmax)
        maxDepth = rand(1:Kmax÷2)
        AA = fill('.',K); depth = 0
        dprob = [rand() for i in 1:maxDepth]
        for i in 1:K
            if depth == 0; AA[i] = '('; depth = 1
            elseif depth == maxDepth || K-i+1 == depth; AA[i] = ')'; depth -= 1
            elseif rand() < dprob[depth]; AA[i] = '('; depth += 1
            else; AA[i] = ')'; depth -= 1
            end
        end
        A = join(AA,"")
        S::Vector{Int64} = [rand(1:K) for i in 1:Q]
        E::Vector{Int64} = [rand(1:K) for i in 1:Q]
        L::Vector{Int64} = [rand(1:Dmax) for i in 1:K]
        R::Vector{Int64} = [rand(1:Dmax) for i in 1:K]
        P::Vector{Int64} = [rand(1:Dmax) for i in 1:K]
        ans2 = (Dmax == 1) ? solveSmall(K,Q,A,L,R,P,S,E) : solveLarge(K,Q,A,L,R,P,S,E)
        if check
            ans1 = solveVerySmall(K,Q,A,L,R,P,S,E)
            if ans1 == ans2; pass += 1
            else
                print("$K $Q\n")
                print("$A\n")
                print(join(L," ")*"\n")
                print(join(R," ")*"\n")
                print(join(P," ")*"\n")
                print(join(S," ")*"\n")
                print(join(E," ")*"\n")
                print("ERROR: ttt:$ttt Dmax:$Dmax ans1:$ans1 ans2:$ans2\n")

                ans1 = solveVerySmall(K,Q,A,L,R,P,S,E)
                ans2 = (Dmax == 1) ? solveSmall(K,Q,A,L,R,P,S,E) : solveLarge(K,Q,A,L,R,P,S,E)
            end
        else
            pass += 1
        end
    end
    print("$pass/$ntc passed\n")
end

function main(infn="")
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
        K,Q = gis()
        A = gs()
        L = gis()
        R = gis()
        P = gis()
        S = gis()
        E = gis()
        #ans = solveSmall(K,Q,A,L,R,P,S,E)
        ans = solveLarge(K,Q,A,L,R,P,S,E)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()

## Small Testing
#test(100000,10,2,1,true)
#test(100,100,100000,1,true)
#test(1000,100,100000,1,true)
#test(20,100000,100000,1,false)
#test(100,1000,1000,1,false)

## Large Testing

#for i in 1:100
#    test(10000,10,5,10,true)
#end

#for i in 1:10
#    test(1000,100,100000,10,true)
#    test(1000,100,100000,1000000,true)
#end

#test(1000,10,2,5,true)
#test(1000,100,100000,10,true)
#test(1000,100,100000,1000000,true)
#test(20,100000,100000,1000000,false)
#test(100,1000,1000,1000000,false)

# Profiling
#using Profile, StatProfilerHTML
#Profile.clear()
#@profile test(1,100000,100000,1,false)
#Profile.clear()
#@profilehtml test(100,100000,100000,1000000,false)

