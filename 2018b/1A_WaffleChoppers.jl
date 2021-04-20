
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

######################################################################################################
### -- We first count up all of the chocolate chips and make sure they are divisible by (H+1) and (V+1)
### -- Next, we need create row-sums and col-sum of the chocolate chips in each row/col respectively.
###    We use this to determine where we must make our cuts.
### -- Finally, we check each piece and make sure that they have the right number of chips
######################################################################################################

function solve(R::I,C::I,H::I,V::I,g::Array{Char,2})::String
    nchips::I = count(x->x=='@',g)
    if nchips == 0; return "POSSIBLE"; end
    if nchips % ((H+1)*(V+1)) != 0; return "IMPOSSIBLE"; end
    chipsPerPiece::I = nchips ÷ ((H+1)*(V+1))
    chipsPerRow::I = chipsPerPiece * (V+1)
    chipsPerCol::I = chipsPerPiece * (H+1)
    rowChips::VI = [count(x->x=='@',g[i,:]) for i in 1:R]
    colChips::VI = [count(x->x=='@',g[:,j]) for j in 1:C]

    hcuts::VI = []
    vcuts::VI = []
    running::I = 0
    for i::I in 1:R
        running += rowChips[i]
        if running > chipsPerRow; return "IMPOSSIBLE"; end
        if running == chipsPerRow; push!(hcuts,i); running=0; end
    end
    running = 0
    for j::I in 1:C
        running += colChips[j]
        if running > chipsPerCol; return "IMPOSSIBLE"; end
        if running == chipsPerCol; push!(vcuts,j); running=0; end
    end
    if length(hcuts) != H+1; return "IMPOSSIBLE"; end
    if length(vcuts) != V+1; return "IMPOSSIBLE"; end
    pop!(hcuts)  ## should always get one extra cut
    pop!(vcuts)

    for ii in 1:H+1
        for jj in 1:V+1
            t = ii == 1   ? 1 : hcuts[ii-1]+1
            b = ii == H+1 ? R : hcuts[ii]
            l = jj == 1   ? 1 : vcuts[jj-1]+1
            r = jj == V+1 ? C : vcuts[jj]
            nchips = count(x->x=='@',g[t:b,l:r])
            if nchips != chipsPerPiece; return "IMPOSSIBLE"; end
        end
    end
    return "POSSIBLE"
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        R,C,H,V = gis()
        g::Array{Char,2} = fill('.',R,C)
        for i in 1:R; g[i,:] = [c for c in gs()]; end
        ans = solve(R,C,H,V,g)
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

