######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        C,F,X = [parse(Float64,x) for x in split(readline(infile))]
        t,f = 0.0,0
        while true
            r1 = 2.0 + F*f
            t1 = X /r1 ## Finishing time if we do not buy the next cookie
            r2 = r1 + F
            t2 = C / r1 + X / r2
            if t1 <= t2
                t += t1
                print("$t\n")
                break
            else
                t += C / r1
                f += 1
            end
        end
    end
end

main()            
