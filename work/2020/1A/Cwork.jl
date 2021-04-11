
using Random

function solveSmall(R::Int64, C::Int64, S::Array{Int64,2})
    ans = 0
    eliminate = []
    while (true)
        ans += sum(S)
        empty!(eliminate)
        for i in 1:R
            for j in 1:C
                if S[i,j] == 0; continue; end
                l,r,u,d,cnt = 0,0,0,0,0
                for k in j-1:-1:1; l = S[i,k]; if l > 0; cnt+=1; break; end; end
                for k in j+1:C;    r = S[i,k]; if r > 0; cnt+=1; break; end; end
                for k in i-1:-1:1; u = S[k,j]; if u > 0; cnt+=1; break; end; end
                for k in i+1:R;    d = S[k,j]; if d > 0; cnt+=1; break; end; end
                if cnt == 0; continue; end
                if S[i,j]*cnt < l+r+u+d; push!(eliminate,(i,j)); end
            end
        end
        if isempty(eliminate); return ans; end
        for (i,j) in eliminate; S[i,j] = 0; end
    end
end

function solveLarge(R::Int64, C::Int64, S::Array{Int64,2})
    ## Initialize the sum and pointer arrays
    ll::Array{Int64,2} = fill(0,R,C)
    rr::Array{Int64,2} = fill(0,R,C)
    uu::Array{Int64,2} = fill(0,R,C)
    dd::Array{Int64,2} = fill(0,R,C)
    for i in 1:R
        for j in 1:C
            ll[i,j] = j==1 ? 0 : j-1
            rr[i,j] = j==C ? 0 : j+1
            uu[i,j] = i==1 ? 0 : i-1
            dd[i,j] = i==R ? 0 : i+1
        end
    end
    ans = 0
    cursum = sum(S)
    #evaluate::Set{Tuple{Int64,Int64}} = Set([(i,j) for i in 1:R for j in 1:C])
    evaluate::Vector{Tuple{Int64,Int64}}  = [(i,j) for i in 1:R for j in 1:C]
    eliminate::Vector{Tuple{Int64,Int64}} = []
    while (true)
        ans += cursum

        ## Evaluate phase
        empty!(eliminate)
        for (i,j) in evaluate
            if S[i,j] == 0; continue; end
            cmpsum,cmpcnt = 0,0
            k = ll[i,j]; if k > 0; cmpcnt += 1; cmpsum += S[i,k]; end
            k = rr[i,j]; if k > 0; cmpcnt += 1; cmpsum += S[i,k]; end
            k = uu[i,j]; if k > 0; cmpcnt += 1; cmpsum += S[k,j]; end
            k = dd[i,j]; if k > 0; cmpcnt += 1; cmpsum += S[k,j]; end
            if cmpcnt > 0 && S[i,j]*cmpcnt < cmpsum; push!(eliminate,(i,j)); end
        end

        if isempty(eliminate); return ans; end

        ## Eliminate phase
        empty!(evaluate)
        for (i,j) in eliminate
            if S[i,j] == 0; continue; end
            cursum -= S[i,j]
            S[i,j] = 0
            ## Stich up the neighbor pointers
            kl,kr = ll[i,j],rr[i,j]
            if kl > 0; rr[i,kl] = kr; push!(evaluate,(i,kl)); end
            if kr > 0; ll[i,kr] = kl; push!(evaluate,(i,kr)); end
            ku,kd = uu[i,j],dd[i,j]
            if ku > 0; dd[ku,j] = kd; push!(evaluate,(ku,j)); end
            if kd > 0; uu[kd,j] = ku; push!(evaluate,(kd,j)); end
        end
    end
end

function tcgen(Rmax,Cmax,RCmax,Smax)
    R::Int64 = 10000
    C::Int64 = 10000
    while true
        R = rand(1:Rmax)
        C = rand(1:Cmax)
        if R*C <= RCmax; break; end
    end
    S = fill(0,R,C)
    for i in 1:R; for j in 1:C; S[i,j] = rand(1:Smax); end; end
    return (R,C,S)
end

function test(ntc,Rmax,Cmax,RCmax,Smax)
    passcnt = 0
    for ttt in 1:ntc
        (R,C,S) = tcgen(Rmax,Cmax,RCmax,Smax)
        S1 = copy(S)
        S2 = copy(S)
        ans1 = solveSmall(R,C,S1)
        ans2 = solveLarge(R,C,S2)
        if ans1 != ans2
            print("ERROR: ttt:$ttt R:$R C:$C ans1:$ans1 ans2:$ans2\n")
            S1 = copy(S)
            S2 = copy(S)
            ans1 = solveSmall(R,C,S1)
            ans2 = solveLarge(R,C,S2)
        else
            passcnt += 1
        end
    end
    print("Summary: $passcnt/$ntc passed\n")
end

function test2(ntc,Rmax,Cmax,RCmax,Smax)
    passcnt = 0
    for ttt in 1:ntc
        print("Test case $ttt\n")
        (R,C,S) = tcgen(Rmax,Cmax,RCmax,Smax)
        ans2 = solveLarge(R,C,S)
    end
end

function test3(ntc,niter)
    tests = []
    for i in 1:ntc
        (R,C,S) = tcgen(1000,1000,100000,1000000)
        push!(tests,(R,C,S))
    end

    for i in 1:niter
        print("Round $i\n")
        for (R,C,S) in tests
            S2 = copy(S)
            solveLarge(R,C,S2)
        end
    end
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
        R,C = gis()
        S::Array{Int64,2} = fill(0,R,C)
        for i in 1:R; S[i,:] = gis(); end
        #ans = solveSmall(R,C,S)
        ans = solveLarge(R,C,S)
        print("$ans\n")
    end
end

Random.seed!(8675309)
#test(1000,30,30,100,1000000)
#test2(100,5000,5000,100000,1000000)
#test3()
#main()

using Profile, StatProfilerHTML
Profile.clear()
@profile test3(2,10)
Profile.clear()
@profilehtml test3(100,100)

