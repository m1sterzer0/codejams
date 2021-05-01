
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

function solve(N::I,B::I,F::I)
    results::Array{I,2} = fill(0,4,N-B)
    for i in 1:4
        println(join([(j >> (i-1)) & 1 for j in 0:N-1],"")); flush(stdout)
        results[i,:] = [parse(Int64,x) for x in gs()]
    end
    addrMod16 = [ results[:,x]' * [1,2,4,8] for x in 1:N-B ]
    ptr::I = 1; bad::VI = []
    for i in 0:N-1
        if ptr <= N-B && i % 16 == addrMod16[ptr]; ptr += 1; else; push!(bad,i); end
    end
    println(join(bad," ")); flush(stdout)
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        N,B,F = gis()
        solve(N,B,F)
        result = gi()
        if result != 1; exit(0); end
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

