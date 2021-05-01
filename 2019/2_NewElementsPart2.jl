
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
### This needs a gem a of continued fractions routine from python that I've transcribed into
### julia.  It uses continued fractions to find the best appproximant of a given fraction using
### denominators <= maxDenom.
######################################################################################################

function limitDenominator(targ::Rational{Int128},maxDenom::Int128)::Rational{Int128}
    if denominator(targ) <= maxDenom; return targ; end
    p0::Int128,q0::Int128,p1::Int128,q1::Int128,n::Int128,d::Int128 = 0,1,1,0,numerator(targ),denominator(targ)
    while (true)
        a::Int128 = n ÷ d
        q2::Int128 = q0+a*q1
        if q2 > maxDenom; break; end
        p0,q0,p1,q1,n,d = p1,q1,p0+a*p1,q2,d,n-a*d
    end
    k::Int128 = (maxDenom-q0) ÷ q1
    bound1::Rational{Int128} = (p0+k*p1) // (q0+k*q1)
    bound2::Rational{Int128} = p1 // q1
    return abs(bound2-targ) <= abs(bound1-targ) ? bound2 : bound1
end


function solve(N::I,C::VI,J::VI)::String
    minjtoc::Rational{Int128} = Int128(0)//Int128(1)
    maxjtoc::Rational{Int128} = Int128(1000000001)//Int128(1)
    good::Bool = true
    for i in 1:N-1
        if C[i] >= C[i+1] && J[i] >= J[i+1]; good=false; break; end
        if C[i+1] >= C[i] && J[i+1] >= J[i]; continue; end
        if C[i+1] > C[i]; maxjtoc = min(maxjtoc, Int128(C[i+1]-C[i])//Int128(J[i]-J[i+1]))
        else              minjtoc = max(minjtoc, Int128(C[i]-C[i+1])//Int128(J[i+1]-J[i]))
        end
    end
    if !good || minjtoc >= maxjtoc; return "IMPOSSIBLE"; end

    ans::Rational{Int128} = Int128(0) // Int128(1)
    if minjtoc < floor(minjtoc) + 1//1 < maxjtoc
        ans = floor(minjtoc) + 1//1
    else
        best::Rational{Int128} = Int128(numerator(minjtoc)+numerator(maxjtoc)) // Int128(denominator(minjtoc)+denominator(maxjtoc))
        lb::Int128,ub::Int128 = Int128(1),denominator(best)
        mid::Rational{Int128} = Int128(1)//Int128(2) * (minjtoc + maxjtoc)
        while (ub-lb) > 1
            m = (ub+lb) ÷ 2
            x = limitDenominator(mid,m)
            if minjtoc < x < maxjtoc; ub = m; best = x
            else                    ; lb = m
            end
        end
        ans = best
    end
    return "$(denominator(ans)) $(numerator(ans))"
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        C::VI = fill(0,N)
        J::VI = fill(0,N)
        for i in 1:N; C[i],J[i] = gis(); end
        ans = solve(N,C,J)
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
