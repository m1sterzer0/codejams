
function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    toys::Array{Int64,2} = fill(0,100,2)
    boxes::Array{Int64,2} = fill(0,100,2)
    dp::Array{Int64,2} = fill(0,101,101)

    for qq in 1:tt
        print("Case #$qq: ")
        N,M = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        NN = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        MM = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        aa = fill(0,101)
        bb = fill(0,101)
        for i in 1:N; toys[i,:] = NN[2*i-1:2*i]; end
        for i in 1:M; boxes[i,:] = MM[2*i-1:2*i]; end
        fill!(dp,0)
        for i in 1:N
            for j in 1:M
                val = max(dp[i+1,j],dp[i,j+1])
                if toys[i,2] == boxes[j,2]
                    fill!(aa,0); fill!(bb,0)
                    aa[i] = toys[i,1]; bb[j] = boxes[j,1]
                    for a in i-1:-1:1; aa[a] = aa[a+1] + (toys[a,2]==toys[i,2] ? toys[a,1] : 0); end
                    for b in j-1:-1:1; bb[b] = bb[b+1] + (boxes[b,2]==boxes[j,2] ? boxes[b,1] : 0); end
                    for a in 1:i
                        for b in 1:j
                            cand = dp[a,b] + min(aa[a],bb[b])
                            val = max(val, cand)
                        end
                    end
                end
                dp[i+1,j+1] = val
            end
        end
        ans = dp[N+1,M+1]
        print("$ans\n")
    end
end

main()

