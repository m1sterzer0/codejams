
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

function doit(L::VI, swapsSoFar::I)::I
    if length(L) == 2; return L[1] < L[2] ? factorial(swapsSoFar) : factorial(swapsSoFar+1); end
    bi1,bi2 = 0,0
    for i in 1:2:length(L)
        if L[i] % 2 == 1 && L[i+1] == L[i] + 1; continue; end
        if bi2 > 0; return 0
        elseif bi1 > 0; bi2 = i
        else; bi1 = i
        end
    end
    if bi1 == 0 
        return doit([x ÷ 2 for x in L[2:2:end]],swapsSoFar)
    elseif bi2 == 0
        LL = L[:]
        LL[bi1],LL[bi1+1] = LL[bi1+1],LL[bi1]
        return doit([x ÷ 2 for x in LL[2:2:end]],swapsSoFar+1)
    else
        a,b,c,d = L[bi1],L[bi1+1],L[bi2],L[bi2+1]
        if d % 2 == 1 && c % 2 == 1 && b == d+1 && a == c+1 ## Case is [a,b] [c,d] --> [d,b] [c,a]
            LL = L[:]
            LL[bi1],LL[bi1+1],LL[bi2],LL[bi2+1] = d,b,c,a
            return doit([x ÷ 2 for x in LL[2:2:end]],swapsSoFar+1)
        elseif a % 2 == 1 && b % 2 == 1 && c == a+1 && d == b+1 ## Case is [a,b] [c,d] --> [a,c] [b,d]
            LL = L[:]
            LL[bi1],LL[bi1+1],LL[bi2],LL[bi2+1] = a,c,b,d
            return doit([x ÷ 2 for x in LL[2:2:end]],swapsSoFar+1) 
        elseif c % 2 == 1 && a % 2 == 1 && b == c+1 && d == a+1  ## Case is [a,b] [c,d] --> [c,b] [a,d] or [a,d] [c,b]
            LL = L[:]
            LL[bi1],LL[bi1+1],LL[bi2],LL[bi2+1] = c,b,a,d
            ans1 = doit([x ÷ 2 for x in LL[2:2:end]],swapsSoFar+1)
            LL = L[:]
            LL[bi1],LL[bi1+1],LL[bi2],LL[bi2+1] = a,d,c,b
            ans2 = doit([x ÷ 2 for x in LL[2:2:end]],swapsSoFar+1)
            return ans1 + ans2
        else
            return 0
        end
    end
end

function solve(N::I,L::VI)
    return doit(L,0)
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        L::VI = gis()
        ans = solve(N,L)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()

