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
buildfontNamed: nm fromForms: forms startingAtAscii: startAscii	ascent: a descent: d maxWid: m	"This builds a StrikeFont instance from existing forms."	| lastAscii width ascii charForm missingForm tempGlyphs |	name := nm.	ascent := 11.	descent := 3.	maxWidth := 16.	pointSize := 8.	name := (name copyWithout: Character space) ,				(pointSize < 10					ifTrue: ['0' , pointSize printString]					ifFalse: [pointSize printString]).	minAscii := 258.	maxAscii := 0.	superscript := ascent - descent // 3.		subscript := descent - ascent // 3.		emphasis := 0.	type := 0.  "ignored for now"	tempGlyphs := Form extent: (maxWidth*257) @ self height.	xTable := (Array new: 258) atAllPut: 0.	xTable at: 1 put: 0.	"Read character forms and blt into tempGlyphs"	lastAscii := -1.	1 to: forms size do:		[:i | charForm := forms at: i. width := charForm width.		ascii := startAscii-1+i.		self displayChar: ascii form: charForm.		ascii = 256			ifTrue: [missingForm := charForm deepCopy]			ifFalse:			[minAscii := minAscii min: ascii.			maxAscii := maxAscii max: ascii.			lastAscii+1 to: ascii-1 do: [:as | xTable at: as+2 put: (xTable at: as+1)].			tempGlyphs copy: ((xTable at: ascii+1)@0									extent: charForm extent)						from: 0@0 in: charForm rule: Form over.			xTable at: ascii+2 put: (xTable at: ascii+1) + width.			lastAscii := ascii]].	lastAscii+1 to: maxAscii+1 do: [:as | xTable at: as+2 put: (xTable at: as+1)].	missingForm == nil ifFalse:		[tempGlyphs copy: missingForm boundingBox from: missingForm				to: (xTable at: maxAscii+2)@0 rule: Form over.		xTable at: maxAscii+3 put: (xTable at: maxAscii+2) + missingForm width].	glyphs := Form extent: (xTable at: maxAscii+3) @ self height.	glyphs copy: glyphs boundingBox from: 0@0 in: tempGlyphs rule: Form over.	xTable := xTable copyFrom: 1 to: maxAscii+3.	characterToGlyphMap := nil.! !

!StrikeFont methodsFor: '*sf2-import'!
displayChar: ascii form: charForm	"Convenience utility used during conversion of BitFont files"	| m bigForm |	Display fillBlack: (0@0 extent: 20@14).	ascii printString displayAt: 0@2.	charForm width > 0 ifTrue:		[m := 5.		bigForm := charForm magnify: charForm boundingBox by: m@m.		Display border: ((bigForm boundingBox expandBy: m) translateBy: 50@2) width: m.		bigForm displayAt: 50@2.		Display fillBlack: ((50@2)+((m*charForm width)@0) extent: 1@(m*self height))].! !

!StrikeFont methodsFor: '*sf2-import' stamp: 'KenD 2/8/2016 16:39'!
familyName

	^self name withoutJustTrailingDigits! !

!StrikeFont methodsFor: '*sf2-import' stamp: 'md 11/14/2003 17:25'!
newFromStrike: fileName	"Build an instance from the strike font file name. The '.strike' extension	is optional."	| strike startName raster16 |	name := fileName copyUpTo: $..	"assumes extension (if any) is '.strike'"	strike := FileStream readOnlyFileNamed: name, '.strike.'.	strike binary.	"strip off direcory name if any"	startName := name size.	[startName > 0 and: [((name at: startName) ~= $>) & ((name at: startName) ~= $])]]		whileTrue: [startName := startName - 1].	name := name copyFrom: startName+1 to: name size.	type			:=		strike nextWord.		"type is ignored now -- simplest												assumed.  Kept here to make												writing and consistency more												straightforward."	minAscii		:=		strike nextWord.	maxAscii		:=		strike nextWord.	maxWidth		:=		strike nextWord.	strikeLength	:=		strike nextWord.	ascent			:=		strike nextWord.	descent			:=		strike nextWord.	"xOffset			:="		strike nextWord. 		raster16			:=		strike nextWord.		superscript		:=		ascent - descent // 3.		subscript		:=		descent - ascent // 3.		emphasis		:=		0.	glyphs			:=	Form extent: (raster16 * 16) @ (self height)  							offset: 0@0.		glyphs bits fromByteStream: strike.	xTable := (Array new: maxAscii + 3) atAllPut: 0.	(minAscii + 1 to: maxAscii + 3) do:		[:index | xTable at: index put: strike nextWord].	"Set up space character"	((xTable at: (Space asciiValue + 2))  = 0 or:			[(xTable at: (Space asciiValue + 2)) = (xTable at: (Space asciiValue + 1))])		ifTrue:	[(Space asciiValue + 2) to: xTable size do:					[:index | xTable at: index put: ((xTable at: index) + DefaultSpace)]].	strike close.	characterToGlyphMap := nil.! !

