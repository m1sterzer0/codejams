
using Random
infile = stdin
## Type Shortcuts (to save my wrists and fingers :))
const I = Int64; const VI = Vector{I}; const SI = Set{I}; const PI = NTuple{2,I};
const TI = NTuple{3,I}; const QI = NTuple{4,I}; const VPI = Vector{PI}; const SPI = Set{PI}
const VC = Vector{Char}; const VS = Vector{String}; VB = Vector{Bool}; VVI = Vector{Vector{Int64}}
const F = Float64; const VF = Vector{F}; const PF = NTuple{2,F}

gs()::String = rstrip(readline(infile))
gi()::Int64 = parse(Int64, gs())
gf()::Float64 = parse(Float64,gs())
gss()::Vector{String} = split(gs())
gis()::Vector{Int64} = [parse(Int64,x) for x in gss()]
gfs()::Vector{Float64} = [parse(Float64,x) for x in gss()]

function parseRegex(ns::I,ne::I,nn::I,gr::Vector{Dict{Char,I}},
                    epsgr::Vector{SI},R::String,rs::I,re::I)
    if re < rs; return nn; end
    if R[re] in "0123456789"
        if rs == re; gr[ns][R[re]] = ne; return nn; end
        gr[nn][R[re]] = ne; ne = nn; nn += 1
        return parseRegex(ns,ne,nn,gr,epsgr,R,rs,re-1)
    end
    if R[re] == '*'
        nestingLevel::I = 0
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
    end

    ## ELSE case
    nestingLevel = 0
    pipes::VI = []
    for repstart::I in re:-1:rs
        if R[repstart] == ')'
            nestingLevel += 1
        elseif R[repstart] == '|' && nestingLevel == 1
            push!(pipes,repstart)
        elseif R[repstart] == '('
            nestingLevel -= 1
            if nestingLevel > 0; continue; end
            unionStarts::VI = []
            unionEnds::VI = []
            push!(unionEnds,re-1)
            for p in pipes; push!(unionStarts,p+1); push!(unionEnds,p-1); end
            push!(unionStarts,repstart+1)
            nextEnd::I = ns
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

## Should be much less than 60 states, so we can use a bit vector for the state
function expandStates(a::I)::SI
    ans::SI = SI()
    for i::I in 1:60; if a & (1 << i) > 0; push!(ans,i); end; end
    return ans
end

function compressStates(a::SI)::I
    ans::I = 0
    for i::I in 1:60; if i ∈ a; ans = ans | (1 << i); end; end
    return ans
end

function countMatchesLessThanOrEqual(X::I,gr::Vector{Dict{Char,I}},epsgr::Vector{SI})::I
    xstr::String = "$X"
    countState::Dict{Tuple{Bool,Bool,I},I} = Dict{Tuple{Bool,Bool,I},I}()
    initState::I = compressStates(epsgr[1])
    countState[(true,true,initState)] = 1
    for (i,c) in enumerate(xstr)
        newCountState::Dict{Tuple{Bool,Bool,I},I} = Dict{Tuple{Bool,Bool,Int64},Int64}()
        for ((isEmpty::Bool,isPrefix::Bool,compStateSet::I),oldCount::I) in countState
            stateSet::SI = expandStates(compStateSet)
            for d in "0123456789"
                if d == '0' && isEmpty; continue; end
                if isPrefix && d > xstr[i]; continue; end
                newIsPrefix::Bool = (isPrefix && d == xstr[i])
                newStates = SI()
                for s::I in stateSet
                    if !haskey(gr[s],d); continue; end
                    union!(newStates,epsgr[gr[s][d]])
                end
                if isempty(newStates); continue; end
                compNewStates::I = compressStates(newStates)
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
    ans::I = 0
    for ((isEmpty,isPrefix,compStateSet),oldCount) in countState
        if !isEmpty && compStateSet & (1 << 2) > 0
            ans += oldCount
        end
    end
    return ans
end

function completeEpsgr(epsgr::Vector{SI},gr::Vector{Dict{Char,I}},maxNumNodes::I)
    function dfs(epsgr::Vector{SI},i::I,j::I,visited::SI)
        if j in visited; return; end
        push!(visited,j)
        push!(epsgr[i],j)
        for k in epsgr[j]
            dfs(epsgr,i,k,visited)
        end
    end

    for i::I in 1:maxNumNodes
        if !isempty(gr[i]); push!(epsgr[i],i); end
        if isempty(epsgr[i]); continue; end
        visited::SI = SI()
        for j in epsgr[i]; dfs(epsgr,i,j,visited); end
    end
end 

######################################################################################################
### 1) We can use a NFA or DFA to represent a regex.  The NFA is simpler, so we use that for this.
### 2) https://en.wikipedia.org/wiki/Thompson%27s_construction for reference
######################################################################################################

function solve(A::I,B::I,R::String)::I
    maxNumNodes = 100
    gr::Vector{Dict{Char,I}} = [Dict{Char,I}() for x in 1:maxNumNodes]
    epsgr::Vector{SI} = [SI() for x in 1:maxNumNodes]
    parseRegex(1,2,3,gr,epsgr,R,1,length(R))
    push!(epsgr[2],2)  
    completeEpsgr(epsgr,gr,maxNumNodes)
    ans = countMatchesLessThanOrEqual(B,gr,epsgr)
    if A > 1; ans -= countMatchesLessThanOrEqual(A-1,gr,epsgr); end
    return ans
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        A,B = gis()
        R = gs()
        ans = solve(A,B,R)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

