
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
### We use a little dynamic programming.  We calulate the following three values from right to left
###     ## most positive difference we can make from the last N digits
###     ## most negative difference we can make from the last N digits
###     ## closest absolute value that we can make from the right digits
###
### We then make a pass from left to right to choose the digits, given the prioritization.
######################################################################################################

function solveit(pv::I,c::I,j::I,pos::I,neg::I,closest::I)
    if c != -1 && j != -1
        adder::I = c > j ? neg : c < j ? pos : closest
        return abs(pv*(c-j) + adder)
    elseif j != -1
        c1::I = j == 0 ? 10^18 : abs(-pv+pos)
        c2::I = j == 9 ? 10^18 : abs(pv+neg)
        return min(c1,c2,closest)
    elseif c != -1
        c1 = c == 9 ? 10^18 : abs(-pv+pos)
        c2 = c == 0 ? 10^18 : abs(pv+neg)
        return min(c1,c2,closest)
    else
        return min(abs(pv+neg),abs(-pv+pos),closest)
    end 
end

function solveit2(pv::I,c::I,j::I,myclosest::I,pos::I,neg::I,closest::I)
    ## Prority is to choose c < j, then c == j, then c > j
    if c != -1 && j != -1
        return (c < j ? 1 : c > j ? -1 : 0, c, j)
    elseif j != -1
        ## Priority here is for the lowest c
        if     j != 0 && myclosest == abs(-pv + pos); return (1,j-1,j)
        elseif closest == myclosest;                  return (0,j,j)
        else;                                         return (-1,j+1,j)            
        end
    elseif c != -1
        ## Priority here is for the lowest j
        if     c != 0 && myclosest == pv + neg;  return (-1,c,c-1)
        elseif closest == myclosest;             return (0,c,c)
        else;                                    return (1,c,c+1)            
        end
    else
        ## Priority here is for (c,j) = (0,0), then (0,1), and finally (1,0)
        if     closest == myclosest;             return (0,0,0)
        elseif myclosest == abs(-pv+pos);        return (1,0,1)
        else;                                    return (-1,1,0)
        end
    end
end

function solveLarge(C::String,J::String)
    Cdig::VI = [x == '?' ? -1 : parse(Int64,x) for x in C]
    Jdig::VI = [x == '?' ? -1 : parse(Int64,x) for x in J]

    numdig::I = length(C)
    mostPos::VI = fill(0,numdig)
    mostNeg::VI = fill(0,numdig)
    closest::VI = fill(0,numdig)

    ### Pass from right to left
    pv::I = 1; runningPos::I = 0; runningNeg::I = 0; runningClosest::I = 0
    for i in numdig:-1:1
        runningClosest = solveit(pv,Cdig[i],Jdig[i],runningPos,runningNeg,runningClosest)
        runningPos += pv * (( Cdig[i] == -1 ? 9 : Cdig[i]) - (Jdig[i] == -1 ? 0 : Jdig[i]))
        runningNeg += pv * (( Cdig[i] == -1 ? 0 : Cdig[i]) - (Jdig[i] == -1 ? 9 : Jdig[i]))
        mostPos[i],mostNeg[i],closest[i] = runningPos,runningNeg,runningClosest
        pv *= 10
    end
    
    ### Now we pass from left to right to chose the digits
    Cans::VI = fill(0,numdig)
    Jans::VI = fill(0,numdig)
    dir::I = 0
    pv = 10^(numdig-1)
    for i::I in 1:numdig
        if dir == 1
            Cans[i] = Cdig[i] == -1 ? 9 : Cdig[i]
            Jans[i] = Jdig[i] == -1 ? 0 : Jdig[i]
        elseif dir == -1
            Cans[i] = Cdig[i] == -1 ? 0 : Cdig[i]
            Jans[i] = Jdig[i] == -1 ? 9 : Jdig[i]
        else
            dir,Cans[i],Jans[i] = solveit2(pv,Cdig[i],Jdig[i],closest[i],
                                           i == numdig ? 0 : mostPos[i+1],
                                           i == numdig ? 0 : mostNeg[i+1],
                                           i == numdig ? 0 : closest[i+1])
        end
        pv = pv ÷ 10
    end

    Cstr = join(Cans,"")
    Jstr = join(Jans,"")
    return "$Cstr $Jstr"
end

function getPossibilities(C::String)
    N::I = length(C)
    ans::VI = []
    for i in 0:10^N-1
        si = lpad(i,N,"0")
        good = true
        for (j,c) in enumerate(si)
            if C[j] != '?' && C[j] != c; good = false; break; end
        end
        if good; push!(ans,i); end
    end
    return ans
end

function solveSmall(C::String,J::String)
    carr = getPossibilities(C)
    jarr = getPossibilities(J)
    best::I,bestC::I,bestJ::I = 1_000_000,0,0
    for (c,j) in Iterators.product(carr,jarr)
        if abs(c-j) < best || abs(c-j) == best && c < bestC || abs(c-j) == best && c == bestC && j < bestJ
            best = abs(c-j); bestC = c; bestJ = j
        end
    end
    cstr::String = lpad(bestC,length(C),"0")
    jstr::String = lpad(bestJ,length(J),"0")
    return "$cstr $jstr"
end

function gencase(Nmin::I,Nmax::I)
    N = rand(Nmin:Nmax)
    carr::VC = []
    jarr::VC = []
    dq,sq,same,diff = rand(),rand(),rand(),rand()
    s = dq+sq+same+diff
    dq /= s; sq = dq + sq/s; same = dq + same/s; diff = 1.00
    for i in 1:N
        x = rand()
        if x < dq; push!(carr,'?'); push!(jarr,'?')
        elseif x < sq
            if rand() < 0.5; push!(carr,'?'); push!(jarr,'0'+rand(0:9))
            else;            push!(jarr,'?'); push!(carr,'0'+rand(0:9))
            end
        elseif x < same
            c = '0' + rand(0:9); push!(carr,c); push!(jarr,c)
        else
            push!(carr,'0'+rand(0:9))
            push!(jarr,'0'+rand(0:9))
        end
    end
    return (join(carr),join(jarr))
end

function test(ntc::I,Nmin::I,Nmax::I,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (C,J) = gencase(Nmin,Nmax)
        ans2 = solveLarge(C,J)
        if check
            ans1 = solveSmall(C,J)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt C:$C J:$J ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(C,J)
                ans2 = solveLarge(C,J)
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
        C,J = gss()
        #ans = solveSmall(C,J)
        ans = solveLarge(C,J)
        print("$ans\n")
    end
end

Random.seed!(8675309)
#test(10000,1,3)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

