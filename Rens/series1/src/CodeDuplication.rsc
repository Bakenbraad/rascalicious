module CodeDuplication

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import util::Math;
import demo::common::Crawl;
import IO;
import List;
import ValueIO;
import Map;
import String;
import FileReader;

// Temporarily used from VolumeMetric.
public loc projectloc = |project://smallsql0.21_src/|;
public map[str, str] filterCharacters = (" " : "", "\t" : "", "\n" : "", "}" : "", "{" : "");
//public loc projectloc = |project://test_project/|;

public int totalDuplicatedLines() {

	// Results should be the block as a string and the locations in which the block occurs.
	map[str, list[loc]] results = ();
	map[int, tuple[loc, str]] resultPerFile = ();
	
	javaFiles = findJavaFiles(projectloc);
	for (l <- javaFiles) {
		// For each file add the locations to the results map (block as string mapped to list of location of occurrance).
		resultPerFile = linesToLocMap(l);
		for (lineNumber <- resultPerFile) {
			if (resultPerFile[lineNumber][1] in results) {
				results[resultPerFile[lineNumber][1]] += [resultPerFile[lineNumber][0]];
			} else {
				results[resultPerFile[lineNumber][1]] = [resultPerFile[lineNumber][0]];
			}			
		}
	}
	
	// Now that we have a duplication map for the individual lines, count the duplicates.
	totalDuplicateLines = 0;
	uniqueLines = 0;
	for (occurrance <- results) {
		duplicates = results[occurrance];
		if (size(duplicates) > 1) {
			totalDuplicateLines += size(duplicates);
		} else {
			uniqueLines += 1;
		}
	}
	println("Total pure code lines: <uniqueLines + totalDuplicateLines>, percentage of duplication: <(uniqueLines / totalDuplicateLines) * 100>");
	return totalDuplicateLines;
}

