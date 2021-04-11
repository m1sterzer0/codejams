
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

function solve(S::String,N::I)::I
    ls = length(S)
    strends = []
    streak = 0
    for (i,c) in enumerate(S)
        if c in "aeiou"
            streak = 0
        else
            streak += 1
            if streak >= N
                push!(strends,i)
            end
        end
    end
    strbeginnings = [x-(N-1) for x in strends]
    if length(strbeginnings) == 0; return 0; end
    ptr = 1; ans = 0
    for i in 1:strbeginnings[end]
        if strbeginnings[ptr] < i; ptr += 1; end
        strend = strends[ptr]
        ans += (ls-strend+1)
    end
    return ans
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        S,sn = gss()
        N = parse(Int64,sn)
        ans = solve(S,N)
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

