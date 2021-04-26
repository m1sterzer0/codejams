
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

################################################################################
## Observations:
## a) Note that since A == 1, we can transmute to any lower degree metal
## b) Note that N+2 --> (N+1,N) --> (N,N,N-1) --> (N-1,N-1,N-1,N-2,N-2) --> 5*(N-2)+3*(N-3) --> 8(N-2)+5(N-3)
##    (looks like Fibbonaci)
## c) Thus, U_34 --> U_33+U_32 --> 2U_32+U_31 --> 3U_31+2U_30 --> 5U_30+3U_29 --> 8U_29+5U_28 -->13U_28+8U_27
##          21U_27+13U_26 --> 34U_26+21U_25 --> 55U_25+34U_24 --> 89U_24+55U_23 --> 144U_23+89U_22 --> 233U_22+144U_21
##          --> 377U_21+233U_20 --> 610U_20+377U_19 >= 400U_20 which is more than enough, so the answer isn't bigger than U_34
## d) We can binary search and just simulate
################################################################################

function simulateSmall(N::I,U::VI,m::I)
    inv::VI = fill(0,max(20,m))
    inv[m] = 1
    for i in max(20,m):-1:1
        if i <= N && U[i] > inv[i]; return false; end
        if i <= N; inv[i] -= U[i]; end
        if i > 1; inv[i-1] += inv[i]; end
        if i > 2; inv[i-2] += inv[i]; end
        inv[i] = 0 ## Not needed
    end
    return true
end

function solveSmall(N::I,A::I,B::I,U::VI)::String
    l::I,u::I = 1,34
    while u-l > 1
        m = (u+l)>>1
        if simulateSmall(N,U,m); u = m; else; l = m; end
    end
    return "$u"
end

################################################################################
## Additional Observations for the large
## a) Notice that if both A and B are even, and I have both even and odd
##    numbers in U, then we are screwed.
## b) More generally, since we only use steps of A,B == ng,mg where g is gcd(A,B),
##    We must have (as a necessary condition) that start - kg == end -->
##    start % g == end % g.
## c) Is this condition sufficient?  Here we turn to offline experiments.  There
##    are only so many values of A & B, so we can fairly exhaustively cover things
##    without the time limit.  The routine below suggests 402 is the Maximum
##    I need.  Thus, we can just set a simulation maximum of 500, and if we
##    don't succeed, we print IMPOSSIBLE.
################################################################################

function simulateLarge(N::I,U::VI,m::I,A::I,B::I)
    inv::VI = fill(0,max(20,m))
    inv[m] = 1
    for i in max(20,m):-1:1
        if i <= N && U[i] > inv[i]; return false; end
        if i <= N; inv[i] -= U[i]; end
        if i > A; inv[i-A] += inv[i]; end
        if i > B; inv[i-B] += inv[i]; end
        inv[i] = 0 ## Not needed
    end
    return true
end

function offlineSearch()
    ## WLOG, A >= B
    maxval = 0
    for A in 1:20
        for B in A:20
            g = gcd(A,B)
            for offset in 1:g
                U = fill(20,20)
                for i in 1:20; if i % g != offset % g; U[i] = 0; end; end
                found = false
                for k in offset:g:100000
                    if simulateLarge(20,U,k,A,B)
                        maxval = max(maxval,k)
                        print("$A $B $offset $k\n")
                        found = true
                        break
                    end
                end
                if !found; print("$A $B $offset NOT_FOUND\n"); end
            end
        end
    end
    print("Maximum needed: $maxval\n")
end

function solveLarge(N::I,A::I,B::I,U::VI)::String
    for k in 1:500
        if simulateLarge(N,U,k,A,B); return "$k"; end
    end
    return "IMPOSSIBLE"
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,A,B = gis()
        U::VI = gis()
        #ans = solveSmall(N,A,B,U)
        ans = solveLarge(N,A,B,U)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
#offlineSearch()
#using Profile, StatProfilerHTML
#Profile.clear()
#@profilehtml offlineSearch()

