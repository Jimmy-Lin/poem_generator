% Project for poem generation


% % prop(word, role, [syllables], [rhythm])

% prop(ah, is, vowel).
% prop(p, is, consonant).
% prop(el, is, vowel).

% prop(apple, word, noun, [ah, p, el], [1, 0]).

% % parse([words], [structure], [syllables], [rhythm])
% parse_verse([], Structure, Sylllables, Rhythm).
% parse_verse([Word|Tail], [Role|RT], Syllables, Rh) :- prop(Word, word, Role, Syllables, Rhythm).

% consult('dictionary.pl').

word(the, [definite_article, adverb, preposition], [[t͟hə]], [[0]]).
word(modest, [adjective], [[m,ä,d,əst]], [[1,0]]).
word(rose, [noun, adjective], [[r,ōz]], [[1]]).
word(put, [verb, noun], [[p,u̇t]], [[1], [0]]).
word(forth, [adverb], [[f,ȯrth]], [[1]]).
word(a, [noun, indefinite_article, preposition, verb], [[ā]], [[1], [0]]).
word(thorn, [noun], [[th,ȯrn]], [[1]]).
word(humble, [adjective, verb], [[h,əm,b,əl]], [[1]]).
word(sheep, [noun], [[sh,ēp]], [[1]]).
word(threatening, [adjective], [[th,r,et,n,iŋ]], [[1, 0, 0]]).
word(horn, [noun], [[h,ȯrn]], [[1]]).




reverse(L, Result) :- reverse(L, [], Result).
reverse([], Result, Result).
reverse([H|T], State, Result) :- reverse(T, [H|State], Result).

append(Head, Tail, Result) :- reverse(Head, ReverseHead), reverse(ReverseHead, Tail, Result).

prefix_match(A, B) :- prefix_match(A, B, _).
prefix_match(A, B, Result) :- prefix_match(A, B, [], Result).
prefix_match([], _, Result, Result) :- Result \= [].
prefix_match(_, [], Result, Result) :- Result \= [].
prefix_match([HA|_], [HB|_], Result, Result) :- HA \= HB, Result \= [].
prefix_match([H|A], [H|B], State, Result) :- prefix_match(A, B, [H|State], Result).

suffix_match(A, B) :- suffix_match(A, B, _).
suffix_match(A, B, Result) :- reverse(A, RA), reverse(B, RB), prefix_match(RA, RB, Result).

% any(Pred, [E|L]) :- call(Pred, E).
% any(Pred, [E|L]) :- \+ any(Pred, [E|L]), any(Pred, [E|L]).

% all(Pred, [E]) :- call(Pred, E).
% all(Pred, [E|L]) :- call(Pred, E), all(Pred, L).

exists(E, [E|_]).
exists(E, [H|L]) :- E \= H, exists(E, L).

none(E, []).
none(E, [H|L]) :- E \= H, none(E, L).

only(E, [E]).
only(E, [E|L]) :- only(E, L).

eq(E, E).
neq(A, B) :- A \= B.

count(E, L, C) :- count(E, L, 0, C).
count(_, [], Result, Result).
count(E, [H|L], Count, Result) :- H \= E, count(E, L, Count, Result).
count(E, [E|L], Count, Result) :- NewCount is Count + 1, count(E, L, NewCount, Result).

len(L, R) :- length(L, 0, R).
len([], Result, Result).
len([_|L], Count, Result) :- NewCount = Count + 1, length(L, NewCount, Result).
 
first([H|_], H).
last(L, E) :- reverse(L, RL), first(RL, E). 

find_word(Role, Result) :- word(Result, R, _, _), exists(Role, R).

% new_word(Role, State, Word) :- find_word(Role, Word), none(Word, State).

find_words(Role, Result) :- find_words(Role, [], Result).
find_words(Role, Result, Result) :- \+ new_word(Role, State, Word).
find_words(Role, State, Result) :-  new_word(Role, State, Word), find_words(Role, [Word|State], Result).


words(W, Result) :- words(W, [], Result).
new_word(L) :- word(W, _, _, _).
words()
syllables(Word, Results) :- word(Word, _, Results, _).
rhythms(Word, Results) :- word(Word, _, _, Results).
role(Word, Results) :- word(Word, Results, _, _).

rhyme(A, B, Syllables) :- last(A, LA), last(B, LB), syllables(LA, SSA), syllables(LB, SSB), exists(SA, SSA), exists(SB, SSB), suffix_match(SA, SB, Syllables).
% Note: I should probably filter consonants out of the syllables first
% I may want to remove the last-word optimization to rank higher rhyme lengths

