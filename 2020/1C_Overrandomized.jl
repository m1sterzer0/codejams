
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

function solve(U::I,Q::VI,R::VS)::String
    letters::Set{Char} = Set{Char}()
    for s::String in R; for c::Char in s; push!(letters,c); end; end
    lu::Dict{Char,I} = Dict{Char,I}()
    for l::Char in letters; lu[l] = 0; end
    for s::String in R; c::Char = s[1]; lu[c] += 1; end
    vals::Vector{Tuple{I,Char}} = [(lu[x],x) for x in letters]
    sort!(vals,rev=true)
    pushfirst!(vals,pop!(vals))
    return join([x[2] for x in vals],"")    
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        U = gi()
        Q::VI = []
        R::VS = []
        for i in 1:10000
            q,r = gss()
            push!(Q,parse(Int64,q))
            push!(R,r)
        end
        ans = solve(U,Q,R)
        print("$ans\n")
    end
end

function test()
    pass = 0
    for i in 1:1000
        Q = fill(-1,10000)
        R::Vector{String} = []
        for i in 1:10000
            M = rand(1:999_999_999_999_999)
            V = rand(1:M)
            s = string(V)
            for (c1::Char,c2::Char) in zip("0123456789","ABCDEFGHIJ")
                s = replace(s,c1 => c2)
            end
            push!(R,s)
        end
        ans2::String = solve(16,Q,R)
        if ans2 == "ABCDEFGHIJ"; print("Test $i passed\n"); pass += 1
        else; print("Test $i ERROR ans2:$ans2\n")
        end
    end
    print("Pass percentage: $pass/1000\n")
end

Random.seed!(8675309)
main()
#test()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

