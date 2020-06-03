using Printf

######################################################################################################
### The key observation that makes that large tractable is as follows
### -- We figure out the set of all turrent each soldier can hit in D moves, assuming any cleared
###    dependencies have been met.
### -- We do a maximal matching of soldiers to turrets using these edges.
### -- This clearly gives us an upper bound on how many turrets we can shoot.  Surprisingly, it is
###    an always realizable upper bound with a clever algorithm.
### -- We pick a soldier and have him walk along his path to the matched square where he can shoot his
###    chosen turret.  Three things can happpen
###    -- He makes it all the way there, and shoots his turret
###    -- He makes it to a point where he is blocked by a turrent not assigned.  He just shoots that
###       turret instead.
###    -- He gets blocked by a turret assigned to that person.
###       --- In this case, we repeat the walk from that soldier and do the same thing.
###       --- This continues until either a soldier is successful, or we find we have a cycle of dependencies.
###           With the cycle, we can just let each shoulder 
######################################################################################################

######################################################################################################
### BEGIN MAXIMUM BIPARTITE MATCHING CODE
### Inspired by https://www.geeksforgeeks.org/maximum-bipartite-matching/
######################################################################################################

function bpm(bpGraph::Array{Int8,2}, u::Int, seen::Array{Bool,1}, matchR::Array{Int,1}, m::Int, n::Int)::Bool
    for v in 1:n
        if bpGraph[u,v] == 1 && !seen[v]
            seen[v] = true
            if matchR[v] < 0 || bpm(bpGraph, matchR[v], seen, matchR, m, n)
                matchR[v] = u
                return true
            end
        end
    end
    return false
end

function maxBPM(bpGraph::Array{Int8,2},m::Int,n::Int)
    matchR = fill(-1,n)
    seen = fill(false,n)
    result = 0
    for u in 1:m
        fill!(seen,false)
        if bpm(bpGraph,u,seen,matchR,m,n); result += 1; end
    end
    matches = Set((matchR[x],x) for x in 1:n if matchR[x] > 0)
    return result,matches
end

######################################################################################################
### END MAXIMUM BIPARTITE MATCHING CODE
### Inspired by https://www.geeksforgeeks.org/maximum-bipartite-matching/
######################################################################################################

function orderMatches(matches,deps,S,T)
    stot = fill(-1,S)
    ttos = fill(-1,T)
    for (s,t) in matches; stot[s]=t; ttos[t]=s; end
    serviced = fill(false,S)
    matchesLeft = length(matches)
    walkIdx = fill(1,S)
    newMatches = []
    currentTurrets = BitSet()

    function checks(s,t)
        tidx = deps[s][walkIdx[s]]
        while tidx in currentTurrets
            walkIdx[s] += 1
            tidx = deps[s][walkIdx[s]]
        end
        return tidx, ttos[tidx]
    end

    function process(s,t)
        ttos[stot[s]] = -1
        stot[s] = -1
        push!(newMatches,(s,t))
        serviced[s] = true
        push!(currentTurrets,t)
        matchesLeft -= 1
    end

    while (matchesLeft > 0)
        ## Clear off a scoreboard
        sb = fill(false,S)

        ## Find a node to start the search from
        hs,ht = -1,-1
        for (s,t) in matches
            if serviced[s]; continue; end
            hs,ht = s,t
            break
        end
        stack = []
        done = false
        while !done
            val,nhs = checks(hs,ht)
            if nhs == -1 
                process(hs,val)
                for (s,t) in stack
                    process(s,t)
                end
                done = true
            elseif nhs == hs
                process(hs,val)
                done = true
            elseif sb[nhs]  ## Here we have a cycle, so we have to pop off until 
                process(hs,val)
                while !isempty(stack)
                    (s,t) = pop!(stack)
                    process(s,t)
                    if s == nhs; break; end
                end
                done = true
            else
                sb[hs] = true
                push!(stack,(hs,val))
                hs,ht = nhs,stot[nhs]
            end
        end
    end
    return newMatches
end

