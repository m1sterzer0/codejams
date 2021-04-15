
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
### -- If you run right/left from the origin, you must always stop on a quail before you turn around.
### -- If you run right/left, you must always run AT LEAST as far as the fastest quail before you turn
###    around, otherwise there was nothing gained by running that far (i.e. your time in that direction
###    would before limited either by the fastest quail or another quail beyond the faster quail, neither
###    of which were ameliorated by stopping early.)
### -- We realize that when we are at the origin, the current time and the identity of the fastest quail
###    not caught on either side is enough to fully specify the relevant details of the current state.
###    --- quails faster than the current fastest quail on each side have been caught already
###    --- quails slower than the current fastest and closer will be caught when we catch the fastest
###        and are thus irrelevant. 
######################################################################################################

struct quail; p0::I; s::I; end
Base.isless(a::quail,b::quail) = (a.s <= b.s) || (a.s == b.s) && (a.p0 < b.p0)

function solve(Y::I,N::I,P::VI,S::VI)
    leftQuail::Vector{quail} = []
    rightQuail::Vector{quail} = []
    for i in 1:N
        if P[i] > 0
            push!(rightQuail,quail(P[i],S[i]))
        else
            push!(leftQuail,quail(-P[i],S[i]))
        end
    end
    reverse!(sort!(leftQuail))
    reverse!(sort!(rightQuail))
    
    initialLeftFastest = length(leftQuail) > 0 ? 1 : 0
    initialRightFastest = length(rightQuail) > 0 ? 1 : 0

    scoreboard::Array{F,2} = fill(1e99,length(leftQuail)+1,length(rightQuail)+1)
    scoreboard[1,1] = 0.00

    for i in 0:length(leftQuail)
        for j in 0:length(rightQuail)
            starttime = scoreboard[i+1,j+1]
            if starttime >= 1e99; continue; end

            lastincr = 0.00
            for k in i+1:length(leftQuail)
                incr = (float(leftQuail[k].p0) + starttime * float(leftQuail[k].s)) / (float(Y)-float(leftQuail[k].s))
                if incr <= lastincr; continue; end
                if k-1 > i; scoreboard[k,j+1] = min(scoreboard[k,j+1],starttime+2*lastincr); end
                lastincr = incr
            end
            scoreboard[length(leftQuail)+1,j+1] = min(scoreboard[length(leftQuail)+1,j+1],starttime+(j == length(rightQuail) ? 1 : 2)*lastincr)

            ## Run right
            lastincr = 0.00
            for k in j+1:length(rightQuail)
                incr = (float(rightQuail[k].p0) + starttime * float(rightQuail[k].s)) / (float(Y)-float(rightQuail[k].s))
                if incr <= lastincr; continue; end
                if k-1 > j; scoreboard[i+1,k] = min(scoreboard[i+1,k],starttime+2*lastincr); end
                lastincr = incr
            end
            scoreboard[i+1,length(rightQuail)+1] = min(scoreboard[i+1,length(rightQuail)+1],starttime+(i == length(leftQuail) ? 1 : 2)*lastincr)
        end
    end
    ans = scoreboard[length(leftQuail)+1,length(rightQuail)+1]
    return ans
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        Y,N = gis()
        P::VI = gis()
        S::VI = gis()
        ans = solve(Y,N,P,S)
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

