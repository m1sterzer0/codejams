
function tryit(B::Int64,X::Vector{Int64},numAtMin::Int64)
    ## Calc minimum required
    ## If budget < min, return 0.00
    ## Calc max I can spend -- need to keep last column above my chips
    ## Calc Profit
    if X[numAtMin] > X[37]-2; return 0.00; end
    minrequired = 0
    maxallowed = 0
    for i in 1:37
        minht = i<=numAtMin ? X[numAtMin] : X[numAtMin]+1
        maxht = 1<=numAtMin ? X[37]-2 : X[37]-1
        minrequired += minht > X[i] ? minht-X[i] : 0
        maxallowed += maxht > X[i] ? maxht-X[i] : 0
    end
    if minrequired > B || maxallowed < minrequired; return 0.00; end
    level = X[37]-2
    if maxallowed > B
        l,u=X[numAtMin],X[37]-2
        while (u-l) > 1
            m = (u+l)÷2
            needed::Int64 = 0
            for i in 1:numAtMin;    needed += X[i] >= m   ? 0 : m-X[i]; end
            for i in numAtMin+1:37; needed += X[i] >= m+1 ? 0 : m-X[i]+1; end
            if needed <= B; l = m; else; u = m; end
        end
        level = l
    end
    spent = 0
    for i in 1:numAtMin;    spent += X[i] >= level   ? 0 : level-X[i]; end
    for i in numAtMin+1:37; spent += X[i] >= level+1 ? 0 : level-X[i]+1; end
    received,frac = 0,36.0/numAtMin
    for i in 1:numAtMin; received += X[i] >= level   ? 0 : level-X[i]; end
    return frac * received - spent
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        B,N = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        X::Vector{Int64} = fill(0,37)
        X[1:N] = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        sort!(X)
        best::Float64 = 0.00
        for numAtMin in 1:36
            ans = tryit(B,X,numAtMin)
            best = max(ans,best)
        end
        print("$best\n")
    end
end

main()

