'From Cuis 4.2 of 25 July 2013 [latest update: #2679] on 8 February 2016 at 5:19:07.133511 pm'!
'Description Code to read and install Squeak .sf2 StrikeFont files'!
!provides: 'SF2-Import' 1 3!
!classDefinition: #NameOfSubclass category: #'SF2-Import'!
Object subclass: #NameOfSubclass
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'SF2-Import'!
!classDefinition: 'NameOfSubclass class' category: #'SF2-Import'!
NameOfSubclass class
	instanceVariableNames: ''!

!classDefinition: #SF2Installer category: #'SF2-Import'!
Object subclass: #SF2Installer
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'SF2-Import'!
!classDefinition: 'SF2Installer class' category: #'SF2-Import'!
SF2Installer class
	instanceVariableNames: ''!


!NameOfSubclass commentStamp: '<historical>' prior: 0!
Code to read and install Squeak .sf2 StrikeFont files!

!SF2Installer commentStamp: '<historical>' prior: 0!
Code to read and install Squeak .sf2 StrikeFont files

See class side!

!AbstractFont class methodsFor: '*sf2-import' stamp: 'KenD 2/8/2016 13:06'!
availableFonts

	^AvailableFonts! !

!StrikeFont methodsFor: '*sf2-import' stamp: 'ar 5/23/2000 12:50'!
buildfontNamed: nm fromForms: forms startingAtAscii: startAscii

!StrikeFont methodsFor: '*sf2-import'!
displayChar: ascii form: charForm

!StrikeFont methodsFor: '*sf2-import' stamp: 'KenD 2/8/2016 16:39'!
familyName

	^self name withoutJustTrailingDigits! !

!StrikeFont methodsFor: '*sf2-import' stamp: 'md 11/14/2003 17:25'!
newFromStrike: fileName

!StrikeFont methodsFor: '*sf2-import' stamp: 'KenD 2/8/2016 13:35'!
readFromStrike2: fileName  "StrikeFont new readFromStrike2: 'Palatino14.sf2'"
	fileEntry := fileName asFileEntry.
	name := fileEntry baseName.
	].! !

!StrikeFont methodsFor: '*sf2-import' stamp: 'KenD 2/7/2016 20:17'!
readFromStrike2Stream: file 

!StrikeFont methodsFor: '*sf2-import' stamp: 'ls 3/27/2000 17:43'!
writeAsStrike2On: file

!StrikeFont methodsFor: '*sf2-import' stamp: 'KenD 2/8/2016 13:31'!
writeAsStrike2named: fileName
	

!Bitmap methodsFor: '*sf2-import' stamp: 'KenD 2/8/2016 08:05'!
decompress: bm fromByteArray: ba at: index
	"Decompress the body of a byteArray encoded by compressToByteArray (qv)...
	The format is simply a sequence of run-coded pairs, {N D}*.
		N is a run-length * 4 + data code.
		D, the data, depends on the data code...
			0	skip N words, D is absent
				(could be used to skip from one raster line to the next)
			1	N words with all 4 bytes = D (1 byte)
			2	N words all = D (4 bytes)
			3	N words follow in D (4N bytes)
		S and N are encoded as follows (see decodeIntFrom:)...
			0-223	0-223
			224-254	(0-30)*256 + next byte (0-7935)
			255		next 4 bytes"	
	"NOTE:  If fed with garbage, this routine could read past the end of ba, but it should fail before writing past the ned of bm."
	| i code n anInt data end k pastEnd |
	<primitive: 'primitiveDecompressFromByteArray' module: 'MiscPrimitivePlugin'>
	<var: #bm declareC: 'int *bm'>
	<var: #ba declareC: 'unsigned char *ba'>
	i := index.  "byteArray read index"
	end := ba size.
	k := 1.  "bitmap write index"
	pastEnd := bm size + 1.
	[i <= end] whileTrue:
		["Decode next run start N"
		anInt := ba at: i.  i := i+1.
		anInt <= 223 ifFalse:
			[anInt <= 254
				ifTrue: [anInt := (anInt-224)*256 + (ba at: i).  i := i+1]
				ifFalse: [anInt := 0.
						1 to: 4 do: [:j | anInt := (anInt bitShift: 8) + (ba at: i).  i := i+1]]].
		n := anInt >> 2.
		(k + n) > pastEnd ifTrue: [^ self primitiveFail].
		code := anInt bitAnd: 3.
		code = 0 ifTrue: ["skip"].
		code = 1 ifTrue: ["n consecutive words of 4 bytes = the following byte"
						data := ba at: i.  i := i+1.
						data := data bitOr: (data bitShift: 8).
						data := data bitOr: (data bitShift: 16).
						1 to: n do: [:j | bm at: k put: data.  k := k+1]].
		code = 2 ifTrue: ["n consecutive words = 4 following bytes"
						data := 0.
						1 to: 4 do: [:j | data := (data bitShift: 8) bitOr: (ba at: i).  i := i+1].
						1 to: n do: [:j | bm at: k put: data.  k := k+1]].
		code = 3 ifTrue: ["n consecutive words from the data..."
						1 to: n do:
							[:m | data := 0.
							1 to: 4 do: [:j | data := (data bitShift: 8) bitOr: (ba at: i).  i := i+1].
							bm at: k put: data.  k := k+1]]]! !

