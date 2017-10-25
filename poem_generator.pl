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

% General Dictionary Template
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
words(RandomWords) :- aggregate_all(set(Word), word(Word, _, _, _), Words), random_permutation(Words, RandomWords).
is_word(Word) :- word(Word, _, _, _).
not_word(Word) :- \+ is_word(Word).
roles(RoleType) :- aggregate_all(set(Role), word(_, Role, _, _), RolesList), flatten(RolesList, Roles), list_to_set(Roles, RolesSet), member(RoleType, RolesSet).
% Possible roles in dictionary
% R = adjective ;
% R = adverb ;
% R = verb ;
% R = interjection ;
% R = intransitive_verb ;
% R = noun ;
% R = transitive_verb ;
% R = preposition ;
% R = plural ;
% R = conjunction ;
% R = pronoun ;
% R = definite_article ;
% R = noun_phrase.

% Reuse cfg_simple.pl for core of sentence structure
% Can be extended with other structures at a higher level

compound_sentence(L0, L2) :-
    simple_sentence(L0,L1),
    compounding_phrase(L1,L2).

compounding_phrase(L, L).
compounding_phrase(L0, L2) :-
    conjunction(L0, L1),
    simple_sentence(L1, L2).

simple_sentence(L0,L2) :- % independent clause
    noun_phrase(L0,L1), 
    verb_phrase(L1,L2).

noun_phrase(L0,L4) :- 
    det(L0,L1), 
    adjectives(L1,L2), 
    pronoun_or_noun(L2,L3), 
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
% modified this to at most 3 consecutive adjectives to prevent infinite sequence
adjectives(Start, Finish) :- adjectives(Start, Finish, 3).
adjectives(Start, Start, _).
adjectives(L0, L2, N) :- 
    N > 0,
    adj(L0,L1),
    adjectives(L1,L2, N-1).


% Dictionary to word mapping

det([Term|L],L) :- word_to_roles(Term, Roles), article(Roles).
det(L,L).

article(Roles) :- member(article, Roles).
article(Roles) :- member(indefinite_article, Roles).
article(Roles) :- member(definite_article, Roles).

% Possible roles in dictionary
% R = adjective ;
% R = adverb (not in use);
% R = verb ;
% R = interjection (not in use);
% R = intransitive_verb (not in use);
% R = noun ;
% R = transitive_verb (not in use);
% R = preposition ;
% R = plural (not in use);
% R = conjunction ;
% R = pronoun ;
% R = definite_article ;

pronoun_or_noun([Term|L], L) :- pronoun([Term|L], L).
pronoun_or_noun([Term|L], L) :- noun([Term|L], L).
pronoun([Term|L], L) :- word_to_roles(Term, Roles), member(pronoun, Roles).
noun([Term|L], L) :- word_to_roles(Term, Roles), member(noun, Roles).
adj([Term | L],L) :- word_to_roles(Term, Roles), member(adjective, Roles).
verb([Term | L],L) :- word_to_roles(Term, Roles), member(verb, Roles).
transitive_verb([Term | L],L) :- word_to_roles(Term, Roles), member(transitive_verb, Roles).
intransitive_verb([Term | L],L) :- word_to_roles(Term, Roles), member(intransitive_verb, Roles).
adverb([Term | L],L) :- word_to_roles(Term, Roles), member(adverb, Roles).
interjection([Term | L],L) :- word_to_roles(Term, Roles), member(interjection, Roles).
conjunction([Term | L],L) :- word_to_roles(Term, Roles), member(conjunction, Roles).
coordinating_conjunction([Term | L],L) :- word_to_roles(Term, Roles), member(coordinating_conjunction, Roles).
subordinating_conjunction([Term | L],L) :- word_to_roles(Term, Roles), member(subordinating_conjunction, Roles).
plural([Term | L],L) :- word_to_roles(Term, Roles), member(plural, Roles).
preposition([Term | L],L) :- word_to_roles(Term, Roles), member(preposition, Roles).

% Utility list operations
head_match([H|_], [H|_]).

prefix_match(_, []).
prefix_match([], _).
prefix_match([], []).
prefix_match([A], [A]).
prefix_match([A, B|_], [A, B|_]).

greedy_prefix_match(_, []).
greedy_prefix_match([], _).
greedy_prefix_match([], []).
greedy_prefix_match([A|LA], [A|LB]) :- greedy_prefix_match(LA, LB).

