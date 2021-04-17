
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
### If N==0, we just dump out INSOMNIA
### For any other number, we just simulate the process
######################################################################################################

function solve(N::I)::String
    if N == 0; return "INSOMNIA"; end
    sb::SI = SI()
    mult::I = 1
    while true
        digits::VI = [parse(Int64,x) for x in string(N*mult)]
        for d::I in digits; push!(sb,d); end
        if length(sb) == 10; return string(N*mult); end
        mult += 1
    end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        ans = solve(N)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
