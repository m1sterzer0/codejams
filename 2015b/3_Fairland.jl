
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

function solve(N::I,D::I,S0::I,As::I,Cs::I,Rs::I,
               M0::I,Am::I,Cm::I,Rm::I,working)::I
    (S::VI,M::VI,MM::VI,ranges::VPI,incEvents::VI,decEvents::VI) = working
    ## A bit awkward to deal with one indexing, but not impossible
    S[1] = S0
    for i in 2:N; S[i] = (S[i-1]*As+Cs) % Rs; end
    M[1] = M0
    for i in 2:N; M[i] = (M[i-1]*Am+Cm) % Rm; end
    MM[1] = -1
    for i in 2:N; MM[i] = (M[i] % (i-1)) + 1; end

    ## Note that every persons manager has an ID less than them, so there is
    ## no need to create a dependency tree-based order.  We can just process the
    ## nodes in numerical order for a tops-down traversal.
    for i in 1:N
        if i == 1
            ranges[i] = (max(0,S[1] - D), S[1])
        else
            boss = ranges[MM[i]]
            ranges[i] = (max(0,S[i]-D,boss[1]), min(S[i],boss[2]))
        end
    end

    ## Filter out invalid ranges
    resize!(incEvents,N)
    resize!(decEvents,N)
    nn = 0
    for i in 1:N 
        x = ranges[i]
        if x[1] <= x[2]
            nn += 1
            incEvents[nn] = x[1]
            decEvents[nn] = x[2]
        end
    end
    resize!(incEvents,nn)
    resize!(decEvents,nn)
    sort!(incEvents)
    sort!(decEvents)
    best,cur = 0,0
    while !isempty(incEvents)
        if (isempty(decEvents) || incEvents[1] <= decEvents[1])
            cur += 1
            best = max(best,cur)
            popfirst!(incEvents)
        else
            cur -= 1
            popfirst!(decEvents)
        end
    end
    return best
end

function prework()
    S::VI = fill(0,1_000_000)
    M::VI = fill(0,1_000_000)
    MM::VI = fill(0,1_000_000)
    ranges::VPI = fill((0,0),1_000_000)
    incEvents::VI = fill(0,1_000_000)
    decEvents::VI = fill(0,1_000_000)
    return (S,M,MM,ranges,incEvents,decEvents)
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    working = prework()
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,D = gis()
        S0,As,Cs,Rs = gis()
        M0,Am,Cm,Rm = gis()
        ans = solve(N,D,S0,As,Cs,Rs,M0,Am,Cm,Rm,working)
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

