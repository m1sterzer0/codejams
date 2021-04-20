
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
### For the small, we can simply figure out how many cookies I can cut before I run out of margin,
### and then I can rotate the cuts to the maximum and see on which side of P that lands.
######################################################################################################

function solveSmall(N::I,P::I,W::VI,H::VI)::F
    basePerim::I = 2*W[1] + 2*H[1]
    minAdder::I = 2*min(W[1],H[1])
    maxAdder::F = 2*sqrt(W[1]*W[1]+H[1]*H[1])
    ncuts = min(N,(P - N * basePerim) ÷ minAdder)
    minPerim = Float64(basePerim * N + minAdder * ncuts)
    maxPerim = Float64(basePerim * N + maxAdder * ncuts)
    return P <= maxPerim ? Float64(P) : maxPerim
end

######################################################################################################
### For the large, we need to do some interval merging math and create a set of intervals for the
### adders.  One might expect this to grow to be 2^N, but the minimum geometric separation between
### the min and max of each interval (i.e. max >= sqrt(2) * min) means that there is a quick upper bound
### on the number of intervals, making this merging practical.
### 
### Because of the "without going over" concept, I was paranoid and kept the intervals in the form
### [int,float].
######################################################################################################

function doIntervalSearch(intervals::Vector{Tuple{I,F}},targ::I)::F
    iarr::Vector{Tuple{I,F}} = createIarr(intervals)
    best::F = 0.0
    for ii::Tuple{I,F} in iarr
        if targ <  ii[1]; return best; end
        if targ <= ii[2]; return Float64(targ); end
        best = ii[2]
    end
    return best;
end

function createIarr(intervals::Vector{Tuple{I,F}})::Vector{Tuple{I,F}}
    iarr::Vector{Tuple{I,F}} = []
    iarr2::Vector{Tuple{I,F}} = []
    for ii::Tuple{I,F} in intervals
        n::I = length(iarr)
        push!(iarr,ii)
        for jj::Tuple{I,F} in iarr[1:n]
            push!(iarr,(ii[1]+jj[1],ii[2]+jj[2]))
        end
        ### Compress the arr
        sort!(iarr)
        resize!(iarr2,0)
        for jj in iarr
            if isempty(iarr2) || jj[1] > iarr2[end][2]
                push!(iarr2,jj)
            elseif jj[2] > iarr2[end][2]
                nn = (iarr2[end][1],jj[2])
                pop!(iarr2)
                push!(iarr2,nn)
            end
        end
        (iarr,iarr2) = (iarr2,iarr)
    end
    return iarr
end

function solveLarge(N::I,P::I,W::VI,H::VI)::F
    basePerim = sum(2*H[i]+2*W[i] for i in 1:N)
    intervals::Vector{Tuple{Int64,Float64}} = [(2*min(W[i],H[i]),2*sqrt(W[i]*W[i]+H[i]*H[i])) for i in 1:N]
    minAdder = minimum(x[1] for x in intervals)
    maxAdder = sum(x[2] for x in intervals)

    if basePerim + minAdder > P; return basePerim; end
    if basePerim + maxAdder <= P; return basePerim+maxAdder; end
    adder = doIntervalSearch(intervals,P-basePerim)
    return basePerim+adder
end

function gencase(Nmin::I,Nmax::I,Cmax::I,smallFlag::Bool)
    N = rand(Nmin:Nmax)
    W::VI = smallFlag ? repeat([rand(1:Cmax)],N) : rand(1:Cmax,N)
    H::VI = smallFlag ? repeat([rand(1:Cmax)],N) : rand(1:Cmax,N)
    Pmin = 2 * (sum(W) + sum(H))
    Pminadd = Pmin + 2 * minimum(vcat(W,H))
    Pmaxf = 0
    for i in 1:N; Pmaxf += 2*H[i]+2*W[i]+2*sqrt(H[i]^2+W[i]^2); end
    Pmax::I = floor(Int64,Pmaxf)
    P = rand() < 0.2 ? rand(Pmin:Pminadd) : rand() < 0.9 ? rand(Pminadd:Pmax) : rand(Pmax:1_000_000_000_000_000_000)
    return (N,P,W,H)
end

function isApproximatelyEqual(x::F,y::F,epsilon::F)::Bool
    if -epsilon <= x - y <= epsilon; return true; end
    if -epsilon <= x <= epsilon || -epsilon <= y <= epsilon; return false; end
    if -epsilon <= (x - y) / x <= epsilon; return true; end
    if -epsilon <= (x - y) / y <= epsilon; return true; end
    return false
end

function test(ntc::I,Nmin::I,Nmax::I,Cmax::I,smallFlag::Bool,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (N,P,W,H) = gencase(Nmin,Nmax,Cmax,smallFlag)
        ans2 = solveLarge(N,P,W,H)
        if check
            ans1 = solveSmall(N,P,W,H)
            if isApproximatelyEqual(ans1,ans2,1e-8)
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(N,P,W,H)
                ans2 = solveLarge(N,P,W,H)
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
        N,P = gis()
        W::VI = fill(0,N)
        H::VI = fill(0,N)
        for i in 1:N; W[i],H[i] = gis(); end
        #ans = solveSmall(N,P,W,H)
        ans = solveLarge(N,P,W,H)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()

#for ntc in (1,10,100,1000)
#    test(ntc,1,100,250,true)
#end
#test(200,90,100,250,false,false)



#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

