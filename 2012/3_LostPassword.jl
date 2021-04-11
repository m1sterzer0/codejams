
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

### For the small input, the letters form the nodes of a graph, and the edges represent the words
### that can be made.  The graph must be connected, given the way it is derived.  We employ a greedy plan.
### a) We count the indegree and outdegree of each nodes
### b) If each node has a matching indegree and outdegree, then the answer is 1 + the number of edges.
### c) Otherwise, our answer is the number of edges + sum of the indegree excesses across the node (note
###    we can always start with one of those in our final string to save the "1+" factor from the solution
###    in (b).
function solveSmall(K::I,S::String)::I
    if K > 2; return 0; end
    leet::Dict{Char,Char} = Dict{Char,Char}('o'=>'0','i'=>'1','e'=>'3','a'=>'4','s'=>'5','t'=>'7','b'=>'8','g'=>'9')
    indeg::Dict{Char,I} = Dict{Char,I}()
    outdeg::Dict{Char,I} = Dict{Char,I}()
    for c in "abcdefghijklmnopqrstuvwxyz01345789"; indeg[c] = 0; outdeg[c] = 0; end
    edges::Set{Tuple{Char,Char}} = Set{Tuple{Char,Char}}()
    for i in 1:length(S)-1
        a,b = S[i],S[i+1]
        push!(edges,(a,b))
        if haskey(leet,a); push!(edges,(leet[a],b)); end 
        if haskey(leet,b); push!(edges,(a,leet[b])); end
        if haskey(leet,a) && haskey(leet,b); push!(edges,(leet[a],leet[b])); end
    end
    for (a,b) in edges; outdeg[a] += 1; indeg[b] += 1; end
    totedges = sum(indeg[c] for c in keys(indeg))
    neededEdges = 0
    ## Only count blocks w/ indegee > outdegree to avoid the doublecount
    for c in keys(indeg); if indeg[c] > outdeg[c]; neededEdges += indeg[c]-outdeg[c]; end; end
    if neededEdges > 1; neededEdges -= 1; end ## Difference between a path and a cycle
    totlen = 1 + totedges + neededEdges
    return totlen
end

### The large is much tougher.  What follows is a transcription of the algorithm in the
### solutions.
function solveLarge(K::I,S::String)
    leet = Dict('o'=>'0','i'=>'1','e'=>'3','a'=>'4','s'=>'5','t'=>'7','b'=>'8','g'=>'9')
    craw::Set{String} = Set{String}()
    ls::I = length(S)
    for i in 1:ls-K+1; push!(craw,S[i:i+K-1]); end
    numcand::I = 0
    PP::Dict{String,Int64} = Dict{String,Int64}()
    SS::Dict{String,Int64} = Dict{String,Int64}()
    for cand in craw
        prefix = cand[1:K-1]
        suffix = cand[2:K]
        ic = count(x->x in "oieastbg",cand); candinc = 2^ic; numcand += candinc
        if haskey(PP,prefix); PP[prefix] += candinc; else; PP[prefix] = candinc; end
        if haskey(SS,suffix); SS[suffix] += candinc; else; SS[suffix] = candinc; end
    end
    x::I,i::I = 0,0
    while (true)
        myset::Set{String} = Set{String}()
        for pp in keys(PP); push!(myset,pp); end
        for ss in keys(SS)
            if ss ∉ myset; continue; end
            v = min(PP[ss],SS[ss])
            x += i*v
            PP[ss] -= v
            SS[ss] -= v
        end
        pkv = [(k,v) for (k,v) in PP]
        skv = [(k,v) for (k,v) in SS]
        empty!(PP); empty!(SS)
        for (pre,v) in pkv
            if v == 0; continue; end
            kk = pre[1:end-1]
            if !haskey(PP,kk); PP[kk] = v; else; PP[kk] += v; end
        end
        for (suf,v) in skv
            if v == 0; continue; end
            kk = suf[2:end]
            if !haskey(SS,kk); SS[kk] = v; else; SS[kk] += v; end
        end
        if length(PP) == 0 ; break; end
        i += 1
    end

    ## Can subtract off the last edge, but only if we added an edge
    ans = (K-1) + numcand + (x == 0 ? 0 : x-i)
    return ans
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        K::I = gi()
        S::String = gs()
        #ans = solveSmall(K,S)
        ans = solveLarge(K,S)
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

