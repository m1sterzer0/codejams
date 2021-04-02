using Printf

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

function doSearch1(gr::Array{Char,2},gra::Array{Int64,2},q::Vector{Tuple{Int64,Int64,Int64}},si::Int64,sj::Int64,subsetT::Int64,R::Int64,C::Int64,M::Int64)
    reachable::Int64 = 0
    #q = Vector{Tuple{Int64,Int64,Int64}}()
    #sizehint!(q,4*R*C)
    rp::Int64,wp::Int64 = 1,1
    visited = fill(false,R,C)
    q[wp] = (si,sj,M); wp += 1
    while rp < wp
        (i::Int64,j::Int64,m::Int64) = q[rp]; rp+=1
        if visited[i,j]; continue; end
        visited[i,j] = true
        ## Am I being attacked
        if gra[i,j] & ~subsetT != 0
            attackers::Int64 = gra[i,j] & ~subsetT
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

function doSearch2(subsetS,subsetT,dp,dps,dpt,S,T,availMap)
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
        gra = fill(0,R,C)
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
        availMap = fill(0,S,1<<T)  ## Going to be a bit awkward with the 1 indexing -- oh well
        q = fill((0,0,0),4*R*C)
        for (i,(si,sj)) in enumerate(soldiers)
            for subsetT in 0:1<<T-1
                availMap[i,subsetT+1] = doSearch1(gr,gra,q,si,sj,subsetT,R,C,M)
            end
        end

        dp  = fill(-1,1<<S,1<<T)
        dps = fill(-1,1<<S,1<<T)
        dpt = fill(-1,1<<S,1<<T)
        dp[1,1] = 0
        doSearch2(1<<S-1,1<<T-1,dp,dps,dpt,S,T,availMap)
        subs,subt = 1<<S-1,1<<T-1 
        ans = dp[subs+1,subt+1]
        print("$ans\n")
        for i in 1:ans
            s = dps[subs+1,subt+1]
            t = dpt[subs+1,subt+1]
            print("$s $t\n")
            subs = subs & ~(1<<(s-1))
            subt = subt & ~(1<<(t-1))
        end
    end
end

main()

