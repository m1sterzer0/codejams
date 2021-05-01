
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

function tryit(moves::VPI)::VPI
    moves2::VPI = shuffle(moves)
    used::VB = fill(false,length(moves))
    order::VPI = [moves2[1]]; used[1] = true
    for i in 2:length(moves)
        (lx,ly) = order[end]
        for (j,(x,y)) in enumerate(moves2)
            if used[j] || lx == x || ly == y || x-y == lx-ly || x+y == lx+ly; continue; end
            push!(order,(x,y)); used[j] = true; break 
        end
        if length(order) != i; return order; end
    end
    return order
end

function solve(R::I,C::I)::VS
    moves::VPI = [(i,j) for i in 1:R for j in 1:C]
    for i in 1:1000
        order::VPI = tryit(moves)
        if length(order) == R*C; return vcat(["POSSIBLE"],["$i $j" for (i,j) in order]); end
    end
    return ["IMPOSSIBLE"]
end

function test()
    for r in 2:20
        for c in 2:20
            print("$r $c\n")
            ans = solve(r,c)
            for l in ans; println(l); end
            print("\n")
        end
    end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        R,C = gis()
        ans = solve(R,C)
        for l in ans; println(l); end
    end
end

Random.seed!(8675309)
main()
#test()
#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

