
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

function solveSmall(X::I,Y::I,S::String)
    inf = 1_000_000_000_000_000_000
    N::I = length(S)
    ans = inf
    for mask in 0:2^N-1
        cc::Vector{Char} = [mask & (1 << (i-1)) == 0 ? 'C' : 'J' for i in 1:N]
        lans = 0
        for i in 1:N
            if cc[i] == 'C' && S[i] == 'J'; lans = inf; break; end
            if cc[i] == 'J' && S[i] == 'C'; lans = inf; break; end
            if i == 1; continue; end
            if cc[i-1] == 'C' && cc[i] == 'J'; lans += X; end
            if cc[i-1] == 'J' && cc[i] == 'C'; lans += Y; end
        end
        ans = min(ans,lans)
    end
    return ans
end

function solveLarge(X::I,Y::I,S::String)
    N::I = length(S)
    inf = 1_000_000_000
    dp::Array{I,2} = fill(0,N,2)
    ## dp[i,1] represents the best we can do if the ith character is a 'C'
    ## dp[i,2] represents the best we can do if the ith character is a 'J'
    dp[1,1] = S[1] == 'J' ? inf : 0
    dp[1,2] = S[1] == 'C' ? inf : 0
    for i in 2:N
        dp[i,1] = min(dp[i-1,1],dp[i-1,2]+Y)
        dp[i,2] = min(dp[i-1,2],dp[i-1,1]+X)
        if S[i] == 'C'; dp[i,2] = inf; end
        if S[i] == 'J'; dp[i,1] = inf; end
    end
    return min(dp[N,1],dp[N,2])
end

function gencase(Nmin::I,Nmax::I,Cmin::I,Cmax::I)
    qchance::F = rand()
    cchance::F = rand()
    N = rand(Nmin:Nmax)
    carr::Vector{Char} = [rand() < qchance ? '?' : rand() < cchance ? 'C' : 'J' for i in 1:N]
    L::String = join(carr,"")
    X = rand(Cmin:Cmax)
    Y = rand(Cmin:Cmax)
    return (X,Y,L)
end

function test(ntc::I,Nmin::I,Nmax::I,Cmin::I,Cmax::I,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (X,Y,L) = gencase(Nmin,Nmax,Cmin,Cmax)
        ans2 = solveLarge(X,Y,L)
        if check
            ans1 = solveSmall(X,Y,L)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(X,Y,L)
                ans2 = solveLarge(X,Y,L)
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
        sx,sy,S = gss()
        X = parse(Int64,sx)
        Y = parse(Int64,sy)
        #ans = solveSmall(X,Y,S)
        ans = solveLarge(X,Y,S)
        print("$ans\n")
    end
end

Random.seed!(8675309)
#test(10000,4,16,1,100)
#test(10000,4,16,-100,100)
#test(1000,4,1000,-100,100,false)
main()
