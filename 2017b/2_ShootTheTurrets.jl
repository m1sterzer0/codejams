
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
### BEGIN MAXIMUM BIPARTITE MATCHING CODE
### Inspired by https://www.geeksforgeeks.org/maximum-bipartite-matching/
######################################################################################################

function bpm(bpGraph::Array{Int8,2}, u::I, seen::VB, matchR::VI, m::I, n::I)::Bool
    for v::I in 1:n
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

function maxBPM(bpGraph::Array{Int8,2},m::I,n::I)::Tuple{I,SPI}
    matchR::VI = fill(-1,n)
    seen::VB = fill(false,n)
    result::I = 0
    for u::I in 1:m
        fill!(seen,false)
        if bpm(bpGraph,u,seen,matchR,m,n); result += 1; end
    end
    matches::SPI = SPI((matchR[x],x) for x in 1:n if matchR[x] > 0)
    return result,matches
end

######################################################################################################
### END MAXIMUM BIPARTITE MATCHING CODE
### Inspired by https://www.geeksforgeeks.org/maximum-bipartite-matching/
######################################################################################################

######################################################################################################
### Even the small is daunting.  For a naive approach, we have up to 10! ways of mapping the turrets
### to the soldiers, and we have another 10! ways of ordering the soldiers.  What can we do??
###
### We *can* precalculate the per soldier mapping of {Turrets killed} --> {Turrets available}.  This
### will take (10 soldier) * (1024 subset) * (1000 cell traverse) which is probably fine.
###
### Then we work on the DP.  Here, we calculate a mapping from (Soldiers Remaining x Turrets remaining) -->
### (# turrets, soldier, turret).  We can do this with an implicit DP (i.e. a DFS w/ memorization) DP where we
### try each remaining soldier,turret pairing, see if it is possible, and then use the precomputed result.
######################################################################################################

function doSearch1(gr::Array{Char,2},gra::Array{I,2},q::Vector{TI},
                   si::I,sj::I,subsetT::I,R::I,C::I,M::I)::I
    reachable::I = 0
    rp::I,wp::I = 1,1
    visited::Array{Bool,2} = fill(false,R,C)
    q[wp] = (si,sj,M); wp += 1
    while rp < wp
        (i::I,j::I,m::I) = q[rp]; rp+=1
        if visited[i,j]; continue; end
        visited[i,j] = true
        ## Am I being attacked
        if gra[i,j] & ~subsetT != 0
            attackers::I = gra[i,j] & ~subsetT
            reachable |= attackers
        ## Can I move more?
        elseif m > 0
            if i > 1 && gr[i-1,j] != '#'; q[wp] = (i-1,j,m-1); wp += 1 end
            if j > 1 && gr[i,j-1] != '#'; q[wp] = (i,j-1,m-1); wp += 1 end
            if i < R && gr[i+1,j] != '#'; q[wp] = (i+1,j,m-1); wp += 1 end
            if j < C && gr[i,j+1] != '#'; q[wp] = (i,j+1,m-1); wp += 1 end
        end
    end
    return reachable
end

function doSearch2(subsetS::I,subsetT::I,dp::Array{I,2},dps::Array{I,2},
                   dpt::Array{I,2},S::I,T::I,availMap::Array{I,2})
    dp[subsetS+1,subsetT+1] = 0
    destroyedTurrets = (1<<T-1) ⊻ subsetT
    tavail = [i for i in 1:T if (1 << (i-1)) & subsetT != 0]
    savail = [i for i in 1:S if (1 << (i-1)) & subsetS != 0]
    for t in tavail
        ttag = 1 << (t-1)
        newSubT = subsetT & ~ttag
        for s in savail
            if ttag & availMap[s,destroyedTurrets+1] == 0; continue; end
            stag = 1 << (s-1)
            newSubS = subsetS & ~stag 
            if dp[newSubS+1,newSubT+1]  < 0; doSearch2(newSubS,newSubT,dp,dps,dpt,S,T,availMap); end
            if 1 + dp[newSubS+1,newSubT+1] <= dp[subsetS+1,subsetT+1]; continue; end
            dp[subsetS+1,subsetT+1]  = 1 + dp[newSubS+1,newSubT+1]
            dps[subsetS+1,subsetT+1] = s
            dpt[subsetS+1,subsetT+1] = t
        end
    end
end


