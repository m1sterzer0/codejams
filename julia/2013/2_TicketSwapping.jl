
function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N,M = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        entry::Vector{Tuple{Int64,Int64}} = []
        exit::Vector{Tuple{Int64,Int64}} = []
        ontrain::Vector{Tuple{Int64,Int64}} = []
        fullprice::Int64 = 0
        lowprice::Int64 = 0
        for i in 1:M
            o,e,p = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
            dist = e-o
            priceper = (N*dist-dist*(dist-1)÷2) % 1_000_002_013
            price = (p*priceper) % 1_000_002_013
            fullprice = (fullprice + price) % 1_000_002_013
            push!(entry,(o,p))
            push!(exit,(e,p))
        end
        sort!(entry)
        sort!(exit)
        while !isempty(entry) || !isempty(exit)
            if isempty(exit) || !isempty(entry) && entry[1][1] <= exit[1][1]
                (o,p) = popfirst!(entry)
                push!(ontrain,(o,p))
            else
                (e,p) = popfirst!(exit)
                while (p > 0)
                    (o,pp) = pop!(ontrain)
                    dist = e-o
                    priceper = (N*dist-dist*(dist-1)÷2) % 1_000_002_013
                    if pp <= p
                        price = (pp*priceper) % 1_000_002_013
                        lowprice = (lowprice + price) % 1_000_002_013
                        p -= pp
                    else
                        price = (p*priceper) % 1_000_002_013
                        lowprice = (lowprice + price) % 1_000_002_013
                        pp -= p
                        p = 0
                        push!(ontrain,(o,pp))
                    end
                end
            end
        end
        ans = fullprice - lowprice
        if ans < 0; ans += 1_000_002_013; end
        print("$ans\n")
    end
end

main()

