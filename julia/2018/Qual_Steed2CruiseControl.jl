######################################################################################################
### I love these interactive problems.  I have no idea whether this strategy is "optimal", but it
### seems good enough in that most of the time I am only waiting for one square to hit and often
### we are doing productive work while that is happening.
###
### OK, our stragegy is as follows
### - Deploy once, and whatever comes back is the upper left corner of our array. WLOG, call it 1,1
###   We refer to coordinates by (row, column) (so it looks like (y,x), with increasing y pointed down).
### - SMALL: we deploy at (2,2), (3,2), (4,2), (5,2), (6,2)
### - LARGE: we deply at (2,2), (3,2), (4,2), ... (19,2), THEN...
###                      (2,3), (3,3), (4,3), ... (19,3). THEN...
###                      ...
###                      (2,9), (3,9), (4,9), ... (19,9) (up to 144 deployments)
###   For both cases, our "move-on" criteria depends on whether we are in a non-final row & column
###   -- Non-final row and non-final column -- move on when the upper-left square is filled
###   -- Final row, non-final column -- move on when all 3 squares on the left are filled
###   -- Non-final row, final column -- move on when the top 3 squares are filled
###   -- final row, final column -- move on when all 9 squares are filled.
###
### I ran a 1000 cases with the python based tester, and I ended up with a mean of 497 (on the 200 case)
### and a stddev of 44. maximum --> minimum was (367 to 667) (-2.9 sigma to +3.8 sigma)  This appears
### to have a healthy margin to the 1000 limit.
######################################################################################################
function trySquare(y::Int64,x::Int64)
    print("$y $x\n"); flush(stdout);
    ny,nx = [parse(Int64,x) for x in split(rstrip(readline(stdin)))]
    return (ny,nx)
end

function doCase(A::Int64)
    ## Prepare the grid
    (N,M) = (A == 20) ? (7,3) : (20,10)
    grid = fill(0,N,M)
    cnt = 0
    ## Get a starter square
    (ny,nx) = trySquare(2,2); cnt += 1
    grid[1,1] = 1
    (cy,cx) = (A == 20) ? (2,2) : (3,2)

    while true
        (vy,vx) = trySquare(cy-1+ny,cx-1+nx); cnt += 1
        if vy == 0 
            print(stderr,"SUCCESS: Count:$cnt\n")
            break
        end
        if vy < 0; exit(1); end
        grid[vy-ny+1,vx-nx+1] = 1
        ## Check if we want to move the cursor
        done = false
        while !done
            done = true
            if cy+1 != N && cx+1 != M  ## Normal square
                if grid[cy-1,cx-1] == 1
                    cy += 1
                    done = false
                end
            elseif cx+1 != M           ## Bottom of column
                if grid[cy-1,cx-1] == grid[cy,cx-1] == grid[cy+1,cx-1] == 1
                    cx += 1; cy = 2
                    done = false
                end  
            elseif cy+1 != N           ## Rightmost column
                if grid[cy-1,cx-1] == grid[cy-1,cx] == grid[cy-1,cx+1] == 1
                    cy += 1
                    done = false
                end 
            end
        end 
    end
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(stdin))
    for qq in 1:tt
        A = parse(Int64,rstrip(readline(stdin)))
        doCase(A)
    end
end

main()
