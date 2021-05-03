
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

function solve(N::I,S::VI,E::VI)::String
    tasks::Vector{TI} = [(S[i],E[i],i) for i in 1:N]
    sort!(tasks)
    assignments::VC = ['X' for i in 1:N]
    cavail::I,javail::I = 0,0
    for (s::I,e::I,i::I) in tasks
        if     cavail <= s; assignments[i] = 'C'; cavail = e
        elseif javail <= s; assignments[i] = 'J'; javail = e
        else;  return "IMPOSSIBLE"
        end
    end
    return join(assignments,"")
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        S::VI = fill(0,N)
        E::VI = fill(0,N)
        for i in 1:N; S[i],E[i] = gis(); end
        ans = solve(N,S,E)
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

