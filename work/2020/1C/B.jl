
using Random

## Looks like a Benford's Law-like problem to me
function solveLarge(Q::Vector{Int64},R::Vector{String})
    letters = Set{Char}()
    for s in R; for c in s; push!(letters,c); end; end
    lu::Dict{Char,Int64} = Dict{Char,Int64}()
    for l in letters; lu[l] = 0; end
    for s in R; c = s[1]; lu[c] += 1; end
    vals = [(lu[x],x) for x in letters]
    sort!(vals,rev=true)
    pushfirst!(vals,pop!(vals))
    return join([x[2] for x in vals],"")
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    gs()::String = rstrip(readline(infile))
    gi()::Int64 = parse(Int64, gs())
    gf()::Float64 = parse(Float64,gs())
    gss()::Vector{String} = split(gs())
    gis()::Vector{Int64} = [parse(Int64,x) for x in gss()]
    gfs()::Vector{Float64} = [parse(Float64,x) for x in gss()]
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        U = gi()
        Q::Vector{Int64} = []
        R::Vector{String} = []
        for i in 1:10000
            q,r = gss()
            push!(Q,parse(Int64,q))
            push!(R,r)
        end
        ans = solveLarge(Q,R)
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
            s = replace(s,'1'  => 'B')
            s = replace(s,'2'  => 'C')
            s = replace(s,'3'  => 'D')
            s = replace(s,'4'  => 'E')
            s = replace(s,'5'  => 'F')
            s = replace(s,'6'  => 'G')
            s = replace(s,'7'  => 'H')
            s = replace(s,'8'  => 'I')
            s = replace(s,'9'  => 'J')
            s = replace(s,'0'  => 'A')
            push!(R,s)
        end
        ans2 = solveLarge(Q,R)
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

