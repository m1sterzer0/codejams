
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

comb(n::I,k::I)::BigInt = k < 0 ? 0 : 
                          k == 0 ? 1 :
                          k == 1 ? n :
                          k < n ? comb(n,k-1) * (n-k+1) ÷ k :
                          k == n ? 1 : 0  

function nn(d::I,A::I,B::I)::BigInt
    ans::BigInt = 0
    if d < A; return 1; end
    ## Part 1: Count the number of valid strings that end in a right
    ## This equals the number of prefixes that consume more than
    ## d-(A+B) days but no more than (d-A) days

    for r::I in 0:50
        drem = d - r*B
        if drem < A; break; end
        lmin = (drem-A-B) < 0 ? 0 : (drem-A-B) ÷ A + 1 
        lmax = (drem-A) ÷ A
        if lmax < lmin; continue;
        elseif lmax == lmin; ans += comb(lmin+r,r)
        else
            ans += comb(lmax+r+1,r+1)  ## Using hockey stick identity
            ans -= comb(lmin+r,r+1)    ## Using hockey stick identity
        end
    end

    ## Part 2: Count the number of valid strings that end in a left
    ## This equals the number of prefixes that consume more than
    ## (d-2A) days but no more than (d-A) days. Remainder theorem
    ## coveres the (d-2A) case.
    for r::I in 0:50
        drem = d - r*B
        if drem < A; break; end
        lnum = (drem-A) ÷ A
        ans += comb(lnum+r,r)
    end
    return ans
end


function solveSmall(N::I,A::I,B::I)
    ## consider the function NN(d) which tells us the maximum number
    ## of foods we can resolve given d days.  Then we have
    ## * NN(0) = 1
    ## * for d < A, NN(d) = 1
    ## * for a <= d < B, NN(d) = N(d-A) + 1
    ## * for d >= B, NN(d) = NN(d-A) + NN(d-B)
    ## * Finally, NN(d) >= 2^(d/B)
    ##   -- For B <= 100, this means NN(50*100) >= NN(50*B) >= 2^50 >= 10^15
    ## This gives us a simple DP to solve the small
    nn::VI = fill(0,5001)
    for d in 0:5000
        if d < A; nn[d+1] = 1
        elseif d < B; nn[d+1] = 1 + nn[d-A+1]
        else; nn[d+1] = nn[d-A+1]+nn[d-B+1]
        end
        if d == 5000 || nn[d+1] >= N; return d; end
    end
end

function solveLarge(N::I,A::I,B::I)
    if N == 1; return 0; end
    dmin,dmax = 0,50*B
    Nbig = BigInt(N)
    while(dmax-dmin>1)
        m = (dmin+dmax)÷2
        if nn(m,A,B) >= Nbig; dmax = m
        else; dmin = m
        end
    end
    return dmax
end

function gencase(Nmin::I,Nmax::I)
    ee::I = rand(0:14)
    N = rand(Nmin:Nmax)
    A = rand(1:100)
    B = rand(A:100)
    return (N,A,B)
end

function test(ntc::I,Nmin::I,Nmax::I,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (N,A,B) = gencase(Nmin,Nmax)
        ans2 = solveLarge(N,A,B)
        if check
            ans1 = solveSmall(N,A,B)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(N,A,B)
                ans2 = solveLarge(N,A,B)
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
        N,A,B = gis()
        #ans = solveSmall(N,A,B)
        ans = solveLarge(N,A,B)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
#test(1000,1,1_000)
#test(1000,1_000,1_000_000)
#test(1000,1_000_000,1_000_000_000)
#test(1000,1_000_000_000,1_000_000_000_000)
#test(1000,1_000_000_000_000,1_000_000_000_000_000)

