
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

function solve(X::I,Y::I)::String
    xmag::I,xsign::I,ymag::I,ysign::I = abs(X),sign(X),abs(Y),sign(Y)
    ansarr::VC = []
    while (true)
        f1::Bool = (xmag % 2 != 0)
        f2::Bool = (ymag % 2 != 0)
        if f1 && f2 || ~f1 && ~f2; return "IMPOSSIBLE"; end
        if xmag == 1 && ymag == 0; push!(ansarr,xsign > 0 ? 'E' : 'W'); break; end 
        if xmag == 0 && ymag == 1; push!(ansarr,ysign > 0 ? 'N' : 'S'); break; end
        f3::Bool = (xmag & 2 != 0)
        f4::Bool = (ymag & 2 != 0)
        if     f1 && (f3 ⊻ f4); push!(ansarr,xsign > 0 ? 'E' : 'W'); xmag -= 1
        elseif f1;              push!(ansarr,xsign > 0 ? 'W' : 'E'); xmag += 1
        elseif f2 && (f3 ⊻ f4); push!(ansarr,ysign > 0 ? 'N' : 'S'); ymag -= 1
        else;                   push!(ansarr,ysign > 0 ? 'S' : 'N'); ymag += 1
        end
        xmag >>= 1; ymag >>= 1
    end
    return join(ansarr,"")
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        X,Y = gis()
        ans = solve(X,Y)
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

