
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

function solve(digstring::String,working)::I
    (dp::Array{I,2},carr::VVI) = working
    N = length(digstring)
    C::VI = [parse(Int64,x) for x in digstring]
    dp[1:N,1:10] .= 0
    for i in 1:N; dp[i,1] = i; end
    for i in 1:9; empty!(carr[i]); end
    for i in 1:N; push!(carr[C[i]],i); end
    cidxarr::VI = fill(0,9)
    ##Max cost is 20 compares * cost of 9.  Round up to 200 to be safe
    for c in 1:200
        ci::I = (c % 10) + 1
        cj::I = ((c-1) % 10) + 1
        for i in 1:N; dp[i,ci] = dp[i,cj]; end
        for d::I in 1:9
            if c-d < 0; continue; end
            mycarr::VI = carr[d]
            lmycarr::I = length(mycarr)
            myidx::I = 0
            refcol::I = ((c-d) % 10) + 1
            for i::I in 1:N
                myidxp1::I = myidx+1
                while (myidxp1 <= lmycarr && mycarr[myidxp1] <= dp[i,refcol])
                    myidxp1 += 1
                end
                myidx = myidxp1-1
                if myidx == 0; continue; end
                newcand::I = mycarr[myidx] == N ? N+1 : dp[mycarr[myidx]+1,refcol]
                dp[i,ci] = max(dp[i,ci],newcand)
            end
        end
        if dp[1,ci] == N+1; return c; end
    end
end

function gencase(Nmin::I,Nmax::I)
    N = rand(Nmin:Nmax)
    digstring = join(rand(['1','2','3','4','5','6','7','8','9'],N))
    return (digstring,)
end

function prework()
    dp::Array{I,2} = fill(0,1_000_000,10)
    carr::VVI = [fill(0,1_000_000) for i in 1:9]
    return (dp,carr)
end

function test(ntc::I,Nmin::I,Nmax::I)
    working = prework()
    for ttt in 1:ntc
        (digstring,) = gencase(Nmin,Nmax)
        ans = solve(digstring,working)
        print("Case #$ttt: $ans\n")
    end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    working = prework()
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        digstring = gs()
        ans = solve(digstring,working)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
#test(1,10^4-10,10^4)
#test(10,10^4-10,10^4)
#test(100,10^4-10,10^4)
#test(1,10^6-10,10^6)
#test(10,10^6-10,10^6)
#test(100,10^6-10,10^6)

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile test(1,10^4,10^4)
#Profile.clear()
#@profilehtml test(10,10^4,10^4)