function solveSmall(C::I,R::I,M::I,gr::Array{Char,2})::VS
    soldiers::VPI = [(i,j) for i in 1:R for j in 1:C if gr[i,j] == 'S']
    turrets::VPI  = [(i,j) for i in 1:R for j in 1:C if gr[i,j] == 'T']
    S::I = length(soldiers); T::I = length(turrets)

    ## Create a new grid where each square lists the turrets that are attacking it.
    gra::Array{I,2} = fill(0,R,C)
    for (ii,(ti,tj)) in enumerate(turrets)
        tie,tiw = tj,tj
        tin,tis = ti,ti
        while tie < C && gr[ti,tie+1] != '#'; tie += 1; end
        while tiw > 1 && gr[ti,tiw-1] != '#'; tiw -= 1; end
        while tin > 1 && gr[tin-1,tj] != '#'; tin -= 1; end
        while tis < R && gr[tis+1,tj] != '#'; tis += 1; end
        ttag = 1 << (ii-1)
        for i in tin:tis; gra[i,tj] |= ttag; end
        for j in tiw:tie; gra[ti,j] |= ttag; end
    end

    ## Do the mapping from soidier x subset of turrets --> available turrets.
    ## Here, I was getting performance bottlenecked by the push! and popfirst! calls, so since we
    ## know each square wont be pushed on the queue more than 4 times, we can use a read pointer/write pointer
    ## approach and use the same array for everyone (saving on the allocation).
    availMap::Array{I,2} = fill(0,S,1<<T)  ## Going to be a bit awkward with the 1 indexing -- oh well
    q::Vector{TI} = fill((0,0,0),4*R*C)
    for (i,(si,sj)) in enumerate(soldiers)
        for subsetT::I in 0:1<<T-1
            availMap[i,subsetT+1] = doSearch1(gr,gra,q,si,sj,subsetT,R,C,M)
        end
    end

    dp::Array{I,2}  = fill(-1,1<<S,1<<T)
    dps::Array{I,2} = fill(-1,1<<S,1<<T)
    dpt::Array{I,2} = fill(-1,1<<S,1<<T)
    dp[1,1] = 0
    doSearch2(1<<S-1,1<<T-1,dp,dps,dpt,S,T,availMap)
    subs,subt = 1<<S-1,1<<T-1
    
    ans::VS = []    
    retval::I = dp[subs+1,subt+1]
    push!(ans,"$retval")
    for i in 1:retval
        s = dps[subs+1,subt+1]
        t = dpt[subs+1,subt+1]
        push!(ans,"$s $t")
        subs = subs & ~(1<<(s-1))
        subt = subt & ~(1<<(t-1))
    end
    return ans
end

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

function doSearch1Large(gr::Array{Char,2},gra::Array{BitSet,2},soldiers::VPI,
                        R::I,C::I,S::I,T::I,M::I)::Tuple{Array{PI,2},Array{PI,3}}
    scoreboard::Array{PI,2}  = fill((-1,-1),S,T)
    pathParents::Array{PI,3} = fill((-1,-1),S,R,C)
    for (sidx::I,(si::I,sj::I)) in enumerate(soldiers)
        currentTurrets::BitSet = BitSet()
        visited::Array{Bool,2} = fill(false,R,C)
        q::Vector{NTuple{5,I}} = []
        push!(q,(si,sj,-1,-1,M))
        while !isempty(q)
            (i::I,j::I,pi::I,pj::I,m::I) = popfirst!(q)
            if visited[i,j]; continue; end
            visited[i,j] = true
            pathParents[sidx,i,j] = (pi,pj)
            newTurrets::BitSet = setdiff(gra[i,j],currentTurrets)
            for tidx::I in newTurrets; scoreboard[sidx,tidx] = (i,j); end
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

function getMaximalMatch(sb::Array{PI,2},S::I,T::I)::SPI
    bpGraph::Array{Int8,2} = [sb[s,t] == (-1,-1) ? Int8(0) : Int8(1) for s in 1:S,t in 1:T]
    numMatches,matches = maxBPM(bpGraph,S,T)
    return matches
end

function makeDeps(matches::SPI,sb::Array{PI,2},pathParents::Array{PI,3},
                  gra::Array{BitSet,2},S::I,T::I)
    deps::VVI = [VI() for x in 1:S]
    for (s::I,t::I) in matches
        (i::I,j::I) = sb[s,t]
        path::VPI = []
        while (i,j) != (-1,-1)
            push!(path,(i,j))
            (i,j) = pathParents[s,i,j]
        end
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

function orderMatches(matches::SPI,deps::VVI,S::I,T::I)::VPI
    stot::VI = fill(-1,S)
    ttos::VI = fill(-1,T)
    for (s,t) in matches; stot[s]=t; ttos[t]=s; end
    serviced::VB = fill(false,S)
    matchesLeft::I = length(matches)
    walkIdx::VI = fill(1,S)
    newMatches::VPI = []
    currentTurrets = BitSet()

    function checks(s::I,t::I)::PI
        tidx::I = deps[s][walkIdx[s]]
        while tidx in currentTurrets
            walkIdx[s] += 1
            tidx = deps[s][walkIdx[s]]
        end
        return tidx, ttos[tidx]
    end

    function process(s::I,t::I)
        ttos[stot[s]] = -1
        stot[s] = -1
        push!(newMatches,(s,t))
        serviced[s] = true
        push!(currentTurrets,t)
        matchesLeft -= 1
    end

    sb::VB = fill(false,S)
    while (matchesLeft > 0)
        ## Clear off a scoreboard
        fill!(sb,false)

        ## Find a node to start the search from
        hs,ht = -1,-1
        for (s,t) in matches
            if serviced[s]; continue; end
            hs,ht = s,t
            break
        end
        stack::VPI = []
        done::Bool = false
        while !done
            val::I,nhs::I = checks(hs,ht)
            if nhs == -1 
                process(hs,val)
                for (s,t) in stack; process(s,t); end
                done = true
            elseif nhs == hs
                process(hs,val)
                done = true
            elseif sb[nhs]  ## Here we have a cycle
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

