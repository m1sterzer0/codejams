
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

function maxBPM(bpGraph::Array{Int8,2},m::I,n::I)
    matchR::VI = fill(-1,n)
    seen::VB = fill(false,n)
    result::I = 0
    for u::I in 1:m
        fill!(seen,false)
        if bpm(bpGraph,u,seen,matchR,m,n); result += 1; end
    end
    return result
end

######################################################################################################
### END MAXIMUM BIPARTITE MATCHING CODE
### Inspired by https://www.geeksforgeeks.org/maximum-bipartite-matching/
######################################################################################################

######################################################################################################
### We need to cover the set of first and second words with as few entries as possible to maximize
### the list of potential fakers.  This cover is minimized when i MAXIMIZE the number of entries that
### "take out" two previoiusly untaken terms at onces.  This can be found with a maximum bipartite
### matching algorithm.
######################################################################################################

function solve(N::I,X::VS,Y::VS)::I
    fw::Dict{String,I} = Dict{String,I}()
    lw::Dict{String,I} = Dict{String,I}()
    ux::VS = unique(X)
    uy::VS = unique(Y)
    for (i,s) in enumerate(ux); fw[s] = i; end
    for (i,s) in enumerate(uy); lw[s] = i; end
    nfw::I = length(ux)
    nlw::I = length(uy)
    gr::Array{Int8,2} = fill(Int8(0),nfw,nlw)
    for i::I in 1:N; gr[fw[X[i]],lw[Y[i]]] = Int8(1); end
    doubles::I = maxBPM(gr,nfw,nlw)
    singles::I = nfw+nlw-2*doubles
    return N-doubles-singles
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N::I = gi()
        X::VS = fill("",N)
        Y::VS = fill("",N)
        for i in 1:N; X[i],Y[i] = gss(); end
        ans = solve(N,X,Y)
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

