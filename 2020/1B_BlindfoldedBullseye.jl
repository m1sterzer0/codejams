
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

function trycoord(X::I,Y::I)::I
    print("$X $Y\n"); flush(stdout)
    ans::String = gs()
    res::I = ans == "MISS" ? 0 : ans == "HIT" ? 1 : ans == "CENTER" ? 2 : 3
    return res
end

function dosearch(xflag::Bool,rightflag::Bool,minval::I,maxval::I,otherval::I)::I
    l::I,r::I = minval,maxval
    while(r-l > 1)
        m::I = (r+l)÷2
        (x::I,y::I) = xflag ? (m,otherval) : (otherval,m)
        a::I = trycoord(x,y); if a == 2; return 1_000_000_001; end
        if rightflag
            if a == 1; r = m; else; l = m; end
        else
            if a == 1; l = m; else; r = m; end
        end
    end
    return rightflag ? r : l
end

function solve()
    coord1::VI = [-1_000_000_000,-500_000_000,0,500_000_000,1_000_000_000]
    coord2::VI = [-750_000_000,-250_000_000,250_000_000,750_000_000]
    initialPoints::VPI = VPI()
    for x::I in coord1; for y::I in coord1; push!(initialPoints,(x,y)); end; end
    for x::I in coord2; for y::I in coord2; push!(initialPoints,(x,y)); end; end

    ## Part 1 -- look for a HIT
    hx::I,hy::I = 0,0
    for (x,y) in initialPoints
        a::I = trycoord(x,y); if a == 2; return; end
        if a == 1; hx=x; hy=y; break; end
    end

    ## Part 2a -- look for left, right, top, bot edge
    left::I  = dosearch(true,true,-1_000_000_000,hx,hy);  if left  == 1_000_000_001; return; end
    right::I = dosearch(true,false,hx,1_000_000_000,hy);  if right == 1_000_000_001; return; end
    bot::I   = dosearch(false,true,-1_000_000_000,hy,hx); if bot   == 1_000_000_001; return; end
    top::I   = dosearch(false,false,hy,1_000_000_000,hx); if top   == 1_000_000_001; return; end

    x::I = (left+right) ÷ 2
    y::I = (bot+top) ÷ 2
    a    = trycoord(x,y)
    if a != 2; print(stderr,"ERROR!!!\n"); exit(); end
    return
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I,A::I,B::I = gis()
    for qq in 1:tt
        solve()
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