% % True if there exists a non-empty common prefix
% prefix_match(A, B) :- prefix_match(A, B, _).
% prefix_match(A, B, Result) :- prefix_match(A, B, [], Result).
% prefix_match([], _, Result, Result) :- Result \= [].
% prefix_match(_, [], Result, Result) :- Result \= [].
% prefix_match([HA|_], [HB|_], Result, Result) :- HA \= HB, Result \= [].
% prefix_match([H|A], [H|B], State, Result) :- prefix_match(A, B, [H|State], Result).

% % True if there exists a non-empty common suffix
% suffix_match(A, B) :- suffix_match(A, B, _).
% suffix_match(A, B, Result) :- reverse(A, RA), reverse(B, RB), prefix_match(RA, RB, Result).

% True if element is not a member
none(E, L) :- \+ member(E, L).

% True if L only consists of E
only(E, [E]).
only(E, [E|L]) :- only(E, L).

% Get Nth element of list
nth(0, [E|_], E).
nth(N, [_|L], E) :- N > 0, M is N - 1, nth(M, L, E).

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

% % Computes a sequence of words of length N.
% n_length_words(N, Result) :- 
%     words(Words),
%     random_permutation(Words, RandomWords),
%     n_length_words(N, RandomWords, 0, [], Result).
% n_length_words(N, _, M, State, Result) :- N is M, reverse(State, Result).
% n_length_words(N, Words, Length, State, Result) :- 
%     Length < N, 
%     member(Word, Words), 
%     word_to_length(Word, WordLength),
%     Length + WordLength =< N,
%     n_length_words(N, Words, Length + WordLength, [Word|State], Result).


% % True if sequence A and B have common suffix syllables
% rhyme_match(A, B) :- 
%     words_to_syllables(A, SyllablesA), words_to_syllables(B, SyllablesB),
%     % writef('Possible Pronunciations: %w - %w \n', [A, SyllablesA]),
%     % writef('Possible Pronunciations: %w - %w \n', [B, SyllablesB]),
%     member(SyllableA, SyllablesA), member(SyllableB, SyllablesB),
%     % writef('Verifying Rhyme Match: %w - %w \n', [SyllableA, SyllableB]),
%     suffix_match(SyllableA, SyllableB).

% % True if sequece A and B have the same rhythm sequence
% rhythm_match(A, B) :-
%     % syllabic_length(A, Length), syllabic_length(B, Length),
%     words_to_rhythms(A, RhythmsA), words_to_rhythms(B, RhythmsB),
%     % writef('Possible Rhythms: %w - %w \n', [A, RhythmsA]),
%     % writef('Possible Rhythms: %w - %w \n', [B, RhythmsB]),
%     member(CommonRhythm, RhythmsA), member(CommonRhythm, RhythmsB).

% % Ensure sequences A and B match on rhyme and rhythm criteria
% match(A, B) :-
%     compound_sentence(A, []), compound_sentence(B, []), 
%     % writef('Verifying Rhyme: %w - %w \n', [A, B]),
%     rhyme_match(A, B),
%     % writef('Verifying Rhythm: %w - %w \n', [A, B]),
%     rhythm_match(A, B).

% % Generate list of text sequences of length N
% % N-length generator creates a finite working set
% generate(N, B) :-
%     aggregate_all(set(X), n_length_words(N, X), B).

% % Entry point for match generator
% generate_match(A, B) :-
%     syllabic_length(A, N),
%     n_length_words(N, B),
%     A \= B,
%     writef('Verifying Sequence: %w \n', [B]),
%     match(A, B).

% TODO: Given a matrix representation of the input verse, find a mirror verse in the following method
% If a line in the source matrix rhymes with a N-lines above it, the mirror verse should rhyme with those mirrored lines above it
% If a line in the source matrix as X rhythm, the mirror line should also have X as it's rhythm
% all mirror lines should be a valid compound sentence

rhyme_match(A, B) :-
    words_to_syllables(A, AS), words_to_syllables(B, BS),
    member(AA, AS), member(BB, BS),
    reverse(AA, RA), reverse(BB, RB),
    prefix_match(RA, RB).

rhyming_index(CurrentLine, PreviousLines, Index) :- rhyming_index(CurrentLine, PreviousLines, false, 0, Index).
rhyming_index(_, _, true, Curr, Curr).
rhyming_index(_, [], false, _, -1).
rhyming_index(CurrentLine, [H|L], false, Curr, Index) :- 
    rhyme_match(CurrentLine, H), 
    rhyming_index(CurrentLine, [H|L], true, Curr, Index).
