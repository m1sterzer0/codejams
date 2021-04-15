
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

function solve(N::I,K::I,sumarr::VI)
    minmodk::VI = fill(0,K)
    maxmodk::VI = fill(0,K)
    lastmodk::VI = fill(0,K)

    for i in 1:length(sumarr)-1
        v = sumarr[i+1]-sumarr[i]
        idx = ((i-1) % K) + 1
        lastmodk[idx] += v
        if lastmodk[idx] < minmodk[idx]; minmodk[idx] = lastmodk[idx]; end
        if lastmodk[idx] > maxmodk[idx]; maxmodk[idx] = lastmodk[idx]; end
    end

    ## Now we line up the bottoms of the ranges for all of the indices
    sumfirstk = 0
    for i in 1:K
        delta = -minmodk[i]
        minmodk[i] += delta
        maxmodk[i] += delta
        sumfirstk += delta
    end

    maxrange = maximum(maxmodk)
    slop = 0
    for i in 1:K; slop += maxrange - maxmodk[i]; end

    ## Now we use sumarr[1] to figure out our target, and to figure out if we are
    ## at the maximum of the ranges of the mod K terms or if we need to 'add 1' for
    ## enough slop to achieve the desired sumarr[1] sum.
    neededExtra = (sumarr[1] - sumfirstk) % K
    if neededExtra < 0; neededExtra += K; end
    ans = neededExtra > slop ? maxrange+1 : maxrange
    return ans
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,K = gis()
        sumarr::VI = gis()
        ans = solve(N,K,sumarr)
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

