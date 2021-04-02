using Printf

######################################################################################################
### 1) After playing around with base cases, we realize that the condition is equivalent to the 
###    workers being partitioned into "cliques", where each of the n workers in the clique knows
###    has the skills to operate the exact same set of n machines, and no other clique can operate
###    any of those machines.  The proof is a bit tedious (online solutions have one), but the
###    intuition can be gotten by looking at base cases.
###
### 2) With that intuition, we build the graph and break the graph into connected components.  We
###    then characterize each connected component by (w,m), where w is the number of workers in the
###    connected component, and m is the number of machines in the connected component.2 
######################################################################################################

function traverse(adjL::Array{Array{Int64,1},1}, n::Int64, visited::Set{Int64},current::Array{Int64,1})
    if n ∉ visited
        push!(current,n)
        push!(visited,n)
        for k in adjL[n]; traverse(adjL,k,visited,current); end
    end
end

function getComponents(adjL,N)
    comps = []
    visited = Set{Int64}()
    for i in 1:2N
        if i ∉ visited
            comp = Array{Int64,1}()
            traverse(adjL,i,visited,comp)
            push!(comps,comp)
        end
    end
    return comps 
end

function processSubset(s,subsets,compList,st)
    if haskey(subsets,s); return; end
    subsets[s] = fill(1000,26)  ## Worst possible cost is 625, so 1000 is just as good as inf
    v = subsets[s]
    v[1] = 0
    sqidx = st[1] == st[2] ? st[1]+1 : 0
    if sqidx > 0; v[sqidx] = (sqidx-1)^2; end 
    for (i,c) in enumerate(s)
        if c == 'A'; continue; end
        st2 = (st[1]-compList[i][1], st[2]-compList[i][2])
        if 0 in st2; continue; end
        substr = prod([s[1:i-1],c-1,s[i+1:end]])
        if !haskey(subsets,substr); processSubset(substr,subsets,compList,st2); end
        v2 = subsets[substr]
        for i in 1:min(st2[1],st2[2])
            v[i+1] = min(v[i+1],v2[i+1])
            if sqidx > 1
                v[sqidx] = min(v[sqidx], v2[i+1] + (sqidx-(i+1))^2)
            end
        end
    end
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,readline(infile))

        ### Build the graph
        adjL = Array{Array{Int64,1},1}()
        numEdges = 0
        for i in 1:2N; push!(adjL,Array{Int64,1}()); end
        for i in 1:N
            S = rstrip(readline(infile))
            for j in 1:N
                if S[j] == '1'
                    numEdges += 1
                    push!(adjL[i],N+j)
                    push!(adjL[N+j],i)
                end
            end
        end

        ### Gater the components of the graph
        components = getComponents(adjL,N)

        ### Create a dictionary of the components by the number of workers and the number of of machines
        sb = Dict{Tuple{Int64,Int64},Int64}()
        for c in components
            w = count(x -> x<=N, c)
            m = length(c)-w
            sb[(w,m)] = haskey(sb,(w,m)) ? sb[(w,m)]+1 : 1
        end

        ### Remove the perfect squares
        remaining = N
        cost = 0
        compList = []
        for (k,v) in sb
            if k[1] == k[2]
                cost += k[1]*k[1]*v
                remaining -= k[1]*v
            else
                push!(compList,k)
            end
        end

        ### Since every subset can be represented at most 25 times in the lineup, it is convenient to use the
        ### 26 upper-case letters as a code for how many of that type of subset remain
        if remaining > 0
            subsets = Dict{String,Array{Int64,1}}()
            startingSubset = prod(['A'+sb[x] for x in compList])
            processSubset(startingSubset,subsets,compList,(remaining,remaining))
            cost += subsets[startingSubset][remaining+1]
        end

        cost -= numEdges
        print("$cost\n")
    end
end

main()