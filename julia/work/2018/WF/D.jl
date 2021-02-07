######################################################################################################
### GENERAL OBSERVATIONS (following solutions)
###  
### GroupID  Can always defend?  Has a winning attack?  What can I learn?
### -------  ------------------  ---------------------  -----------------
###  D1             NO                    NO             Everything (these are fully dominated)
###  D2             YES                   YES            Small case: EITHER a winning attack OR
###                                                        defense for all my attacks
###                                                      Large case: Additionally, one attack
###                                                        if I know none of his attacks.
###  D3             NO                    YES            A winning attack
###  D4             YES                   NO             All defences for my attacks  
###
###  * Clearly we will dual anyone in D1 when they become available.
###  * We can then use D4 to learn defenses for all of my attacks (assuming D4 is non-empty)
###  * Next, we can generally make "forward progress" by alternating between D3 & D4
###    -- We learn an attack from D3
###    -- We learn the corresponding defence from D4.
###    Within each of these steps (or partial steps), at least one of the following happens
###    -- We learn a new attack and defence
###    -- People in D3 can move to D1
###    -- People in D4 can move to D1
###    -- People in D2 can move to D3/D4 and possibly onto D1
###  * What problems can we encounter?  When do we get "stuck"? 
###    - PROBLEM 1) All remaining people have an attack we cannot counter, and all
###      choose not to defend. (D2/D3 case)
###    - PROBLEM 2) All remaining people have BOTH
###      a) defences for all of our attacks
###      b) knowledge of an attack we already know. (D2/D4 case)
###  * PROBLEM A doesn't change with what attacks we know, so to solve problem A, we can assume
###      we start with an unblockable attack and see if that leads to full domination.
###  * Solving PROBLEM B is different between the small and large cases
###
###  SMALL CASE
###  ----------
###  * Because the condition (2b) is automatically met in the small case, Probelm B turns into
###    the dual of Problem A.  We assume we start out with all defences, and see if we can
###    gain attacks that can defeat everyone.
###
###  LARGE CASE
###  ----------
###  * We now have more outs, since we can learn attacks.
###  * What does the end state look like now?
###    -- Each remaining person has an attack they will play that is defendable by
###       everyone in the group
###    -- The group can defend against all attacks from outside the group.
###  * For the second condition, assume Y has an attack that can beat X.
###    Then we can't have Y outside the group and X inside the group.
###    Thus X being in the group implies Y is in the group.
###  * We create a directed implication graph, and look for "leaf" SCCs.  We don't want
###    outgoing edges, as this means our implication graph is not complete.  These leaf SSCs
###    satisfy the second criteria, and then we can check for the first criteria separately. 
######################################################################################################

function solveProbA(N::Int64,P::Int64,AA::Array{Bool,2},DD::Array{Bool,2},lenA::Vector{Int64})
    dsb = fill(false,P)
    psb = fill(0,N)
    psb[1] = lenA[1]
    q = []
    for j in 1:P
        if DD[1,j]; push!(q,j); end
    end
    while !isempty(q)
        s = popfirst!(q)
        if dsb[s]; continue; end
        dsb[s] = true
        for i in 2:N
            if AA[i,s]
                psb[i] += 1
                if psb[i] == lenA[i]
                    for j in 1:P
                        if DD[i,j]; push!(q,j); end
                    end
                end
            end
        end
    end
    for i in 1:N
        if psb[i] < lenA[i]; return false; end
    end
    return true
end

function solveProbBsmall(N::Int64,P::Int64,AA::Array{Bool,2},DD::Array{Bool,2})
    asb = fill(false,P)
    psb = fill(false,N)
    psb[1] = true
    q = []
    for j in 1:P
        if AA[1,j]; push!(q,j); end
    end
    while !isempty(q)
        s = popfirst!(q)
        if asb[s]; continue; end
        asb[s] = true
        for i in 2:N
            if !DD[i,s] && !psb[i]
                psb[i] = true
                for j in 1:P
                    if AA[i,j]; push!(q,j); end
                end
            end
        end
    end
    for i in 1:N
        if !psb[i]; return false; end
    end
    return true
