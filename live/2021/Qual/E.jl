
using Random

expectedRight(s::Float64)::Float64 = 1.00 - 1.0/6.0*log( (exp(s)+exp(3.0)) / (exp(s)+exp(-3.0)) )

function solveExpected(s::Float64)
    if s >= expectedRight(3.0); return 3.0; end
    if s <= expectedRight(-3.0); return -3.0; end
    l,r,m = -3.0,3.0,0.0
    for i in 1:15
        m = 0.5*(l+r)
        if expectedRight(m) < s; l = m; else; r = m; end
    end
    #print("DBG: solveExpected s:$s m:$m exp:$(expectedRight(m))\n")
    return m
end

function solveSmall(M::Array{Int64,2})
    parrfair::Vector{Float64} = fill(0.00,100)
    parrcheater::Vector{Float64} = fill(0.00,100)

    qarr::Vector{Float64} = fill(0.00,10000)
    for i in 1:100
        numRight = sum(M[i,:])
        fracRight = 1.0 * numRight / 10000
        parrfair[i] = solveExpected(fracRight)
        fracRightCheater = (numRight-5000) / 5000
        parrcheater[i] = solveExpected(fracRightCheater)
    end
    for j in 1:10000
        numRight = sum(M[:,j])
        fracRight = 1.0 * numRight / 100
        qarr[j] = solveExpected(1.0-fracRight)
    end
    #print("DBG: parr:$parr\n")
    #print("DBG: qarr:$qarr\n")
    pcheat = fill(0.01,100)

    for i in 1:100
        pa = 0.01
        for j in 1:10000
            diff = parrfair[i]-qarr[j]
            fairRightPercent = 1.0 / (1.0 + exp(-diff))
            diff2 = parrcheater[i]-qarr[j]
            cheatRightPercent = 0.5 + 0.5 / (1.0 + exp(-diff2))
            pbgivena = M[i,j] == 1 ? cheatRightPercent : 1.0 - cheatRightPercent
            pbgivennota = M[i,j] == 1 ? fairRightPercent : 1.0 - fairRightPercent
            pb = pa * pbgivena + (1-pa) * pbgivennota
            newpa = pa * pbgivena / pb
            #print("DBG: i:$i j:$j pa:$newpa M[i,j]:$(M[i,j]) fairRightPercent:$fairRightPercent cheatRightPercent:$cheatRightPercent\n")
            pa = newpa
        end
        pcheat[i] = pa
    end
    (_m,cheater) = findmax(pcheat)
    #for i in 1:100
    #    print("DBG: i:$i parrfair[i]:$(parrfair[i]) parrcheater[i]:$(parrcheater[i]) pcheat[i]:$(pcheat[i])\n")
    #end
    return cheater
end

randu(l::Float64,r::Float64)::Float64 = l + (r-l)*rand(Float64)

function test(ntc::Int64)
    pass = 0
    M::Array{Int64,2} = fill(0,100,100000)
    for ttt in 1:ntc
        cheater = rand(1:100)
        parr = [randu(-3.00,3.00) for x in 1:100]
        qarr = [randu(-3.00,3.00) for x in 1:10000]
        for i in 1:100
            for j in 1:10000
                d = parr[i]-qarr[j]
                thresh = 1.0 / (1.0 + exp(-d))
                v = (i == cheater && rand() < 0.5) ? 1 : (rand() < thresh ? 1 : 0)
                M[i,j] = v
            end
        end
        res = solveSmall(M)
        if res == cheater
            pass += 1
            print("$ttt passed\n")
        else
            print("testcase missed: ref:$cheater exp:$res refp:$(parr[cheater]) expp:$(parr[res])\n")
        end
    end
    print("$pass/$ntc passed")
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
    P = parse(Int64,readline(infile))
    M::Array{Int64,2} = fill(0,100,10000)
    for qq in 1:tt
        print("Case #$qq: ")
        for i in 1:100
            ss = gs()
            M[i,:] = [parse(Int64,x) for x in ss]
        end
        ans = solveSmall(M)
        #ans = solveLarge()
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
#test(1000)


#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

