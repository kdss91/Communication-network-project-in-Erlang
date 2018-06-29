-module(exchange).
-import(io,[fwrite/2,fwrite/1,format/2,format/1]).
-import(string,[concat/2]). 
-import(lists,[nth/2,sum/1]).
-import(calling,[start/2]).
-import(lists,[merge/1]). 
-export([main/0]).
-export([for/3]).
-export([messagefn/0]).


for(0,_,_) -> io:fwrite(""); 
   
for(N,MapKeys,CallsMap) when N > 0 ->
   Key = nth(N,MapKeys),
   Pid = spawn(calling, start, [Key, maps:get(Key,CallsMap)]),	
			register(Key,Pid),
   for(N-1,MapKeys,CallsMap). 
  
   
main()->
	register(exchange,self()),
	Str1 = "** Calls to be made **",
	fwrite("~s~n",[Str1]),
	Content = file:consult("calls.txt"),
	Tmp = tuple_to_list(Content),
	lists:foreach(
        fun(I)-> 
			Tmp2 = tuple_to_list(I),
			io:fwrite("~p: ~p~n", [nth(1,Tmp2),nth(2,Tmp2)]) end,
         nth(2,Tmp)
    ),
	fwrite("~n"),
	Clist = nth(2,Tmp),
	CallsMap = maps:from_list(Clist),
	MapKeys = maps:keys(CallsMap),
	KeyLength = length(MapKeys),
	for(KeyLength,MapKeys,CallsMap),
	messagefn().
	
	
messagefn() ->
		receive
				{print,Msg} ->
					format("~s~n",[Msg]),
					messagefn()
				after 8500 -> fwrite("Master has received no replies for 1.5 seconds, ending...~n")
		end.
	
	
