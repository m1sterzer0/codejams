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
        ans = solveLarge(R,C,S)
        print("$ans\n")
    end
end

main()
