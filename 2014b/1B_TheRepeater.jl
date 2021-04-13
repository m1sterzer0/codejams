
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

function getsig(s::String)::String
    ca::VC = []; last::Char = '.'
    for c in s
        if c == last; continue; end
        last = c
        push!(ca,c)
    end
    return join(ca)
end

function getCounts(s::String)::VI
    ca::VI = []; last::Char = '.'
    for c in s
        if c == last; ca[end] += 1
        else; last = c; push!(ca,1)
        end
    end
    return ca
end

function solveColumn(a::VI)::I
    n::I = length(a)
    sort!(a)
    val::I = a[(n+1) ÷ 2] 
    while(true)
        ltval = count(x->x<val,a)
        eqval = count(x->x==val,a)
        gtval = count(x->x>val,a)
        if ltval > eqval + gtval; val -= 1
        elseif gtval > ltval + eqval; val += 1
        else; break
        end
    end
    ans = sum([abs(xx-val) for xx in a])
    return ans
end

function solve(N::I,S::VS)::String
    sigs = Set{String}()
    for s in S; push!(sigs,getsig(s)); end
    if length(sigs) > 1; return "Fegla Won"; end;
    sig = [x for x in sigs][1]
    counts = fill(0,N,length(sig))
    for i in 1:N; counts[i,:] = getCounts(S[i]); end
    ans::Int64 = 0
    for j in 1:length(sig); ans += solveColumn(counts[:,j]); end
    return "$ans"
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        S = [gs() for i in 1:N]
        ans = solve(N,S)
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

