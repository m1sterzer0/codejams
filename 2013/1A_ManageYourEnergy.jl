
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


## Going to divide and conquer, which (I think) is O(N^2) in worst case.
## We can improve findmax if we need and make this O(NlogN)
function solve2(ii::I,jj::I,enin::I,enout::I,E::I,R::I,V::VI):I
    if ii==jj; s = min(enin,enin+R-enout); return s*V[ii]; end
    budget = min(E,enin+R*(jj-ii+1)-enout)
    if budget == 0; return 0; end
    (m,kk) = findmax(V[ii:jj]); kk += (ii-1)
    inc = min(E,enin+R*(kk-ii))
    out = max(R,enout-(jj-kk)*R)
    spend = inc - (out-R)
    return spend*V[kk] + (kk==ii ? 0 : solve2(ii,kk-1,enin,inc,E,R,V)) +
                         (kk==jj ? 0 : solve2(kk+1,jj,out,enout,E,R,V))
end

function solve(E::I,R::I,N::I,V::VI)
    R = min(R,E)
    return solve2(1,N,E,R,E,R,V)
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        E,R,N = gis()
        V::VI = gis()
        ans = solve(E,R,N,V)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
