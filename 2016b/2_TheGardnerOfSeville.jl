
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

function processPP(PP::VI,perim::I)::VPI
    locpairs::Vector{Tuple{I,PI}} = []
    for (x,y) in zip(PP[1:2:length(PP)],PP[2:2:length(PP)])
        if x > y; x,y=y,x; end
        if y-x <= perim+x-y
            push!(locpairs,(y-x,(x,y)))
        else
            push!(locpairs,(perim+x-y,(y,x)))
        end
    end
    sort!(locpairs)
    return [xx[2] for xx in locpairs]
end

function convert(x::I,r::I,c::I)::Tuple{I,I,Char}
    if     x <= c;    return (0, x, 'S')
    elseif x <= r+c;  return (x-c, c+1, 'W')
    elseif x <= r+2c; return (r+1, c+r+c+1-x, 'N')
    else              return (c+r+c+r+1-x, 0, 'E')
    end
end

function move(y::I,x::I,d::Char,arr::Array{Char,2},
              r::I,c::I)::Tuple{I,I,Char}
    ## Do the move
    (y,x) = (d == 'N') ? (y-1,x) :
            (d == 'S') ? (y+1,x) :
            (d == 'E') ? (y,x+1) : (y,x-1)

    ## Check for exit
    if y < 1 || y > r || x < 1 || x > c; return (y,x,d); end

    ## Place the hedge if necessary
    if arr[y,x] == ' '; arr[y,x] = d in "NS" ? '\\' : '/'; end

    ## Calculate the new direction
    if     (d == 'N'); d = arr[y,x] == '/' ? 'E' : 'W'
    elseif (d == 'E'); d = arr[y,x] == '/' ? 'N' : 'S'
    elseif (d == 'S'); d = arr[y,x] == '/' ? 'W' : 'E'
    else;              d = arr[y,x] == '/' ? 'S' : 'N'
    end

    return (y,x,d)
end


function goLeft(arr::Array{Char,2},p::PI,r::I,c::I)::Bool
    (s1,s2,d)     = convert(p[1],r,c)
    (e1,e2,dummy) = convert(p[2],r,c)
    while(true)
        (s1,s2,d) = move(s1,s2,d,arr,r,c)
        if s1 < 1 || s1 > r || s2 < 1 || s2 > c; break; end
    end
    return s1 == e1 && s2 == e2
end


function solve(R::I,C::I,PP::VI)::VS
    arr::Array{Char,2} = fill(' ',R,C)
    pairs::VPI = processPP(PP,2*R+2*C)
    good::Bool = true
    for p in pairs
        if !goLeft(arr,p,R,C); return ["IMPOSSIBLE"]; end
    end
    ## Fill in all of the spaces with forward slash
    f(x::Char)::Char = x == ' ' ? '/' : x 
    arr = f.(arr)
    return [join(arr[i,:],"") for i in 1:R]
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq:\n")
        R,C = gis()
        PP::VI = gis()
        ans = solve(R,C,PP)
        for l in ans; print("$l\n"); end
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

