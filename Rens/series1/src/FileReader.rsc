module FileReader
import demo::common::Crawl;
import IO;
import ValueIO;
import List;
import Map;
import String;

// Get all java files from a project location.
public list[loc] findJavaFiles(loc l) {
	return crawl(l, ".java");
}

// From a location, reads untill eol or eof in case of last line.
public tuple[str,loc] getLine(loc l) {
	
	fileLength = getFileLength(toLocation(l.uri));
	lengthUnitllEOF = fileLength - l.offset;
	
	if(lengthUnitllEOF > 0) {
		l.length = lengthUnitllEOF;
		for (line <- readFileLines(l)) {
			if (line != "") {
				newLoc = toLocation(l.uri)(l.offset, size(line) + 2);
				return <line, newLoc>;
			} else {
				// Empty line found, add 2 for next line /n.
				l.offset += 2;
			}
		}
	}
	return <"",l>;
}

// Find the next line after a location (can be the last line if loc ends in the middle of a line.
public tuple[str,loc] getNextLine(loc l) {
	l.offset = l.offset + l.length;
	line = getLine(l);
	return line;		
} 

// Filters everything between quotation marks out of a line.
public str filterLines(str line){
	while(/<before:.*>.\".*\"<after:.*>/:=line) {		
			line = before+" "+after;
		}
	return line;
}

// Not or logical operator.
public bool notOr(bool b) {
	return (!b || false);
}
