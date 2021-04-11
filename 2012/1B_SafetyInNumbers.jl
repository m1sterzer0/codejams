
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

function enough(N::I,J::VI,X::I,idx::I,myfrac::F)::Bool
    oneoverx::F = 1.0 / X
    thresh::F = J[idx] + X * myfrac
    pool::F = 0.00
    for i in 1:N
        if J[i] > thresh; continue; end
        pool += (thresh-J[i]) * oneoverx
    end
    return pool > 1.00
end

## Binary search for the score for each person
## We know that getting all of the audience votes gives you half of the total, so 1.00 always works
## Multiply by 100 at end to get percentages 
function solveSmall(N::I,J::VI)::String
    X::I = sum(J)
    ansarr::VF = []
    for i in 1:N
        if enough(N,J,X,i,0.00); push!(ansarr,0.00); continue; end
        l::F,u::F = 0.0,1.0
        for j in 1:30
            m::F = 0.5*(l+u)
            if enough(N,J,X,i,m); u = m; else; l = m; end
        end
        push!(ansarr,100*0.5*(l+u))
    end
    ansstr = join(ansarr," ")
    return ansstr
end

## Linear solution
## Total points == 2 * sum(J)
## Sort players from highest to lowest score
## For a player not to be eliminated, his point threshold is totPointsLeft/numPlayersLeft
##     * If a player is already over the threshold without adding audience points,
##       then we subtract out that players points and player count from the total.
##     * Otherwise, we calc the required audience threshold and allocate.
##       Note that once we find the first player that needs audience points to hit his threshold,
##       the threshold never changes.
function solveLarge(N::I,J::VI)
    ansarr::VF = fill(0.00,N)
    sb::Vector{Tuple{F,I}} = []
    for i in 1:N; push!(sb,(J[i],i)); end
    sort!(sb,rev=true)
    audiencepoints = sum(J)
    pointsleft = 2*audiencepoints
    playersleft = N
    for (curscore,j) in sb
        thresh::F = pointsleft/playersleft
        if curscore > thresh
            ansarr[j] = 0.00
            pointsleft -= curscore
            playersleft -= 1
        else
            ansarr[j] = 100.0 * (thresh-curscore) / audiencepoints
        end
    end
    ansstr = join(ansarr," ")
    return ansstr
end

function gencase(Nmin::I,Nmax::I)
    N = rand(Nmin:Nmax)
    J::VI = fill(0,N)
    while sum(J) == 0; J = rand(0:100,N); end
    return (N,J)
end

function isApproximatelyEqual(x::F,y::F,epsilon::F)::Bool
    if -epsilon <= x - y <= epsilon; return true; end
    if -epsilon <= x <= epsilon || -epsilon <= y <= epsilon; return false; end
    if -epsilon <= (x - y) / x <= epsilon; return true; end
    if -epsilon <= (x - y) / y <= epsilon; return true; end
    return false
end

function test(ntc::I,Nmin::I,Nmax::I,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (N,J) = gencase(Nmin,Nmax)
        ans2 = solveLarge(N,J)
        if check
            ans1 = solveSmall(N,J)
            match = true
            ans1arr = [parse(Float64,x) for x in split(ans1)]
            ans2arr = [parse(Float64,x) for x in split(ans2)]
            if length(ans1arr) != N || length(ans2arr) != N
                match = false
            else
                for i in 1:N
                    if !isApproximatelyEqual(ans1arr[i],ans2arr[i],1e-7); match = false; end
                end
            end
            if match
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(N,J)
                ans2 = solveLarge(N,J)
            end
       else
           print("Case $ttt: $ans2\n")
       end
    end
    if check; print("$pass/$ntc passed\n"); end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        J::VI = gis()
        N::I = popfirst!(J)
        #ans = solveSmall(N,J)
        ans = solveLarge(N,J)
        print("$ans\n")
    end
end

Random.seed!(8675309)
#test(1000,2,10)
#test(1000,2,200)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

