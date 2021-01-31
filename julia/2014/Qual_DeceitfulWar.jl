######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        ans = 0
        N = parse(Int64,readline(infile))
        naomi = [parse(Float64,x) for x in split(readline(infile))]
        ken   = [parse(Float64,x) for x in split(readline(infile))]
        sort!(naomi,rev=true)
        sort!(ken,rev=true)

        kenWins = 0
        kenptr = 1
        for i in 1:N
            if ken[kenptr] > naomi[i]; kenWins += 1; kenptr += 1; end
        end
        fairWins = N - kenWins

        deceitfulWins = 0
        naomiptr = 1
        for i in 1:N
            if naomi[naomiptr] > ken[i]; deceitfulWins += 1; naomiptr+=1; end
        end
        
        print("$deceitfulWins $fairWins\n")
    end
end

main()
