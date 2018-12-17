module UnitTesting

import IO;
import String;
import List;
import util::Math;

import FileReader;
import SubClassFiltering;
import CloneDetection;
import CloneStats;

alias randLine 					= tuple[int, str, str];

public str lineName 			= "lines";
public str comName 				= "comments";
public str empName 				= "emptylines"; 
public str bracName 			= "brackets";

public int sampleLength 		= 10;
public int testSamples 			= 30;
public loc fileReaderOutputLoc 	= toLocation("project://series2/TestingFramework/FileReader/countingTestLines.java");

public str succText 			= "Successfully tested with <testSamples> samples\n";
public str succTextSingle 		= "Successfully tested functions\n";
public str hashtagLine 			= "################################################\n";

public void printFailMsg(str funName, str output, str generated) {
	println("<funName>: Test Failed, Could not match:\n output: <output>\n with \n generated: <generated>");
	return;	
}

public void runUnitTests() {
	testFileReader();
	testSubClassFiltering();
	testCloneDetection();
	return;
}

/* 
	########################
	Tests for CloneDetection.rsc
	########################
*/

public void testCloneDetection() {
	
	println("<hashtagLine>Testing Rascal Module: CloneDetection, CloneStats\n<hashtagLine>");
	testCloningType("One");
	testCloningType("Two");
	return;
	
}

public void testCloningType(str cloneType) {

	println("TESTING: findCloneClasses and getClonePercentage");

	list[str] cases = ["Basic", "Commented", "DifferentBrackets", "DifferentSpacing", "InLineCommented", "MultiLineCommented"];
	
	for (c <- cases) {
		projectLoc = toLocation("project://series2/TestingFramework/CloneDetection/ClonesType<cloneType>/<c>");
		cloneClasses = findCloneClasses(projectLoc, numString(cloneType));
		clonePercentage = getClonePercentage(cloneClasses, projectLoc);
		if (clonePercentage != 100) {
			println("Clone Type <cloneType>: Test Failed, could not match nodes in <c>: should bee 100%, is <clonePercentage>");
			return;
		}
	}
	println("Successfully tested clone detection type <cloneType>.\n");
}
public int numString(str number) {
	switch (number) {
		case "One":
			return 1;
		case "Two":
			return 2;
	}
	return 1;
}

/* 
	########################
	Tests for SubClassFiltering.rsc
	########################
*/

public void testSubClassFiltering() {

	println("<hashtagLine>Testing Rascal Module: SubClassFiltering\n<hashtagLine>");
	testGetLocCombinations();
	testIsSubLocOf();
	return;
}

public void testIsSubLocOf() {
	
	println("TESTING: isSubLocOf");

	for (i <- [0..testSamples]) {
	
		subLoc 						= generateRandomLoc();	
		subLoc.length 				= arbInt(sampleLength);
		subLoc.offset 				= arbInt(sampleLength);
		
		superLocLength 				= subLoc;
		superLocLength.length 		+= arbInt(sampleLength);
		
		superLocOffset 				= subLoc;
		offsetDiff 					= arbInt(superLocOffset.offset + 1);
		superLocOffset.offset 		-= offsetDiff;
		superLocOffset.length		+= offsetDiff;
		
		superLocBothSides 			= subLoc;
		offsetDiff					= arbInt(superLocBothSides.offset + 1);
		superLocBothSides.offset 	-= offsetDiff;
		superLocBothSides.length 	+= (arbInt(sampleLength) + offsetDiff);
		
		if (!isSubLocOf(subLoc, superLocLength) || !isSubLocOf(subLoc, superLocOffset) || !isSubLocOf(subLoc, superLocBothSides)) {
			println("isSubLocOf: Test Failed, could not match:\n <subLoc>\n and one of\n <superLocLength>, <superLocOffset>, <superLocBothSides>");
			return;
		}
	}
	println(succText);
}

public void testGetLocCombinations() {

	println("TESTING: getLocCombinations");

	for (i <- [0..testSamples]) {
		randLocs = generateRandomLocs();
		locCombinations = getLocCombinations(randLocs);
		if (!(testLocCombinations(locCombinations, randLocs))) {
			println("getLocCombinations: Test Failed, could not match:\n <locCombinations>\n and \n <randLocs>");
			return;
		}
	}
	println(succText);
	
	return;
}

public bool testLocCombinations(list[tuple[loc, loc]] locCombinations, list[loc] randLocs) {
	
	allLocs = randLocs;
	
	if (randLocs == []) {
		return (locCombinations == []);
	} 
	
	if (size(randLocs) == 1) {
		return (locCombinations == []);
	}
	
	for (tup <- locCombinations) {
		if (!(tup[0] in randLocs) || !(tup[1] in randLocs) || (<tup[1], tup[0]> in locCombinations)) {
			return false;
		} 
		if (tup[0] in allLocs) {
			allLocs -= tup[0];
		}
		if (tup[1] in allLocs) {
			allLocs -= tup[1];		
		}
	}
	if (allLocs != []) {
		return false;
	}	
	return true;
}

