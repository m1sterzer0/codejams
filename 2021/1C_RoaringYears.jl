
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

## Should iterate on size of the prefix?
## Question == when do we have to add a digit?
## Question == when do we need to change the length

## What is the top end? 1_2_3_4_5_6_7_8_9_10_11_12_13_14
## Just use Int128 to avoid having to be careful
## How many are there if we exclude the pairs.
## Triples < 10^18: 10^6, Quads < 10^18: 10^5 Quints < 10^18: 10^3
## Much less than 2mil -- we precalc these
function prework()
    VV::Vector{Int128} = []
    for numelem in 3:14
        for seed in 1:1_000_000
            n = parse(Int128,join([seed+i-1 for i in 1:numelem],""))
            if n > 1234567891011121314; break; end
            push!(VV,n)
        end
    end
    unique!(sort!(VV))
    return (VV,)
end

function solve(Y::Int128,working)
    (VV::Vector{Int128},) = working
    ## Step 1, bin search on which element of VV is greater -- covers case of 3-14 copies
    opt1::Int128 = 1234567891011121314
    if VV[1] > Y
        opt1 = VV[1]
    else
        l,u = 1,length(VV)
        while u-l > 1; m = (u+l)>>1; if VV[m] > Y; u = m; else; l = m; end; end
        opt1 = VV[u]
    end

    opt2::Int128 = 1234567891011121314
    if 12 > Y
        opt2 = 12
    else
        l,u = 1,10_000_000_000
        while u-l > 1
            m = (u+l)>>1
            cand = parse(Int128,join([m,m+1],""))
            if cand > Y; u = m; else; l = m; end
        end
        opt2 = parse(Int128,join([u,u+1],""))
    end

    return opt1 < opt2 ? string(opt1) : string(opt2)
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    working = prework()
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        Y::Int128 = parse(Int128,gs())
        ans = solve(Y,working)
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

