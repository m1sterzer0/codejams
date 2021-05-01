
######################################################################################################
### A) Look at 119 "first characters" to see which we are missing
### B) Look at 23  "second characters" to see which one we are missing
### C) Look at 5   "third characters" to see which one we are missing
### D) Look at 1   "fourth character" to see which one we are missing
######################################################################################################

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

function solve()
    ss::Set{Char} = Set{Char}(['A','B','C','D','E'])
    remaining::VI = collect(1:5:595)
    ansarr::VC = []
    expected::I = 24
    d::Dict{Char,VI} = Dict{Char,VI}()
    for pos in 1:4
        empty!(d); for c in ss; d[c] = VI(); end
        for r in remaining; print("$r\n"); end
        flush(stdout)
        for r in remaining; push!(d[gs()[1]],r+1); end
        missingchar::Char = [x for x in ss if length(d[x]) < expected][1]
        push!(ansarr,missingchar); delete!(ss,missingchar)
        remaining = d[missingchar]; expected ÷= (5-pos)
    end
    push!(ansarr,[x for x in ss][1]) ## Last remaining character
    println(join(ansarr)); flush(stdout)
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I,F::I = gis()
    for qq in 1:tt
        solve()
        res = gs(); if res != "Y"; exit(0); end
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

