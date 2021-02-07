################################################################
## BEGIN Dinic's Max Flow
################################################################

function dinic(n::Int64, s::Int64, t::Int64, edgeList::Vector{Tuple{Int64,Int64,Int64}})::Int64
    myinf = typemax(Int64)
    nume = size(edgeList,1)
    adj,newEdgeList = _dinicBuildAdj(n,edgeList)
    level::Vector{Int64} = [0 for i in 1:n]
    next::Vector{Int64} = [0 for i in 1:n]
    maxflow::Int64 = 0
    while(_dinicBfs(s,t,newEdgeList,adj,level))
        fill!(next,1)
        f = _dinicDfs(s,t,nume,newEdgeList,adj,level,next,myinf)
        while(f > 0)
            maxflow += f
            f = _dinicDfs(s,t,nume,newEdgeList,adj,level,next,myinf)
        end
    end
    return maxflow
end

function _dinicBuildAdj(n::Int64,edgeList::Vector{Tuple{Int64,Int64,Int64}})
    ne = length(edgeList)
    newEdgeList::Array{Int64,2} = fill(0,2*ne,3)
    adj::Vector{Vector{Int64}} = [Vector{Int64}() for x in 1:n]
    for i in 1:ne
        (n1,n2,c) = edgeList[i]
        newEdgeList[i,:] = [n1,n2,c]
        newEdgeList[ne+i,:] = [n2,n1,0]
        push!(adj[n1],i)
        push!(adj[n2],ne+i)
    end
    return adj,newEdgeList
end
    
function _dinicBfs(s::Int64, t::Int64, edgeList::Array{Int64,2}, adj::Vector{Vector{Int64}}, level::Vector{Int64})
    fill!(level,-1)
    level[s] = 0
    q::Vector{Int64} = [s]
    while(!isempty(q))
        nn = pop!(q)
        for eid in adj[nn]
            n1,n2,c = edgeList[eid,:]
            if (c > 0 && level[n2] == -1)
                level[n2] = level[n1] + 1
                push!(q,n2)
            end
        end
    end
    return level[t] != -1
end

function _dinicDfs(n::Int64, t::Int64, nume::Int64, edgeList::Array{Int64,2}, adj::Vector{Vector{Int64}}, level::Vector{Int64}, next::Vector{Int64}, flow::Int64)::Int64
    if n == t; return flow; end
    ne = length(adj[n])
    while next[n] <= ne
        eid = adj[n][next[n]]
        n1,n2,c = edgeList[eid,:]
        if c > 0 && level[n2] == level[n1]+1
            bottleneck = _dinicDfs(n2,t,nume,edgeList,adj,level,next,min(flow,c))
            if bottleneck > 0
                edgeList[eid,3] -= bottleneck
                eid2 = eid > nume ? eid - nume : eid + nume
                edgeList[eid2,3] += bottleneck
                return bottleneck
            end
        end
        next[n] += 1
    end
    return 0
end


################################################################
## END Dinic's Max Flow
################################################################

function doEdges(S::Int64,SS::Array{Int64,2},rows::Vector{Int64},cols::Vector{Int64})
    return bridgeEdges,tailEdges
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        R,C,S = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        SS::Array{Int64,2} = fill(0,S,3)
        for i in 1:S
            SS[i,:] = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        end
        cols = []
        rows = []
        for i in 1:S
            left = max(1,SS[i,2] - SS[i,3])
            bot  = max(1,SS[i,1] - SS[i,3])
            right = min(C+1,SS[i,2] + SS[i,3]+1)
            top   = min(R+1,SS[i,1] + SS[i,3]+1)
            for x in [left,right]; push!(cols,x); end
            for x in [top,bot];    push!(rows,x); end
        end
        unique!(sort!(cols))
        unique!(sort!(rows))

        ## Build the edge data structures
        bridgeEdges = []
        tailEdges = []
        full = 0
        regionidx = 3+S
        myinf = 1_000_000_000_000_000_001
        numrows,numcols = length(rows),length(cols)
        for i in 1:numrows-1
            for j in 1:numcols-1
                left,right,top,bot = cols[j],cols[j+1]-1,rows[i+1]-1,rows[i]
                area = (top-bot+1) * (right-left+1)
                active = false
                ## Answer 2 questions here
                ## is this rectangle in the possible patrol region for this station?  Just need a test point
                ## does this region contain the station
                for k in 1:S
                    if left >= SS[k,2] - SS[k,3] && left <= SS[k,2] + SS[k,3] && top >= SS[k,1] - SS[k,3] && top <= SS[k,1] + SS[k,3]
                        active = true
                        push!(bridgeEdges,(2+k,regionidx,myinf))
                    end
                    if SS[k,2] >= left && SS[k,2] <= right && SS[k,1] >= bot && SS[k,1] <= top
                        area -= 1
                    end
                end
                if area > 0; push!(tailEdges,(regionidx,2,area)); end
                if active; full += area; end
                regionidx += 1
            end
        end

        ## Special case if there are no available assignments
        if full == 0; print("0\n"); continue; end

        numnodes = 2 + S + (numrows-1)*(numcols-1)
        ## Do the lower bound search
        l,u = 0,1_000_000_000_000_000_001
        while u-l > 1
            m = (u+l) ÷ 2
            #print("DBG: LOWER m:$m\n")
            prefixEdges = [(1,2+x,m) for x in 1:S]
            myEdges::Vector{Tuple{Int64,Int64,Int64}} = vcat(prefixEdges,bridgeEdges,tailEdges)
            f = dinic(numnodes,1,2,myEdges)
            if f == m*S; l=m; else; u=m; end  ## Looking to make sure we get full flow
        end
        L = l

        ## Do the upper bound search
        l,u = 0,1_000_000_000_000_000_001
        while u-l > 1
            m = (u+l) ÷ 2
            #print("DBG: UPPER m:$m\n")
            prefixEdges = [(1,2+x,m) for x in 1:S]
            myEdges::Vector{Tuple{Int64,Int64,Int64}} = vcat(prefixEdges,bridgeEdges,tailEdges)
            f = dinic(numnodes,1,2,myEdges)
            if f == full; u=m; else; l=m; end ## Looking to make sure we get full coverage
        end
        U=u

        ans = U-L
        print("$ans\n")
    end
end

main()


