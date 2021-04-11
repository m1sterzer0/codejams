
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


function solve(N::I,X::VS)::I
    ans::I = 0
    lastval = X[1]
    for i in 2:N
        curlen = length(X[i])
        if curlen > length(lastval) || (curlen == length(lastval) && X[i] > lastval)
            lastval = X[i]
        elseif curlen == length(lastval)
            ans += 1
            lastval = X[i]*"0"
        elseif X[i][1:curlen] < lastval[1:curlen]
            adder = length(lastval)-curlen+1
            ans += adder
            lastval = X[i][1:curlen]*"0"^adder
        elseif X[i][1:curlen] > lastval[1:curlen]
            adder = length(lastval)-curlen
            ans += adder
            lastval = X[i][1:curlen]*"0"^adder
        else
            xx = string(parse(BigInt,lastval)+BigInt(1))
            if xx[1:curlen] == X[i][1:curlen]
                adder = length(lastval)-curlen
                ans += adder
                lastval = xx
            else
                adder = length(lastval)-curlen+1
                ans += adder
                lastval = X[i][1:curlen]*"0"^adder
            end
        end
    end
    return ans
end

function test()
    for i in 1:100
        for j in 1:100
            ans = solve(2,[string(i),string(j)])
            print("$i $j $ans\n")
        end
    end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        X::VS = gss()
        ans = solve(N,X)::I
        print("$ans\n")
    end
end

function gencase(Nmin::I,Nmax::I,Xmin::I,Xmax::I)
    N = rand(Nmin:Nmax)
    X::VI = [rand(Xmin:Xmax) for i in 1:N]
    return (N,X)
end

function test(ntc::I,Nmin::I,Nmax::I,Xmin::I,Xmax::I)
    for ttt in 1:ntc
        (N,X) = gencase(Nmin,Nmax,Xmin,Xmax)
        solve(N,X)
    end
end


Random.seed!(8675309)
main()
#test()
#solve(2,["10","1"])

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

