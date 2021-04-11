
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

function solve(N::I,X::I,Y::I)::F
    targshell = Y+abs(X)
    numspent,curshell,inc = 0,0,1
    while numspent + inc <= N
        numspent += inc; inc += 4; curshell += 2
    end
    if targshell < curshell; return 1.000; end
    if targshell > curshell; return 0.000; end
    if X == 0; return 0.000; end
    numneeded = 1 + Y
    numavailable = N - numspent
    if numneeded > numavailable; return 0.000; end

    ## Do a simulation of the last shell (doing it with binomial coefficients) is
    ## a bit rough because of the magnitudes involved (need bigint code)
    sidemax = (inc-1)÷2
    state::Dict{Tuple{Int64,Int64},Float64} = Dict{Tuple{Int64,Int64},Float64}()
    state[(0,0)] = 1.000
    for i in 1:numavailable
        newstate::Dict{Tuple{Int64,Int64},Float64} = Dict{Tuple{Int64,Int64},Float64}()
        for ((a,b),v) in state
            if a == sidemax
                if !haskey(newstate,(a,b+1)); newstate[(a,b+1)] = 0.0; end
                newstate[(a,b+1)] += v 
            elseif a == b
                if !haskey(newstate,(a+1,b)); newstate[(a+1,b)] = 0.0; end
                newstate[(a+1,b)] += v
            else
                if !haskey(newstate,(a+1,b)); newstate[(a+1,b)] = 0.0; end
                newstate[(a+1,b)] += 0.5*v
                if !haskey(newstate,(a,b+1)); newstate[(a,b+1)] = 0.0; end
                newstate[(a,b+1)] += 0.5*v
            end
        end
        state = newstate
    end

    ans = 0.0
    for ((a,b),v) in state
        if numneeded <= b; ans += v
        elseif numneeded <= a; ans += 0.5*v
        end
    end
    return ans
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,X,Y = gis()
        ans = solve(N,X,Y)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()

