
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

function solveit(sp::VI,np::VI,Q::I)
    besti::I = 0; best::I = 0
    idxn::I = 1; candn::I = 0; idxp::I = 1; candp::I = length(sp)
    for i in 0:Q;
        while idxn <= length(np) && i > np[idxn]; idxn += 1; candn += 1; end
        while idxp <= length(sp) && i >= sp[idxp]; idxp += 1; candp -= 1; end
        if candn+candp > best; besti = i; best = candn+candp; end
    end
    return besti
end

function solve(P::I,Q::I,X::VI,Y::VI,D::VC)
    sp::VI = [Y[i] for i in 1:P if D[i] == 'S']
    np::VI = [Y[i] for i in 1:P if D[i] == 'N']
    ep::VI = [X[i] for i in 1:P if D[i] == 'E']
    wp::VI = [X[i] for i in 1:P if D[i] == 'W']
    for xx in (sp,np,ep,wp); sort!(xx); end
    y::I = solveit(sp,np,Q)
    x::I = solveit(wp,ep,Q)
    return (x,y)
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        P,Q = gis()
        X::VI = fill(0,P)
        Y::VI = fill(0,P)
        D::VC = fill('.',P)
        for i in 1:P
            xx::VS = gss()
            X[i] = parse(Int64,xx[1])
            Y[i] = parse(Int64,xx[2])
            D[i] = xx[3][1]
        end
        ans = solve(P,Q,X,Y,D)
        println("$(ans[1]) $(ans[2])")
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

