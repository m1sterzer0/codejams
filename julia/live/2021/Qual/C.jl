
using Random

function solveSmall(N::Int64,C::Int64)::String
    ## Minv is 1 + 1 + ... + 1 (N-1 terms)
    ## Maxv is N + (N-1) + ... + 2
    if C < N-1 || C > (N-1)*(N+2) ÷ 2; return "IMPOSSIBLE"; end
    a = solveit(1,N,C-(N-1))
    ans = join(a," ")
    return ans
end

function solveit(st::Int64,en::Int64,c::Int64)::Vector{Int64}
    n = en-st+1
    if c == 0; return collect(st:en); end
    if c <= n-1; a = collect(st:en); a[1:c+1] .= reverse(a[1:c+1]); return a; end
    a = solveit(st+1,en,c-(n-1))
    reverse!(a); push!(a,st); return a
end

## Check -- from A.jl
function checker(N::Int64,L::Vector{Int64})::Int64
    ans = 0
    for i in 1:N-1
        minv = 1_000_000_000_000_000_000; minidx = 0
        for j in i:N
            if L[j] < minv; minv = L[j]; minidx = j; end
        end
        ans += minidx-i+1
        L[i:minidx] .= reverse(L[i:minidx])
    end
    return ans
end


function test()
    pass = 0; ntc = 0
    for N in 2:100
        print("N==$N\n")
        for C in 1:1000
            ntc += 1
            a = solveSmall(N,C)
            ## Checking
            if C < N-1 || C > sum(2:N)
                if a == "IMPOSSIBLE"; pass += 1; else; print("ERROR: N:$N C:$C ref:IMPOSSIBLE exp:$a\n"); end
            else
                aa = [parse(Int64,x) for x in split(a)]
                ref = checker(N,aa)
                if ref == C; pass += 1; else; print("ERROR: N:$N C:$C exp:$a checker:$ref\n"); end
            end
        end
    end
    print("$pass/$ntc passed\n")
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
        N,C = gis()
        ans = solveSmall(N,C)
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

