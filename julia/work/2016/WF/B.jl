using Printf

######################################################################################################
### 1) We can use a NFA or DFA to represent a regex.  The NFA is simpler, so we use that for this.
### 2) https://en.wikipedia.org/wiki/Thompson%27s_construction for reference
######################################################################################################

function parseRegex(ns::Int64,ne::Int64,nn::Int64,gr,epsgr,R,rs::Int64,re::Int64)
    if re < rs
        return nn
    elseif R[re] in "0123456789"
        if rs == re 
            gr[ns][R[re]] = ne
            return nn
        else
            gr[nn][R[re]] = ne
            ne = nn
            nn += 1
            return parseRegex(ns,ne,nn,gr,epsgr,R,rs,re-1)
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
                push!(epsgr[nextEnd],nn)
                push!(epsgr[nn+1],ne)
                push!(epsgr[nn+1],nn)
                push!(epsgr[nextEnd],ne)
                nn = parseRegex(nn,nn+1,nn+2,gr,epsgr,R,repstart+1,re-2)
                return parseRegex(ns,nextEnd,nn,gr,epsgr,R,rs,repstart-1)
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
                    push!(epsgr[nextEnd],nn)
                    push!(epsgr[nn+1],ne)
                    nn = parseRegex(nn,nn+1,nn+2,gr,epsgr,R,st,en)
                end
                return parseRegex(ns,nextEnd,nn,gr,epsgr,R,rs,repstart-1)
            end
        end
    end
end
### Had to cheat on this part

## Should be much less than 60 states, so we can use a bit vector for the state
function expandStates(a::Int64)
    ans = Set{Int64}()
    for i in 1:60
        if a & (1 << i) > 0; push!(ans,i); end
    end
    return ans
end

function compressStates(a::Set{Int64})
    ans = 0
    for i in 1:60
        if i ∈ a; ans = ans | (1 << i); end
    end
    return ans
end

function countMatchesLessThanOrEqual(X::Int64,gr,epsgr)
    xstr = "$X"
    countState = Dict{Tuple{Bool,Bool,Int64},Int64}()
    initState = compressStates(epsgr[1])
    countState[(true,true,initState)] = 1
    for (i,c) in enumerate(xstr)
        newCountState = Dict{Tuple{Bool,Bool,Int64},Int64}()
        for ((isEmpty,isPrefix,compStateSet),oldCount) in countState
            stateSet = expandStates(compStateSet)
            for d in "0123456789"
                if d == '0' && isEmpty; continue; end
                if isPrefix && d > xstr[i]; continue; end
                newIsPrefix = (isPrefix && d == xstr[i])
                newStates = Set{Int64}()
                for s in stateSet
                    if !haskey(gr[s],d); continue; end
                    union!(newStates,epsgr[gr[s][d]])
                end
                if isempty(newStates); continue; end
                compNewStates = compressStates(newStates)
                if haskey(newCountState,(false,newIsPrefix,compNewStates));
                    newCountState[(false,newIsPrefix,compNewStates)] += oldCount
                else
                    newCountState[(false,newIsPrefix,compNewStates)] = oldCount
                end
            end
            newCountState[(true,false,initState)] = 1
        end
        countState = newCountState
    end
    ans::Int64 = 0
    for ((isEmpty,isPrefix,compStateSet),oldCount) in countState
        if !isEmpty && compStateSet & (1 << 2) > 0
            ans += oldCount
        end
    end
    return ans
end

function completeEpsgr(epsgr,gr,maxNumNodes)
    function dfs(epsgr,i,j,visited)
        if j in visited; return; end
        push!(visited,j)
        push!(epsgr[i],j)
        for k in epsgr[j]
            dfs(epsgr,i,k,visited)
        end
    end

    for i in 1:maxNumNodes
        if !isempty(gr[i]); push!(epsgr[i],i); end
        if isempty(epsgr[i]); continue; end
        visited = Set{Int64}()
        for j in epsgr[i]; dfs(epsgr,i,j,visited); end
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
        gr = [Dict{Char,Int64}() for x in 1:maxNumNodes]
        epsgr = [Set{Int64}() for x in 1:maxNumNodes]
        parseRegex(1,2,3,gr,epsgr,R,1,length(R))
        push!(epsgr[2],2)  
        completeEpsgr(epsgr,gr,maxNumNodes)
        ans = countMatchesLessThanOrEqual(B,gr,epsgr)
        if A > 1; ans -= countMatchesLessThanOrEqual(A-1,gr,epsgr); end
        print("$ans\n")
    end
end

main()