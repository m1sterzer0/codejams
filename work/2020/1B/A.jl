
using Random

function solveLarge(X::Int64,Y::Int64)::String
    xmag::Int64,xsign::Int64,ymag::Int64,ysign::Int64 = abs(X),sign(X),abs(Y),sign(Y)
    ansarr::Vector{Char} = []
    while (true)
        f1 = (xmag % 2 != 0)
        f2 = (ymag % 2 != 0)
        if f1 && f2 || ~f1 && ~f2; return "IMPOSSIBLE"; end
        if xmag == 1 && ymag == 0; push!(ansarr,xsign > 0 ? 'E' : 'W'); break; end 
        if xmag == 0 && ymag == 1; push!(ansarr,ysign > 0 ? 'N' : 'S'); break; end
        f3 = (xmag & 2 != 0)
        f4 = (ymag & 2 != 0)
        if     f1 && (f3 ⊻ f4); push!(ansarr,xsign > 0 ? 'E' : 'W'); xmag -= 1
        elseif f1;              push!(ansarr,xsign > 0 ? 'W' : 'E'); xmag += 1
        elseif f2 && (f3 ⊻ f4); push!(ansarr,ysign > 0 ? 'N' : 'S'); ymag -= 1
        else;                   push!(ansarr,ysign > 0 ? 'S' : 'N'); ymag += 1
        end
        xmag >>= 1; ymag >>= 1
    end
    return join(ansarr,"")
end

function tcgen()
    return 0
end

function regress1()
    return 0
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
        X,Y = gis()
        #ans = solveSmall()
        ans = solveLarge(X,Y)
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

