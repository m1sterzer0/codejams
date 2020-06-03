using Printf

######################################################################################################
### Observations
### If we split that letters into 4 classes (by letter and parity)
###     Ce -- C's in even numbered positions
###     Co -- C's in odd numbered positions
###     Je -- J's in even numbered positions
###     Jo -- J's in odd numbered positions
### We notice that every 10 must be achieved either by matching a Je<->Jo or Ce<->Co (since, because
### of the "stack" nature of the left over problem, there must be an even number of steps between these
### two events).  We also notice we should never get anything less than 5 (e.g. can always pick up an
### "in-mood" problem).  Thus, the upper bound is 5*((Ce+Co+Je+Jo) ÷ 2 + min(Ce,Co) + min(Je,Jo)).
###
### We also notice that this bound is realizable by taking adjacent matches and pairing
### them for a 10-point turn-in and then removing them from the (linked) list.  This operation
### doesn't change the parity of the positions of any of the remaining items and always pairs a Ce<->Co or
### Je<->Jo.  Once there are no more matches, we know that min(Ce,Co) == 0 and min(Je,Jo) == 0.
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        S = rstrip(readline(infile))
        co = count(x->x=='C', S[1:2:end])
        ce = count(x->x=='C', S[2:2:end])
        jo = count(x->x=='J', S[1:2:end])
        je = count(x->x=='J', S[2:2:end])
        ans = 5 * ( (ce + co + je + jo) ÷ 2 + min(je,jo) + min(ce,co) )
        print("$ans\n")
    end
end

main()