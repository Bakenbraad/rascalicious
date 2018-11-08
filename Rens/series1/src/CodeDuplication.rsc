module CodeDuplication

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import util::Math;
import IO;
import List;
import Map;
import String;

public loc carProject = |project://test_project//src//test_project/Cars.java|;

public map[int, str] getAggregatedLines(){

	int linesOfCom = 0;
	int lineCount = 0;
	whiteSpaces = (" " : "", "\t" : "", "\n" : "");
	
	// Return the list of modified strings (no comments and no whitespace) in combination to their original start line.
	results = ();
	
	for (line <- readFileLines(carProject)) {
	
		lineCount += 1;
		
		// Check if a line is a comment (Should not affect code duplication).
		if(startsWith(trim(line), "//") || (startsWith(trim(line),"/*") && endsWith(trim(line),"*/"))) {
			// We have  a comment line, skip it!
			results += (lineCount : "");				
		} else if (startsWith(trim(line),"/*") || linesOfCom > 0) {
			// Skip multiline code.
			linesOfCom += 1;
			if (endsWith(trim(line),"*/")){
				linesOfCom = 0;
			}
		} else if (contains(line, "//")) {
			// We have a line of code with a comment, cut off the comment.
			lineSplit = split("//", trim(line));
			modifiedLine = escape(lineSplit[1], whiteSpaces);
			results += (lineCount : modifiedLine);
		} else {
			// Remove all whitespace and add the string to the list of modified strings.
			modifiedLine = escape(line, whiteSpaces);
			results += (lineCount : modifiedLine);
		}
		
	} 
	return results;
}

public map[tuple[int,int],str] getBlocks() {

	cleanLines = getAggregatedLines();
	cleanLinesCount = size(cleanLines);
	
	// Results should be the block and the first and last line in which the block occurs.
	map[tuple[int,int],str] results = ();
	
	for (int i <- [1..cleanLinesCount - 5]) {
				
		int j = 0;
		int blocksize = 0;
		str block = "";
		
		// Add lines of code to the blocks untill it is 6 long or the end is reached.
		while (blocksize < 6 && cleanLinesCount > (i + j) && cleanLines[i] != "") {
			if (cleanLines[i + j] != "") {
				block += cleanLines[i + j];
				blocksize += 1;
			}
			j += 1;
		}
		if (blocksize == 6) {
			results[<i,i + j>] = block;
		}
	}
	return results;
}

public void blocksToHashMap() {

	map[str,list[tuple[int,int]]] duplications = ();
	blocks = getBlocks();
	
	// Map all blockstrings to their occurrences in text, mulitple occurrences have multiple start-end line tuples.
	for (b <- blocks) {
		blockstring = blocks[b];
		if(blockstring in duplications) {
			println(b);
			duplications[blockstring] += b;
		} else {
			duplications[blockstring] = [b];
		}
	}
	
	// Print all duplications that are duplications.
	fileLines = readFileLines(carProject);
	for (d <- duplications) {
		if (size(duplications[d]) > 1){
			original = min(duplications[d]);
			originalLines = [original[0]..original[1]];
			duplicat = duplications[d] - original;
			println("The code in lines <originalLines>:");
			
			for (i <- originalLines) {
				println(fileLines[i - 1]);
			}
			println("is is duplicated in lines:");
			for (dup <- duplicat) {
				println("Lines: <[dup[0]..dup[1]]>");
			}
		}
	}	
}