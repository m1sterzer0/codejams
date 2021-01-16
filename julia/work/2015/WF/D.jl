######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function bfsMaxFlow(s::Int64, t::Int64, adj::Vector{Set{Int64}}, capacity::Dict{Tuple{Int64,Int64},Int64}, parent::Vector{Int64})::Int64
    fill!(parent,-1)
    parent[s] = -2
    q = Vector{Tuple{Int64,Int64}}()
    push!(q,(s,1000000000000000000))

    while !isempty(q)
        (cur::Int64,flow::Int64) = popfirst!(q)
        for next::Int64 in adj[cur]
            if parent[next] == -1 && capacity[(cur,next)] > 0
                parent[next] = cur
                newFlow = min(flow,capacity[(cur,next)])
                if next == t; return newFlow; end
                push!(q,(next,newFlow))
            end
        end
    end
    return 0
end

function pushEdges(adj::Vector{Set{Int64}}, capacity::Dict{Tuple{Int64,Int64},Int64}, n1::Int64, n2::Int64, cap::Int64, ncap::Int64)
    push!(adj[n1],n2)
    push!(adj[n2],n1);
    capacity[(n1,n2)] = cap;
    capacity[(n2,n1)] = ncap;
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")

        N,M,K = [parse(Int64,x) for x in split(readline(infile))]
        edgeList::Vector{Tuple{Int64,Int64}} = []
        for i in 1:M
            x1,x2 = [parse(Int64,x) for x in split(readline(infile))]
            push!(edgeList,(x1+1,x2+1))
        end

        ##Following answer as envisioned in the official solutions
        ##Node-id for (v,x,bool) is 2*N*(x+1) + N*bool + v, where v goes from 1..N
        ##Note there are no bidrectional links
        
        adj = Vector{Set{Int64}}()
        capacity = Dict{Tuple{Int64,Int64},Int64}()

        ## Do the initial stuff for X == 0
        for i in 1:2*N; push!(adj,Set{Int64}()); end
        for i in 1:N; pushEdges(adj,capacity,i,i+N,1,0); end
        x,flow = 0,0

        myinf = 1000000000000000000
        while flow <= K
            x += 1
            offset = 2*N*x
            for i in 1:2*N; push!(adj,Set{Int64}()); end
            for i in 1:N; pushEdges(adj,capacity,offset+i,offset+i+N,1,0); end                  ## These are the fragile edges where there is no guard
            for i in 1:N; pushEdges(adj,capacity,offset+i-2*N,offset+i,myinf,0); end            ## These are the wait paths
            for i in 1:N; pushEdges(adj,capacity,offset+i-2*N,offset+i+N,myinf,0); end          ## These are the path through the guard
            for (n1,n2) in edgeList; 
                pushEdges(adj,capacity,offset+n1-N,offset+n2,myinf,0);
                pushEdges(adj,capacity,offset+n2-N,offset+n1,myinf,0);
            end ## These are the paths from the graph

            ## Now do the maxflow
            parent = fill(-1,2*N*(x+1))
            while(true)
                newFlow = bfsMaxFlow(1,N+offset,adj,capacity,parent)
                if newFlow == 0; break; end
                flow += newFlow
                if flow > K; break; end
                cur::Int64 = N+offset
                while(cur != 1)
                    prev::Int64 = parent[cur]
                    capacity[(prev,cur)] -= newFlow
                    capacity[(cur,prev)] += newFlow
                    cur = prev
                end
            end
        end
        print("$x\n")
    end
end

main()
