
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
### After a bit of reasoning, we see that there are only 5 possible patterns that each
### take up a set of full rows that are possible, with some additional stacking restricitons
### -- 2 rows of '3's
### -- 1 row of '2's 
### -- Alternating 2x2 squares of 2s with a vertical 1's "domino"
###    (need C multiple of 3)
###
###     221221221221221221221221...
###     221221221221221221221221...
###
### -- A 2 row pattern of a 'snake' of 2s around staggered horizontal dominoes
###    (need C multiple of 6)
###
###    222112222112222112222112...
###    112222112222112222112222..
###
### -- A 3 row pattern of a 'snake' of 2s around staggered vertical dominoes
###    (need C multiple of 4)
###
###     2122212221222122212221222122...
###     2121212121212121212121212121...
###     2221222122212221222122212221...
###
###  Furthermore, the patterns with 2's cannot border each other
######################################################################################################
function solve(R::I,C::I)::I
    m = 1_000_000_007
    dp::Array{I,3} = fill(0,R,12,3)
    dp[1,1,2] = 1 ## Row of 2s
    dp[2,1,3] = 1 ## 2 Rows of 3s
    if C % 3 == 0; dp[2,3,2] = 3; end
    if C % 6 == 0; dp[2,6,2] = 6; end
    if C % 4 == 0 && R >=3; dp[3,4,2] = 4; end
    lcm3 = [lcm(3,x) for x in 1:12]
    lcm4 = [lcm(4,x) for x in 1:12]
    lcm6 = [lcm(6,x) for x in 1:12]

    for i in 1:R-1
        for rpt in [1,3,4,6,12]
            if dp[i,rpt,2] > 0 && i+2 <= R
                dp[i+2,rpt,3] = (dp[i+2,rpt,3] + dp[i,rpt,2]) % m
            end
            if dp[i,rpt,3] == 0; continue; end
            dp[i+1,rpt,2] = (dp[i+1,rpt,2] + dp[i,rpt,3]) % m

            if C % 3 == 0 && i+2 <= R
                dp[i+2,lcm3[rpt],2] = ( ((3 * dp[i,rpt,3]) % m) + dp[i+2,lcm3[rpt],2]) % m
            end

            if C % 6 == 0 && i+2 <= R
                dp[i+2,lcm6[rpt],2] = ( ((6 * dp[i,rpt,3]) % m) + dp[i+2,lcm6[rpt],2]) % m
            end

            if C % 4 == 0 && i+3 <= R
                dp[i+3,lcm4[rpt],2] = ( ((4 * dp[i,rpt,3]) % m) + dp[i+3,lcm4[rpt],2]) % m
            end
        end
    end

    ans = 0
    for rpt in [1,3,4,6,12]
        inv = invmod(rpt,m) 
        for e in [2,3]
            ans = (ans + ((inv * dp[R,rpt,e]) % m)) % m
        end
    end
    return ans
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        R,C = gis()
        ans = solve(R,C)
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

