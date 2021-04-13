
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

function negamax(mypos::I,otherpos::I,myscoresofar::I,
                 mystuck::Bool,otherstuck::Bool,
                 C::VI, edgesb::Array{Bool,2}, adj::VVI,
                 alpha::I,beta::I)
    inf::Int64 = 1000000007  ## Biggset score should be 500 * 10k = 5M.
    if mystuck && otherstuck; return myscoresofar; end
    if mystuck; return -negamax(otherpos,mypos,-myscoresofar,otherstuck,mystuck,
                                C, edgesb, adj, -beta, -alpha); end
    value::I,incgold::I,n2::I = -inf,C[mypos],0
    C[mypos] = 0;  myscoresofar += incgold; mystuck = true
    for n2::I in adj[mypos]
        if !edgesb[mypos,n2]; continue; end
        mystuck = false
        edgesb[mypos,n2] = edgesb[n2,mypos] = false
        value = max(value,-negamax(otherpos,n2,-myscoresofar,otherstuck,mystuck,
                                   C, edgesb, adj, -beta, -alpha))
        edgesb[mypos,n2] = edgesb[n2,mypos] = true
        alpha = max(alpha,value)
        if alpha >= beta; break; end
    end
    if mystuck; value = -negamax(otherpos,mypos,-myscoresofar,otherstuck,mystuck,
                                 C, edgesb, adj, -beta, -alpha);  end
    C[mypos] = incgold
    return value
end
     

function solveSmall(N::I,preC::VI,X::VI,Y::VI)::I
    C::VI = copy(preC)
    edgesb::Array{Bool,2} = fill(false,N,N)
    adj::VVI = [VI() for i in 1:N]
    for i in 1:N-1
        edgesb[X[i],Y[i]] = edgesb[Y[i],X[i]] = true
        push!(adj[X[i]],Y[i]); push!(adj[Y[i]],X[i])
    end

    inf::Int64 = 1000000007  ## Biggset score should be 500 * 10k = 5M.
    alpha = -inf
    for i in 1:N
        beta = inf
        for j in 1:N
            value = negamax(i,j,0,false,false,C,edgesb,adj,alpha,beta)
            beta = min(beta,value)
            if alpha > beta; break; end
        end
        alpha = max(alpha,beta)
    end
    return alpha
end

function preworkLarge()
    inf::Int64 = 1000000007  ## Biggset score should be 500 * 10k = 5M.
    C::VI                   = fill(0,500)
    maxGold::VI             = fill(-inf,1000)
    bestFour::Array{I,2}    = fill(-1,500,4)
    nextNode::Array{I,2}    = fill(0,500,500)
    sumCoins::Array{I,2}    = fill(-inf,500,500)
    bestTwoEdge::Array{I,2} = fill(-inf,1000,1000)
    doitCache::Array{I,2}   = fill(-inf,1000,1000)
    edgesb::Array{I,2}      = fill(0,500,500)
    adj::VVI                = []
    return (C,maxGold,bestFour,nextNode,sumCoins,bestTwoEdge,doitCache,edgesb,adj)
end

