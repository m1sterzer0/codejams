
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

function prework(N::I)
    f1::F = (N-1)/N
    f2::F = 1/N
    aa::Array{F,2} = fill(0.0,N,N)
    bb::Array{F,2} = fill(0.0,N,N)
    cc::VF = fill(0.0,N)
    for i in 1:N; aa[i,i] = 1.0; end
    for i in 1:N
        cc .= f2 .* aa[i,:]
        bb .= f1 .* aa .+ cc'
        bb[i,:] .= f2
        aa,bb = bb,aa
    end
    return (aa,)
end

function solve(N::I,P::VI,working)::String
    (badmat,) = working
    f1 = 1/ N
    badprob = 0.5
    for i in 1:1000
        badprob *= badmat[i,P[i]+1] / (badprob * badmat[i,P[i]+1] + (1-badprob) * f1)
    end
    return badprob > 0.5 ? "BAD" : "GOOD"
end

function test(ntc,printflag::Bool=false)
    N = 1000
    working = prework(N)
    pass = 0
    for ttt in 1:ntc
        good = rand() < 0.5
        P = collect(0:999)
        if good
            shuffle!(P)
        else
            for k in 1:N
                p = rand(1:N)
                P[k],P[p] = P[p],P[k]
            end
        end
        ans = solve(N,P,working)
        if printflag; print("Case #$ttt $ans\n"); end
        if good && ans == "GOOD" || !good && ans == "BAD"
            pass += 1
        else
            print("ERROR: ttt:$ttt good:$good ans:$ans\n")
        end
    end
    print("$pass/$ntc passed ($(100*pass/ntc)%)\n")
end

function main(infn="")
    working = prework(1000)
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        P::VI = gis()
        ans = solve(N,P,working)
        print("$ans\n")
    end
end

Random.seed!(8675309)
#test(120,true)
#test(120)
#test(120)
#test(1000)
#test(10000)
#test(100000)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile prework(10)
#Profile.clear()
#@profilehtml prework(1000)


## O(N^2) Cleverness from Gennady -- worth capturing here
##val n = 1000
##var f = Array(n) { Array(n) {0.toDouble()} }
##var k = DoubleArray(n)
##var b = DoubleArray(n)
##for (i in 0..n-1) {
##    f[i][i] = 1.0
##    k[i] = 1.0
##    b[i] = 0.0
##}
##var p: Double = (n - 1).toDouble() / n
##var q: Double = 1.toDouble() / n
##for (it in 0..n-1) {
##    for (i in 0..n-1) { 
##        val add = (k[i] * f[i][it] + b[i]) * q
##        k[i] = k[i] * p 
##        b[i] = b[i] * p + add 
##        f[i][it] = (q - b[i]) / k[i]
##    }
##}
##for (i in 0..n-1) {
##    for (j in 0..n-1) {
##        f[i][j] = k[i] * f[i][j] + b[i]
##    }
##}
