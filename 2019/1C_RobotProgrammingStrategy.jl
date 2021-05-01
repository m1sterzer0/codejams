
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

function solve(A::I,R::VS)::String
    ## Pad out the strings to avoid wraparound
    q::VS = []
    for r in R; push!(q,r^( (A + length(r) - 1)÷length(r) )); end
    ansarr::VC = []
    for i in 1:A
        charstr = join(unique(sort([x[i] for x in q])))
        if length(charstr) == 3; return "IMPOSSIBLE"; end
        if length(charstr) == 1
            push!(ansarr, charstr[1] == 'P' ? 'S' : charstr[1] == 'S' ? 'R' : 'P')
            return join(ansarr)
        end
        mychar = charstr == "PR" ? 'P' : charstr == "PS" ? 'S' : 'R'
        push!(ansarr,mychar)
        q = [x for x in q if x[i]==mychar]
    end
    return "IMPOSSIBLE"
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        A = gi()
        R::VS = []
        for i in 1:A; push!(R,gs()); end
        ans = solve(A,R)
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