!StrikeFont methodsFor: '*sf2-import' stamp: 'KenD 2/8/2016 13:35'!
readFromStrike2: fileName  "StrikeFont new readFromStrike2: 'Palatino14.sf2'"	"Build an instance from the strike font stored in strike2 format.	fileName is of the form: <family name><pointSize>.sf2"	| fileEntry |	('*.sf2' match: fileName) ifFalse: [self halt.  "likely incompatible"].
	fileEntry := fileName asFileEntry."	name := (fileEntry pathComponents last) copyUpTo: $. . "  "Drop filename extension"
	name := fileEntry baseName.	fileEntry readStream: [ :strm |		strm binary.		self readFromStrike2Stream: strm.
	].! !

!StrikeFont methodsFor: '*sf2-import' stamp: 'KenD 2/7/2016 20:17'!
readFromStrike2Stream: file 	"Build an instance from the supplied binary stream on data in strike2 format"	type := file nextInt32.  type = 2 ifFalse: [file close. self error: 'not strike2 format'].	minAscii := file nextInt32.	maxAscii := file nextInt32.	maxWidth := file nextInt32.	ascent := file nextInt32.	descent := file nextInt32.	pointSize := file nextInt32.	superscript := ascent - descent // 3.		subscript := descent - ascent // 3.		emphasis := file nextInt32.	xTable := (Array new: maxAscii + 3) atAllPut: 0.	(minAscii + 1 to: maxAscii + 3) do:		[:index | xTable at: index put: file nextInt32].	glyphs := Form new readFrom: file.	"Set up space character"	((xTable at: (Character space  asciiValue + 2))  = 0 or:			[(xTable at: (Character space  asciiValue + 2)) = (xTable at: (Character space  asciiValue + 1))])		ifTrue:	[(Character space  asciiValue + 2) to: xTable size do:					[:index | xTable at: index put: ((xTable at: index) + 4 "DefaultSpace")]].	characterToGlyphMap := nil.! !

!StrikeFont methodsFor: '*sf2-import' stamp: 'ls 3/27/2000 17:43'!
writeAsStrike2On: file	"Write me onto a file in strike2 format.	fileName should be of the form: <family name><pointSize>.sf2"	file binary.	file nextInt32Put: 2.	file nextInt32Put: minAscii.	file nextInt32Put: maxAscii.	file nextInt32Put: maxWidth.	file nextInt32Put: ascent.	file nextInt32Put: descent.	file nextInt32Put: pointSize.	superscript := ascent - descent // 3.		subscript := descent - ascent // 3.		file nextInt32Put: emphasis.	(minAscii + 1 to: maxAscii + 3) do:		[:index | file nextInt32Put: (xTable at: index)].	glyphs writeOn: file.	file close.! !

!StrikeFont methodsFor: '*sf2-import' stamp: 'KenD 2/8/2016 13:31'!
writeAsStrike2named: fileName	"Write me onto a file in strike2 format.	fileName should be of the form: <family name> <pointSize>.sf2"
		fileName asFileEntry writeStream: [ :file | self writeAsStrike2On: file ]! !

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
