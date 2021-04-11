
using Random
infile = stdin
## Type Shortcuts (to save my wrists and fingers :))
const I = Int64; const VI = Vector{I}; const SI = Set{I}; const PI = NTuple{2,I};
const TI = NTuple{3,I}; const QI = NTuple{4,I}; const VPI = Vector{PI}; const SPI = Set{PI}
const F = Float64; const VF = Vector{F}; const PF = NTuple{2,F}

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
            if ans1 == ans2
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

function weightedRandChoice(seq,weights::VF,nn::I)
    cumweights::VF = [weights[1]]
    for i in 2:length(weights); push!(cumweights,cumweights[end]+weights[i]); end
    res = []
    for i in 1:nn; push!(res,seq[min(length(seq),searchsortedfirst(cumweights,cumweights[end]*rand()))]); end
    return res
end

