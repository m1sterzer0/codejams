
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

function solve()
    return 0
end

function genInterestingCase()
    A::BigInt = BigInt(rand(2:100_000))
    B::BigInt = BigInt(rand(2:20))
    X::BigInt = BigInt(rand(1:B-1))
    Y::BigInt = BigInt(rand(1:A-1))
    Vx::BigInt = BigInt(rand(1:20))
    Vy::BigInt = BigInt(rand(1:999_999))
    M::BigInt = BigInt(rand(1:3))
    N::BigInt = BigInt(rand(1:3))
    newA = A * Vx
    for i in 1:1000
        Vy = rand(1:999_999)
        del1 = 2*B*Vy % newA
        if del1 ÷ (2*B*max(N,M)) >= 1; break; end
    end
    V = max(BigInt(1), (2*B*Vy % newA) ÷ (2*B*N) - rand(0:5))
    W = max(BigInt(1), (2*B*Vy % newA) ÷ (2*B*N) - rand(0:5))
    return (A,B,N,M,V,W,Y,X,Vy,Vx)
end

#function test(ntc::I,check::Bool=true)
#    pass = 0
#    for ttt in 1:ntc
#        (A) = gencase()
#        ans2 = solveLarge(A)
#        if check
#            ans1 = solveSmall(A)
#            if ans1 == ans2
#                 pass += 1
#            else
#                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
#                ans1 = solveSmall()
#                ans2 = solveLarge()
#            end
#       else
#           print("Case $ttt: $ans2\n")
#       end
#    end
#    if check; print("$pass/$ntc passed\n"); end
#end
function solveit2(twoA::BigInt,vdist::BigInt,l::BigInt,r::BigInt)
    if twoA-vdist < vdist; return solveit2(twoA,twoA-vdist,twoA-r,twoA-l); end
    q = l ÷ vdist
    base = q*vdist
    if base == l; return q; end
    if (base+vdist) <= r; return q+1; end

    q2 = twoA ÷ vdist
    base2 = q2 * vdist
    if base2 == twoA; return -1; end
    backward = twoA - base2
    newl,newr = l-base,r-base
    aa = solveit2(vdist,backward,vdist-newr,vdist-newl)
    if aa == -1; return -1; end
    finall,finalr = l+backward*aa,r+backward*aa
    adder = finall ÷ vdist
    if vdist*adder < finall; adder += 1; end
    return q2*aa+adder
end

function solveit(A::BigInt, B::BigInt, Y::BigInt, Vy::BigInt, M::BigInt, W::BigInt)
    ## Figure out the intervals.
    twoA = 2*A
    vdist1 = 2*B*Vy % twoA
    vdist = 2*B*M*Vy % twoA
    if vdist > A; vdist = twoA - vdist; Y = twoA - Y; vdist1 = twoA - vdist1; end
    pdist = 2*B*M*W
    if pdist >= vdist; return -1; end
    a = (vdist-pdist-1) ÷ 2
    (t1a,t1b) = (-a,A-vdist+a)
    (t2a,t2b) = (A+t1a,A+t1b)
    if t1a <= Y && Y <= t1b; return 1+M; end
    if t2a <= Y && Y <= t2b; return 1+M; end
    if twoA+t1a <= Y && Y <= twoA+t1b; return 1+M; end
    inc1 = twoA-Y
    inc2 = Y < t2a ? -Y : inc1
    (u1a,u1b,u2a,u2b) = (t1a+inc1,t1b+inc1,t2a+inc2,t2b+inc2)
    s1 = solveit2(twoA,vdist1,u1a,u1b)
    s2 = solveit2(twoA,vdist1,u2a,u2b)
    return s1 < 0 && s2 < 0 ? -1 : 1+M+(s1 < 0 ? s2 : s2 < 0 ? s1 : s1 < s2 ? s1 : s2)
end

function solve(A::BigInt,B::BigInt,N::BigInt,M::BigInt,V::BigInt,W::BigInt,
               Y::BigInt,X::BigInt,Vy::BigInt,Vx::BigInt)::String
    if Vy == 0 || Vx == 0; return "DRAW"; end
    if Vy < 0; Y = A-Y; Vy = -Vy; end
    flipped = false
    if Vx < 0; flipped = true; X = B-X; (N,M,V,W) = (M,N,W,V); Vx = -Vx; end

    ## Now we are going up and to the right.
    ## now we deal with time units
    ## Normally, go (0,0) --> (Vx,Vy) every 1 time unit
    ## Equivalent to going (0,0) --> (1,Vy/Vx) every 1/Vx time unit
    ## If we divide up the vertical into Vx more steps for every 1, we 
    ##   go from (0,0) --> (1,Vy) every 1/Vx time unit.
    A *= Vx; Y *= Vx
    ## Wall 1 start
    twoA = 2*A

    ## Do the right side first
    W1y = (Y + (B-X) * Vy) % twoA
    n1 = solveit(A,B,W1y,Vy,M,W)

    ## Now do the left side
    W2y = (W1y + B*Vy) % twoA
    n2 = solveit(A,B,W2y,Vy,N,V)

    leftstr  = flipped ? "RIGHT" : "LEFT"
    rightstr = flipped ? "LEFT"  : "RIGHT"

    if n1 < 0 && n2 < 0; return "DRAW"
    elseif n1 < 0;       return "$rightstr $(n2-1)"
    elseif n2 < 0;       return "$leftstr $(n1-1)"
    elseif n1 <= n2;     return "$leftstr $(n1-1)"
    else                 return "$rightstr $(n2-1)"
    end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        A,B = [parse(BigInt,x) for x in gss()]
        N,M = [parse(BigInt,x) for x in gss()]
        V,W = [parse(BigInt,x) for x in gss()]
        Y,X,Vy,Vx = [parse(BigInt,x) for x in gss()]
        ans = solve(A,B,N,M,V,W,Y,X,Vy,Vx)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

