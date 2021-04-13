
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

function solve(N::I,L::I,outlets::VI,shota::VI)::String
    answers::SI = SI(outlets)
    best = 60
    for o in outlets
        for s in shota
            xorstr = o ⊻ s
            done = true
            for ss in shota
                if ss ⊻ xorstr ∉ answers; done = false; break; end
            end
            if done
                trial = 0
                for i in 0:39
                    if xorstr & (1 << i) > 0; trial += 1; end
                end
                best = min(best,trial)
            end
        end
    end
    return best == 60 ? "NOT POSSIBLE" : "$best"
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,L = gis()
        outlets = [parse(Int64,x,base=2) for x in gss() ]
        shota   = [parse(Int64,x,base=2) for x in gss() ]
        ans = solve(N,L,outlets,shota)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
