## Treat like numbers in the complex plane
## Let S1 be the star we choose for the first rotation, S2 the second, etc.
## P1 = S1 + -i*(P0-S1) = (1+i)*S1
## P2 = S2 + -i*(P1-S2) = (1+i)*S2 - i*P1 = (1+i)*S2 + (1-i)*S1
## P3 = S3 + -i*(P2-S3) = (1+i)*S3 - i*P2 = (1+i)*S3 + (1-i)*S2 + (-1-i)*S3
## P4 = S4 + -i*(P3-S4) = (1+i)*S4 - i*P3 = (1+i)*S4 + (1-i)*S3 + (-1-i)*S2 + (-1+i)*S1
## ...
## Pn = (1+i)*(Sn+Snm4+Snm8+...) + (1-i)*(Snm1+Snm5+Snm9+...) + (-1-i)*(Snm2+Snm6+Snm10+...) + (-1+i)*(Snm3+Snm7+Snm11+...)

function solve(N::Int64,M::Int64,X::Vector{Int64},Y::Vector{Int64})
    C::Vector{Complex{Int64}} = [X[i] + 1im*Y[i] for i in 1:N]
    ans::Float64 = 0.0
    for i in 1:N
        for j in 1:N
            for k in 1:N
                for l in 1:N
                    terms = [C[i],C[j],C[k],C[l],C[i],C[j],C[k],C[l],C[i],C[j]]
                    loc = 0+0im
                    for ii in 1:M
                        loc = terms[ii] + -1im*(loc-terms[ii])
                        if abs(loc) > ans
                            #print("DBG: ans:$ans abs(loc):$(abs(loc)) ii:$i (i,j,k,l) = ($i,$j,$k,$l)\n")
                            ans = abs(loc)
                        end
                    end
                end
            end
        end
    end
    return ans
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
        N = gi()
        M = gi()
        X::Vector{Int64} = fill(0,N)
        Y::Vector{Int64} = fill(0,N)
        for i in 1:N; X[i],Y[i] = gis(); end
        ans = solve(N,M,X,Y)
        print("$ans\n")
    end
end

main()
