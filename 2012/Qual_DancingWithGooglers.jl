
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

function solveLarge(N::I,S::I,p::I,T::VI)::I
    nonspecial::Vector{Bool} = fill(false,31)
    special::Vector{Bool} = fill(false,31)
    for a in 0:10; for b in 0:10; for c in 0:10
        if max(a,b,c) < p; continue; end
        if max(a,b,c) - min(a,b,c) > 2; continue; end
        s = a+b+c
        if max(a,b,c) - min(a,b,c) > 1; special[s+1] = true; else; nonspecial[s+1] = true; end
    end; end; end

    ## Every score can be made in a non-surprising way, hence don't have to worry about being FORCED to
    ## use our surprising score allocation to make scores otherwise unattainable.  We can use the full
    ## allocation of surprising scores toward our answer
    ans::I = 0
    for s in T;
        if nonspecial[s+1]; ans += 1; continue; end
        if special[s+1] && S > 0; ans += 1; S -= 1; end
    end
    return ans
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        T::VI = gis()
        N::I = popfirst!(T)
        S::I = popfirst!(T)
        p::I = popfirst!(T)
        ans = solveLarge(N,S,p,T)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
