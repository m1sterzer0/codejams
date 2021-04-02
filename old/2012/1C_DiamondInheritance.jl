
function testit(N,p,adj)::Bool
    sb::Vector{Bool} = fill(false,N)
    function dfs(n::Int64)
        if sb[n]; return true; end
        sb[n] = true
        for c in adj[n]
            if dfs(c); return true; end
        end
        return false
    end
    return dfs(p)
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,rstrip(readline(infile)))
        parents = []
        adj::Vector{Vector{Int64}} = [Vector{Int64}() for i in 1:N]
        for i in 1:N
            MM = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
            M = popfirst!(MM)
            if M == 0; push!(parents,i); continue; end
            for m in MM; push!(adj[m],i); end
        end
        diamond = false
        for p in parents; diamond |= testit(N,p,adj); end
        ans = diamond ? "Yes" : "No"
        print("$ans\n")
    end
end

main()

