
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

function solve(N::I,M::I,O::VI,E::VI,P::VI)::I
    entry::VPI = []
    exit::VPI = []
    ontrain::VPI = []
    fullprice::I = 0
    lowprice::I = 0
    for i in 1:M
        o,e,p = O[i],E[i],P[i]
        dist = e-o
        priceper = (N*dist-dist*(dist-1)÷2) % 1_000_002_013
        price = (p*priceper) % 1_000_002_013
        fullprice = (fullprice + price) % 1_000_002_013
        push!(entry,(o,p)); push!(exit,(e,p))
    end
    sort!(entry); sort!(exit)
    while !isempty(entry) || !isempty(exit)
        if isempty(exit) || !isempty(entry) && entry[1][1] <= exit[1][1]
            (o,p) = popfirst!(entry)
            push!(ontrain,(o,p))
        else
            (e,p) = popfirst!(exit)
            while (p > 0)
                (o,pp) = pop!(ontrain)
                dist = e-o
                priceper = (N*dist-dist*(dist-1)÷2) % 1_000_002_013
                if pp <= p
                    price = (pp*priceper) % 1_000_002_013
                    lowprice = (lowprice + price) % 1_000_002_013
                    p -= pp
                else
                    price = (p*priceper) % 1_000_002_013
                    lowprice = (lowprice + price) % 1_000_002_013
                    pp -= p
                    p = 0
                    push!(ontrain,(o,pp))
                end
            end
        end
    end
    ans = fullprice - lowprice
    if ans < 0; ans += 1_000_002_013; end
    return ans
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,M = gis()
        O::VI = fill(0,M)
        E::VI = fill(0,M)
        P::VI = fill(0,M)
        for i in 1:M; O[i],E[i],P[i] = gis(); end
        ans = solve(N,M,O,E,P)
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

