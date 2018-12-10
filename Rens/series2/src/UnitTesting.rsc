module UnitTesting

import IO;
import String;
import FileReader;
import util::Math;

alias randLine = tuple[int, str, str];

public str lineName = "lines";
public str comName = "comments";
public str empName = "emptylines"; 
public str bracName = "brackets";

public int testFileLines = 15;
public int testSamples = 50;
public loc outputLoc = toLocation("project://series2/TestingFramework/countingTestLines.txt");

public str succText = "Successfully tested with <testSamples> samples";
public str succTextSingle = "Successfully tested functions";

public void main() {
	testFileReader();
	return;
}

public void testFileReader() {

	println("TESTING: countLines and addFilteredLines");

	for (n <- [0..testSamples]) {
		generatedValues = volumeTestFileGenerator();
		functionValues = countLines(outputLoc);
		if (functionValues != generatedValues) {
			println("Test Failed: Could not match:\n output: <functionValues>\n with \n generated: <generatedValues>");
			return;
		}		
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

	writeFile(outputLoc, lines);
	
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

	for (i <- [0..testFileLines]) {
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
