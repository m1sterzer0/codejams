
function solveLarge(N::Int64,D::Int64,A::Vector{Int64})
    d::Dict{Tuple{Int64,Int64},Vector{Int64}} = Dict{Tuple{Int64,Int64},Vector{Int64}}()
    sort!(A)
    for a in A
        for x in 1:D
            g = gcd(a,x); num = a÷g; denom = x÷g
            if haskey(d,(num,denom)); push!(d[(num,denom)],x)
            else; d[(num,denom)] = [x]
            end
        end
    end
    myisless(a::Tuple{Int64,Int64},b::Tuple{Int64,Int64})::Bool = a[1]*b[2] < a[2]*b[1]
    dk = [x for x in keys(d)]
    sort!(dk,lt=myisless)

    function issmallenough(num::Int64,denom::Int64)::Bool
        sidx = 1
        if N >= D
            sidx = N-D+1
            if num <= denom * A[sidx]; return true; end
        end
        tot = 0
        for i in N:-1:sidx
            tot += (denom * A[i]) ÷ num
            if tot >= D; return true; end
        end
        return false
    end

    l,u = 1,length(dk)
    if issmallenough(dk[end][1],dk[end][2]); l = u; end
    while (u-l > 1)
        m = (u+l) ÷ 2
        if issmallenough(dk[m][1],dk[m][2]); l = m; else; u = m; end
    end

    function countcuts(v::Vector{Int64})::Int64
        ## Note v should alread be sorted
        cuts,slices = 0,0
        for vv in v
            if slices+vv > D; break; end
            slices += vv; cuts += vv-1
        end
        return cuts + (D-slices)
    end

    best::Int64 = D-1
    for i in 1:l
        (num,denom) = dk[i]
        c = countcuts(d[(num,denom)])
        best = min(best,c)
    end

    return best
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
        N,D = gis()
        A::Vector{Int64} = gis()
        ans = solveLarge(N,D,A)
        print("$ans\n")
    end
end

main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

