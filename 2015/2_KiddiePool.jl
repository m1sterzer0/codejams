
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

function solve(N::I,V::F,X::F,R::VF,C::VF)::String
    ds::Vector{Tuple{F,F}} = [(C[i],R[i]) for i in 1:N]
    sort!(ds)
    if ds[1][1] > X || ds[end][1] < X
        return "IMPOSSIBLE"
    elseif  ds[1][1] == X || ds[end][1] == X
        ds2 = [x for x in ds if x[1] == X]
        newR = sum(x[2] for x in ds2)
        ans = V / newR
        return "$ans"
    end

    (lastT,lastR) = ds[1]
    for i in 2:N
        newR = sum(x[2] for x in ds[1:i])
        newT = sum(x[1]*x[2] for x in ds[1:i]) / newR
        if newT > X
            T0,R0,T1 = lastT,lastR,ds[i][1]
            newR = R0 + R0 * (X - T0) / (T1 - X)
            ans = V / newR
            return "$ans"
        end
        lastR,lastT = newR,newT
    end

    for i in 1:N-1
        newR = sum(x[2] for x in ds[i+1:end])
        newT = sum(x[1]*x[2] for x in ds[i+1:end]) / newR
        if newT > X
            T0,R0,T1 = newT,newR,ds[i][1]
            newR = R0 + R0 * (T0 - X) / (X - T1)
            ans = V / newR
            return "$ans"
        end
        lastR,lastT = newR,newT
    end

    return "-1.000" ## Shouldn't get here
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        inp = gss()
        N = parse(Int64,inp[1])
        V = parse(Float64,inp[2])
        X = parse(Float64,inp[3])
        R::VF = fill(0.00,N)
        C::VF = fill(0.00,N)
        for i in 1:N; R[i],C[i] = gfs(); end
        ans = solve(N,V,X,R,C)
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

