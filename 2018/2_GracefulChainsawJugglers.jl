
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
### * It never makes sense to give 1 juggler more than 31 chain saws of one color, since 1+2+...+32 = 528 
### * We can set up a quick DP here, where DP[red][blue][j] is the best we can do restricting ourself
###   to jugglers with less than or equal to j red chain saws. (There are other ways to set up
###   the DP too).
### * The DP is a bit expensive, but we only have to run it once.
### * Dealing with the one indexing is a bit tricky
######################################################################################################

function solve(R::I,B::I,working)::I
    (dp::Array{I,2},) = working
    return dp[R+1,B+1]-1 ## Have to subtract off 0,0 case
end

function prework()
    ##Do the DP
    dp::Array{I,2}     = fill(0,501,501)
    dplast::Array{I,2} = fill(0,501,501)
    triang::VI  = [(i-1)*i ÷ 2 for i in 1:33]
    for i in 0:31
        dplast .= dp
        for n::I in 1:32
            tr::I,tb::I = i*n,triang[n]
            for r::I in tr:500
                for b::I in tb:500
                    dp[r+1,b+1] = max(dp[r+1,b+1],n+dplast[r-tr+1,b-tb+1])
                end
            end
        end
    end
    return (dp,)
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    working = prework()
    for qq in 1:tt
        print("Case #$qq: ")
        R,B = gis()
        ans = solve(R,B,working)
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

