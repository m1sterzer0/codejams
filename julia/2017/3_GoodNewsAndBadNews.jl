using Printf
using Random
Random.seed!(2345)

######################################################################################################
### a) Since we can tolerate negative weights, we can consider the graph as undirected and we can
###    decide the direction by convention.
### 
### b) We split the graph up into connected components.
###
### c) In each graph, we need degrees of freedom to balance, so we pick out a spanning tree and we
###    randomize the rest.
###
### d) Then we just balance the nodes and see if it works.  We just try it a ton of times, and
###    if it doesn't work, we "guess" it is "IMPOSSIBLE" 
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        F,P = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        A = fill(0,P)
        B = fill(0,P)
        for i in 1:P
            A[i],B[i] = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        end

        ## Unify the edges
        undirEdges = Set{Tuple{Int64,Int64}}()
        dirEdges   = Set{Tuple{Int64,Int64}}()
        for i in 1:P
            push!(dirEdges,(A[i],B[i]))
            push!(undirEdges,(min(A[i],B[i]),max(A[i],B[i])))
        end

        ## Build the adjacency structure
        adjl = [Set{Int64}() for i in 1:F]
        for (a,b) in undirEdges
            push!(adjl[a],b)
            push!(adjl[b],a)
        end
        adjv = fill(0,F,F)

        ## Iterate through the nodes
        visited = fill(false,F)
        spanning = Vector{Tuple{Int64,Int64}}()
        function dfs(par,n)
            if visited[n]; return; end
            visited[n] = true
            push!(spanning,(par,n))
            for c in adjl[n]; dfs(n,c); end
        end
        for i in 1:F; dfs(-1,i); end

        F2 = F*F
        zeroWeight,unbalanced,extremeWeight = false,false,false
        ans = []
        for i in 1:1000
            zeroWeight,unbalanced,extremeWeight = false,false,false
            weights = vcat(collect(1:F),collect(-1:-1:-F))
            for (a,b) in undirEdges
                w = rand(weights)
                adjv[a,b] = w
                adjv[b,a] = -w
            end
            for (a,b) in reverse(spanning)
                rs = 0
                for n in adjl[b]; rs += adjv[b,n]; end
                if a == -1
                    if rs != 0; unbalanced = true; end
                else
                    adjv[b,a] -= rs
                    adjv[a,b] += rs
                    if (adjv[b,a] == 0) && ((a,b) ∉ dirEdges || (b,a) ∉ dirEdges); zeroWeight = true; end
                    if abs(adjv[b,a]) > F2; extremeWeight = true; end
                end
            end
            if !zeroWeight && !unbalanced && !extremeWeight; break; end
        end

        if zeroWeight || unbalanced || extremeWeight;
            print("IMPOSSIBLE\n");
        else
            ans = []
            for i in 1:P
                a,b = A[i],B[i]
                if (b,a) ∉ dirEdges; push!(ans,adjv[a,b])
                elseif adjv[a,b] == 0; push!(ans,1)
                elseif a < b
                    push!(ans, adjv[a,b] == -F2 ? -F2+1 : adjv[a,b] == 1  ? 2 : adjv[a,b]-1)
                else
                    push!(ans, adjv[b,a]== -F2 ? 1      : adjv[b,a] == 1  ? 1 : -1 )
                end
            end
            println(join(ans," "))
        end
    end
end

main()
