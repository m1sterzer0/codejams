
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

function traverse(p::I,n::I,adj::VVI)::I
    best::I,secondbest::I = 0,0
    for x in adj[n]
        if x == p; continue; end
        cans = traverse(n,x,adj)
        if cans > best
            (best,secondbest) = (cans,best)
        elseif cans > secondbest
            secondbest = cans
        end
    end
    if secondbest == 0; return 1; end
    return 1 + best + secondbest
end

function solve(N::I,X::VI,Y::VI)::I
    adj::VVI = [VI() for i in 1:N]
    for i in 1:N-1
        push!(adj[X[i]],Y[i])
        push!(adj[Y[i]],X[i])
    end
    best::I = 0
    for i in 1:N
        ans = traverse(-1,i,adj)
        best = max(best,ans)
    end
    return N - best
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        X::VI = fill(0,N-1)
        Y::VI = fill(0,N-1)
        for i in 1:N-1; X[i],Y[i] = gis(); end
        ans = solve(N,X,Y)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()