public list[loc] generateRandomLocs() {
	
	int r = arbInt(testSamples);
	list[loc] randLocs = [];
	
	for (i <- [0..r]) {
		l = generateRandomLoc();
		if (!(l in randLocs)) {
			randLocs += l;
		}		
	}
	return randLocs;
}

public loc generateRandomLoc() {
	int r = arbInt(10000);
	loc l = toLocation("project://series2/TestingFramework/SubClassFiltering/<r>.java");
	return (l(0,0));
}	

/*  
	########################
	Tests for FileReader.rsc
	########################
*/
public void testFileReader() {

	println("<hashtagLine>Testing Rascal Module: FileReader\n<hashtagLine>");
	testLineCategorisation();
	testFilters();
	
	return;
}

public void testLineCategorisation() {

	println("TESTING: countLines and addFilteredLines");
	generatedValues = ();
	

	for (n <- [0..testSamples]) {
		generatedValues = volumeTestFileGenerator();
		functionValues = countLines(fileReaderOutputLoc);
		if (functionValues != generatedValues) {
			printFailMsg("addFilteredLines", toString(functionValues), toString(generatedValues));
			return;
		}		
	}
	
	if (countLines(fileReaderOutputLoc) != generatedValues) {
		printFailMsg("countLines", countLines(fileReaderOutputLoc), generatedValues);
	}
	
	println(succText);
	
	return;
}

public void testFilters() {

	str commentInString 		= "str a = \"test // test\"";
	str filteredComInString 	= "str a = ";
	
	str multiLineInLine 		= "str a = /* test */ 10";
	str filteredMulLineInLine 	= "str a =  10";
	
	str hybridLine = "str a = /* First a com */ \" Then a // string\"";
	str filteredHybridLine = "str a =  ";
	
	println("TESTING: string filters (filterNestedLines, filterNestedComments)");
	
	if (filteredComInString != filterNestedLines(commentInString)) {
		println("Test Failed: Could not filter <commentInString> properly: <filterNestedLines(commentInString)>");
		return;
	}
	if (filteredMulLineInLine != filterNestedComments(multiLineInLine)) {
		println("Test Failed: Could not filter <filteredMulLineInLine> properly: <filterNestedComments(multiLineInLine)>");
		return;
	}
	if (filteredHybridLine != filterNestedLines(filterNestedComments(hybridLine))) {
		println("Test Failed: Could not filter <filteredMulLineInLine> properly: <filterNestedComments(multiLineInLine)>");
		return;
	}
	println(succTextSingle);
	return;
}

public map[str,int] volumeTestFileGenerator() {

	<lines, values> = generateLines();

	writeFile(fileReaderOutputLoc, lines);
	
	return values;
}

public tuple[str, map[str, int]] generateLines() {

	map[str,int] values = (
					"lines" 		: 1,
					"comments" 		: 0,
					"emptylines" 	: 0, 
					"brackets" 		: 0
					);
	str outputString = "start\n";

	for (i <- [0..sampleLength]) {
		randLine rLine = randomLine();
		
		outputString += (rLine[2] + "\n");
		values[rLine[1]] += rLine[0];
		if (rLine[1] != lineName) {
			values[lineName] += rLine[0];
		}
	}
	// Add a "start" and "return" to prevent first/last emptylines.
	outputString += "return";
	values[lineName] += 1;
	 
	return <outputString, values>;
}

public randLine randomLine() {

	int randomInt = arbInt(13);
	
	// Return the expected linecount, the category it should fall in and the textual representation.
	switch (randomInt) {
		case 0:
			return <1, lineName, "a = 1;">;
		case 1: 
			return <1, comName, "// Hello this is a comment">;
		case 2:
			return <1, lineName, "int a = 1; //This is a hybrid line">;
		case 3:
			return <2, comName, "/* This is a multiline \n comment */">;
		case 4:
			return <2, lineName,  "a = 1;/* Multi hybrid \n line */ a = 2">;
		case 5: 
			return <1, empName, "">;
		case 6:
			return <1, lineName, "str edgeC = \"A string with a // comment\" ">;
		case 7:
			return <1, lineName, "a = 1 /* nested multiline */ + 2;">;
		case 8:
			return <8, comName, "/*\n This \n is \n a \n long \n multiline \n comment \n */">;
		case 9:
			return <1, bracName, "}">;
		case 10:
			return <1, bracName, "{">;
		case 11:
			return <1, bracName, "} // Bracket with comment.">; 
		case 12:
			return <2, comName, "/* Strange hybrid comment \n */ // Another com">;
	}
}
