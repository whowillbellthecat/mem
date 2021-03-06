:- dynamic(repetition/3). :- multifile(repetition/3). :- dynamic(score/2). :- include('config.pl').
pdf(X,Y):-atom_concat(X,'.pdf',Y). pdf(X) :- pdf(_,X).
filter(_,[],[]). filter(P,[X|Xs],Y):-(call(P,X)->Y=[X|Ys];Y=Ys),filter(P,Xs,Ys).
atom_join([X],_,X). atom_join([X|Xs],C,R):-atom_join(Xs,C,Rs),atom_concat(X,C,R0),atom_concat(R0,Rs,R).
scan(_,[],Acc,[Acc]). scan(P,[X|Xs],A,[R|Rs]):-call(P,A,X,R),scan(P,Xs,R,Rs).
monomial(V,C,D,R):-R is C*V^D.
poly(V,P,R):-length(P,L),D0 #< L,fd_dom(D0,D),maplist(monomial(V),P,D,R0),sum_list(R0,R).
ef(E,Q,R):-poly(Q,[-0.8,0.28,-0.02],R0),R is min(2.5,max(1.3,E+R0)).
interval(0-_,_,1-1). interval(1-_,_,2-6).
interval(2-I,Q-EF,0-R):-Q<3, R is ceiling(EF*I). interval(2-I,Q-EF,2-R):-Q>2, R is ceiling(EF*I).
intervals(Q,I):-scan(ef,Q,2.5,[_|Es]),maplist(pair,Q,Es,L),scan(interval,L,0-0,X),unzip(X,_,I).
due(ID):-repetitions(ID,D,Q),intervals(Q,I),last(I,T),last(D,Last),day(Today),Due is Last+T,Due=<Today.
date(D):-popen('date +%s',read,S),read_integer(S,D),close(S). day(D):-date(S), D is floor(S/(24*60^2)).
pair(X,Y,X-Y). unzip(P,X0,Y0):-maplist(pair,X0,Y0,P). ids(I):-findall(I,repetition(I,_,_),I0),sort(I0,I).
repetitions(ID,Dates,Scores):-repetition(ID,_,_),findall(X-Y,repetition(ID,X,Y),R),keysort(R),unzip(R,Dates,Scores).
review(N):-randomize,findall(X,due(X),X),append(X,N,D0),sort(D0,D),shuffle(D,C),maplist(testrecall,C).
auto:-init,readlog,carddir(X),directory_files(X,F),filter(pdf,F,Y),maplist(pdf,Z,Y),ids(I),subtract(Z,I,T),review(T),save.
readlog:-logfile(L),(file_exists(L)->consult(L);open(L,append,S),portray_clause(S,':-'(multifile(repetition/3))),close(S)).
showcard(ID):-write_to_atom(I,ID),pdf(I,F),carddir(P),atom_join([P,F],'/',T),pdfviewer(V),spawn(V,[T]).
rq(Q):-repeat,print('Q?: '),(catch(read_number(Q),_,true);get0(Q),Q= -1).
testrecall(ID):-showcard(ID),rq(Q),number(Q),Q>=0,Q=<5,assertz(score(ID,Q)).
times(_,0,[]). times(P,X,[R|Rs]):-X>0,X0 is X-1,call(P,R),times(P,X0,Rs).
shuffle(X,Y):-length(X,N),times(random,N,R),maplist(pair,R,X,R0),keysort(R0),unzip(R0,_,Y).
newrep(I-Q,repetition(I,D,Q)):-day(D).
save:-findall(X-Y,score(X,Y),T0),maplist(newrep,T0,T),logfile(L),open(L,append,S),maplist(portray_clause(S),T),close(S).
init:-memdir(M),(file_exists(M);make_directory(M)),change_directory(M),!.
:-initialization(auto).
