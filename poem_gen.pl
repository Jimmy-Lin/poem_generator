% Project for poem generation


% % prop(word, role, [syllables], [rhythm])

% prop(ah, is, vowel).
% prop(p, is, consonant).
% prop(el, is, vowel).

% prop(apple, word, noun, [ah, p, el], [1, 0]).

% % parse([words], [structure], [syllables], [rhythm])
% parse_verse([], Structure, Sylllables, Rhythm).
% parse_verse([Word|Tail], [Role|RT], Syllables, Rh) :- prop(Word, word, Role, Syllables, Rhythm).

:- consult('dictionary.pl').

% word(the, [definite_article, adverb, preposition], [[t͟hə]], [[0]]).
% word(modest, [adjective], [[m,ä,d,əst]], [[1,0]]).
% word(rose, [noun, adjective], [[r,ōz]], [[1]]).
% word(put, [verb, noun], [[p,u̇t]], [[1], [0]]).
% word(forth, [adverb], [[f,ȯrth]], [[1]]).
% word(a, [noun, indefinite_article, preposition, verb], [[ā]], [[1], [0]]).
% word(thorn, [noun], [[th,ȯrn]], [[1]]).
% word(humble, [adjective, verb], [[h,əm,b,əl]], [[1, 0]]).
% word(sheep, [noun], [[sh,ēp]], [[1]]).
% word(threatening, [adjective], [[th,r,et,n,iŋ]], [[1, 0, 0]]).
% word(horn, [noun], [[h,ȯrn]], [[1]]).

% Aggregate all words in the dictionary
words(Words) :- aggregate_all(set(Word), word(Word, _, _, _), Words).

% Reuse cfg_simple.pl for core of sentence structure
% Can be extended with other structures at a higher level
sentence(L0,L2) :- 
    noun_phrase(L0,L1), 
    verb_phrase(L1,L2).

noun_phrase(L0,L4) :- 
    det(L0,L1), 
    adjectives(L1,L2), 
    noun(L2,L3), 
    pp(L3,L4).

% an optional noun phrase is either nothing or a noun phrase
opt_noun_phrase(L,L).
opt_noun_phrase(L0,L1) :-
   noun_phrase(L0,L1).

% a verb phrase is a verb followed by a noun phrase and an optional pp
verb_phrase(L0,L3) :- 
   verb(L0,L1), 
   opt_noun_phrase(L1,L2), 
   pp(L2,L3).

% an optional prepositional phrase is either
% nothing or a preposition followed by a noun phrase
pp(L,L).
pp(L0,L2) :-
   preposition(L0,L1),
   noun_phrase(L1,L2).

% adjectives is a sequence of adjectives
adjectives(L,L).
adjectives(L0,L2) :-
    adj(L0,L1),
    adjectives(L1,L2).

% Dictionary to word mapping
det(L,L).
det([a | L],L).
det([the | L],L).

noun([student | L],L).
noun([course | L],L).
noun([computer | L],L).

adj([practical | L],L).
adj([new | L],L).
adj([computer, science | L],L).

verb([passed | L],L).
verb([failed | L],L).

preposition([with | L],L).

% Utility list operations

% True if there exists a non-empty common prefix
prefix_match(A, B) :- prefix_match(A, B, _).
prefix_match(A, B, Result) :- prefix_match(A, B, [], Result).
prefix_match([], _, Result, Result) :- Result \= [].
prefix_match(_, [], Result, Result) :- Result \= [].
prefix_match([HA|_], [HB|_], Result, Result) :- HA \= HB, Result \= [].
prefix_match([H|A], [H|B], State, Result) :- prefix_match(A, B, [H|State], Result).

% True if there exists a non-empty common suffix
suffix_match(A, B) :- suffix_match(A, B, _).
suffix_match(A, B, Result) :- reverse(A, RA), reverse(B, RB), prefix_match(RA, RB, Result).

% True if element is not a member
none(E, L) :- \+ member(E, L).

% True if L only consists of E
only(E, [E]).
only(E, [E|L]) :- only(E, L).

% Count the number of occurrences of E in L
count(E, L, C) :- count(E, L, 0, C).
count(_, [], Result, Result).
count(E, [H|L], Count, Result) :- H \= E, count(E, L, Count, Result).
count(E, [E|L], Count, Result) :- NewCount is Count + 1, count(E, L, NewCount, Result).

% Fetch the first or last element
first([H|_], H).
last(L, E) :- reverse(L, RL), first(RL, E). 

