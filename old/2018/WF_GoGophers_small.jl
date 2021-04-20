function getn(v::Int64,n::Int64)
    infile = stdin
    ss = join(fill(v,n),"\n")
    print("$ss\n")
    flush(stdout)
    vals = [parse(Int64,readline(infile)) for i in 1:n]
    return vals
end

function findfirst(l::Int64,u::Int64)
    cnt = 0
    while (u-l) > 1
        m = (u+l) ÷ 2
        vals = getn(m,50)
        cnt += 50
        if sum(vals) > 0; u = m; else; l = m; end
    end
    return u,cnt
end

function analyze(res,cnt) 
    for n in 2:25
        offset = cnt ÷ n == 0 ? 0 : n - cnt % n
        good = true
        while offset+n <= 625
            if sum(res[offset+1:offset+n]) != 1
                good = false
                break
            end
            offset += n
        end
        if good; return n; end
    end
    return 2  ## Should not get here
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        ss = parse(Int64,readline(infile))
        if ss != 100_000; exit(); end
        m,cnt = findfirst(0,1_000_000)
        res = getn(m,625); cnt+=625
        ans = analyze(res,cnt-625)
        print("$(-ans)\n")
        flush(stdout)
    end
end

main()


