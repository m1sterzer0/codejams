
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

function solve(N::I,P::VS)
    prefix::VC = []; lenpre = 0
    suffix::VC = []; lensuf = 0
    middle::VC = []
    for i::I in 1:N
        lp::I = length(P[i])
        i1::I,i2::I = 1,lp
        while P[i][i1] != '*'
            c::Char = P[i][i1]
            if i1 <= lenpre && c != prefix[i1]; return "*"; end
            if i1 > lenpre; push!(prefix,c); lenpre += 1; end
            i1 += 1
        end
        while P[i][i2] != '*'
            c = P[i][i2]
            invidx::I = lp+1-i2
            if invidx <= lensuf && c != suffix[invidx]; return "*"; end
            if invidx > lensuf; push!(suffix,c); lensuf += 1; end
            i2 -= 1
        end
        for i3::I in i1+1:i2-1
            c = P[i][i3]
            if c != '*'; push!(middle,c); end
        end
    end
    ansarr::VC = vcat(prefix,middle,reverse(suffix))
    return join(ansarr,"")
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        P::VS = []
        for i in 1:N; push!(P,gs()); end
        ans = solve(N,P)
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

