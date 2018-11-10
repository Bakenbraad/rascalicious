module CodeDuplication

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import util::Math;
import demo::common::Crawl;
import IO;
import List;
import Map;
import String;

// Temporarily used from VolumeMetric.
public loc projectloc = |project://smallsql0.21_src/|;

public list[loc] findJavaFiles() {
	return crawl(projectloc, ".java");
}

public map[int, tuple[loc, str]] linesToLocMap(loc location){
	
	int linesOfCom = 0;
	int linesCount = 0;
	int totalLength = 0;
	whiteSpaces = (" " : "", "\t" : "", "\n" : "");
	
	// Return the list of modified strings (no comments and no whitespace) in combination to their original start line.
	results = ();
	
	for (line <- readFileLines(location)) {
		linesCount += 1;
			
		// Check if a line is a comment (Should not affect code duplication).
		if(startsWith(trim(line), "//") || (startsWith(trim(line),"/*") && endsWith(trim(line),"*/"))) {
			// We have  a comment line, dont add the string!
			results += (linesCount : <location(totalLength, size(line)), "">);				
		} else if (startsWith(trim(line),"/*") || linesOfCom > 0) {
			// Skip multiline code strings.
			linesOfCom += 1;
			if (endsWith(trim(line),"*/")){
				linesOfCom = 0;
			}
			results += (linesCount : <location(totalLength, size(line)), "">);
		} else if (contains(line, "//")) {
			// We have a line of code with a comment, cut off the comment.
			lineSplit = split("//", trim(line));
			modifiedLine = escape(lineSplit[1], whiteSpaces);
			results += (linesCount : <location(totalLength, size(line)), modifiedLine>);
		} else {
			// Remove all whitespace and add the string to the list of modified strings.
			modifiedLine = escape(line, whiteSpaces);
			results += (linesCount : <location(totalLength, size(line)), modifiedLine>);
		}
		// Add the line length plus 2 (for the /n unicode chars left out by the read function).
		totalLength += (size(line) + 2);
		
	} 
	return results;
}

public map[str, list[loc]] generateAggregates(loc location, map[str, list[loc]] results) {

	locMap = linesToLocMap(location);
	locMapSize = size(locMap);
	
	for (int i <- [1..locMapSize - 5]) {
				
		int j = 0;
		int blocksize = 0;
		str block = "";
		
		// Get the <loc, string> tuple form the line.
		locAndString = locMap[i];
		lineLoc = locAndString[0];
		lineStr = locAndString[1];
		
		// Initiate the start and end of the block.
		startOfBlock = lineLoc.offset;
		endOfBlock = 0;
		
		// Add lines of code to the blocks untill it is 6 long or the end is reached.
		while (blocksize < 6 && locMapSize > (i + j) && lineStr != "") {
		
			// Retrieve the next line.
			nextLine = locMap[i + j];
			
			// If the next line is not empty (actual code), add it to the block.
			if (nextLine[1] != "") {
				block += nextLine[1];
				blocksize += 1;
			}
			
			// Increase the offset of the block and add 2 for /n.
			endOfBlock += (nextLine[0].length + 2);
			
			// Move to the next line.
			j += 1;
		}
		
		// If the block is complete, save it in the results map and move to the next one.
		if (blocksize == 6) {
			if (block in results) {
				results[block] += (location(startOfBlock, endOfBlock));
			}
			else {
				results[block] = [(location(startOfBlock, endOfBlock))];
			}
		}
	}
	return results;
}

public void main() {

	// Results should be the block as a string and the locations in which the block occurs.
	map[str, list[loc]] results = ();
	
	javaFiles = findJavaFiles();
	for (l <- javaFiles) {
		// For each file add the locations to the results map (block as string mapped to list of location of occurrance).
		results = generateAggregates(l, results);
	}
	
	// Print the duplications found in all the files.
	for (occurrance <- results) {
		if (size(results[occurrance]) > 1){
			println("Duplicate occurrances of code in:");
			
			// Print all locations in which the code occurs.
			duplicates = results[occurrance];
			for (dup <- duplicates) {
				println("<dup>");
			}
		}
	}
}