end

function solveProbB(N::Int64,P::Int64,AA::Array{Bool,2},DD::Array{Bool,2})
    adj::Vector{Vector{Int64}} = [Vector{Int64}() for i in 1:(N+P)]
    for j in 1:P
        if sum(AA[i,j] ? 1 : 0 for i in 1:N) == 0; continue; end
        for i in 1:N
            if AA[i,j]; push!(adj[N+j],i); end
            if !DD[i,j]; push!(adj[i],N+j); end
        end
    end

    ssc = kosarajuAdj(N+P,adj)
    numssc = maximum(ssc)
    sscs::Vector{Vector{Int64}} = [Vector{Int64}() for i in 1:numssc]
    for i in 1:(N+P)
        if ssc[i] > 0; push!(sscs[ssc[i]],i); end
    end
    for i in 1:numssc
        if 1 in sscs[i]; continue; end ## Can't pick an SSC with 1
        if length([x for x in sscs[i] if x <= N]) == 0; continue; end  ## Need a non-empty SSC
        if !isleafssc(N+P,sscs[i],adj); continue; end
        if isSelfSufficient(N,P,sscs[i],AA,DD); return false; end
    end
    return true
end

function kosarajuAdj(n::Int64,adj::Vector{Vector{Int64}})
    visited::Vector{Bool} = fill(false,n)
    visitedInv::Vector{Bool} = fill(false,n)
    s::Vector{Int64} = []
    adjInv::Vector{Vector{Int64}} = [Vector{Int64}() for i in 1:n]
    ssc::Vector{Int64} = fill(0,n)
    counter::Int64 = 1
    for i in 1:n
        for j in adj[i]
            push!(adjInv[j],i)
        end
    end

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
        ssc[u] = counter
    end

    for i in 1:n
        if !visited[i]; dfsFirst(i); end
    end
    while !isempty(s)
        nn = pop!(s)
        if !visitedInv[nn]; dfsSecond(nn); counter += 1; end 
    end
    return ssc
end

function isleafssc(n::Int64,ssc::Vector{Int64},adj::Vector{Vector{Int64}})
    legal::Vector{Bool} = fill(false,n)
    for nn in ssc; legal[nn] = true; end
    for nn in ssc
        for pp in adj[nn]
            if !legal[pp]
                return false
            end
        end
    end
    return true
end

function isSelfSufficient(N::Int64,P::Int64,ssc::Vector{Int64},AA::Array{Bool,2},DD::Array{Bool,2})
    fullDefense::Vector{Bool} = fill(true,P)
    for i in ssc
        if i > N; continue; end
        for j in 1:P
            if !DD[i,j]; fullDefense[j] = false; end
        end
    end
    for i in ssc
        if i > N; continue; end
        foundAttack = false
        for j in 1:P
            if !fullDefense[j]; continue; end
            if AA[i,j]; foundAttack = true; break; end
        end
        if !foundAttack; return false; end
    end
    return true
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N,P = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        AA::Array{Bool,2} = fill(false,N,P)
        DD::Array{Bool,2} = fill(false,N,P)
        lenA::Vector{Int64} = fill(0,N)
        lenD::Vector{Int64} = fill(0,N)
        for i in 1:N
            lenA[i],lenD[i] = [parse(Int64,x) for x in split(readline(infile))]
            A = [parse(Int64,x) for x in split(readline(infile))]
            D = [parse(Int64,x) for x in split(readline(infile))]
            for x in A; AA[i,x] = true; end
            for x in D; DD[i,x] = true; end
        end

        if !solveProbA(N,P,AA,DD,lenA)
            print("NO\n")
        elseif !solveProbB(N,P,AA,DD)
            print("NO\n")
        else
            print("YES\n")
        end
    end
end

main()

