
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

function makeDD(D::VS)::Dict{String,VI}
    DD::Dict{String,VI} = Dict{String,VI}()
    keys = []
    for c in "abcdefghijklmnopqrstuvwxyz."; push!(keys,"$c"); end
    for i in 1:3
        nkeys = keys[:]
        for k in nkeys
            for c in "abcdefghijklmnopqrstuvwxyz."; push!(keys,"$k$c"); end
        end
    end
    for k in keys; DD[k] = []; end
    for (i,w) in enumerate(D)
        if length(w) == 1
            push!(DD[w[1:1]],i)
            push!(DD["."],i)
        elseif length(w) == 2
            push!(DD[w[1:2]],i)
            push!(DD["."*w[2:2]],i)
            push!(DD[w[1:1]*"."],i)
        elseif length(w) == 3
            push!(DD[w[1:3]],i)
            push!(DD["."*w[2:3]],i)
            push!(DD[w[1:1]*"."*w[3:3]],i)
            push!(DD[w[1:2]*"."],i)
        else
            push!(DD[w[1:4]],i)
            push!(DD["."*w[2:4]],i)
            push!(DD[w[1:1]*"."*w[3:4]],i)
            push!(DD[w[1:2]*"."*w[4:4]],i)
            push!(DD[w[1:3]*"."],i)
        end
    end
    return DD
end

function solve(D::VS,S::String,working)::I
    DD::Dict{String,VI} = working[1]
    DP::Array{I,2} = fill(10000,4000,5)
    ls::I = length(S)
    for i in ls:-1:1

        ## Get the prefixes
        prefixes = [".",S[i:i]]
        if i+1 <= ls
            push!(prefixes,S[i:i+1])
            push!(prefixes,S[i:i]*".")
            push!(prefixes,"."*S[i+1:i+1])
            if i+2 <= ls
                push!(prefixes,S[i:i+2])
                push!(prefixes,S[i:i+1]*".")
                push!(prefixes,S[i:i]*"."*S[i+2:i+2])
                push!(prefixes,"."*S[i+1:i+2])
                if i+3 <= ls
                    push!(prefixes,S[i:i+3])
                    push!(prefixes,S[i:i+2]*".")
                    push!(prefixes,S[i:i+1]*"."*S[i+3:i+3])
                    push!(prefixes,S[i:i]*"."*S[i+2:i+3])
                    push!(prefixes,"."*S[i+1:i+3])
                end
            end
        end

        wordindices::Set{Int64} = Set{Int64}()
        for p in prefixes
            for widx in DD[p]
                push!(wordindices,widx)
            end
        end
        for wi in wordindices
            w = D[wi]
            lw::I = length(w)
            if lw + i - 1 > ls; continue; end
            mismatches = [i+j-1 for j in 1:lw if w[j] != S[i+j-1]]
            good = true
            for i in 1:length(mismatches)-1
                if mismatches[i+1]-mismatches[i] < 5; good = false; break; end
            end
            if !good; continue; end
            nexti = i + lw
            if length(mismatches) == 0
                if nexti > ls
                    for j in 1:5; DP[i,j] = 0; end
                else
                    for j in 1:5; DP[i,j] = min(DP[i,j],DP[nexti,max(1,j-lw)]); end
                end
            else
                prefix = min(5,1+mismatches[1]-i)
                suffix = min(4,nexti-mismatches[end]-1)
                ans = length(mismatches) + (nexti > ls ? 0 : DP[nexti,5-suffix])
                for j in 1:prefix; DP[i,j] = min(DP[i,j],ans); end
            end
        end
    end
    return DP[1,1]
end

function gencase(D::VS,Slenmax::I)
    slen = rand(1:Slenmax)
    words = []; numlet = 0
    while numlet < slen;
        w = rand(D)
        if numlet + length(w) > slen; continue; end
        push!(words,w); numlet += length(w)
    end
    shuffle!(words)
    w = join(words,"")
    lets = [x for x in w]
    prev = 4; cchance = rand()
    for i in 1:slen
        if prev < 4 || rand() < cchance
            prev += 1
        else
            prev = 0
            lets[i] = rand("abcdefghijklmnopqrstuvwxyz")
        end
    end
    w2 = join(lets,"")
    return (w2,)
end

function weightedRandChoice(seq,weights::VF,nn::I)
    cumweights::VF = [weights[1]]
    for i in 2:length(weights); push!(cumweights,cumweights[end]+weights[i]); end
    res = []
    for i in 1:nn; push!(res,seq[min(length(seq),searchsortedfirst(cumweights,cumweights[end]*rand()))]); end
    return res
end

function test(ntc::I,Dsize::I,Slenmax::I)
    ## Generate the dictionary
    LD::Set{String} = Set{String}()
    weights = [1.0*x for x in 1:26]; shuffle!(weights)
    wlens::VI = []
    for i in 1:10
        for j in 1:i; push!(wlens,i); end
    end
    while length(LD) < Dsize
        wlen = rand(wlens)
        lets = weightedRandChoice("abcdefghijklmnopqrstuvwxyz",weights,wlen)
        w = join(lets,"")
        push!(LD,w)
    end
    D = [x for x in LD]
    sort!(D)

    ## Do the preprocessing
    DD = makeDD(D)

    for ttt in 1:ntc
        (S,) = gencase(D,Slenmax)
        ans2 = solve(D,S,(DD,))
        print("Case #$ttt: $ans2\n")
    end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    W = gi()
    D::VS = []
    for i in 1:W; push!(D,gs()); end
    DD::Dict{String,VI} = makeDD(D)
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        S = gs()
        ans = solve(D,S,(DD,))
        #ans = solveLarge()
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
#test(20,500000,50)
#test(10,500000,4000)

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

