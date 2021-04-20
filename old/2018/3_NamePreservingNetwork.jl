using Random 
Random.seed!(8765309)

######################################################################################################
### So there are really 2 subproblems to this main problem.
### -- How to generate a network that satifies the constraints with enough "character" to satisfactorily
###    disambiguate the nodes.
### -- How to quickly calculate the the mapping between our nodes and the ones the judge spits back
###    to us.
###
### 1) Generating the graph.  We do this pseudo-randomly.  First, we string a connection from 1-2, 2-3,
###    ... , (n-1)-n.  This accounts for n-1 of the edges.  For the other n+1 of the edges, we just
###    randomly pick 2 nodes that haven't hit their edge quota, ensure that an edge between them doesn't
###    already exist, and then add them to the network.  The routine needs enough retry/checks to 
###    account for the various ways it can get stuck.
###
### 2) Coming up with a "node signature" -- The powers p of the adjacency matrix provide the number of
###    unique paths from i->j of length p.  We sort each row of the particular power matrix and use that
###    as a signature for the node.  We try p in the range of 2:10, and we stop when we find a p
###    that produces unique signatures for a node.  If we run out at 10, we signal back to the main
###    process, and we start the graph generation all over again.
######################################################################################################

function randomlyPopulateAdjMatrix(n::Int64)
    done = false
    res = nothing
    power = 0
    a = fill(zero(Int128),n,n)
    while !done
        done = true
        fill!(a,0)
        cnt = fill(0,n)
        for i in 1:n-1
            a[i,i+1] = a[i+1,i] = 1
            cnt[i] += 1
            cnt[i+1] += 1
        end
        edges = Set{Int}(collect(1:n))
        left = n+1
        for i in 1:100*n  ## Try a bunch
            if left == 0; break; end
            if length(edges) == 1; done=false; break; end
            x = Random.rand(edges)
            y = x
            while (x==y); y = Random.rand(edges); end
            if a[x,y] == 1; continue; end ## Try again, this edge is taken
            a[x,y] = a[y,x] = 1
            left -= 1
            cnt[x] += 1
            cnt[y] += 1
            if cnt[x] == 4; delete!(edges,x); end
            if cnt[y] == 4; delete!(edges,y); end
        end
        if left > 0; done = false; continue; end
        (b,power,res) = tryPowers(a,n)
        if !b; done = false; continue; end
    end
    return power,res,a
end

function tryPowers(a::Array{Int128,2},n::Int64)
    for i in 2:10
        b = a^i
        d = Dict()
        for i in 1:n
            x = Tuple(sort(b[i,:]))
            d[x] = i
        end
        if length(keys(d)) == n
            return (true,i,d)
        end
    end
    return (false,0,Dict())
end

function solve(a::Array{Int128,2},power::Int64,res::Dict,aa::Array{Int128,2})
    n = size(aa,1)
    x = fill(0,n)
    b = aa^power
    for i in 1:n
        yy = Tuple(sort(b[i,:]))
        if !haskey(res,yy); exit(1); end
        j = res[yy]
        x[j] = i
    end
    return x
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        #print("Case #$qq: ")
        L,U = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        print("$L\n")
        power,res,a = randomlyPopulateAdjMatrix(L)
        for i in 1:L-1
            for j in i+1:L
                if a[i,j] == 1
                    print("$i $j\n")
                end
            end
        end
        flush(stdout)
        N = parse(Int64,rstrip(readline(infile)))
        if N == -1; exit(1); end
        aa = fill(zero(Int128),N,N)
        for i in 1:2N
            x,y = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
            aa[x,y] = aa[y,x] = 1
        end
        x = solve(a,power,res,aa)
        xstr = join(x," ")
        print("$xstr\n")
        flush(stdout)
    end
end

main()
