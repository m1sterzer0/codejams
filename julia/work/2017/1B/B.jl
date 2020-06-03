using Printf

######################################################################################################
### First, consider the case of just primary colors
### a) If we have a color with a clear MAJORITY, then things are impossible, since we don't have
###    enough other unicorns to put between them.
### b) If we don't have a horse with a clear majority, there is an easy algorithm for a solution.  Lets
###    say there are b blue unicorns, r red unicorns, and y yellow unicorns.  Furthermore, WLOG, assume
###    that b >= r and b >= y.
### c) We need exactly b segments to stick between the blue unicorns.  We claim we can make them out of
###    segemnts of  the following forms {'R','RY','Y'}.  Using a bit of algebra, we claim that we need
###    (r+y-b) "RY" strings, (b-y) "R" strings, and (b-r) "Y" strings.
###    --- b >= y and b >= r, so b-y and b-r are non-negative
###    --- There is no majority, so r+y-b is >= 0.
###    --- Note (r+y-b) + (b-y) = r, and (r+y-b) + (b-r) = y
###
### Now for the large case.
### a) Note that every hybrid must be surrounded on both sides by the opposite primary color.  That collection of
###    3 unicorns logically just looks like one horse of the primary color.
### 
### b) Thus, we need B >= O + 1, Y >= V + 1, and R >= G + 1.  Otherwise, this is impossible.
### c) Finally, we can just replace B+1 blues as one logical Blue (same for red and yellow), solve the primary
###    case above, and then replace on blue/orange/yellow with the collection needed to hide the O's, V's, and G's.
### d) There is a corner case! If we only have B's and O's, and we have the same number, we can still make the circle.
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N,R,O,Y,G,B,V = [parse(Int64,x) for x in split(rstrip(readline(infile)))]

        ## Check for the hybrid corner cases
        if B + O == N && B == O; s = "OB"^(N ÷ 2); print("$s\n"); continue; end;
        if R + G == N && R == G; s = "GR"^(N ÷ 2); print("$s\n"); continue; end;
        if Y + V == N && Y == V; s = "VY"^(N ÷ 2); print("$s\n"); continue; end;

        ## Check to see if we have too many hybrids
        if O > 0 && B <= O; print("IMPOSSIBLE\n"); continue; end
        if G > 0 && R <= G; print("IMPOSSIBLE\n"); continue; end
        if V > 0 && Y <= V; print("IMPOSSIBLE\n"); continue; end

        ## Subtract off the hybrids
        r = R-G; y = Y-V; b = B-O
        
        ## Check for a majority
        if r > b + y || b > r + y || y > b + r; print("IMPOSSIBLE\n"); continue; end

        ## Solve the primary case
        solve(x,y,z) = (y+z-x,x-z,x-y)
        if (r >= b && r >= y)
            (pairs,sing1,sing2) = solve(r,y,b)
            arr1 = ["R" for i in 1:r]
            arr2 = vcat(fill("YB",pairs),fill("Y",sing1),fill("B",sing2))
        elseif (y >= r && y >= b)
            (pairs,sing1,sing2) = solve(y,b,r)
            arr1 = ["Y" for i in 1:y]
            arr2 = vcat(fill("BR",pairs),fill("B",sing1),fill("R",sing2))
        elseif (b >= r && b >= y)
            (pairs,sing1,sing2) = solve(b,r,y)
            arr1 = ["B" for i in 1:b]
            arr2 = vcat(fill("RY",pairs),fill("R",sing1),fill("Y",sing2))
        end

        ## Interleve the two strings
        ans = reduce(*,[x*y for (x,y) in zip(arr1,arr2)])

        ## Now we substitute our hybrid sequences in
        ans = replace(ans,"B" => "BO"^O*"B", count=1)
        ans = replace(ans,"R" => "RG"^G*"R", count=1)
        ans = replace(ans,"Y" => "YV"^V*"Y", count=1)

        print("$ans\n")
    end
end

main()