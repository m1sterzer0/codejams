
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
### First, consider the case of just primary colors
### a) If we have a color with a clear MAJORITY, then things are impossible, since we don't have
###    enough other unicorns to put between them.
### b) If we don't have a horse with a clear majority, there is an easy algorithm for a solution.  Lets
###    say there are b blue unicorns, r red unicorns, and y yellow unicorns.  Furthermore, WLOG, assume
###    that b >= r and b >= y.
### c) We need exactly b segments to stick between the blue unicorns.  We claim we can make them out of
###    segemnts of  the following forms {'R','RY','Y'}.  Using a bit of algebra, we claim that we need
###    (r+y-b) "RY" strings, (b-y) "R" strings, and (b-r) "Y" strings.
###    --- b >= y and b >= r, so b-y and b-r are non-negative
###    --- There is no majority, so r+y-b is >= 0.
###    --- Note (r+y-b) + (b-y) = r, and (r+y-b) + (b-r) = y
###
### Now for the large case.
### a) Note that every hybrid must be surrounded on both sides by the opposite primary color.  That collection of
###    3 unicorns logically just looks like one horse of the primary color.
### 
### b) Thus, we need B >= O + 1, Y >= V + 1, and R >= G + 1.  Otherwise, this is impossible.
### c) Finally, we can just replace B+1 blues as one logical Blue (same for red and yellow), solve the primary
###    case above, and then replace on blue/orange/yellow with the collection needed to hide the O's, V's, and G's.
### d) There is a corner case! If we only have B's and O's, and we have the same number, we can still make the circle.
######################################################################################################

function solve(N::I,R::I,O::I,Y::I,G::I,B::I,V::I)::String
    ## Check for the hybrid corner cases
    if B + O == N && B == O; s = "OB"^(N ÷ 2); return s; end 
    if R + G == N && R == G; s = "GR"^(N ÷ 2); return s; end
    if Y + V == N && Y == V; s = "VY"^(N ÷ 2); return s; end

    ## Check to see if we have too many hybrids
    if O > 0 && B <= O; return "IMPOSSIBLE"; end
    if G > 0 && R <= G; return "IMPOSSIBLE"; end
    if V > 0 && Y <= V; return "IMPOSSIBLE"; end

    ## Subtract off the hybrids
    r = R-G; y = Y-V; b = B-O
    
    ## Check for a majority
    if r > b + y || b > r + y || y > b + r; return "IMPOSSIBLE"; end

    ## Solve the primary case
    solve(x,y,z) = (y+z-x,x-z,x-y)
    if (r >= b && r >= y)
        (pairs,sing1,sing2) = solve(r,y,b)
        arr1 = ["R" for i in 1:r]
        arr2 = vcat(fill("YB",pairs),fill("Y",sing1),fill("B",sing2))
    elseif (y >= r && y >= b)
        (pairs,sing1,sing2) = solve(y,b,r)
        arr1 = ["Y" for i in 1:y]
        arr2 = vcat(fill("BR",pairs),fill("B",sing1),fill("R",sing2))
    elseif (b >= r && b >= y)
        (pairs,sing1,sing2) = solve(b,r,y)
        arr1 = ["B" for i in 1:b]
        arr2 = vcat(fill("RY",pairs),fill("R",sing1),fill("Y",sing2))
    end

    ## Interleve the two strings
    ans = reduce(*,[x*y for (x,y) in zip(arr1,arr2)])

    ## Now we substitute our hybrid sequences in
    ans = replace(ans,"B" => "BO"^O*"B", count=1)
    ans = replace(ans,"R" => "RG"^G*"R", count=1)
    ans = replace(ans,"Y" => "YV"^V*"Y", count=1)
    return ans
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,R,O,Y,G,B,V = gis()
        ans = solve(N,R,O,Y,G,B,V)
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

