
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

function solve(R::I,C::I,map::Array{Char,2})::String
    singletonRowSet::SPI = SPI()
    singletonColSet::SPI = SPI()
    changeSet::SPI = SPI()

    ## Do the rows first
    for i in 1:R
        found::VI = []
        for j in 1:C
            if map[i,j] == '.'; continue; end
            push!(found,j)
        end
        if length(found) == 0
            continue
        elseif length(found) == 1
            push!(singletonRowSet,(i,found[1]))
            if map[i,found[1]] == '<' || map[i,found[1]] == '>'; push!(changeSet,(i,found[1])); end
        else
            if map[i,found[1]] == '<';   push!(changeSet,(i,found[1])); end
            if map[i,found[end]] == '>'; push!(changeSet,(i,found[end])); end
        end
    end

    ## Do the columns second
    for j in 1:C
        found = []
        for i in 1:R
            if map[i,j] == '.'; continue; end
            push!(found,i)
        end
        if length(found) == 0
            continue
        elseif length(found) == 1
            push!(singletonColSet,(found[1],j))
            if map[found[1],j] == '^' || map[found[1],j] == 'v'; push!(changeSet,(found[1],j)); end
        else
            if map[found[1],j] == '^';   push!(changeSet,(found[1],j)); end
            if map[found[end],j] == 'v'; push!(changeSet,(found[end],j)); end
        end
    end

    if length(intersect(singletonRowSet,singletonColSet)) > 0
        return "IMPOSSIBLE"
    else
        ans = length(changeSet)
        return "$ans"
    end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        R,C = gis()
        map::Array{Char,2} = fill('.',R,C)
        for i in 1:R; map[i,:] = [x for x in gs()]; end
        ans = solve(R,C,map)
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

