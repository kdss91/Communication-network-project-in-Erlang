-module(calling).
-import(io,[fwrite/1,fwrite/2,format/2]).
-import(string,[concat/2]).
-import(lists,[nth/2]).	
-export([start/2]).
-export([for/3]).
-export([cmessagefn/1]).

for(0,_,_) -> io:fwrite(""); 
   
for(N,Name,Callees) when N >= 1 ->
	Callee = nth(N,Callees),
	CPid = whereis(Callee),
	random:seed(now()),
	timer:sleep(rand:uniform(100)),
	CPid!{intro,Name},
    for(N-1,Name,Callees).
   
   
start(Name,Callees) ->
	Len = length(Callees),
	for(Len,Name,Callees),
	cmessagefn(Name).


cmessagefn(Name) ->
		receive
				{reply,Msg,Mc} ->
					R = lists:flatten(io_lib:format("~s received reply message from ~s [~p]",[Name,Msg,Mc])),
					whereis(exchange)!{print,R},
					cmessagefn(Name);
				{intro,Msg} ->
					{M,S,Mc} = now(),
					L = lists:flatten(io_lib:format("~s received intro message from ~s [~p]",[Name,Msg,Mc])),
					whereis(exchange)!{print,L},
					random:seed(now()),
					timer:sleep(rand:uniform(100)),
					whereis(Msg)!{reply,Name,Mc},
				    cmessagefn(Name)
			after 8000 -> fwrite("Process ~p has received no calls for 1 second, ending...~n",[Name])
		end.






				