!Bitmap methodsFor: '*sf2-import' stamp: 'KenD 2/8/2016 08:12'!
readCompressedFrom: strm
	"Decompress an old-style run-coded stream into this bitmap:
		[0 means end of runs]
		[n = 1..127] [(n+3) copies of next byte]
		[n = 128..191] [(n-127) next bytes as is]
		[n = 192..255] [(n-190) copies of next 4 bytes]"
	| n byte out outBuff bytes |
	out := WriteStream on: (outBuff := ByteArray new: self size*4).
	[(n := strm next) > 0] whileTrue:
		[(n between: 1 and: 127) ifTrue:
			[byte := strm next.
			1 to: n+3 do: [:i | out nextPut: byte]].
		(n between: 128 and: 191) ifTrue:
			[1 to: n-127 do: [:i | out nextPut: strm next]].
		(n between: 192 and: 255) ifTrue:
			[bytes := (1 to: 4) collect: [:i | strm next].
			1 to: n-190 do: [:i | bytes do: [:b | out nextPut: b]]]].
	out position = outBuff size ifFalse: [self error: 'Decompression size error'].
	"Copy the final byteArray into self"
	self copyFromByteArray: outBuff.! !

!Bitmap class methodsFor: '*sf2-import' stamp: 'KenD 2/8/2016 08:09'!
decodeIntFrom: s
	"Decode an integer in stream s as follows...
		0-223	0-223
		224-254	(0-30)*256 + next byte (0-7935)
		255		next 4 bytes	"		
	| int |
	int := s next.
	int <= 223 ifTrue: [^ int].
	int <= 254 ifTrue: [^ (int-224)*256 + s next].
	int := s next.
	1 to: 3 do: [:j | int := (int bitShift: 8) + s next].
	^ int! !

!Bitmap class methodsFor: '*sf2-import' stamp: 'KenD 2/8/2016 08:08'!
decompressFromByteArray: byteArray
	| s bitmap size |
	s := ReadStream on: byteArray.
	size := self decodeIntFrom: s.
	bitmap := self new: size.
	bitmap decompress: bitmap fromByteArray: byteArray at: s position+1.
	^ bitmap! !

!Bitmap class methodsFor: '*sf2-import' stamp: 'KenD 2/8/2016 08:11'!
newFromStream: s
	| len |
	s next = 16r80 ifTrue:
		["New compressed format"
		len := self decodeIntFrom: s.
		^ Bitmap decompressFromByteArray: (s nextInto: (ByteArray new: len))].
	s skip: -1.
	len := s nextInt32.
	len <= 0
		ifTrue: ["Old compressed format"
				^ (self new: len negated) readCompressedFrom: s]
		ifFalse: ["Old raw data format"
				^ s nextWordsInto: (self new: len)]! !

!String methodsFor: '*sf2-import' stamp: 'KenD 2/8/2016 16:37'!
withoutJustTrailingDigits
	"Answer the portion of the receiver that precedes any trailing series of digits.  If the receiver consists entirely of digits and blanks, return an empty string"
	| firstDigit |
	firstDigit := (self findFirst: [:m | m isDigit]).
	^ firstDigit > 0
		ifTrue:
			[(self copyFrom: 1 to: firstDigit-1) withoutTrailingBlanks]
		ifFalse:
			[self]

"
'Wh oopi e234' withoutJustTrailingDigits
'Wh oopi e 234' withoutJustTrailingDigits
"
! !

!SF2Installer class methodsFor: 'read sf2' stamp: 'KenD 2/8/2016 16:49'!
readSF2FontsFromDir: aString
	"Add *.sf2 file fonts to AbstractFont availableFonts"
	| dirEntry strikeFonts |
	dirEntry := aString asDirectoryEntry.
	strikeFonts := (dirEntry filesMatches: [ :fileEntry | '*.sf2' match: fileEntry pathName]) 
		collect: [:fileEntry | StrikeFont new readFromStrike2: fileEntry pathName].
	strikeFonts do: [ :font | font reset ].
	"(strikeFonts asArray sort: [:a :b | a height < b height]) inspect."
	strikeFonts do: [ :sf | | fontDict familyName |
		AbstractFont availableFonts at: sf familyName ifAbsentPut: [ Dictionary new ] .
		fontDict := AbstractFont availableFonts at: sf familyName.
		fontDict at: sf pointSize put: sf.
	].! !