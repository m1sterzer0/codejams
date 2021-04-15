
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

function presolveSmall()
    sarr = zeros(Int64,1000000)
    rarr = zeros(Int64,1000000)
    larr = zeros(Int64,1000000)
    for i in 1:1000000
        sarr[i] = i
        larr[i] = length(string(i))
        rarr[i] = parse(Int64,lstrip(reverse(string(i)),['0']))
    end
    done = false
    passes = 1
    while (!done)
        #print(stderr,"Pass number $passes\n")
        done = true
        for i in 2:1000000
            if sarr[i-1] + 1 < sarr[i]
                done = false
                sarr[i] = sarr[i-1]+1
            end
            if larr[i] == larr[rarr[i]] && sarr[rarr[i]] + 1 < sarr[i]
                done = false
                sarr[i] = sarr[rarr[i]] + 1
            end
        end
        passes += 1
    end
    return sarr
end

function presolvePow10()
    sarr = zeros(Int64,15)
    sarr[1] = 1
    sarr[2] = 10
    for i in 3:15; sarr[i] = sarr[i-1] + (i%2==1 ? 10^((i-1)÷2) + 10^((i-1)÷2) - 1 : 10^(i÷2) + 10^(i÷2-1) - 1); end
    return sarr
end

function solveit(lhalf,rhalf)
    if parse(Int64,rhalf) == 0
        newlhalf = string(parse(Int64,lhalf)-1)  ## Will still have the same number of digits, since we already filtered out the 10^n case 
        return parse(Int64,reverse(newlhalf)) - 1 + 1 + 10^length(rhalf) ## We have to roll it over
    else
        return parse(Int64,reverse(lhalf)) - 1 + 1 + parse(Int64,rhalf)
    end
end

function solveSmall(N::I,workingSmall)::I
    (sarr,) = workingSmall
    return N > 1000000 ? 0 : sarr[N]
end

function solveLarge(N::I,workingLarge)::I
    (sarr,) = workingLarge
    ans::I = 0
    if N < 10  ## Do single digit case separately
        ans = N
    else
        strN = string(N)
        ndig = length(strN)
        baseans = sarr[ndig]
        ans = baseans
        if rstrip(strN,['0']) != "1" ## we need to do more moves if we are not a power of 10
            hndig = ndig ÷ 2
            ans = baseans + (N-10^(ndig-1))  ## option if we just count up to the number
            ans = min(ans, baseans + solveit(strN[1:hndig],strN[hndig+1:ndig]))
            if ndig % 2 == 1
                ans = min(ans, baseans + solveit(strN[1:hndig+1],strN[hndig+2:ndig]))
            end
        end
    end
    return ans
end

function gencase(Nmin::I,Nmax::I)
    N = rand(Nmin:Nmax)
    return (N,)
end

function test(ntc::I,Nmin::I,Nmax::I,check::Bool=true)
    sarrSmall = presolveSmall()
    sarrLarge = presolvePow10()
    pass = 0
    for ttt in 1:ntc
        (N,) = gencase(Nmin,Nmax)
        ans2 = solveLarge(N,(sarrLarge,))
        if check
            ans1 = solveSmall(N,(sarrSmall,))
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(N,(sarrSmall,))
                ans2 = solveLarge(N,(sarrLarge,))
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
    sarrSmall = presolveSmall()
    sarrLarge = presolvePow10()
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        #ans = solveSmall(N,(sarrSmall,))
        ans = solveLarge(N,(sarrLarge,))
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
#test(1000,1,1_000_000)

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

