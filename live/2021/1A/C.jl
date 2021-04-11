
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

function solve(N::I,Q::I,A::VS,S::VI)::String
    ## Here we just 
    teststr = ""
    resstr = ""
    if N == 1
        if 2 * S[1] >= Q
            teststr = A[1]
            resstr = "$(S[1])/1"
        else
            teststr = join([A[1][i] == 'T' ? 'F' : 'T' for i in 1:Q],"")
            resstr = "$(Q-S[1])/1"
        end
    elseif N == 2
        ## For the questions where we are the same, the choice is copy or anticopy
        ## For the questions where we are different, the choice is between the smart person and the dumb person
        samecnt = count(x->x,[A[1][i] == A[2][i] for i in 1:Q])
        diffcnt = Q - samecnt
        
        ## Let a == number of samecnt correct
        ## Let b == number of diffcnt correct by player 1
        ## a + b = S[1]
        ## a + (diffcnt-b) = S[2]
        ## Summing --> 2a + diffcnt = S[1] + S[2] --> 2a = S[1] + S[2] - diffcnt --> a = 1/2 (S[1] + S[2] - diffcnt)
        a = (S[1] + S[2] - diffcnt) ÷ 2
        b1 = S[1] - a
        b2 = S[2] - a

        diffplayer = S[1] > S[2] ? 1 : 2
        oppflag = S[1] + S[2] - diffcnt < samecnt
        expected = max(a,samecnt-a) + max(b1,b2)
        resarr::Vector{Char} = []
        for i in 1:Q
            if A[1][i] != A[2][i]; push!(resarr,A[diffplayer][i]); continue; end
            if oppflag; push!(resarr, A[1][i] == 'T' ? 'F' : 'T'); continue; end
            push!(resarr,A[1][i])
        end
        teststr = join(resarr,"")
        resstr = "$expected/1"
    else
        teststr = "F"^Q
        resstr = "$Q/1"
    end
    return "$teststr $resstr"
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,Q = gis()
        A::VS = []
        S::VI = []
        for i in 1:N
            xx = gss()
            push!(S,parse(Int64,xx[2]))
            push!(A,xx[1])
        end
        ans = solve(N,Q,A,S)
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

