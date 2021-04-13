
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
### Key observation
### * So that we work with integers, we reformulate and assume we get one coin per game, a reroll costs game
###   coins, and we are capped at RG coins.
### * We want to optimize the states sequentially, as the crossproduct will become unweildy.
### * When given a choice, we will either play the game and move onto the next money state (except
###   when capped), or reroll and have to traverse through (at least) G states before coming back.
### * We need to come up with a figure of merit for each state as a function of its own probability
###   and (perhaps) the probabilities of the previous states in the moneychain 
### * What quantity should we optimize for?  The obvious metrics have problems
###   -- Total wins between state entry and state exit to state n+1 doesn't take into account state losses.
###   -- Win percentage doesn't keep track of the number of games played
### * (VERY HARD) Key insight here is equivalent to the concept of "par" in golf
###   -- We are going to binary search on our maximum achievable win percentage
###   -- We are going to call our current query a "target par" which we label as Q
###   -- We are going to keep track of our excess/deficit wins relative to winning steadily at the rate Q
###      -- This integration of games fixes both of the two problems above.
###   -- For each state S, we are going to consider the set SS of games played between the time of entering
###      state S and the time of entering state S+1.  Over all these possible sets, we are going to calculate
###      (wins - Q * games) and calculate an expected value A[S] for this quantity.
###   -- For states where we have no choice, A[S] = AvgWinProb(all champions) - Q.
###   -- For states where we have a choice (S >= G), consider we reroll on bottom K_S champions.
###      Then A[S] = (N-K_S)/N * (AvgWinProb(top N-K_S champions)-Q) + K_S/N * (A[S-G]+A[S-G+1]+...+A[S])
###   -- OPEN QUESTION: Should we ever stochastically choose?  For now, assume no, but not convinced yet.
######################################################################################################

function tryit(Q::F,avgtopk::VF,N::I,R::I,G::I)::Bool
    if N == 1; return avgtopk[N] > Q; end
    A::VF = []
    for i in 0:G-1; push!(A,avgtopk[N]-Q); end
    for i in G:R*G
        idx = i+1
        sumprev::F = sum(A[idx-G:idx-1])
        best::F = -1e100
        for j in 1:N-1 ## If N > 1, always reroll worst, never reroll best
            probReroll::F = Float64(j)/Float64(N)
            candidate::F = probReroll / (1.0 - probReroll) * sumprev + (avgtopk[N-j]-Q)
            best = max(best,candidate)
        end
        push!(A,best)
    end
    return A[end] >= 0
end

function solve(N::I,R::I,G::I,prechamps::VF)
    champs::VF = copy(prechamps)
    sort!(champs,rev=true)
    avgtopk::VF = fill(0.00,N)
    ss::F = 0.0
    for i in 1:N
        ss += champs[i]
        avgtopk[i] = ss / Float64(i)
    end

    Qmin,Qmax = 0.00,1.000
    for i in 1:50
        Qmid = (Qmin+Qmax)*0.5
        if tryit(Qmid,avgtopk,N,R,G); Qmin = Qmid
        else; Qmax = Qmid
        end
    end
    return Qmin
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,R,G = gis()
        champs::VF = gfs()
        ans = solve(N,R,G,champs)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()

