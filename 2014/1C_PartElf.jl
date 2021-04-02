######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        frac = readline(infile)
        P,Q = [parse(Int64,x) for x in split(frac,'/')]
        x = gcd(P,Q)
        P ÷= x; Q ÷= x;
        if 2^40 % Q != 0; print("impossible\n"); continue; end
        for i in 1:40
            if 2^i*P >= Q; print("$i\n"); break; end
        end
    end
end

main()
