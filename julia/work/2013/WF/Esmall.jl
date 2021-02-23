function modinv(a::Int64,p::Int64)
    ans::Int64, factor::Int64, e::Int64 = [1,a,p-2]
    while (e > 0) 
        if e & 1 ≠ 0; ans = (ans * factor) % p; end
        factor = (factor * factor) % p
        e = e >> 1
    end
    return ans
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    fact::Vector{Int64} = fill(1,10001)
    factinv::Vector{Int64} = fill(1,10001)
    for i in 1:10000
        fact[i+1] = (fact[i] * i) % 10007
        factinv[i+1] = modinv(fact[i+1],10007)
    end
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,rstrip(readline(infile)))
        NN = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        noninc::Array{Int64,2} = fill(0,N,N)
        for i in 1:N; noninc[i,1] = 1; end
        for i in N-1:-1:1
            for j in i+1:N
                if NN[i] < NN[j]; continue; end
                for k in 1:N-1
                    noninc[i,k+1] = (noninc[i,k+1] + noninc[j,k]) % 10007
                end
            end
        end

        totperms = 0
        badperms = 0
        for i in 1:N
            for k in 1:N
                totinc = (fact[N-k+1] * noninc[i,k]) % 10007
                totperms = (totperms + totinc) % 10007
                if k > 1
                    badper = (fact[N-k+1] * k) % 10007
                    badinc = badper * noninc[i,k] % 10007
                    badperms = (badperms + badinc) % 10007
                end
            end
        end

        ans = totperms - badperms
        if ans < 0; ans += 10007; end
        print("$ans\n")
    end
end

main()

