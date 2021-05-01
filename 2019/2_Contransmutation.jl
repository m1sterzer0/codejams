
using Random
infile = stdin
## Type Shortcuts (to save my wrists and fingers :))
const I = Int64; const VI = Vector{I}; const SI = Set{I}; const PI = NTuple{2,I};
const TI = NTuple{3,I}; const QI = NTuple{4,I}; const VPI = Vector{PI}; const SPI = Set{PI}
const VC = Vector{Char}; const VS = Vector{String}; VB = Vector{Bool}; VVI = Vector{Vector{Int64}}
const F = Float64; const VF = Vector{F}; const PF = NTuple{2,F}

gs()::String = rstrip(readline(infile))
gi()::Int64 = parse(Int64, gs())
gf()::Float64 = parse(Float64,gs())
gss()::Vector{String} = split(gs())
gis()::Vector{Int64} = [parse(Int64,x) for x in gss()]
gfs()::Vector{Float64} = [parse(Float64,x) for x in gss()]

######################################################################################################
### I had to look up the answers for this one.
###
### We split this problem into two parts
### A) Checking to see whether the amount of lead is bounded
### B) Counting the amount of lead that can be made
###
### 1) First, we create the transformation graph, and prune nodes/edges that will never be used because 
###    we can't hit them.
### 2) Then we create the reverse of this graph, and trace from node 1 to see which elements can produce
###    lead.
### 3) Assume node n replicates both lead and itself.  Also assume node n splits into c1 and c2.  We
###    have 3 cases:
###       * Case 1: c1 generates lead, and c2 generates n
###       * Case 2: c2 generates lead, and c1 generates n
###       * Case 3: Either c1 or c2 generates BOTH lead and n
###    If we are in the last case, note that cx then generates n and itself, so it is also self
###    replicating.  If we keep running the argument on "Case 3" nodes, we will eventually running
###    out, so some self replicating node in the loop will be of the case1 or case 2 variety.
###    We call these self replicating nodes "ROOT self replicating nodes".
### 4) We can find the root self replicating nodes in linear time by using Kosaraju to identify
###    the SSC for each node and (2) above to see if the other node generates lead.
### 5) We can then "flood fill" these ROOT self replicating nodes back along the reverse graph identifying
###    all such nodes that lead to replication.  If any of them start non-empty, we are UNBOUNDED.
### 6) Now that we are not unbounded, we prune back the reverse graph again removing self replicating
###    nodes.  Ignoring node 1, this should now create a DAG, which we can process from group 1 and
###    figure out how much Lead we can make from each material .  We combine this with starting material
###    to calculate the final answer.  (Similarly and equivalently, we could do a simulation at this stage,
###    using the DAG to appropriately order the nodes)  
######################################################################################################

function kosarajuAdj(n::I,adj::VVI)::VI
    visited::VB = fill(false,n)
    visitedInv::VB = fill(false,n)
    s::VI = []
    adjInv::VVI = [VI() for i in 1:n]
    ssc::VI = fill(0,n)
    counter::I = 1
    for i::I in 1:n
        for j::I in adj[i]; push!(adjInv[j],i); end
    end

    function dfsFirst(u::I)
        if visited[u]; return; end
        visited[u] = true
        for x in adj[u]; dfsFirst(x); end
        push!(s,u)
    end

    function dfsSecond(u::I)
        if visitedInv[u]; return; end
        visitedInv[u] = true
        for x in adjInv[u]; dfsSecond(x); end
        ssc[u] = counter
    end

    for i::I in 1:n; if !visited[i]; dfsFirst(i); end; end
    while !isempty(s)
        nn::I = pop!(s)
        if !visitedInv[nn]; dfsSecond(nn); counter += 1; end 
    end
    return ssc
end

