
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
### I LOVE the interactive problems!!
###
### The obvious strategy here seems to be just to sell the "most rare" flavors (based on the
### flavors requested so far) amongs the set of pops we still have available and that the customer likes, 
### saving the popular flavors for the final customers when the inventory is low.
######################################################################################################

function solve()
    N::I = gi()
    seen::VI = fill(0,N)
    used::SI = SI()
    for i::I in 1:N
        darr::VI = gis()
        if darr[1] == -1 exit(1); end;
        if darr[1] == 0; print("-1\n"); flush(stdout); continue; end
        popfirst!(darr)
        for d in darr; seen[d+1] += 1; end
        remaining = [d for d in darr if d ∉ used]
        if length(remaining) == 0; print("-1\n"); flush(stdout); continue; end
        targ::I = minimum([seen[x+1] for x in remaining])
        vals::VI = [d for d in remaining if seen[d+1] == targ]
        v::I = rand(vals)
        push!(used,v)
        print("$v\n"); flush(stdout)
    end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        solve()
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

