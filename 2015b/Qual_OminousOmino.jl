
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

function solve(X::I,R::I,C::I)::String
    r,c = [min(R,C),max(R,C)]
    if (r*c) % X != 0; return "RICHARD" ## Area of region isn't a multiple of X, so impossible
    elseif X == 1; return "GABRIEL"  ## Only one 1-omino, and it tiles easily
    elseif X == 2; return "GABRIEL"  ## Only one 2-omino, and it tiles easily
    ## KEY RICHARD PIECES
    ##  x    xx    x     x     xxx
    ##  xx    xx   xx   xxxx   x x
    ##              xx   x     xx
    elseif X == 3
        if r == 1; return "RICHARD"; else; return "GABRIEL"; end
    elseif X == 4
        if r <= 2; return "RICHARD"; else; return "GABRIEL"; end
    elseif X == 5
        ## piece requires at least 3x10 region if r == 3
        if r <= 2; return "RICHARD"; elseif (r == 3 && c == 5); return "RICHARD"; else; return "GABRIEL"; end 
    elseif X == 6
        ## key piece divides triple row into two regions that can never be divisible by 6
        if r <= 3; return "RICHARD"; else; return "GABRIEL"; end 
    else
        ## Can create an unfillable hole with X >= 7
        return "RICHARD" 
    end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        X,R,C = gis()
        ans = solve(X,R,C)
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

