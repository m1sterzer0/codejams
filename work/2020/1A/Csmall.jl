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
                for k in j-1:-1:1; u = S[i,k]; if u > 0; cnt+=1; break; end; end
                for k in j+1:C;    d = S[i,k]; if d > 0; cnt+=1; break; end; end
                for k in i-1:-1:1; l = S[k,j]; if l > 0; cnt+=1; break; end; end
                for k in i+1:R;    r = S[k,j]; if r > 0; cnt+=1; break; end; end
                if cnt == 0; continue; end
                if S[i,j]*cnt < l+r+u+d; push!(eliminate,(i,j)); end
            end
        end
        if isempty(eliminate); return ans; end
        for (i,j) in eliminate; S[i,j] = 0; end
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
        ans = solveSmall(R,C,S)
        print("$ans\n")
    end
end

main()

