
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

function tryit(B::I,X::VI,numAtMin::I)::F
    ## Calc minimum required
    ## If budget < min, return 0.00
    ## Calc max I can spend -- need to keep last column above my chips
    ## Calc Profit
    if X[numAtMin] > X[37]-2; return 0.00; end
    minrequired = 0
    maxallowed = 0
    for i in 1:37
        minht = i<=numAtMin ? X[numAtMin] : X[numAtMin]+1
        maxht = 1<=numAtMin ? X[37]-2 : X[37]-1
        minrequired += minht > X[i] ? minht-X[i] : 0
        maxallowed += maxht > X[i] ? maxht-X[i] : 0
    end
    if minrequired > B || maxallowed < minrequired; return 0.00; end
    level = X[37]-2
    if maxallowed > B
        l,u=X[numAtMin],X[37]-2
        while (u-l) > 1
            m = (u+l)÷2
            needed::I = 0
            for i in 1:numAtMin;    needed += X[i] >= m   ? 0 : m-X[i]; end
            for i in numAtMin+1:37; needed += X[i] >= m+1 ? 0 : m-X[i]+1; end
            if needed <= B; l = m; else; u = m; end
        end
        level = l
    end
    spent = 0
    for i in 1:numAtMin;    spent += X[i] >= level   ? 0 : level-X[i]; end
    for i in numAtMin+1:37; spent += X[i] >= level+1 ? 0 : level-X[i]+1; end
    received,frac = 0,36.0/numAtMin
    for i in 1:numAtMin; received += X[i] >= level   ? 0 : level-X[i]; end
    return frac * received - spent
end

function solve(B::I,N::I,Xorig::VI)::F
    X = vcat(Xorig,fill(0,37-N))
    sort!(X)
    best::F = 0.00
    for numAtMin in 1:36
        ans = tryit(B,X,numAtMin)
        best = max(ans,best)
    end
    return best
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        B,N = gis()
        X = gis()
        ans = solve(B,N,X)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()