rhyming_index(CurrentLine, [H|L], false, Curr, Index) :- 
    \+ rhyme_match(CurrentLine, H), 
    NextIndex is Curr + 1, 
    rhyming_index(CurrentLine, L, false, NextIndex, Index).

reverse_lists(Lists, Results) :- reverse_lists(Lists, [], Results).
reverse_lists([], State, Results) :- reverse(State, Results).
reverse_lists([H|L], State, Results) :- reverse(H, RH), reverse_lists(L, [RH|State], Results).

validate_rhyme(Word, State, RS) :-
    words_to_syllables([Word|State], Syllables), 
    reverse_lists(Syllables, NRS),
    validate_rhyme_match(RS, NRS).
validate_rhyme_match(SyllablesA, SyllablesB) :- 
    member(A, SyllablesA), member(B, SyllablesB), prefix_match(A, B), !.

validate_rhythm(Word, State, RR) :-
    words_to_rhythms([Word|State], Rhythms), 
    reverse_lists(Rhythms, NRR),
    validate_rhythm_match(RR, NRR).
validate_rhythm_match(RhythmsA, RhythmsB) :- 
    member(A, RhythmsA), member(B, RhythmsB), greedy_prefix_match(A, B), !.

build_line(RhymeLine, RhythmLine, Result) :- 
    words_to_syllables(RhymeLine, Syllables), 
    words_to_rhythms(RhythmLine, Rhythms),
    reverse_lists(Syllables, RS),
    reverse_lists(Rhythms, RR),
    syllabic_length(RhythmLine, Length),
    words(Words),
    build_line_help(Words, RS, RR, Length, [], Result).
build_line(RhythmLine, Result) :-
    words_to_rhythms(RhythmLine, Rhythms),
    reverse_lists(Rhythms, RR),
    syllabic_length(RhythmLine, Length),
    words(Words),
    build_line_help(Words, RR, Length, [], Result).

% Build line with rhyme constraint and rhythm constraint
% build_line_help(_, _, _, 0, Result, Result) :- compound_sentence(Result, []). % Final filter for grammatical correctness.
build_line_help(_, _, _, 0, Result, Result).
build_line_help(Words, RS, RR, Length, State, Result) :-
    member(Word, Words),
    syllabic_length([Word], WL),
    NewLength is Length - WL,
    NewLength >= 0,
    validate_rhythm(Word, State, RR),
    validate_rhyme(Word, State, RS),
    build_line_help(Words, RS, RR, NewLength, [Word|State], Result).

% Build line with rhythm constraint
% build_line_help(_, _, 0, Result, Result) :- compound_sentence(Result, []). % Final filter for grammatical correctness.
build_line_help(_, _, 0, Result, Result).
build_line_help(Words, RR, Length, State, Result) :-
    member(Word, Words),
    syllabic_length([Word], WL),
    NewLength is Length - WL,
    NewLength >= 0,
    validate_rhythm(Word, State, RR),
    build_line_help(Words, RR, NewLength, [Word|State], Result).


% build_line_help(Words, RR, Length, [cream], Result) :-
%     member(ice, Words),
%     syllabic_length([ice|[cream]], NL),
%     NewLength is Length - NL,
%     writef('Current State: %w\n', [[ice|[cream]]]),
%     writef('Length: %w\n', [NewLength]),
%     NewLength >= 0,
%     validate_rhythm(Word, State, RR),
%     writef('Current State: %w\n', [[Word|State]]),
%     writef('Length: %w\n', [NewLength]),
%     build_line_help(Words, RR, NewLength, [Word|State], Result).

write_lines([]).
write_lines([H|L]) :- write(H), nl(), write_lines(L).

start :- 
    write('What is the verse you would like to imitate?\n'),
    read(Verse),
    query(Verse),
    start.

start :- 
    write('What is the verse you would like to imitate?\n'),
    read(Verse),
    \+ query(Verse),
    start.

query(Verse) :-
    parse_verse(Verse, Sequences),
    build_verse(Sequences, MirrorSequences),
    sequences_to_lines(MirrorSequences, MirrorLines),
    write_lines(MirrorLines).

build_verse(TemplateVerse, MirrorVerse) :- build_verse(TemplateVerse, [], [], MirrorVerse).
build_verse([], _, State, MirrorVerse) :- reverse(State, MirrorVerse).
build_verse([CurrentLine|NextLines], PreviousLines, State, MirrorVerse) :-
    rhyming_index(CurrentLine, PreviousLines, RhymeIndex),
    RhymeIndex \= -1,
    nth(RhymeIndex, State, RhymeLine),
    build_line(RhymeLine, CurrentLine, BuiltLine),
    BuiltLine \= CurrentLine,
    writef('Building Line: %w\n', [BuiltLine]),
    build_verse(NextLines, [CurrentLine|PreviousLines], [BuiltLine|State], MirrorVerse).