% Filter list based on success or failure of predicate
select(Data, Pred, Result) :- select(Data, Pred, [], Result).
select([], _, State, Result) :- reverse(State, Result).
select([H|L], Pred, State, Result) :- call(Pred, H), select(L, Pred, [H|State], Result).
select([H|L], Pred, State, Result) :- \+ call(Pred, H), select(L, Pred, State, Result).

% Fetches various attributes for a single word
word_to_syllables(Word, Results) :- word(Word, _, ResultsList, _), list_to_set(ResultsList, Results).
word_to_rhythms(Word, Results) :- word(Word, _, _, ResultsList), list_to_set(ResultsList, Results).
word_to_roles(Word, Results) :- word(Word, ResultsList, _, _), list_to_set(ResultsList, Results).
word_to_length(Word, Results) :- word(Word, _, _, Rhythms), member(Rhythm, Rhythms), length(Rhythm, Results).

% Computes all possible syllable sequences for a sequence of words
words_to_syllables(Words, Syllables) :- aggregate_all(set(Syllable), words_to_syllables(Words, [], Syllable), Syllables).
words_to_syllables([], State, Result) :- reverse(State, ReverseState), flatten(ReverseState, Result).
words_to_syllables([H|L], State, Result) :- word_to_syllables(H, SyllableList), member(Syllable, SyllableList), words_to_syllables(L, [Syllable|State], Result).

% Computes all possible rhythm sequences for a sequence of words
words_to_rhythms(Words, Rhythms) :- aggregate_all(set(Rhythm), words_to_rhythms(Words, [], Rhythm), Rhythms).
words_to_rhythms([], State, Result) :- reverse(State, ReverseState), flatten(ReverseState, Result).
words_to_rhythms([H|L], State, Result) :- word_to_rhythms(H, RhythmList), member(Rhythm, RhythmList), words_to_rhythms(L, [Rhythm|State], Result).

% Computes the sequence length in terms of syllables
syllabic_length(Words, Result) :- words_to_rhythms(Words, Rhythms), member(Rhythm, Rhythms), length(Rhythm, Result).

% Computes a sequence of words of length N.
n_length_words(N, Result) :- 
    words(Words),
    random_permutation(Words, RandomWords),
    n_length_words(N, RandomWords, 0, [], Result).
n_length_words(N, _, M, State, Result) :- N is M, reverse(State, Result).
n_length_words(N, Words, Length, State, Result) :- 
    Length < N, 
    member(Word, Words), 
    word_to_length(Word, WordLength),
    Length + WordLength =< N,
    n_length_words(N, Words, Length + WordLength, [Word|State], Result).


% True if sequence A and B have common suffix syllables
rhyme_match(A, B) :- 
    words_to_syllables(A, SyllablesA), words_to_syllables(B, SyllablesB),
    % writef('Possible Pronunciations: %w - %w \n', [A, SyllablesA]),
    % writef('Possible Pronunciations: %w - %w \n', [B, SyllablesB]),
    member(SyllableA, SyllablesA), member(SyllableB, SyllablesB),
    % writef('Verifying Rhyme Match: %w - %w \n', [SyllableA, SyllableB]),
    suffix_match(SyllableA, SyllableB).

% True if sequece A and B have the same rhythm sequence
rhythm_match(A, B) :-
    % syllabic_length(A, Length), syllabic_length(B, Length),
    words_to_rhythms(A, RhythmsA), words_to_rhythms(B, RhythmsB),
    % writef('Possible Rhythms: %w - %w \n', [A, RhythmsA]),
    % writef('Possible Rhythms: %w - %w \n', [B, RhythmsB]),
    member(CommonRhythm, RhythmsA), member(CommonRhythm, RhythmsB).

% Ensure sequences A and B match on rhyme and rhythm criteria
match(A, B) :-
    % writef('Verifying Rhyme: %w - %w \n', [A, B]),
    rhyme_match(A, B),
    % writef('Verifying Rhythm: %w - %w \n', [A, B]),
    rhythm_match(A, B).

% Generate list of text sequences of length N
% N-length generator creates a finite working set
generate(N, B) :-
    aggregate_all(set(X), n_length_words(N, X), B).

% Entry point for match generator
generate_match(A, B) :-
    syllabic_length(A, N),
    n_length_words(N, B),
    A \= B,
    writef('Verifying Sequence: %w \n', [B]),
    match(A, B).

% TODO: Implement sentence parser

% TODO: Implement String to atom parser, should normalize case to lowercase
string_to_sequence.
verse_to_strings.


% TODO: Implement Bayesian Objective

% Moon-shot: normalize terms into modal synonym before bayesian scoring