function solveLarge(M::I,R1::VI,R2::VI,G::VI)::String
    ## Build the graph
    adj::VVI = [VI() for i in 1:M]
    for i in 1:M; push!(adj[i],R1[i]); push!(adj[i],R2[i]); end

    ## Quick BFS To find what is reachable from the starters
    visited::VB = [G[i] > 0 for i in 1:M]
    q::VI = [i for i in 1:M if G[i] > 0]
    while !isempty(q)
        for c in adj[popfirst!(q)]
            if visited[c]; continue; end
            visited[c] = true; push!(q,c)
        end
    end

    ## Prune the nodes that are unreachable
    adj2::VVI = [VI() for i in 1:M]
    for i in 1:M; for j in adj[i]; if visited[i] && visited[j]; push!(adj2[i],j); end; end; end

    ## Reverse the graph, and remove self loops
    adjinv::VVI = [VI() for i in 1:M]
    for i in 1:M; for j in adj2[i]; if i != j; push!(adjinv[j],i); end; end; end

    ## Search again from lead, and prune the unreachable nodes
    visited2::VB = fill(false,M); visited2[1] = true; push!(q,1)
    while !isempty(q)
        for c in adjinv[popfirst!(q)]
            if visited2[c]; continue; end
            visited2[c] = true; push!(q,c)
        end
    end

    ## Prune the nodes unreachable from lead
    adjinv2::VVI = [VI() for i in 1:M]
    for i in 1:M; for j in adjinv[i]; if visited2[i] && visited2[j]; push!(adjinv2[i],j); end; end; end

    ## SSC on the pruned forward graph
    sscarr::VI = kosarajuAdj(M,adj2)

    ## Find the root self replicating nodes
    rootSelfReplicating::VB = fill(false,M)
    for i in 1:M
        if sscarr[i] == sscarr[R1[i]] && visited2[R2[i]] || sscarr[i] == sscarr[R2[i]] && visited2[R1[i]]
            rootSelfReplicating[i] = true
        end
    end

    ## Do a quick BFS to find all of the self replicating nodes
    visited3::VB = copy(rootSelfReplicating)
    q = [i for i in 1:M if rootSelfReplicating[i] ]
    while !isempty(q)
        for c in adjinv2[popfirst!(q)]
            if visited3[c]; continue; end
            visited3[c] = true; push!(q,c)
        end
    end
    selfReplicating::VB = visited3
    for i in 1:M; if selfReplicating[i] && G[i] > 0; return "UNBOUNDED"; end; end

    ## Prune back to non self replicating nodes in the inverse graph
    adjinv3::VVI = [VI() for i in 1:M]
    for i in 1:M; for j in adjinv2[i]
        if !selfReplicating[i] && !selfReplicating[j]; push!(adjinv3[i],j); end
    end; end

    ## If we've done everything correctly, ignoring node 1, we should have a directed acyclic graph.
    ## We can order this by keeping track of a dependency count 
    ## Create the amount of lead produced from each source node, and then do a dot product
    nodevals::VI = fill(0,M); nodevals[1] = 1
    deps::Vector{Int64} = fill(0,M)
    for i in 1:M; for j in adjinv3[i]; deps[j] += 1; end; end
    deps[1] = 0; nodevals[1] = 1
    push!(q,1)
    while !isempty(q)
        n = popfirst!(q)
        for j in adjinv3[n]
            if j == 1; continue; end ## Don't loop back through lead
            nodevals[j] = (nodevals[j] + nodevals[n]) % 1_000_000_007
            deps[j] -= 1
            if deps[j] == 0; push!(q,j); end
        end
    end

    ## Do the dot product and wrap things up
    ans::I = 0
    for i::I in 1:M
        adder::I = (nodevals[i] * G[i]) % 1_000_000_007
        ans = (ans + adder) % 1_000_000_007
    end
    return "$ans"
end

function simulate(M,R1::VI,R2::VI,G::VI)::Tuple{I,I,I,Bool,Bool}
    ## We keep the number modulo 3 different primes
    p1 = 1_000_000_007
    p2 = 1_000_000_009
    p3 = 1_000_000_023
    inv1::VI = [g%p1 for g in G]
    inv2::VI = [g%p2 for g in G]
    inv3::VI = [g%p3 for g in G]
    emp::VB  = [g == 0 for g in G]

    ## M^2
    infflag = false
    lead::TI = (0,0,0)
    for iter in 1:2
        for i in 1:M
            for j in 2:M
                if emp[j]; continue; end
                u,v = R1[j],R2[j]
                emp[j] = true; emp[u] = false; emp[v] = false
                x1,x2,x3 = inv1[j],inv2[j],inv3[j]
                inv1[j],inv2[j],inv3[j] = 0,0,0
                for xxx in (u,v)
                    inv1[xxx] = (inv1[xxx]+x1) % p1
                    inv2[xxx] = (inv2[xxx]+x2) % p2
                    inv3[xxx] = (inv3[xxx]+x3) % p3
                end
            end
        end
        if iter == 1; lead = (inv1[1],inv2[1],inv3[1]); end
        if iter == 2; if (inv1[1],inv2[1],inv3[1]) != lead; infflag = true; end; end
    end
    return (inv1[1],inv2[1],inv3[1],emp[1],infflag)
end

function solveSmall(M::I,R1::VI,R2::VI,G::VI)
    x1,x2,x3,em,inflag = simulate(M,R1,R2,G)
    G2 = fill(0,M)
    G2[R1[1]] += 1
    G2[R2[1]] += 1
    x4,x5,x6,em2,inflag2 = simulate(M,R1,R2,G2)
    if inflag; return "UNBOUNDED"; end
    if !em && !em2 && (x4 != 1 || x5 != 1 || x6 != 1); return "UNBOUNDED"; end
    return string(x1)
end

function gencase(Mmin::I,Mmax::I,Gzeroprob::F,Gmax::I)
    M = rand(Mmin:Mmax)
    R1::VI = rand(1:M,M)
    R2::VI = rand(2:M,M)
    G::VI = [ rand() < Gzeroprob ? 0 : rand(1:Gmax) for i in 1:M]
    return (M,R1,R2,G)
end

function test(ntc::I,Mmin::I,Mmax::I,Gzeroprob::F,Gmax::I,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (M,R1,R2,G) = gencase(Mmin,Mmax,Gzeroprob,Gmax)
        ans2 = solveLarge(M,R1,R2,G)
        if check
            ans1 = solveSmall(M,R1,R2,G)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(M,R1,R2,G)
                ans2 = solveLarge(M,R1,R2,G)
            end
       else
           print("Case $ttt: $ans2\n")
       end
    end
    if check; print("$pass/$ntc passed\n"); end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        M = gi()
        R1::VI = fill(0,M)
        R2::VI = fill(0,M)
        for i in 1:M; R1[i],R2[i] = gis(); end
        G::VI = gis()
        #ans = solveSmall(M,R1,R2,G)
        ans = solveLarge(M,R1,R2,G)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
#test(10000,2,3,0.3,10)
#test(10000,2,3,0.5,10)
#test(10000,2,3,0.7,10)
#test(10000,2,3,0.9,10)


#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

