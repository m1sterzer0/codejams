using Printf

######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    pr() = print("RICHARD\n")
    pg() = print("GABRIEL\n")
    for qq in 1:tt
        print("Case #$qq: ")
        X,R,C = [parse(Int64,x) for x in split(readline(infile))]
        r,c = [min(R,C),max(R,C)]
        if (r*c) % X != 0; pr() ## Area of region isn't a multiple of X, so impossible
        elseif X == 1; pg()  ## Only one 1-omino, and it tiles easily
        elseif X == 2; pg()  ## Only one 2-omino, and it tiles easily
            ## KEY piece
            ##  x
            ##  xx
        elseif X == 3; r == 1 ? pr() : pg()
            ## KEY piece
            ##  xx
            ##   xx
        elseif X == 4; r <= 2 ? pr() : pg()
            ## KEY piece
            ##  x    
            ##  xx    
            ##   xx 
        elseif X == 5; r <= 2 ? pr() : (r == 3 && c == 5) ? pr() : pg()  ## piece requires at least 3x10 region if r == 3
            ## KEY piece
            ##   x    
            ##  xxxx    
            ##   x 
        elseif X == 6; r <= 3 ?  pr() : pg() ## key piece divides triple row into two regions that can never be divisible by 6
        else; pr() ## Can create an unfillable hole with X >= 7
        end
    end
end

main()
