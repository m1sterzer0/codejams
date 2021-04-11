gs()::String = rstrip(readline(stdin))
gi()::Int64 = parse(Int64, gs())
gf()::Float64 = parse(Float64,gs())
gss()::Vector{String} = split(gs())
gis()::Vector{Int64} = [parse(Int64,x) for x in gss()]
gfs()::Vector{Float64} = [parse(Float64,x) for x in gss()]

function solve(B::Int64)
    diffidx,sameidx = 0,0
    invdiff,invsame = false,false
    ans = fill('0',B)
    idx = 0
    ## Iterate through pairs
    for i in 1:71
        if i % 5 == 1
            if diffidx > 0; print("$diffidx\n"); flush(stdout); a = gs(); invdiff = ans[diffidx] != a[1]
            else; print("1\n"); flush(stdout); a = gs()
            end

            if sameidx > 0; print("$sameidx\n"); flush(stdout); a = gs(); invsame = ans[sameidx] != a[1]
            else; print("1\n"); flush(stdout); a = gs()
            end
        elseif idx < B÷2
            idx += 1
            jidx = B+1-idx
            print("$idx\n$jidx\n"); flush(stdout); a = gs(); b = gs();
            if a[1] == b[1]; sameidx = idx; else; diffidx = idx; end
            invflag = a[1] == b[1] ? invsame : invdiff
            ans[idx]  = invflag ? (a[1] == '0' ? '1' : '0') : a[1]
            ans[jidx] = invflag ? (b[1] == '0' ? '1' : '0') : b[1]
        else
            print("1\n1\n"); flush(stdout); a = gs(); b = gs()
        end
    end

    fans = fill('0',B)
    for i in 1:B÷2
        j = B+1-i
        invflag = ans[i] == ans[j] ? invsame : invdiff 
        if invflag; fans[i] = ans[i] == '0' ? '1' : '0'; fans[j] = ans[j] == '0' ? '1' : '0'
        else ; fans[i] = ans[i]; fans[j] = ans[j]
        end
    end
    ansstr = join(fans,"")
    print("$ansstr\n")
    flush(stdout)
    return gs()
end

function main(infn="")
    tt,B = gis()
    for qq in 1:tt
        solve(B)
    end
end

main()
