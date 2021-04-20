
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
###  D4             YES                   NO             All defenses for my attacks  
###
###  * Clearly we will dual anyone in D1 when they become available.
###  * We can then use D4 to learn defenses for all of my attacks (assuming D4 is non-empty)
###  * Next, we can generally make "forward progress" by alternating between D3 & D4
###    -- We learn an attack from D3
###    -- We learn the corresponding defense from D4.
###    Within each of these steps (or partial steps), at least one of the following happens
###    -- We learn a new attack and defense
###    -- People in D3 can move to D1
###    -- People in D4 can move to D1
###    -- People in D2 can move to D3/D4 and possibly onto D1
###  * What problems can we encounter?  When do we get "stuck"? 
###    - PROBLEM A) All remaining people have an attack we cannot counter, and all
###      choose not to defend. (D2/D3 case)
###    - PROBLEM B) All remaining people have BOTH
###      a) defenses for all of our attacks
###      b) knowledge of an attack we already know. (D2/D4 case)
###  * PROBLEM A doesn't change with what attacks we know, so to solve problem A, we can assume
###      we start with an unblockable attack and see if that leads to full domination.
###  * Solving PROBLEM B is different between the small and large cases
###
###  SMALL CASE
###  ----------
###  * Because the condition (2b) is automatically met in the small case, Problem B turns into
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

function solveProbA(N::I,P::I,AA::Array{Bool,2},DD::Array{Bool,2},lenA::VI)
    dsb::VB = fill(false,P)
    psb::VI = fill(0,N)
    psb[1] = lenA[1]
    q::VI = []
    for j::I in 1:P
        if DD[1,j]; push!(q,j); end
    end
    while !isempty(q)
        s::I = popfirst!(q)
        if dsb[s]; continue; end
        dsb[s] = true
        for i::I in 2:N
            if AA[i,s]
                psb[i] += 1
                if psb[i] == lenA[i]
                    for j in 1:P; if DD[i,j]; push!(q,j); end; end
                end
            end
        end
    end
    for i in 1:N; if psb[i] < lenA[i]; return false; end; end
    return true
end

function solveProbBSmall(N::I,P::I,AA::Array{Bool,2},DD::Array{Bool,2})
    asb::VB = fill(false,P)
    psb::VB = fill(false,N)
    psb[1] = true
    q::VI = []
    for j::I in 1:P; if AA[1,j]; push!(q,j); end; end
    while !isempty(q)
        s = popfirst!(q)
        if asb[s]; continue; end
        asb[s] = true
        for i in 2:N
            if !DD[i,s] && !psb[i]
                psb[i] = true
                for j in 1:P; if AA[i,j]; push!(q,j); end; end
            end
        end
    end
    for i in 1:N; if !psb[i]; return false; end; end
    return true
end

function kosarajuAdj(n::I,adj::VVI)
    visited::VB = fill(false,n)
    visitedInv::VB = fill(false,n)
    s::VI = []
    adjInv::VVI = [VI() for i in 1:n]
    ssc::VI = fill(0,n)
    counter::I = 1
    for i::I in 1:n
        for j::I in adj[i]
            push!(adjInv[j],i)
        end
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

    for i in 1:n
        if !visited[i]; dfsFirst(i); end
    end
    while !isempty(s)
        nn = pop!(s)
        if !visitedInv[nn]; dfsSecond(nn); counter += 1; end 
    end
    return ssc
end

function isleafssc(n::I,ssc::VI,adj::VVI)
    legal::VB = fill(false,n)
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

function isSelfSufficient(N::I,P::I,ssc::VI,AA::Array{Bool,2},DD::Array{Bool,2})
    fullDefense::VB = fill(true,P)
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

function solveProbBLarge(N::I,P::I,AA::Array{Bool,2},DD::Array{Bool,2})
    adj::VVI = [VI() for i in 1:(N+P)]
    for j::I in 1:P
        if sum(AA[i,j] ? 1 : 0 for i in 1:N) == 0; continue; end
        for i in 1:N
            if AA[i,j]; push!(adj[N+j],i); end
            if !DD[i,j]; push!(adj[i],N+j); end
        end
    end

    ssc = kosarajuAdj(N+P,adj)
    numssc::I = maximum(ssc)
    sscs::VVI = [VI() for i in 1:numssc]
    for i::I in 1:(N+P)
        if ssc[i] > 0; push!(sscs[ssc[i]],i); end
    end
    for i::I in 1:numssc
        if 1 in sscs[i]; continue; end ## Can't pick an SSC with 1
        if length([x for x in sscs[i] if x <= N]) == 0; continue; end  ## Need a non-empty SSC
        if !isleafssc(N+P,sscs[i],adj); continue; end
        if isSelfSufficient(N,P,sscs[i],AA,DD); return false; end
    end
    return true
