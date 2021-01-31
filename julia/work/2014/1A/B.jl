######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function traverse(p::Int64,n::Int64,adj::Vector{Vector{Int64}})::Int64
    best::Int64,secondbest::Int64 = 0,0
    for x in adj[n]
        if x == p; continue; end
        cans = traverse(n,x,adj)
        if cans > best;           (best,secondbest) = (cans,best)
        elseif cans > secondbest; secondbest = cans
        end
    end
    if secondbest == 0; return 1; end
    return 1 + best + secondbest
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,readline(infile))
        adj::Vector{Vector{Int64}} = []
        for i in 1:N; push!(adj,[]); end
        for i in 1:N-1
            e1,e2 = [parse(Int64,x) for x in split(readline(infile))]
            push!(adj[e1],e2)
            push!(adj[e2],e1)
        end
        best::Int64 = 0
        for i in 1:N
            ans = traverse(-1,i,adj)
            best = max(best,ans)
        end
        deleted = N - best
        print("$deleted\n")
    end
end

main()
