# SF2-Import
Import Squeak sf2 format (StrikeFont) files
============================
Tested in Cuis 4.2  rev 2679

To load the package
````Smalltalk
	Feature require: #'SF2-Import''.
````

You will need to unzip the AccuFonts.zip file.  A good place for this would be Cuis-Smalltalk-Dev/AdditionalFonts.
````Smalltalk
	AdditionalFontData/StrikeFonts'.
	(StringMorph 
		contents: 'Some text in a particular font!' 
		font: (AbstractFont familyName: 'Accujen' aroundPointSize: 30))
		 openInHand.
````
