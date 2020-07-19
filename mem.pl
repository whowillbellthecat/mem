:- dynamic(repetition/3).
:- include('config.pl').
pdf(X,Y):-atom_concat(X,'.pdf',Y). pdf(X) :- pdf(_,X). iota(0,[]). iota(N,[N0|R]):-N>0,N0 is N-1,iota(N0,R).
filter(_,[],[]). filter(P,[X|Xs],Y):-(call(P,X)->Y=[X|Ys];Y=Ys),filter(P,Xs,Ys).
atom_join([X],_,X). atom_join([X|Xs],C,R):-atom_join(Xs,C,Rs),atom_concat(X,C,R0),atom_concat(R0,Rs,R).
scan(_,[],Acc,[Acc]). scan(P,[X|Xs],A,[R|Rs]):-call(P,A,X,R),scan(P,Xs,R,Rs).
monomial(V,C,D,R):-R is C*V^D. poly(V,P,R):-length(P,L),iota(L,D),maplist(monomial(V),P,D,R0),sum_list(R0,R).
ef(E,Q,R):-poly(Q,[-0.02,0.28,-0.8],R0),R is min(2.5,max(1.3,E+R0)).
interval(0-_,_,1-1). interval(1-_,_,2-6).
interval(2-I,Q-EF,0-R):-Q<3, R is ceiling(EF*I). interval(2-I,Q-EF,2-R):-Q>2, R is ceiling(EF*I).
intervals(Q,I):-scan(ef,Q,2.5,[_|Es]),maplist(pair,Q,Es,L),scan(interval,L,0-0,X),unzip(X,_,I).
due(ID):-repetitions(ID,D,Q),intervals(Q,I),last(I,T),last(D,Last),day(Today),Due is Last+T,Due=<Today.
date(D):-popen('date +%s',read,S),read_integer(S,D),close(S). day(D):-date(S), D is floor(S/(24*60^2)).
pair(X,Y,X-Y). unzip(P,X0,Y0):-maplist(pair,X0,Y0,P). ids(I):-findall(I,repetition(I,_,_),I0),sort(I0,I).
repetitions(ID,Dates,Scores):-repetition(ID,_,_),findall(X-Y,repetition(ID,X,Y),R),keysort(R),unzip(R,Dates,Scores).
review(N):-review(N,C,Q),maplist(pair,C,Q,R),save(R). review:-review([]).
review(N,C,Q):-randomize,findall(X,due(X),X),append(X,N,D0),sort(D0,D),shuffle(D,C),maplist(testrecall,C,Q).
auto:-init,readlog,carddir(X),directory_files(X,F),filter(pdf,F,Y),maplist(pdf,Z,Y),ids(I),subtract(Z,I,T),review(T).
readlog:-logfile(L),(file_exists(L)->consult(L);true).
showcard(ID):-write_to_atom(I,ID),pdf(I,F),carddir(P),atom_join([P,F],'/',T),pdfviewer(V),spawn(V,[T]).
testrecall(ID,Q):-showcard(ID),print('Q?: '),read_number(Q),Q=<5,Q>=0. %todo softfail on mupdf error
times(_,0,[]). times(P,X,[R|Rs]) :- X>0, X0 is X-1, call(P,R),times(P,X0,Rs).
shuffle(X,Y):-length(X,N),times(random,N,R),maplist(pair,R,X,R0),keysort(R0),unzip(R0,_,Y).
newrep(I-Q,repetition(I,D,Q)):-day(D).
save(T0):-maplist(newrep,T0,T),logfile(L),open(L,append,S),maplist(portray_clause(S),T),close(S).
init:-memdir(M),(file_exists(M);make_directory(M)),change_directory(M).
:-initialization(auto).
