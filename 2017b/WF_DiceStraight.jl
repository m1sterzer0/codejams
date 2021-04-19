
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

function findNextStart(st::I,lastGap::I,dgr::VVI,maxdig::I)
    while(st <= maxdig)
        while st <= maxdig && length(dgr[st]) == 0; st += 1; end
        good::Bool = true
        for en in st:st+lastGap
            if en > maxdig || length(dgr[en]) == 0 
                st = en+1; good=false; break
            end
        end
        if good; return (st,st+lastGap); end
    end
    return (maxdig+1,maxdig+1)
end

function tryMatch(st::I,en::I,dgr::VVI)
    gr::SI = SI(j for i in st:en for j in dgr[i])
    bpGraph::Array{Int8,2} = fill(Int8(0),en-st+1,length(gr))
    lookup::Dict{I,I} = Dict{I,I}()
    for (i::I,x::I) in enumerate(gr); lookup[x] = i; end
    for i::I in st:en; for j::I in dgr[i]; bpGraph[i-st+1,lookup[j]] = Int8(1); end; end
    res::I,_matches::SPI = maxBPM(bpGraph,en-st+1,length(lookup))
    return res == (en-st+1)
end

function solveSmall(N::I,D::Array{I,2})
    maxdig::I = maximum(D)
    dgr::VVI = [VI() for i in 1:maxdig]
    for i in 1:N; for j in 1:6; push!(dgr[D[i,j]],i); end; end
    best::I = 1
    (i::I,j::I) = findNextStart(1,best,dgr,maxdig)
    while (i < maxdig && j <= maxdig)
        if tryMatch(i,j,dgr)
            best += 1
            if j < maxdig && length(dgr[j+1]) > 0; j += 1
            else; (i,j) = findNextStart(j+2,best,dgr,maxdig);
            end
        else
            if j < maxdig && length(dgr[j+1]) > 0; j += 1; i += 1
            else;  (i,j) = findNextStart(j+2,best,dgr,maxdig);
            end
        end
    end
    return best
end

function checkMatch(dgr::VVI, matchR::VI, seen::Vector{Int8}, minval::I, maxval::I, n::I)
    if n == maxval; fill!(seen,0); end
    for v in dgr[n]
        if seen[v] > 0; continue; end
        seen[v] = 1
        if matchR[v] == -1; matchR[v] = n; return true; end
        if checkMatch(dgr,matchR,seen,minval,maxval,matchR[v]); matchR[v] = n; return true; end
    end
    return false
end

function solveLarge(N::I,D::Array{I,2})
    maxdig::I = maximum(D)
    dgr::VVI = [VI() for i in 1:maxdig]
    for i in 1:N; for j in 1:6; push!(dgr[D[i,j]],i); end; end
    ## Figure out the best possible straight we can make at each starting digits
    last::I = 0
    bestPossible::VI = fill(0,maxdig)
    for i in maxdig:-1:1
        last = length(dgr[i]) == 0 ? 0 : last+1
        bestPossible[i] = last
    end
    seen::Vector{Int8} = fill(Int8(0),N)
    matchR::VI = fill(-1,N)
    start::I,best::I = 0,1
    while(true)
        start += 1
        while start <= maxdig && bestPossible[start] <= best; start += 1; end
        if start > maxdig; break; end
        fill!(matchR,-1)
        myend::I = start
        #println("DEBUG: Starting search from $start")
        while bestPossible[start] > best
            if checkMatch(dgr,matchR,seen,start,myend,myend)
                #println("DEBUG: Search $start..$myend successful, bumping up $myend to $(myend+1)")
                myend += 1
                best = max(best,myend-start)
                if myend > maxdig; start = myend; break; end
                if length(dgr[myend]) == 0; start = myend; break; end
            else
                #println("DEBUG: Search $start..$myend failed, moving range to $(start+1)..$myend")
                for v in dgr[start]
                    if matchR[v] == start; matchR[v] = -1; end
                end
                start += 1
            end
        end
    end
    return best
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        D::Array{I,2} = fill(-1,N,6)
        for i in 1:N; D[i,:] = gis(); end
        #ans = solveSmall(N,D)
        ans = solveLarge(N,D)
        print("$ans\n")
    end
end

function gencase(Nmin::I,Nmax::I,Dvalmax::I)
    N = rand(Nmin:Nmax)
    D::Array{I,2} = rand(1:Dvalmax,N,6)
    return (N,D)
end

function test(ntc::I,Nmin::I,Nmax::I,Dvalmax::I,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (N,D) = gencase(Nmin,Nmax,Dvalmax)
        ans2 = solveLarge(N,D)
        if check
            ans1 = solveSmall(N,D)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(N,D)
                ans2 = solveLarge(N,D)
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
#    test(ntc,1,100,100)
#    test(ntc,1,100,300)
#    test(ntc,1,100,1000)
#    test(ntc,1,100,3000)
#end
#test(200,49900,50000,100000,false)

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

