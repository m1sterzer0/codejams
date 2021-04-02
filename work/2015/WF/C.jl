using Printf

######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")

        temp = split(readline(infile))
        N = parse(Int64,temp[1])
        num = temp[2][1] == '1' ? 1000000 : parse(Int64,temp[2][3:end])
        digits::Vector{Int8} = [parse(Int8,x) for x in readline(infile)]

        ## Consider the set of N+1 points defined by (0,0) joined with the n terms
        ## (prefix length,prefix ones).  We are looking for the two points here
        ## defining the line segement with slope closest to F.  We can normalize out
        ## the slope by subtracting the line segment y=Fx from the points above.  This
        ## turns the problem into looking for the two points with minimum
        ## absolute value slope.  Finally, it is hard to see, but easy to prove, that the 
        ## optimal answer occurs between two adjacent points when the list is sorted by
        ## y coordinate.  The rest is details...
        
        pts::Vector{Tuple{Int64,Int64}} = fill((0,0),N+1)
        for i in 1:N; pts[i+1] = (i,pts[i][2]+digits[i]); end
        pts2::Vector{Tuple{Int64,Int64}} = [(x[1],1000000*x[2]-num*x[1]) for x in pts]
        sort!(pts2,by=x->x[2])
        best,bestnum::Int128,bestdenom::Int128= -1,1000001,1
        for i in 1:N
            diffx,diffy = pts2[i+1][1]-pts2[i][1], pts2[i+1][2]-pts2[i][2]
            if diffx < 0; diffx = -diffx; end
            if diffy < 0; diffy = -diffy; end
            minx = min(pts2[i][1],pts2[i+1][1])
            v::Int128 = Int128(diffy)*bestdenom - Int128(diffx)*bestnum; 
            if (v < 0 || (v == 0 && minx < best))
                best,bestnum,bestdenom = minx,diffy,diffx
            end
        end
        print("$best\n")
    end
end

main()


