
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

paintReq(r::I,k::I)::I = 2*r*k + k + 2*(k-1)*k

function solve(r::I,t::I)::I
    ## One ring is (r+1)^2 - r^2     = 2r + 1  = 2r + 0 + 1
    ## 2nd ring is (r+3)^2 - (r+2)^2 = 2r + 5  = 2r + 4 + 1
    ## 3rd ring is (r+5)^2 - (r+4)^2 = 2r + 9  = 2r + 8 + 1
    ## 4th ring is (r+7)^2 - (r+6)^2 = 2r + 13 = 2r + 12 + 1
    ##
    ## Sum from ring 1 to k is 2*r*k + k + 4 * (0+1+2+3+...+(k-1))
    ##      = 2rk + k + 2*(k-1)*k
    ## For a bound, we restrict 2*r*k < 4*10^18 and we restrict k + 2*(k-1)*k < ~4*10^18
    ## for the second term 14*10^8 seems to be a good enough bound
    l::I,u::I=0,min(14*10^8,2*10^18÷r)
    if paintReq(r,u) <= t; return u; end
    while (u-l) > 1
        m::I = (u+l)÷2; if paintReq(r,m) <= t; l = m; else; u = m; end
    end
    return l
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        r,t = gis()
        ans = solve(r,t)
       print("$ans\n")
    end
end

Random.seed!(8675309)
main()