end

function solveSmall(N::I,P::I,attacks::VVI,defenses::VVI)::String
    AA::Array{Bool,2} = fill(false,N,P)
    DD::Array{Bool,2} = fill(false,N,P)
    lenA::VI = [length(attacks[i]) for i in 1:N]
    lenD::VI = [length(defenses[i]) for i in 1:N]
    for i in 1:N; for a in attacks[i]; AA[i,a] = true; end; end
    for i in 1:N; for d in defenses[i]; DD[i,d] = true; end; end
    return solveProbA(N,P,AA,DD,lenA) && solveProbBSmall(N,P,AA,DD) ? "YES" : "NO"
end

function solveLarge(N::I,P::I,attacks::VVI,defenses::VVI)::String
    AA::Array{Bool,2} = fill(false,N,P)
    DD::Array{Bool,2} = fill(false,N,P)
    lenA::VI = [length(attacks[i]) for i in 1:N]
    lenD::VI = [length(defenses[i]) for i in 1:N]
    for i in 1:N; for a in attacks[i]; AA[i,a] = true; end; end
    for i in 1:N; for d in defenses[i]; DD[i,d] = true; end; end
    return solveProbA(N,P,AA,DD,lenA) && solveProbBLarge(N,P,AA,DD) ? "YES" : "NO"
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,P = gis()
        attacks::VVI = []
        defenses::VVI = []
        for i in 1:N
            xx = gis() ## Throw always
            push!(attacks,gis())
            push!(defenses,gis())
        end
        #ans = solveSmall(N,P,attacks,defenses)
        ans = solveLarge(N,P,attacks,defenses)
        print("$ans\n")
    end
end

function gencase(Nmin::I,Nmax::I,Pmin::I,Pmax::I,Aprobmax::F,Dprobmax::F,smallFlag::Bool)
    N = rand(Nmin:Nmax)
    P = rand(Pmin:Pmax)
    attacks::VVI = [VI() for i in 1:N]
    defenses::VVI = [VI() for i in 1:N]
    Aprob = [Aprobmax*rand() for i in 1:P]
    Dprob = [Dprobmax*rand() for i in 1:P]
    ## DO 1 separatel
    if smallFlag
        for i in 1:N
            push!(attacks[i],1); push!(defenses[i],1);
            for p in 2:P
                if rand() < Aprob[p]; push!(attacks[i],p); end
                if rand() < Dprob[p]; push!(defenses[i],p); end
            end
        end
    else
        for i in 1:N
            while isempty(attacks[i])
                for p in 1:P
                    if rand() < Aprob[p]; push!(attacks[i],p); end
                end
            end
            while isempty(defenses[i])
                for p in 1:P
                    if rand() < Dprob[p]; push!(defenses[i],p); end
                end
            end
        end
    end
    return (N,P,attacks,defenses)
end

function test(ntc::I,Nmin::I,Nmax::I,Pmin::I,Pmax::I,Aprobmax::F,Dprobmax::F,smallFlag::Bool,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (N,P,attacks,defenses) = gencase(Nmin,Nmax,Pmin,Pmax,Aprobmax,Dprobmax,smallFlag)
        ans2 = solveLarge(N,P,attacks,defenses)
        if check
            ans1 = solveSmall(N,P,attacks,defenses)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(N,P,attacks,defenses)
                ans2 = solveLarge(N,P,attacks,defenses)
            end
       else
           print("Case $ttt: $ans2\n")
       end
    end
    if check; print("$pass/$ntc passed\n"); end
end

Random.seed!(8675309)
main()
#for ntc in (1,10,100,1000)
#    test(ntc,1,1000,1,1000,0.4,0.4,true)
#    test(ntc,1,1000,1,1000,0.6,0.6,true)
#    test(ntc,1,1000,1,1000,0.8,0.8,true)
#end
#test(200,1,1000,1,1000,0.6,0.6,false,false)


#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

