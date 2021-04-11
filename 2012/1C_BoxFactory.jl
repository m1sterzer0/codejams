
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

function solve(N::I,M::I,A::VI,AT::VI,B::VI,BT::VI)::I
    dp::Array{Int64,2} = fill(0,101,101)
    aa::VI = fill(0,101)
    bb::VI = fill(0,101)
    for i in 1:N; for j in 1:M
        val = max(dp[i+1,j],dp[i,j+1])  ##Either skip this collection of boxes, or skip this collection of toys
        if AT[i] == BT[j]  ## We match
            fill!(aa,0); fill!(bb,0)
            aa[i] = A[i]; bb[j] = B[j]
            for a in i-1:-1:1; aa[a] = aa[a+1] + (AT[a]==AT[i] ? A[a] : 0); end
            for b in j-1:-1:1; bb[b] = bb[b+1] + (BT[b]==BT[j] ? B[b] : 0); end
            for a in 1:i; for b in 1:j; val = max(val, dp[a,b] + min(aa[a],bb[b])); end; end
        end
        dp[i+1,j+1] = val
    end; end
    return dp[N+1,M+1]
end

function gencase(Nmin::I,Nmax::I,Mmin::I,Mmax::I,BvalMax::I,TypesMin::I,TypesMax::I)
    N = rand(Nmin:Nmax)
    M = rand(Mmin:Mmax)
    numT = rand(TypesMin:TypesMax)
    A::VI = rand(1:BvalMax,N)
    AT::VI = rand(1:numT,N)
    B::VI = rand(1:BvalMax,M)
    BT::VI = rand(1:numT,M)
    return (N,M,A,AT,B,BT)
end

function test(ntc::I,Nmin::I,Nmax::I,Mmin::I,Mmax::I,BvalMax::I,TypesMin::I,TypesMax::I)
    for ttt in 1:ntc
        (N,M,A,AT,B,BT) = gencase(Nmin,Nmax,Mmin,Mmax,BvalMax,TypesMin,TypesMax)
        ans = solve(N,M,A,AT,B,BT)
        print("Case #$ttt: $ans\n")
    end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,M = gis()
        XX::VI = gis()
        YY::VI = gis()
        A::VI  = [XX[2i-1] for i in 1:N]
        AT::VI = [XX[2i]   for i in 1:N]
        B::VI  = [YY[2i-1] for i in 1:M]
        BT::VI = [YY[2i]   for i in 1:M]
        ans = solve(N,M,A,AT,B,BT)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()

#test(200,1,3,1,100,10_000_000_000_000_000,1,100)
#test(200,1,100,1,100,10_000_000_000_000_000,1,100)
#test(200,95,100,95,100,10_000_000_000_000_000,1,100)
#test(200,95,100,95,100,10_000_000_000_000_000,1,2)
#test(200,95,100,95,100,10_000_000_000_000_000,1,1)

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

