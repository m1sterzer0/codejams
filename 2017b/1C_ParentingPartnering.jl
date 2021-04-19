
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

#########################################################################################################
### 1) Because the time of the day is just a circle, we can start counting at the earliest apppointment
### 2) All intervals break down into 5 possibilities
###    -- C must have baby
###    -- J must have baby
###    -- C|J can have baby with no change to the answer (i.e. this interval is between a "C must have baby" and "J must have baby")
###    -- prefer for C to have baby (costs 2 transitions to give baby to J)
###    -- prefer for J to have baby (costs 2 transitions to give baby to C)
### 3) This leads to the following algorithm
###    -- Construct all of the intervals and calculate the minimum number of forced transitions
###    -- For each of C & J (in the example below, lets assume C)
###       * Start with the minimum number of transitions
###       * Count the "C must have baby" time + "Prefer C" time + "C|J" time
###       * While that is < 720 minutes
###         Add 2 transitions
###         Add the largest element left from the "prefer J" list
###    -- The answer is the maximum of running that algorithm with C vs. running it with J
#########################################################################################################

function solve(Ac::I,Aj::I,C::VI,D::VI,J::VI,K::VI)::I
    if Ac == 0 && Aj == 0; return 2; end
    
    ## Intervals
    intervals::Vector{Tuple{I,I,Char}} = vcat([(C[i],D[i],'c') for i in 1:Ac],
                                              [(J[i],K[i],'j') for i in 1:Aj])
    sort!(intervals)
    cpref::VI = []
    jpref::VI = []
    csum::I,jsum::I = 0,0
    minTransitions::I = 0
    for (i,ii1) in enumerate(intervals)
        if ii1[3] == 'c'; csum += (ii1[2]-ii1[1]); end
        if ii1[3] in 'j'; jsum += (ii1[2]-ii1[1];) end
        ii2::Tuple{I,I,Char} = (i == length(intervals)) ? intervals[1] : intervals[i+1]
        gapTime::I = (ii2[1] + 1440 - ii1[2]) % 1440
        if      ii1[3] != ii2[3]; csum += gapTime; jsum += gapTime; minTransitions += 1
        elseif  ii1[3] == 'c'; csum += gapTime; push!(cpref,gapTime)
        elseif  ii1[3] == 'j'; jsum += gapTime; push!(jpref,gapTime)
        end
    end
    sort!(cpref); sort!(jpref)
    best::I = minTransitions
    for (xsum::I,xpref::VI) in [(csum,jpref),(jsum,cpref)]
        current = minTransitions
        while(xsum < 720)
            current += 2
            xsum += pop!(xpref)
        end
        best = max(best,current)
    end
    return best
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        Ac,Aj = gis()
        C::VI = fill(0,Ac)
        D::VI = fill(0,Ac)
        J::VI = fill(0,Aj)
        K::VI = fill(0,Aj)
        for i in 1:Ac; C[i],D[i] = gis(); end
        for i in 1:Aj; J[i],K[i] = gis(); end
        ans = solve(Ac,Aj,C,D,J,K)
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

