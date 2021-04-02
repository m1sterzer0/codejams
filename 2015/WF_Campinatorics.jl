using Printf

function modadd(a::Int64,b::Int64)::Int64
    s::Int64 = a + b; return s >= 1000000007 ? s-1000000007 : s
end

function modsub(a::Int64,b::Int64)::Int64
    s::Int64 = a - b; return s < 0 ? s + 1000000007 : s
end

function modmul(a::Int64,b::Int64)::Int64
    return (a*b) % 1000000007
end

function modinv(a::Int64)::Int64
    ans::Int64 = 1
    factor::Int64 = a
    e::Int64 = 1000000007-2
    while (e > 0)
        if e & 1 ≠ 0; ans = modmul(ans,factor); end
        factor = modmul(factor,factor)
        e = e >> 1
    end
    return ans
end


######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function main(infn="")
    fact    = zeros(Int64,1000000)
    factinv = zeros(Int64,1000000)
    derangements = zeros(Int64,1000000)

    t::Int64 = 1
    for i in 1:1000000; t = modmul(t,i); fact[i] = t; end
    t = 1
    for i in 1:1000000; a = modinv(i); t = modmul(t,a); factinv[i] = t; end
    derangements[1] = 0
    derangements[2] = 1
    for i in 3:1000000; derangements[i] = modmul(i-1,modadd(derangements[i-1],derangements[i-2])); end

    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")

        N,X = [parse(Int64,x) for x in split(readline(infile))]
        ans = 0
        for x in X:N
            ## Answer for x is C(N,x) * N!/(N-x)! * (N-x)! * !(N-x)
            ##  = N! / x! / (N-x)! * N! / (N-x)! * (N-x)! * !(N-x)
            ##  = N! * N! / x! /(N-x)! * !*(N-x)
            t = 1
            t = modmul(t,N==0 ? 1 : fact[N])
            t = modmul(t,N==0 ? 1 : fact[N])
            t = modmul(t,x==0 ? 1 : factinv[x])
            t = modmul(t,x==N ? 1 : factinv[N-x])
            t = modmul(t,x==N ? 1 : derangements[N-x])
            ans = modadd(ans,t)
        end
        print("$ans\n")
    end
end

main()