public map[int, tuple[loc, str]] linesToLocMap(loc location){
	
	int linesOfCom = 0;
	int linesCount = 0;
	int totalLength = 0;
	
	// Return the list of modified strings (no comments and no whitespace) in combination to their original start line.
	results = ();
	
	for (line <- readFileLines(location)) {
		linesCount += 1;
		filteredLine = filterLines(line);
			
		// Check if a line is a comment (Should not affect code duplication).
		if(startsWith(trim(filteredLine), "//") || (startsWith(trim(filteredLine),"/*") && endsWith(trim(filteredLine),"*/"))) {
			// We have  a comment line, dont add the string!
			results += (linesCount : <location(totalLength, size(line)), "">);				
		} else if (startsWith(trim(filteredLine),"/*") || linesOfCom > 0) {
			// Skip multiline code strings.
			linesOfCom += 1;
			if (endsWith(trim(line),"*/")){
				linesOfCom = 0;
			}
			results += (linesCount : <location(totalLength, size(line)), "">);
		} else if (contains(filteredLine, "//")) {
			// We have a line of code with a comment, cut off the comment.
			lineSplit = split("//", trim(line));
			modifiedLine = escape(lineSplit[1], filterCharacters);
			results += (linesCount : <location(totalLength, size(line)), modifiedLine>);
		} else {
			modifiedLine = escape(line, filterCharacters);
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
	if (locMapSize - 5 < 0) {
		return results;
	}
	for (int i <- [1..locMapSize - 4]) {
				
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
		while (blocksize < 6 && locMapSize >= (i + j) && lineStr != "") {
		
			// Retrieve the next line.
			nextLine = locMap[i + j];
			
			// If the next line is not empty (actual code), add it to the block.
			if (nextLine[1] != "") {
				block += nextLine[1];
				blocksize += 1;
			}
			
			// Increase the offset of the block and add 2 for /n.
			if (locMapSize != i + j) {
				endOfBlock += (nextLine[0].length + 2);
			} else {
				// Dont add the 2 offset if the eof is reached.
				endOfBlock += nextLine[0].length;
			}			
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
	
	javaFiles = findJavaFiles(projectloc);
	for (l <- javaFiles) {
		// For each file add the locations to the results map (block as string mapped to list of location of occurrance).
		results = generateAggregates(l, results);
	}
	// Keep a list of the areas so you dont have to expand the same area over and over.
	// File pairs mapped to all the intervals of duplication.
	map[tuple[str, str], list[tuple[loc, loc]]] duplicateAreas = ();
	
	// Expand the duplications found in all the files.
	for (occurrance <- results) {	
		if (size(results[occurrance]) > 1){
			duplicates = results[occurrance];
			
			pairs = dupCombinations(duplicates);
			for (pair <- pairs) {
				nestedPair = false;
				if (<pair[0].uri, pair[1].uri> in duplicateAreas) {
					// There are already duplicate areas known between these files.
					// check if this pair is already covered by another
					intervals = duplicateAreas[<pair[0].uri, pair[1].uri>];
					
					for (i <- intervals) {
						if (!nestedPair && isSubLocOf(pair[0], i[0]) && isSubLocOf(pair[1], i[1])) {
							nestedPair = true;							
						}
					}
				} else {
					// No intervals yet known, add it unconditionally.
					expandedBlocks = tryExpandBlockPair(pair);
					duplicateAreas[<expandedBlocks[0].uri, expandedBlocks[1].uri>] = [expandedBlocks];
					// Set this to true so as to not add it twice.
					nestedPair = true;
				}
				if (!nestedPair) { 
					// No larger pair between these files known, expand and add.
					expandedBlocks = tryExpandBlockPair(pair);
					duplicateAreas[<expandedBlocks[0].uri, expandedBlocks[1].uri>] += [expandedBlocks];
					
					// Remove any smaller pair. This makes sure that no other subpairs are considered in the future.
					intervalsNew = [ni | ni <- duplicateAreas[<expandedBlocks[0].uri, expandedBlocks[1].uri>], !isSubLocOf(ni[0], expandedBlocks[0]), !isSubLocOf(ni[1], expandedBlocks[1])];
					duplicateAreas[<expandedBlocks[0].uri, expandedBlocks[1].uri>] = intervalsNew + [expandedBlocks];
				}
				
			}
		}
	}
	for (fileArea <- duplicateAreas) {
		dupList = duplicateAreas[fileArea];
		println("Duplication found between files <fileArea[0]> and <fileArea[1]>\n");
		for (dupBlocks <- dupList) {			
			println("See code in the following locations:");
			println("<dupBlocks[0]>");
			println("<dupBlocks[1]>\n");
		}		
	}
}

public bool isSubLocOf(loc l, loc superloc) {
	if (l.offset >= superloc.offset && l.offset + l.length <= superloc.offset + superloc.length) {
		return true;
	}
	return false;
}

public tuple[loc, loc] tryExpandBlockPair(tuple[loc, loc] pair) {

	nextRelLine1 = getNextRelevantLine(pair[0]);
	nextRelLine2 = getNextRelevantLine(pair[1]);
	
	if (nextRelLine1[0] == nextRelLine2[0] && nextRelLine1[0] != ""){
		// Expand the blocks with this line
		pair[0] = addLineToLoc(pair[0], nextRelLine1[1]);
		pair[1] = addLineToLoc(pair[1], nextRelLine2[1]);
				
		// Block has changed, call in recursion.
		return tryExpandBlockPair(pair);
	}
				
	return pair;
}

public loc addLineToLoc(loc l, loc nl) {
	newLength = (nl.offset - l.offset) + nl.length;
	l.length = newLength;
	return l;
}

// Generate all block combinations we need to explore.
public lrel[loc, loc] dupCombinations(list[loc] ls) {

	lrel[loc, loc] res = [];
	int s = size(ls);
	for (i <- [0..s]) {
		for (j <- [0..s]) {
			if (i != j) {
				fst = ls[i];
				snd = ls[j];
				if (!(<snd, fst> in res)) {
					res += [<fst, snd>];
				}
			}
		}
	}
	return res;
}

public tuple[str,loc] getNextRelevantLine(loc l) {
	
	nextLine = getNextLine(l);
	linesOfCom = 0;
	fileLength = getFileLength(toLocation(l.uri));
	
	while(nextLine[1].offset + nextLine[1].length <= fileLength) {

		filteredLine = filterLines(nextLine[0]);
		
		// Check if the line is a line of code or comment, if mixed, clip and return.
		if(startsWith(trim(filteredLine), "//") || (startsWith(trim(filteredLine),"/*") && endsWith(trim(filteredLine),"*/"))) {
			// We have a pure comment line, NOP.
			l = l;
		} else if (startsWith(trim(filteredLine),"/*") || linesOfCom > 0) {
			// Skip over multiline code strings.
			linesOfCom += 1;
			if (endsWith(trim(nextLine[0]),"*/")){
				linesOfCom = 0;
			}
		} else if (contains(filteredLine, "//")) {
			// We have a line of code with a comment appended, cut off the comment.
			lineSplit = split("//", trim(nextLine[0]));
			modifiedLine = escape(lineSplit[1], filterCharacters);
			if (modifiedLine != "") {
				nextLoc = nextLine[1];
				return <modifiedLine, nextLoc>;
			}			
		} else {
			// Remove all whitespace and add the string to the list of modified strings.
			modifiedLine = escape(nextLine[0], filterCharacters);
			if (modifiedLine != "") {
				nextLoc = nextLine[1];
				return <modifiedLine, nextLoc>;
			}
		}	
		// Get the next line.
		nextLine = getNextLine(nextLine[1]);
	}
	return <"", l>;
}


