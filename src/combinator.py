cdict = dict()
edict = dict()
cmufile = open('cmudict-0.7.txt')
mobfile = open('mobyposi.txt')
dicfile = open('dictionary.pl', 'w')
mapping = {
	'N': 'noun',							
	'p': 'plural', 
	'h': 'noun_phrase',
	'V': 'verb', 			#(usu participle)
	't': 'transitive_verb', 	#(transitive)
	'i': 'intransitive_verb', 	#(intransitive)
	'A': 'adjective',
	'v': 'adverb',
	'C': 'conjunction',
	'P': 'preposition',
	'r': 'pronoun',
	'D': 'definite_article',
	'I': 'indefinite_article',
	'!': 'interjection',
	'o': 'nominative',
}
for line in cmufile :
	if line[0] == ';' :
		continue
	array = line.strip('\n').split(' ')
	if array[0][-1] == ')' :
		cdict[array[0][:-3].lower()].append(array[2:])
		# print('Added old word', array[0][:-3])
	else :
		cdict[array[0].lower()] = list()
		cdict[array[0].lower()].append(array[2:])
		# print('Added new word', array[0])
		
		
for line in mobfile :
	word, attr = line.split('$')
	word = word.lower()
	if word not in cdict :
		continue
	edict[word] = attr[:-1]
	
for word in edict :
	# poll NV ['P', 'OW1', 'L'] =>
	# word(poll, [noun, verb], [[P, OW, L]], [[1]]).
	
	part_of_speeches = '['
	for char in edict[word] :
		part_of_speeches += mapping[char]
		part_of_speeches += ', '
	part_of_speeches = part_of_speeches[:-2] + '], '

	stresses = list()
	pronunciations = list()
	for raw_pronunciation in cdict[word] :
		stress = '['
		pronunciation = '['
		for syllable in raw_pronunciation :
			if syllable[-1].isdigit() :
				stress += syllable[-1]
				stress += ', '
				pronunciation += syllable[:-1].lower()
				pronunciation += ', '
			else :
				pronunciation += syllable.lower()
				pronunciation += ', '
		stress = stress[:-2] + ']'
		pronunciation = pronunciation[:-2] + ']'
		stresses.append(stress)
		pronunciations.append(pronunciation)
		
	rule = "word(\""
	rule = rule + word + "\", " + part_of_speeches + '['
	rule += ', '.join(pronunciations)
	rule += '], ['
	rule += ', '.join(stresses)
	rule += ']).'
	dicfile.write(rule + '\n')
