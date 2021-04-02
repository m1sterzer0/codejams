using Printf

######################################################################################################
### 1) We can use a NFA or DFA to represent a regex.  The NFA is simpler, so we use that for this.
### 2) https://en.wikipedia.org/wiki/Thompson%27s_construction for reference
######################################################################################################

function parseRegex(ns::Int64,ne::Int64,nn::Int64,gr,R,rs::Int64,re::Int64)
    if re < rs
        return nn
    elseif R[re] in "0123456789"
        if rs == re 
            gr[ns][ne] = R[re]
            return nn
        else
            gr[nn][ne] = R[re]
            ne = nn
            nn += 1
            return parseRegex(ns,ne,nn,gr,R,rs,re-1)
        end
    elseif R[re] == '*'
        nestingLevel = 0
        for repstart in re:-1:rs
            if R[repstart] == ')'
                nestingLevel += 1
            elseif R[repstart] == '('
                nestingLevel -= 1
                if nestingLevel > 0; continue; end
                nextEnd = ns
                if repstart != rs; nextEnd = nn; nn += 1; end
                gr[nextEnd][nn] = 'e'
                gr[nn+1][ne] = 'e'
                gr[nn+1][nn] = 'e'
                nn = parseRegex(nn,nn+1,nn+2,gr,R,repstart+1,re-2)
                return parseRegex(ns,nextEnd,nn,gr,R,rs,repstart-1)
            end
        end
    else
        nestingLevel = 0
        pipes = []
        for repstart in re:-1:rs
            if R[repstart] == ')'
                nestingLevel += 1
            elseif R[repstart] == '|' && nestingLevel == 1
                push!(pipes,repstart)
            elseif R[repstart] == '('
                nestingLevel -= 1
                if nestingLevel > 0; continue; end
                unionStarts = []
                unionEnds = []
                push!(unionEnds,re-1)
                for p in pipes; push!(unionStarts,p+1); push!(unionEnds,p-1); end
                push!(unionStarts,repstart+1)
                nextEnd = ns
                if repstart != rs; nextEnd = nn; nn += 1; end
                for (st,en) in zip(unionStarts,unionEnds)
                    gr[nextEnd][nn] = 'e'
                    gr[nn+1][ne]    = 'e'
                    nn = parseRegex(nn,nn+1,nn+2,gr,R,st,en)
                end
                return parseRegex(ns,nextEnd,nn,gr,R,rs,repstart-1)
            end
        end
    end
end

  
function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        A,B = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        R = rstrip(readline(infile))

        maxNumNodes = 100
        gr = [Dict{Int64,Char}() for x in 1:maxNumNodes]
        parseRegex(1,2,3,gr,R,1,length(R))

        ans = 0
        print("$ans\n")
    end
end

main("B.in")