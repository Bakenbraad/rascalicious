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

public map[int, tuple[loc, str]] linesToLocMap(loc location){
	
	int multiLineComment = 0;
	int linesCount = 0;
	int totalLength = 0;
	
	fileText = readFile(location);
	//fileFiltered = escape(fileText,("\r" : "")); 
	fileLines = split("\n",fileText);
	
	// Return the list of modified strings (no comments and no whitespace) in combination to their original start line.
	results = ();
	for (line <- fileLines) {
		linesCount += 1;
		
		<filteredLine, multiLineComment> = filterLine(line, multiLineComment);
		results += (linesCount : <location(totalLength, size(line)), escape(filteredLine,filterCharacters)>);
	
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
			
			locationBlock = (location(startOfBlock, endOfBlock));
			if (block in results) {				
				results[block] += locationBlock;
			}
			else {
				results[block] = [(location(startOfBlock, endOfBlock))];
			}
		}
	}
	return results;
}

public int getProjectCodeDuplication(loc projectloc, int printMode) {

	// Results should be the block as a string and the locations in which the block occurs.
	map[str, list[loc]] results = ();
	
	javaFiles = findJavaFiles(projectloc);
	for (l <- javaFiles) {
		// For each file add the locations to the results map (block as string mapped to list of location of occurrance).
		results = generateAggregates(l, results);
	}
	// Keep a list of the areas so you dont have to expand the same area over and over.
	// File pairs mapped to all the intervals of duplication.
	map[tuple[str, str], list[tuple[tuple[loc, loc], int]]] duplicateAreas = ();
	
	// Expand the duplications found in all the files.
	for (occurrance <- results) {	
		if (size(results[occurrance]) > 1){
			duplicates = results[occurrance];
			
			pairs = dupCombinations(duplicates);
			for (pair <- pairs) {
				nestedPair = false;
				if (<pair[0][0].uri, pair[0][1].uri> in duplicateAreas) {
					// There are already duplicate areas known between these files.
					// check if this pair is already covered by another
					intervals = duplicateAreas[<pair[0][0].uri, pair[0][1].uri>];
					
					for (i <- intervals) {
						if (!nestedPair && isSubLocOf(pair[0][0], i[0][0]) && isSubLocOf(pair[0][1], i[0][1])) {
							nestedPair = true;							
						}
					}
				} else {
					// No intervals yet known, add it unconditionally.
					expandedBlocks = tryExpandBlockPair(pair);
					duplicateAreas[<expandedBlocks[0][0].uri, expandedBlocks[0][1].uri>] = [expandedBlocks];
					// Set this to true so as to not add it twice.
					nestedPair = true;
				}
				if (!nestedPair) { 
					// No larger pair between these files known, expand and add.
					expandedBlocks = tryExpandBlockPair(pair);
					duplicateAreas[<expandedBlocks[0][0].uri, expandedBlocks[0][1].uri>] += [expandedBlocks];
					
					// Remove any smaller pair. This makes sure that no other subpairs are considered in the future.
					intervalsNew = [ni | ni <- duplicateAreas[<expandedBlocks[0][0].uri, expandedBlocks[0][1].uri>], !isSubLocOf(ni[0][0], expandedBlocks[0][0]), !isSubLocOf(ni[0][1], expandedBlocks[0][1])];
					duplicateAreas[<expandedBlocks[0][0].uri, expandedBlocks[0][1].uri>] = intervalsNew + [expandedBlocks];
				}				
			}
		}
	}
	duplicatedLines = 0;
	for (fileArea <- duplicateAreas) {
		dupList = duplicateAreas[fileArea];
		if (printMode == 1) {
			println("Duplication found between files <fileArea[0]> and <fileArea[0]>\n");			
		}

		for (dupBlocks <- dupList) {			
			if(printMode == 1) {
				println("See code in the following locations:");
				println("<dupBlocks[0][0]>");
				println("<dupBlocks[0][1]>");
				println("For a total lines of <dupBlocks[1]>\n");
			}			
			// Add the line size of the duplicated block to the duplicated lines counter.
			duplicatedLines += dupBlocks[1];
		}		
	}
	return (duplicatedLines);
}

public bool isSubLocOf(loc l, loc superloc) {
	if (l.offset >= superloc.offset && l.offset + l.length <= superloc.offset + superloc.length) {
		return true;
	}
	return false;
}

public tuple[tuple[loc, loc], int] tryExpandBlockPair(tuple[tuple[loc, loc], int] pair) {

	nextRelLine1 = getNextRelevantLine(pair[0][0]);
	nextRelLine2 = getNextRelevantLine(pair[0][1]);
	
	if (nextRelLine1[0] == nextRelLine2[0] && nextRelLine1[0] != ""){
		// Expand the blocks with this line
		tup1 = addLineToLoc(pair[0][0], nextRelLine1[1]);
		tup2 = addLineToLoc(pair[0][1], nextRelLine2[1]);
		pair[0] = <tup1,tup2>;
		
		// Add one line
		pair[1] += 1;
				
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
public lrel[tuple[loc, loc], int] dupCombinations(list[loc] ls) {

	lrel[tuple[loc, loc], int] res = [];
	int s = size(ls);
	for (i <- [0..s]) {
		for (j <- [0..s]) {
			if (i != j) {
				fst = ls[i];
				snd = ls[j];
				if (!(<<snd, fst>,6> in res)) {
					res += [<<fst, snd>,6>];
				}
			}
		}
	}
	return res;
}

public tuple[str,loc] getNextRelevantLine(loc l) {
	
	nextLine = getNextLine(l);
	multiLineComment = 0;
	fileLength = getFileLength(toLocation(l.uri));
	
	while(nextLine[1].offset + nextLine[1].length <= fileLength) {

		<filteredLine, multiLineComment> = filterLine(nextLine[0], multiLineComment);
		if (filteredLine != "") {
			return <filteredLine, nextLine[1]>;
		}
		// Get the next line.
		nextLine = getNextLine(nextLine[1]);
	}
	return <"", l>;
}

// Not or logical operator.
public bool notOr(bool b) {
	return (!b || false);
}
