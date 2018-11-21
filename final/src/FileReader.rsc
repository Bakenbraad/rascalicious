module FileReader
import demo::common::Crawl;
import IO;
import ValueIO;
import List;
import Map;
import String;

public map[str, str] filterCharacters = (" " : "", "\t" : "", "\n" : "", "{" : "", "}" : "");

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
public str filterNestedLines(str line){
	while(/<before:.*>.\".*\"<after:.*>/:=line) {		
			line = before+" "+after;
		}
	return line;
}


public map[str,int] countLines(loc curProjectLoc) {

	map[str,int] results = ();
	
	results["lines"] 		= 0;
	results["comments"]		= 0;
	results["emptylines"]	= 0;
	results["brackets"]		= 0;
	int linesOfCom 			= 0;
	int counter 			= 0;
	brackets				= ("{":"", "}":"");			
	
	
		for (line <- readFileLines(curProjectLoc)) {
			line = filterNestedLines(line);
			results["lines"] += 1;
			
			// checks for one line comments
			if(startsWith(trim(line),"//") || (startsWith(trim(line),"/*") && endsWith(trim(line),"*/"))){
				results["comments"] += 1;
			}
			// checks for comments of more than one line
			else if (startsWith(trim(line),"/*") || linesOfCom>0 || contains(trim(line),"/*")){
				if((!startsWith(trim(line),"/*") && contains(trim(line),"/*"))){
					counter+=1;
				}
				linesOfCom += 1;
				if (endsWith(trim(line),"*/")){
					results["comments"] += (linesOfCom - counter);
					linesOfCom 	= 0;
					counter		= 0;
				}
				else if (contains(line,"*/")){
					counter+=1;
					results["comments"] += (linesOfCom - counter);
					linesOfCom 	= 0;
					counter		= 0;
				}
			}
			// checks for empty lines
			else if(trim(line) == ""){
				results["emptylines"]+=1;
			}
			else if(escape(trim(line), brackets)==""){
				results["brackets"]+=1;
			}
		 }
		
	return results;
}

public tuple[str, int] filterLine(str line, int multiLineCom) {

	// Remove any comment indicators nested in strings.
	filteredLine = trim(filterNestedLines(line));
	
	if(startsWith(filteredLine,"//") || (startsWith(filteredLine,"/*") && endsWith(filteredLine,"*/")) && multiLineCom != 0){
		// We have  a single comment line
		return <"", multiLineCom>;						
	} else if (contains(filteredLine,"/*") && multiLineCom == 0){
		// We enter a mulitline comment.
		multiLineCom = 1;
		
		if (startsWith(trim(line), "/*")) {
			return <"",multiLineCom>;
		} else {
			lineSplit = split("/*", trim(line));
			if (size (lineSplit) > 1 && contains(lineSplit[1], "*/")) {
				// A multiline comment starts and ends on this line, after some code.
				modifiedLine = escape(lineSplit[0], filterCharacters);
				multiLineCom = 0;
				return <modifiedLine, multiLineCom>;
			} else if (size(lineSplit) > 1) {
				modifiedLine = escape(lineSplit[0], filterCharacters);
				return <modifiedLine, multiLineCom>;
			}
		}		
	} else if (multiLineCom > 0) {
		if (endsWith(trim(line),"*/")){
			// A mulitline comment ends here.
			multiLineCom = 0;
			return <"", multiLineCom>;
		}
		else if (contains(line,"*/")){
			// A mulitline comment ends somewhere in this line.
			multiLineCom = 0;
			lineSplit = split("*/", trim(line));
			
			if (size(lineSplit) > 1) {
				modifiedLine = escape(lineSplit[1], filterCharacters);
				return <modifiedLine, multiLineCom>;	
			} else {
				return <"", multiLineCom>;	
			}				
		}
		return <"", multiLineCom>;
	} else if (contains(filteredLine, "//") && multiLineCom == 0) {
		lineSplit = split("//", trim(line));
		modifiedLine = escape(lineSplit[0], filterCharacters);
		return <modifiedLine, multiLineCom>;	
		
	}
	return <escape(trim(line),filterCharacters), multiLineCom>;			
}