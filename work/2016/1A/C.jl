using Printf

######################################################################################################
### BEGIN MAIN PROGRAM
###
### Observations
###    * Because there is only one edge out of each node, each element may only belong to 0
###      or 1 cycles.
###    * The end result will be either
###      a) The largest cycle we can make
###      b) The largest collection of chains we can assemble that loop back on themselves
###
### To this end, we should endeavor to find three "structures" in the graphs
###  a) Cycles with >= 3 elements
###  b) Cycles with exactly 2 elements
###  c) Chains that end in a 2 element cycle.  For this one, we can search from non-sink nodes in
###     the graph.
###
### We then output either the maximum cycle size, or the sum of the disjoint chains, including
### all of the 2 cycles.  One hiccup is that we can up to 2 chains that end in the same two cycle
### provided they come into the chain from different elements there.
######################################################################################################

function biggestChains(chains,twoCycles)
    endpoints   = Set{Int64}()
    chainPoints = Set{Int64}()
    for c in twoCycles
        for x in c
            push!(endpoints,x)
        end
    end
    sort!(chains,rev=true,by=length)
    for c in chains
        if c[end] in endpoints
            for x in c; push!(chainPoints,x); end
            pop!(endpoints,c[end])
        end
    end
    total = length(union(endpoints,chainPoints))
    return total
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,readline(infile))
        F = [parse(Int64,x) for x in split(readline(infile))]
        bigCycles,twoCycles,chains = [],[],[]
        for i in 1:N
            path = [i]
            while F[path[end]] ∉ path; push!(path,F[path[end]]); end
            if F[path[end]] == path[1] 
                if length(path) == 2
                    push!(twoCycles,path)
                else
                    push!(bigCycles,path)
                end
            elseif F[path[end]] == path[end-1]
                push!(chains,path)
            end
        end
        best = length(bigCycles) == 0 ? 0 : maximum([length(x) for x in bigCycles])
        best = max(best, biggestChains(chains,twoCycles))
        print("$best\n")
    end
end

main()