function solveLarge(C::I,R::I,M::I,gr::Array{Char,2})::VS
    soldiers::VPI = [(i,j) for i in 1:R for j in 1:C if gr[i,j] == 'S']
    turrets::VPI  = [(i,j) for i in 1:R for j in 1:C if gr[i,j] == 'T']
    S::I = length(soldiers); T::I = length(turrets)

    ## Create a new grid where each square lists the turrets that are attacking it.
    gra::Array{BitSet,2} = [BitSet() for r in 1:R, c in 1:C]
    for (ii::I,(ti::I,tj::I)) in enumerate(turrets)
        tie::I,tiw::I = tj,tj
        tin::I,tis::I = ti,ti
        while tie < C && gr[ti,tie+1] != '#'; tie += 1; end
        while tiw > 1 && gr[ti,tiw-1] != '#'; tiw -= 1; end
        while tin > 1 && gr[tin-1,tj] != '#'; tin -= 1; end
        while tis < R && gr[tis+1,tj] != '#'; tis += 1; end
        for i in tin:tis; push!(gra[i,tj],ii); end
        for j in tiw:tie; push!(gra[ti,j],ii); end
    end

    ## Now for each soldier, we create an array which is > 0 if
    ## we can hit that turret index, and the value that is stored
    ## there is previous cell we were in (so we can resconstruct
    ## a path to that cell)
    scoreboard::Array{PI,2},pathParents::Array{PI,3} = doSearch1Large(gr,gra,soldiers,R,C,S,T,M)
    matches::SPI = getMaximalMatch(scoreboard,S,T)
    deps::VVI = makeDeps(matches,scoreboard,pathParents,gra,S,T)
    newMatches = orderMatches(matches,deps,S,T)
    retval = length(newMatches)
    ans::VS = ["$retval"]
    for (s,t) in newMatches; push!(ans,"$s $t"); end
    return ans
end

function gencase(Rmin::I,Rmax::I,Cmin::I,Cmax::I,Mmin::I,Mmax::I,Smin::I,Smax::I,Tmin::I,Tmax::I)
    S = rand(Smin:Smax)
    T = rand(Tmin:Tmax)
    R = rand(Rmin:Rmax)
    C = rand(Cmin:Cmax)
    M = rand(Mmin:Mmax)
    wallprob = 0.6*rand()
    while R*C < S+T; if R <= C; R += 1; else; C += 1; end; end
    gr::Array{Char,2} = fill('.',R,C)
    squares::VPI = [(i,j) for i in 1:R for j in 1:C]
    shuffle!(squares)
    for i in 1:S; (i,j) = popfirst!(squares); gr[i,j] = 'S'; end
    for i in 1:T; (i,j) = popfirst!(squares); gr[i,j] = 'T'; end
    numwalls = Int64(floor(length(squares)*wallprob))
    for i in 1:numwalls; (i,j) = popfirst!(squares); gr[i,j] = '#'; end
    return (C,R,M,gr)
end

function test(ntc::I,Rmin::I,Rmax::I,Cmin::I,Cmax::I,Mmin::I,Mmax::I,Smin::I,Smax::I,Tmin::I,Tmax::I,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (C,R,M,gr) = gencase(Rmin::I,Rmax::I,Cmin::I,Cmax::I,Mmin::I,Mmax::I,Smin::I,Smax::I,Tmin::I,Tmax::I)
        ans2 = solveLarge(C,R,M,gr)
        if check
            ans1 = solveSmall(C,R,M,gr)
            if ans1[1] == ans2[1]
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(C,R,M,gr)
                ans2 = solveLarge(C,R,M,gr)
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
        C,R,M = gis()
        gr::Array{Char,2} = fill('.',R,C)
        for i in 1:R; gr[i,:] = [x for x in gs()]; end
        #ans = solveSmall(C,R,M,gr)
        ans = solveLarge(C,R,M,gr)
        for l in ans; print("$l\n"); end
    end
end

Random.seed!(8675309)
main()
#for ntc in (1,10,100,1000)
#    test(ntc,1,30,1,30,1,60,1,10,1,10)
#end
#test(200,1,100,1,100,1,60,1,100,1,100,false)

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