function makeDeps(matches,scoreboard,pathParents,gra,S,T)
    deps = [[] for x in 1:S]
    for (s,t) in matches
        (i,j) = scoreboard[s,t]
        path = []
        while (i,j) != (-1,-1); push!(path,(i,j)); (i,j) = pathParents[s,i,j]; end
        reverse!(path)
        currentTurrets = BitSet()
        for (i,j) in path
            newTurrets = setdiff(gra[i,j],currentTurrets)
            for tidx in newTurrets 
                push!(deps[s],tidx)
            end
            union!(currentTurrets,newTurrets)
        end
    end
    return deps
end


function getMaximalMatch(scoreboard,S,T)
    bpGraph = fill(zero(Int8),S,T)
    for s in 1:S
        for t in 1:T
            if scoreboard[s,t] != (-1,-1); bpGraph[s,t] = one(Int8); end
        end
    end
    numMatches,matches = maxBPM(bpGraph,S,T)
    return matches
end

function doSearch1(gr::Array{Char,2},gra::Array{BitSet,2},soldiers::Vector{Tuple{Int64,Int64}},R::Int64,C::Int64,S::Int64,T::Int64,M::Int64)
    scoreboard  = fill((-1,-1),S,T)
    pathParents = fill((-1,-1),S,R,C)
    for (sidx,(si,sj)) in enumerate(soldiers)
        currentTurrets = BitSet()
        visited = fill(false,R,C)
        q = Vector{Tuple{Int64,Int64,Int64,Int64,Int64}}()
        push!(q,(si,sj,-1,-1,M))
        while !isempty(q)
            (i::Int64,j::Int64,pi::Int64,pj::Int64,m::Int64) = popfirst!(q)
            if visited[i,j]; continue; end
            visited[i,j] = true
            pathParents[sidx,i,j] = (pi,pj)
            #newTurrets = gra[i,j] & ~currentTurrets
            newTurrets = setdiff(gra[i,j],currentTurrets)
            for tidx in newTurrets
                scoreboard[sidx,tidx] = (i,j)
            end
            union!(currentTurrets,newTurrets)
            if m > 0
                if i > 1 && gr[i-1,j] != '#'; push!(q,(i-1,j,i,j,m-1)); end
                if j > 1 && gr[i,j-1] != '#'; push!(q,(i,j-1,i,j,m-1)); end
                if i < R && gr[i+1,j] != '#'; push!(q,(i+1,j,i,j,m-1)); end
                if j < C && gr[i,j+1] != '#'; push!(q,(i,j+1,i,j,m-1)); end
            end
        end
    end
    return scoreboard,pathParents
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")

        C,R,M = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        gr = fill('.',R,C)
        for i in 1:R
            gr[i,:] = [x for x in rstrip(readline(infile))]
        end
        soldiers = [(i,j) for i in 1:R for j in 1:C if gr[i,j] == 'S']
        turrets  = [(i,j) for i in 1:R for j in 1:C if gr[i,j] == 'T']
        S = length(soldiers)
        T = length(turrets)

        ## Create a new grid where each square lists the turrets that are attacking it.
        gra = [BitSet() for r in 1:R, c in 1:C]
        for (ii,(ti,tj)) in enumerate(turrets)
            tie,tiw = tj,tj
            tin,tis = ti,ti
            while tie < C && gr[ti,tie+1] != '#'; tie += 1; end
            while tiw > 1 && gr[ti,tiw-1] != '#'; tiw -= 1; end
            while tin > 1 && gr[tin-1,tj] != '#'; tin -= 1; end
            while tis < R && gr[tis+1,tj] != '#'; tis += 1; end
            ttag = Int128(1) << (ii-1)
            for i in tin:tis; push!(gra[i,tj],ii); end
            for j in tiw:tie; push!(gra[ti,j],ii); end
        end

        ## Now for each soldier, we create an array which is > 0 if we can hit that turret index, and the value
        ## that is stored there is previous cell we were in (so we can resconstruct a path to that cell)
        scoreboard,pathParents = doSearch1(gr,gra,soldiers,R,C,S,T,M)
        matches = getMaximalMatch(scoreboard,S,T)
        deps = makeDeps(matches,scoreboard,pathParents,gra,S,T)
        newMatches = orderMatches(matches,deps,S,T)
        ans = length(newMatches)
        print("$ans\n")
        for (s,t) in newMatches
            print("$s $t\n")
        end
    end
end

main()

