function tryit(x::Int64,t::Int64,CC::Array{Int64,2},C::Int64,twoX::Int64,twoN::Int64)::Int64
    ## Double times and distances to avoid fractions
    tmin::Int64,tmax::Int64,N::Int64 = -2,twoX+2,(twoN>>1)
    for i in 1:C
        s::Int64  = CC[i,1]
        t1::Int64 = CC[i,2]
        t2::Int64 = CC[i,4]
        x1::Int64 = (x + (t - t1)) % twoN; if x1 <= 0; x1 += twoN; end
        startdist::Int64 = x1 - s; if startdist < 0; startdist += twoN; end
        neededdist::Int64 = (t2-t1)*2
        if neededdist >= startdist
            tt1::Int64 = t1 + startdist ÷ 2
            if     tt1 == t; return 0
            elseif tt1 <= t; tmin=max(tmin,tt1)
            else;            tmax=min(tmax,tt1)
            end
            if neededdist >= startdist + twoN
                tt2::Int64 = tt1 + (twoN >> 1)
                if     tt2 == t; return 0
                elseif tt2 <= t; tmin=max(tmin,tt2)
                else             tmax=min(tmax,tt2)
                end
            end
        end
    end
    tmin += (tmin & 1 == 0) ? 2 : 1
    tmax -= (tmax & 1 == 0) ? 2 : 1
    return tmax ÷ 2 - tmin ÷ 2
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        C::Int64 = parse(Int64,rstrip(readline(infile)))
        X::Int64,N::Int64 = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        CC::Array{Int64,2} = fill(0,C,4)
        for i in 1:C
            s,e,t = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
            t2 = e > s ? t + (e-s) : t + (N-s) + e
            CC[i,:] = [2*s,2*t,2*e,2*t2]
        end
        if C == 0; print("$X\n"); continue; end
        twoX,twoN = 2*X,2*N
        best = 0
        for i in 1:C
            for (x,t) in ((CC[i,1],CC[i,2]),(CC[i,3],CC[i,4]))
                for xdel in (-2,0,2)
                    xx = x + xdel; xx = (xx == 0) ? twoN : (xx > twoN) ? xx - twoN : xx
                    for tdel in (-2,0,2)
                        tt = t + tdel
                        if tt < 0 || tt > twoX; continue; end
                        a::Int64 = tryit(xx,tt,CC,C,twoX,twoN) 
                        best = max(best,a)
                    end
                end
            end
        end
        print("$best\n")
    end
end

main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("A.in")
#Profile.clear()
#@profilehtml main("Atc1.in")
