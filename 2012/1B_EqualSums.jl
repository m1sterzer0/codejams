
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

## 2^20 subsets possible subsets, and max sum is 1e6, so it seems we may not be able to find an answer.
## HOWEVER, 1,2,4,8,...,2^16 cover all possible numbers, so last 4 elements must be contained in some subset.
## 10 testcases and 60s should afford brute force opportunity here with simple linear storage
function solveSmall(N::I,S::VI)::Tuple{VI,VI}
    found::VI = fill(0,2000000)
    for i in 1:2^N-1 ## Skip empty subset
        s::I = 0
        for j in 1:N; if i & (1 << (j-1)) != 0; s += S[j]; end; end
        if found[s] == 0; found[s] = i; continue; end
        ## We found our answer
        a::VI = []; for j in 1:N; if i & (1 << (j-1)) != 0; push!(a,S[j]); end; end
        b::VI = []; for j in 1:N; if found[s] & (1 << (j-1)) != 0; push!(b,S[j]); end; end
        return (a,b)
    end
    return ([],[])
end

## For the large, the algorithm doesn't work for the small, so we need to defer to the small
## for the smaller case.  For the larger case, this is a "Birthday Paradox" sort of problem.
## ASSUME subset sums are uniformly distributed over their range (pessimistic)
## From wiki, prob of match is approximately 1 - exp(-n^2/(2*range))
## Size of sums     Num subsets   Range of Sums  Guaranteed Overlap            100k   300k     1M    3M     10M
## --------------   -----------   -------------  ------------------            -----  -----  -----  -----  -----
## 1 element sums     500            1e12             NO                
## 2 element sums     125e3          2e12             NO
## 3 element sums     20e6           3e12             NO
## 4 element sums     2.5e9          4e12             NO
## 5 element sums     2.55e11        5e12             NO (but pessimistic)
## 6 element sums     2.11e13        6e12             YES                      0.08%  0.74%  8.00%  52.8%  99.9% 
function encodeArray(a::VI)::I
    ans::I = 0; pv::I = 1
    for i in 1:6; ans += a[i]*pv; pv *= 1000; end
    return ans
end

function decodeArray(S::VI,a::I)::VI
    ans::VI = []
    for i in 1:6; idx = a % 1000; push!(ans,S[idx]); a ÷= 1000; end
    return ans
end

function solveLarge(N::I,S::VI)::Tuple{VI,VI}
    if N == 20; return solveSmall(N,S); end
    d::Dict{I,I} = Dict{I,I}()
    numbers::VI = fill(0,6)
    while true
        empty!(d)
        for i in 1:10_000_000
            rand!(numbers,1:500)
            sort!(numbers)
            good = true
            for i in 1:5; if numbers[i] == numbers[i+1]; good = false; break; end; end
            if !good; continue; end
            s = sum(S[numbers[j]] for j in 1:6)
            enc::I = encodeArray(numbers)
            if haskey(d,s) && d[s] != enc
                a::VI = decodeArray(S,enc)
                b::VI = decodeArray(S,d[s])
                return (a,b)
            else
                d[s] = enc
            end
        end
    end
end

function gencase(N::I,Smax::I)
    sans::Set{I} = Set{I}()
    while length(sans) != N; push!(sans,rand(1:Smax)); end
    ans::VI = [x for x in sans]
    shuffle!(ans)
    return (N,ans)
end

function test(ntc::I,N::I,Smax::I)
    pass = 0
    for ttt in 1:ntc
        (N,S) = gencase(N,Smax)
        (A,B) = solveLarge(N,S)
        s1 = sum(A)
        s2 = sum(B)
        if s1 != s2
            print("Case #$ttt: ERROR SUMS DO NOT MATCH. sa:$s1 sb:$s2 A:$A B:$B\n")
        else
            astr = join(A," ")
            bstr = join(B," ")
            print("Case $ttt:\n$astr\n$bstr\n")
        end
    end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        S::VI = gis()
        N::I = popfirst!(S)
        (A,B) = solveLarge(N,S)
        astr = join(A," ")
        bstr = join(B," ")
        print("Case #$qq:\n$astr\n$bstr\n")
    end
end

Random.seed!(8675309)
main()

#test(20,20,100_000)
#test(20,500,1_000_000_000_000)

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile test(1,20,100_000)
#Profile.clear()
#@profilehtml test(20,500,1_000_000_000_000)

