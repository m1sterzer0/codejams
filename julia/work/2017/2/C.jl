using Printf

######################################################################################################
### This feels like a simple 2-SAT problem.
### The only key observation is that a maximum of two lasers can hit the same square; otherwise they
### would run into one another.
######################################################################################################

################################################################
## BEGIN Twosat from geeks for geeks
## https://www.geeksforgeeks.org/2-satisfiability-2-sat-problem/
## https://cp-algorithms.com/graph/2SAT.html
## Assumes 1:n code the true values of the variables, and n+1:2n code the complements
################################################################
function twosat(n::Int64,m::Int64,a::Array{Int64},b::Array{Int64})
    adj = [[] for i in 1:2n]
    adjInv = [[] for i in 1:2n]
    visited = fill(false,2n)
    visitedInv = fill(false,2n)
    s = Int64[]
    scc = fill(0,2n)
    counter = 1

    function addEdges(x::Int64,y::Int64); push!(adj[x],y); end

    function addEdgesInverse(x::Int64,y::Int64); push!(adjInv[y],x); end

    function dfsFirst(u::Int64)
        if visited[u]; return; end
        visited[u] = true
        for x in adj[u]; dfsFirst(x); end
        push!(s,u)
    end

    function dfsSecond(u::Int64)
        if visitedInv[u]; return; end
        visitedInv[u] = true
        for x in adjInv[u]; dfsSecond(x); end
        scc[u] = counter
    end

    ### Start the main routine
    ### Build the impplication graph
    for i in 1:m
        na = a[i] > n ? a[i] - n : a[i] + n
        nb = b[i] > n ? b[i] - n : b[i] + n
        addEdges(na,b[i])
        addEdges(nb,a[i])
        addEdgesInverse(na,b[i])
        addEdgesInverse(nb,a[i])
    end

    ### Kosaraju 1
    for i in 1:2n
        if !visited[i]; dfsFirst(i); end
    end

    ### Kosaraju 2
    while !isempty(s)
        nn = pop!(s)
        if !visitedInv[nn]; dfsSecond(nn); counter += 1; end 
    end

    assignment = fill(false,n)
    for i in 1:n
        if scc[i] == scc[n+i]; return (false,[]); end
        assignment[i] = scc[i] > scc[n+i]
    end

    return (true,assignment)
end

################################################################
## END Twosat from geeks for geeks
################################################################

function solvegrid(lasers,forcedLasers,dots,db2)
    n = length(lasers)
    m = length(dots)
    lidx = Dict()
    for (i,l) in enumerate(lasers)
        lidx[l] = i
    end

    ## Build the conjunctions
    a = Int64[]
    b = Int64[]
    for (k,v) in db2
        (i1,j1,d1) = v[1]
        n1 = lidx[(i1,j1)] + (d1 == 'H' ? 0 : n)
        n2 = n1
        if length(v) > 1
            (i2,j2,d2) = v[2]
            n2 = lidx[(i2,j2)] + (d2 == 'H' ? 0 : n)
        end
        push!(a,n1)
        push!(b,n2)
    end

    ## Forced lasers
    for (i1,j1,d1) in forcedLasers
        n1 = lidx[(i1,j1)] + (d1 == 'H' ? 0 : n)
        n2 = n1
        push!(a,n1)
        push!(b,n2)
    end

    (success,assignment) = twosat(n,length(a),a,b)
    if !success; return false,[]; end
    ans = []
    for i in 1:n
        (j,k) = lasers[i]
        d = assignment[i] ? '-' : '|'
        push!(ans,(j,k,d))
    end
    return true,ans
end

function move(gr,i,j,R,C,d,arr)
    if i <= 0 || j <= 0 || i > R || j > C; return true; end
    if gr[i,j] in "|-"; return false; end
    if gr[i,j] == '#'; return true; end
    movedir = d
    if gr[i,j] == '.'; push!(arr,(i,j)); end
    if gr[i,j] == '/'
        if     d == 'N'; movedir = 'E'
        elseif d == 'S'; movedir = 'W'
        elseif d == 'W'; movedir = 'S'
        elseif d == 'E'; movedir = 'N'
        end
    end
    if gr[i,j] == '\\'
        if     d == 'N'; movedir = 'W'
        elseif d == 'S'; movedir = 'E'
        elseif d == 'W'; movedir = 'N'
        elseif d == 'E'; movedir = 'S'
        end
    end
    if movedir == 'N'; return move(gr,i-1,j,R,C,movedir,arr); end
    if movedir == 'S'; return move(gr,i+1,j,R,C,movedir,arr); end
    if movedir == 'W'; return move(gr,i,j-1,R,C,movedir,arr); end
    if movedir == 'E'; return move(gr,i,j+1,R,C,movedir,arr); end
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        ## Read the input
        R,C = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        gr = fill('.',R,C)
        for i in 1:R
            gr[i,:] = [x for x in rstrip(readline(infile))]
        end

        dots   = [(i,j) for i in 1:R for j in 1:C if gr[i,j] == '.']
        lasers = [(i,j) for i in 1:R for j in 1:C if gr[i,j] in "|-"]

        db2 = Dict()
        for (i,j) in dots
            db2[(i,j)] = []
        end

        good = true
        forcedLasers = []
        for (i,j) in lasers
            arrns,arrew = [],[]
            ns = move(gr,i-1,j,R,C,'N',arrns) && move(gr,i+1,j,R,C,'S',arrns)
            ew = move(gr,i,j-1,R,C,'W',arrew) && move(gr,i,j+1,R,C,'E',arrew)

            if ns
                unique!(arrns)
                for (k,l) in arrns; push!(db2[(k,l)],(i,j,'V')); end
                if !ew; push!(forcedLasers,(i,j,'V')); end
            end
            if ew
                unique!(arrew)
                for (k,l) in arrew; push!(db2[(k,l)],(i,j,'H')); end
                if !ns; push!(forcedLasers,(i,j,'H')); end
            end
            if !ns && !ew
                good = false
                break
            end
        end
        if !good; print("IMPOSSIBLE\n"); continue; end

        ## Now we check if any of the dots are empty
        for (i,j) in dots
            if length(db2[(i,j)]) == 0; good = false; break; end; 
        end

        if !good; print("IMPOSSIBLE\n"); continue; end

        ## There is hope, now we just need to run 2sat
        ans,vals = solvegrid(lasers,forcedLasers,dots,db2)
        if !ans; print("IMPOSSIBLE\n"); continue; end

        ## Wow, it worked, print crap out
        print("POSSIBLE\n")
        gr2 = copy(gr)
        for (i,j,d) in vals
            gr2[i,j] = d
        end
        for i in 1:R
            println(join(gr2[i,:],""))
        end
    end
end

main()
