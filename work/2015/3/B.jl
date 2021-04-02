######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        solveit(infile)
        #@time solveit(infile)
    end
end

function solveit(infile)
    N,K =    [parse(Int64,x) for x in split(readline(infile))]
    sumarr = [parse(Int64,x) for x in split(readline(infile))]

    minmodk = zeros(Int64,K)
    maxmodk = zeros(Int64,K)
    lastmodk = zeros(Int64,K)

    for i in 1:length(sumarr)-1
        v = sumarr[i+1]-sumarr[i]
        idx = ((i-1) % K) + 1
        lastmodk[idx] += v
        if lastmodk[idx] < minmodk[idx]; minmodk[idx] = lastmodk[idx]; end
        if lastmodk[idx] > maxmodk[idx]; maxmodk[idx] = lastmodk[idx]; end
    end

    ## Now we line up the bottoms of the ranges for all of the indices
    sumfirstk = 0
    for i in 1:K
        delta = -minmodk[i]
        minmodk[i] += delta
        maxmodk[i] += delta
        sumfirstk += delta
    end

    maxrange = maximum(maxmodk)
    slop = 0
    for i in 1:K; slop += maxrange - maxmodk[i]; end

    ## Now we use sumarr[1] to figure out our target, and to figure out if we are
    ## at the maximum of the ranges of the mod K terms or if we need to 'add 1' for
    ## enough slop to achieve the desired sumarr[1] sum.
    neededExtra = (sumarr[1] - sumfirstk) % K
    if neededExtra < 0; neededExtra += K; end
    ans = neededExtra > slop ? maxrange+1 : maxrange
    print("$ans\n")
end

main()