function solveLarge(N::I,preC::VI,X::VI,Y::VI,working)::I
    inf::Int64 = 1000000007  ## Biggset score should be 500 * 10k = 5M.
    (C::VI,maxGold::VI,bestFour::Array{I,2},nextNode::Array{I,2},sumCoins::Array{I,2},
     bestTwoEdge::Array{I,2},doitCache::Array{I,2},edgesb::Array{I,2},adj::VVI) = working

    function getMaxGold(mypos::Int64,myprev::Int64)::Int64
        eid = edgesb[mypos,myprev]
        if maxGold[eid] == -inf
            ans::Int64 = 0
            for n in adj[mypos]
                if n == myprev; continue; end
                ans = max(ans,getMaxGold(n,mypos))
            end
            ans += C[mypos]
            maxGold[eid] = ans
        end
        return maxGold[eid]
    end

    function getBestFour(mypos::Int64)::Tuple{Int64,Int64,Int64,Int64}
        n1::Int64,n2::Int64,n3::Int64,n4::Int64 = 0,0,0,0
        if bestFour[mypos,1] < 0
            g1::Int64,g2::Int64,g3::Int64,g4::Int64 = -inf,-inf,-inf,-inf
            for n in adj[mypos]
                t = getMaxGold(n,mypos)
                (g1,g2,g3,g4,n1,n2,n3,n4) = (t > g1 ? (t,g1,g2,g3,n,n1,n2,n3) :
                                             t > g2 ? (g1,t,g2,g3,n1,n,n2,n3) :
                                             t > g3 ? (g1,g2,t,g3,n1,n2,n,n3) : 
                                             t > g4 ? (g1,g2,g3,t,n1,n2,n3,n) : (g1,g2,g3,g4,n1,n2,n3,n4))
            end
            bestFour[mypos,:] = [n1,n2,n3,n4]
        end
        n1,n2,n3,n4 = bestFour[mypos,:]
        return (n1,n2,n3,n4)
    end

    function doTraverse(cur::Int64,par::Int64,targ::Int64)
        nextNode[cur,targ] = par
        for n in adj[cur]
            if n == par; continue; end
            doTraverse(n,cur,targ)
        end
    end

    function getNextNode(mypos::Int64,targ::Int64)::Int64
        if nextNode[mypos,targ] <= 0; doTraverse(targ,targ,targ); end
        return nextNode[mypos,targ]
    end

    function getSumCoins(mypos::Int64,targ::Int64)::Int64
        if sumCoins[mypos,targ] < 0
            if mypos==targ
                sumCoins[mypos,targ] = C[mypos]
            else
                nn = getNextNode(mypos,targ)
                sumCoins[mypos,targ] = C[mypos]+getSumCoins(nn,targ)
            end
        end
        return sumCoins[mypos,targ]
    end

    function getBestTwoEdge(mypos::Int64,myprev::Int64,blkpos::Int64,blkprev::Int64)::Int64
        eid1 = edgesb[mypos,myprev]
        eid2 = edgesb[blkpos,blkprev]
        if bestTwoEdge[eid1,eid2] == -inf
            ans::Int64 = C[mypos]
            (n1,n2,n3,n4) = getBestFour(mypos)
            if mypos==blkpos
                for n in [n1,n2,n3]
                    if n != 0 && n != myprev && n != blkprev
                        ans += getMaxGold(n,mypos)
                        break
                    end
                end
            else
                nn = getNextNode(mypos,blkpos)
                adder::Int64 = getBestTwoEdge(nn,mypos,blkpos,blkprev) 
                for n in [n1,n2,n3]
                    if n != 0 && n != myprev && n != nn
                        adder = max(adder,getMaxGold(n,mypos))
                    end
                end
                ans += adder
            end
            bestTwoEdge[eid1,eid2] = ans
        end
        return bestTwoEdge[eid1,eid2]
    end

    function conjunction(mypos::Int64,myprev::Int64,oppprev::Int64)::Int64
        (n1,n2,n3,n4) = getBestFour(mypos)
        mynode::Int64 = 0
        ans::Int64 = 0
        for n in [n1,n2,n3]
            if n > 0 && n != myprev && n != oppprev
                mynode = n
                ans += getMaxGold(n,mypos)
                break
            end
        end
        for n in [n1,n2,n3,n4]
            if n > 0 && n != myprev && n != oppprev && n != mynode
                ans -= getMaxGold(n,mypos)
                break
            end
        end
        return ans
    end

    function getBranch(mypos::Int64,myprev::Int64,branchpt::Int64,blk1::Int64,blk2::Int64)::Int64
        opt1::Int64,opt2::Int64,opt3::Int64 = 0,0,0
        nn::Int64 = getNextNode(mypos,branchpt)
        nl::Int64 = getNextNode(branchpt,mypos)

        ## Option 1, go all the way to the branch point and take the best available path away from it
        opt1 += getSumCoins(mypos,branchpt) - C[branchpt]
        (n1,n2,n3,n4) = getBestFour(branchpt)
        for n::Int64 in (n1,n2,n3,n4)
            if n > 0 && n!= blk1 && n != blk2 && n != nl
                opt1 += getMaxGold(n,branchpt)
                break
            end
        end

        ## Option 2, branch away from the path now
        opt2 += C[mypos]
        (n1,n2,n3,n4) = getBestFour(mypos)
        for n::Int64 in (n1,n2,n3)
            if n > 0 && n!= nn && n != myprev
                opt2 += getMaxGold(n,mypos)
                break
            end
        end
    
        ## Option 3, take one step toward the branch point, and solve the problem bounded by 2 edges
        if nn != branchpt
            opt3 = C[mypos] + getBestTwoEdge(nn,mypos,nl,branchpt)
        end
        return max(opt1,opt2,opt3)
    end


    function doit(mypos::Int64,myprev::Int64,opppos::Int64,oppprev::Int64)::Int64
        eid1::Int64,eid2::Int64 = 0,0
        if myprev > 0 && oppprev > 0
            eid1 = edgesb[mypos,myprev]
            eid2 = edgesb[opppos,oppprev]
            if doitCache[eid1,eid2] > -inf;
                return doitCache[eid1,eid2]
            end
        end

        ans::Int64 = 0
        if mypos == opppos
            ans =  C[mypos] + conjunction(mypos,myprev,oppprev)
        else
            nn = getNextNode(mypos,opppos)
            option1::Int64 = C[mypos] - doit(opppos,oppprev,nn,mypos)
            option2::Int64 = -inf
            (n1,n2,n3,n4) = getBestFour(mypos)
            for n in [n1,n2,n3]
                if n > 0 && n != myprev && n != nn
                    option2 = C[mypos] + getMaxGold(n,mypos) - getBranch(opppos,oppprev,mypos,myprev,n)
                    break
                end
            end
            ans = max(option1,option2)
        end
        if eid1 > 0; doitCache[eid1,eid2] = ans; end
        return ans
    end

    function resetStorage()
        fill!(C,0); fill!(maxGold,-inf); fill!(bestFour,-1); fill!(nextNode,0)
        fill!(sumCoins,-inf); fill!(bestTwoEdge,-inf); fill!(edgesb,0);
        fill!(doitCache,-inf); empty!(adj)
    end

    resetStorage()
    for i in 1:N; push!(adj,VI()); end
    for i in 1:N; C[i] = preC[i]; end
    for i in 1:N-1
        edgesb[X[i],Y[i]] = X[i]
        edgesb[Y[i],X[i]] = N+X[i]
        push!(adj[X[i]],Y[i])
        push!(adj[Y[i]],X[i])
    end
    alpha = -inf
    for i in 1:N
        beta = inf
        for j in 1:N
            value = doit(i,0,j,0)
            beta = min(beta,value)
            if alpha > beta; break; end
        end
        alpha = max(alpha,beta)
    end
    return alpha
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    workingLarge = preworkLarge()
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        C::VI = fill(0,N)
        for i in 1:N; C[i] = gi(); end
        X::VI = fill(0,N-1)
        Y::VI = fill(0,N-1)
        for i in 1:N-1; X[i] = i; Y[i] = gi(); end
        #ans = solveSmall(N,C,X,Y)
        ans = solveLarge(N,C,X,Y,workingLarge)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

