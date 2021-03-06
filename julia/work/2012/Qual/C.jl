function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        A,B = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        numdig = length(string(A))
        working = Set{String}()
        sb = string(B)
        ans = 0
        for n in A:B
            empty!(working)
            sn = string(n)
            for i in 1:numdig-1
                if sn[i+1] == '0' || sn[i+1] < sn[1]; continue; end  ##quick checks
                sm = sn[i+1:end]*sn[1:i]
                if sm > sn && sm <= sb && sm ∉ working
                    ans += 1
                    push!(working,sm)
                end
            end
        end
        print("$ans\n")
    end
end

main()
