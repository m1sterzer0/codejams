
function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        A,B = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        P = [parse(Float64,x) for x in split(rstrip(readline(infile)))]
        curp = 1.0
        cump = [1.0]
        for p in P; curp *= p; push!(cump,curp); end
        ans = 2.0 + B
        for bs in 0:A
            cand = 1+B-A+2*bs+(1.0-cump[A-bs+1])*(1+B)
            ans = min(cand,ans)
        end
        print("$ans\n")
    end
end

main()
