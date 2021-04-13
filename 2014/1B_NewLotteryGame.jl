
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

function solveSmall(A::I,B::I,K::I)::I
    ans::I = 0
    for a in 0:A-1
        for b in 0:B-1
            if a & b < K; ans += 1; end
        end
    end
    return ans
end

function solveplace(Alim::Int64,Blim::Int64,Klim::Int64,p::Int64,cache::Dict{Tuple{Int64,Int64,Int64,Int64},Int64})::Int64
    pv = 1 << p
    maxgen = 2*pv-1
    if Alim >= maxgen && Blim >= maxgen && Klim >= maxgen; return 2^(2*p+2); end
    Alim = min(Alim,maxgen)
    Blim = min(Blim,maxgen)
    Klim = min(Klim,maxgen)
    if !haskey(cache,(Alim,Blim,Klim,p))
        ans::I = 0
        if p == 0
            ans += 1
            if Alim >= pv; ans += 1; end
            if Blim >= pv; ans += 1; end
            if Alim >= pv && Blim >= pv && Klim >= pv; ans += 1; end
        else
            ans += solveplace(Alim,Blim,Klim,p-1,cache)
            if Alim >= pv;                             ans += solveplace(Alim-pv,Blim,Klim,p-1,cache); end
            if Blim >= pv;                             ans += solveplace(Alim,Blim-pv,Klim,p-1,cache); end
            if Alim >= pv && Blim >= pv && Klim >= pv; ans += solveplace(Alim-pv,Blim-pv,Klim-pv,p-1,cache); end
        end
        cache[(Alim,Blim,Klim,p)] = ans
    end
    return cache[(Alim,Blim,Klim,p)]
end

function solveLarge(A::I,B::I,K::I)::I
    cache::Dict{QI,I} = Dict{QI,I}()
    ans = solveplace(A-1,B-1,K-1,31,cache)
end

function gencase(Amax::I,Bmax::I,Kmax::I)
    A = rand(1:Amax)
    B = rand(1:Bmax)
    K = rand(1:Kmax)
    return (A,B,K)
end

function test(ntc::I,Amax::I,Bmax::I,Kmax::I,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (A,B,K) = gencase(Amax,Bmax,Kmax)
        ans2 = solveLarge(A,B,K)
        if check
            ans1 = solveSmall(A,B,K)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(A,B,K)
                ans2 = solveLarge(A,B,K)
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
        A,B,K = gis()
        #ans = solveSmall(A,B,K)
        ans = solveLarge(A,B,K)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
#test(1000,1000,1000,1000)

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

