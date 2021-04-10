
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

function solveSmall(M::Array{Int64,2})
    ## Sort the questions by difficulty
    qq::VPI = []
    for j in 1:10_000
        r = sum(M[:,j])
        push!(qq,(r,j))
    end
    sort!(qq)
    qqq::VI = [x[2] for x in qq]
    ## Rate players by the number of inversions and report the most inversions
    ## as a cheater
    best,cheater = 0,1
    for i in 1:100
        l = M[i,qqq[1]]
        inv = 0
        for j in 2:10_000
            if M[i,qqq[j]] == l; continue; end
            inv += 1; l = M[i,qqq[j]]
        end
        if inv > best; best = inv; cheater = i; end
    end
    return cheater
end

function calcSkill(p0::Float64)
    ## assuming question difficulty uniformity from -3 to 3
    ## player of skill s should answer 10000*p0 questions correctly, where
    ## p_0 = \frac16\cdot\int_{-3}^{3} \frac{1}{1 + e^{x-s}}dx.
    ## Using wolfram alpha (because I'm lazy)
    ## 6p_0 = 6 - \log\left(\frac{e^s+e^{-3}}{e^s+e^3}\right)
    ## Finally, using wolfram alpha again to solve for s in terms of p_0, we get
    ## s = 3 + \log(e^{6p_0}-1) - \log(e^6-e^{6p_0})
    return p0 <= 0 ? -6.0 : p0 >= 1 ? 6.0 : 3 + log(exp(6*p0)-1) - log(exp(6)-exp(6*p0))
end
    
function solveLarge(M::Array{Int64,2})

    parrfair::VF = fill(0.00,100)
    parrcheater::VF = fill(0.00,100)
    qarr::VF = fill(0.00,10000)
    for i in 1:100
        numRight = sum(M[i,:])
        fracRightFair = 1.0 * numRight / 10000
        fracRightCheater = (numRight-5000) / 5000
        parrfair[i] = calcSkill(fracRightFair)
        parrcheater[i] = calcSkill(fracRightCheater)
    end
    ## Capping skill to -3,3 for now -- might want to use the raw fit later
    for i in 1:100
        parrfair[i] =    min(3.0,max(-3.0,parrfair[i]))
        parrcheater[i] = min(3.0,max(-3.0,parrcheater[i]))
    end

    for j in 1:10_000
        numRight = sum(M[:,j])
        fracRight = 1.0 * numRight / 100
        qarr[j] = calcSkill(1.0-fracRight)
    end
    lpcheat = fill(0.01,100)

    for i in 1:100
        lpa::F = log(0.01)
        for j in 1:10000
            pa::F = exp(lpa)
            if pa < 0; pa = 0; elseif pa > 1; pa = 1; end
            diff1::F = parrfair[i]-qarr[j]
            diff2::F = parrcheater[i]-qarr[j]
            fairRightPercent::F = 1.0 / (1.0 + exp(-diff1))
            cheatRightPercent::F = 0.5 + 0.5 / (1.0 + exp(-diff2))
            pbgivena::F = M[i,j] == 1 ? cheatRightPercent : 1.0 - cheatRightPercent
            pbgivennota::F = M[i,j] == 1 ? fairRightPercent : 1.0 - fairRightPercent
            pb::F = pa * pbgivena + (1-pa) * pbgivennota
            lpa += log(pbgivena) - log(pb)
        end
        lpcheat[i] = lpa
    end
    (_m,cheater) = findmax(lpcheat)

    return cheater
end

randu(l::Float64,r::Float64)::Float64 = l + (r-l)*rand(Float64)
function test(ntc::Int64,smallFlag=true)
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
        res = smallFlag ? solveSmall(M) : solveLarge(M)
        if res == cheater
            pass += 1
        else
            print("testcase missed: ref:$cheater exp:$res refp:$(parr[cheater]) expp:$(parr[res])\n")
        end
        if ttt % 100 == 0; print("$pass/$ttt passed\n"); end
    end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    P::I = gi()
    M::Array{I,2} = fill(0,100,10_000)
    for qq in 1:tt
        print("Case #$qq: ")
        for i in 1:100
            ss = gs()
            M[i,:] = [parse(Int64,x) for x in ss]
        end
        #ans = solveSmall(M)
        ans = solveLarge(M)
        print("$ans\n")
    end
end

Random.seed!(8675309)
#test(1000,false)
main()