build_verse([CurrentLine|NextLines], PreviousLines, State, MirrorVerse) :-
    rhyming_index(CurrentLine, PreviousLines, RhymeIndex),
    RhymeIndex == -1,
    build_line(CurrentLine, BuiltLine),
    BuiltLine \= CurrentLine,
    writef('Building Line: %w\n', [BuiltLine]),
    build_verse(NextLines, [CurrentLine|PreviousLines], [BuiltLine|State], MirrorVerse).

% Moon-shot: Implement Bayesian Objective
% Moon-shot: normalize terms into modal synonym before bayesian scoring


% Crazy string parsing to validate knowledge of vocabulary, escape characters, and convert verses to and from atom matrices.

string_to_sequence(Line, Words) :- split_string(Line, '\s\n\t', '\s\n\t,.?!:;', Strings), strings_to_atoms(Strings, Words).
strings_to_sequences(Lines, Words) :- strings_to_sequences(Lines, [], Words).
strings_to_sequences([], State, Words) :- reverse(State, Words).
strings_to_sequences([H|L], State, Words) :- string_to_sequence(H, Sequence), strings_to_sequences(L, [Sequence|State], Words).

verse_to_strings(Verse, Lines) :- 
    escape_string(Verse, EscapedVerse),
    string_lower(EscapedVerse, LowerVerse), 
    split_string(LowerVerse, '\n', '\s\n\t,.?!:;', Lines).
verse_to_sequences(Verse, Words) :- 
    verse_to_strings(Verse, Lines), 
    strings_to_sequences(Lines, Words).

sequences_to_lines(Sequences, Verse) :- sequences_to_lines(Sequences, [], Verse).
sequences_to_lines([], State, Lines) :- reverse(State, Lines).
sequences_to_lines([H|L], State, Verse) :- atomics_to_string(H, '\s', String), sequences_to_lines(L, [String|State], Verse).

parse_verse(Verse, Lines) :-
    unknown_vocabulary(Verse, Unknown),
    length(Unknown, C), C > 0,
    writef('Unrecognized Vocabulary: %w\n', [Unknown]),
    Lines = [].

parse_verse(Verse, Lines) :-
    unknown_vocabulary(Verse, Unknown),
    length(Unknown, C), 
    C == 0,
    verse_to_sequences(Verse, Lines).

vocabulary(Verse, Vocabulary) :- 
    escape_string(Verse, EscapedVerse),
    string_lower(EscapedVerse, LowerVerse),
    split_string(LowerVerse, '\s\n\t', '\s\n\t,.?!:;', Strings), 
    strings_to_atoms(Strings, Words), 
    list_to_set(Words, Vocabulary).

unknown_vocabulary(String, Unknown) :- 
    vocabulary(String, Words), 
    member(Word, Words), 
    aggregate_all(set(Word), not_word(Word), Unknown).

atoms_to_strings(Atoms, Strings) :- atoms_to_strings(Atoms, [], Strings).
atoms_to_strings([], State, Strings) :- reverse(State, Strings).
atoms_to_strings([H|L], State, Strings) :- atom_string(H, String), atoms_to_strings(L, [String|State], Strings).

strings_to_atoms(Strings, Atoms) :- strings_to_atoms(Strings, [], Atoms).
strings_to_atoms([], State, Atoms) :- reverse(State, Atoms).
strings_to_atoms([H|L], State, Atoms) :- atom_string(Atom, H), strings_to_atoms(L, [Atom|State], Atoms).

escape_string(X, Y) :-
    gsub(X, '’', '\'', Y).

gsub(String, Pattern, Replacement, NewString) :-
    sub_string(String, Before, PatternLength, After, Pattern),
    ForeBoundary is PatternLength + After,
    HindBoundary is PatternLength + Before,
    sub_string(String, 0, Before, ForeBoundary, Forestring),
    sub_string(String, HindBoundary, After, 0, Hindstring),
    string_concat(Forestring, Replacement, Mid), 
    string_concat(Mid, Hindstring, NextString), 
    gsub(NextString, Pattern, Replacement, NewString).
gsub(String, Pattern, _, String) :- \+ sub_string(String, _, _, _, Pattern).

string_list(S, L) :- split_string(S, '', '', L).

:- start.