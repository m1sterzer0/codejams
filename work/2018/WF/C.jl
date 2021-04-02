function getn(v::Int64,n::Int64)
    infile = stdin
    ss = join(fill(v,n),"\n")
    print("$ss\n")
    flush(stdout)
    vals = [parse(Int64,readline(infile)) for i in 1:n]
    return vals
end

function analyze(vals,cnt,sb,num)
    ## Return value
    ## -2 if we are maxed
    ## -1 if we changed
    ##  0 if we only have 1 viable number left
    ##  1 if we are the same
    newsb = fill(-1,25)
    if sum(vals) == num; return -2,newsb; end
    res,goodcnt = 1,0
    for n in 2:25
        if sb[n] == -1; newsb[n] = -1; continue; end
        offset = cnt ÷ n == 0 ? 0 : n - (cnt % n)
        cand = sum(vals[offset+1:offset+n])
        if cand == n; newsb[n] = -1; continue; end
        good = true
        while offset+n <= num
            if sum(vals[offset+1:offset+n]) != cand
                good = false
                break
            end
            offset += n
        end
        newsb[n] = good ? cand : -1
        if newsb[n] >= 0 && newsb[n] > sb[n]; res = -1; end
        if newsb[n] >= 0; goodcnt += 1; end
    end
    if goodcnt == 1; res = 0; end
    #print(stderr,"DBG: sb:$sb\n")
    #print(stderr,"DBG: newsb:$newsb\n")
    valstr = join(vals,"")
    #print(stderr,"DBG: valstr:$valstr\n")
    #print(stderr,"DBG: res:$res\n")

    return res,newsb
end

function processsb(sb)
    ans = -2 
    for i in 2:25
        if sb[i] > 0; ans = -i; break; end
    end
    print("$ans\n"); flush(stdout)
    #print(stderr, "DBG: Answering $ans\n")
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        #print(stderr,"DBG: STARTING CASE\n")
        ss = parse(Int64,readline(infile))
        cnt = 0
        if ss != 100_000; exit(); end
        l,u = 0,0
        sb = fill(0,25)
        done = false
        for i in 1:12
            l,u = u,1_000_000
            while (u-l) > 1
                m = (u+l) ÷ 2
                #print(stderr,"DBG: m:$m\n")
                vals = getn(m,300); cnt += 300
                res,newsb = analyze(vals,cnt-300,sb,300)
                if res == 0; processsb(newsb); done=true; break; end
                if res > 0; l=m; else; u=m; end
            end
            if done; break; end
            #print(stderr,"DBG: u:$u\n")
            vals = getn(u,1250); cnt += 1250
            res,newsb = analyze(vals,cnt-1250,sb,1250)
            if res == -2; processsb(sb); done=true; break; end
            if res == 0; processsb(newsb); done=true; break; end
            sb = newsb
        end
        if !done; processsb(sb); end
    end
end

main()


