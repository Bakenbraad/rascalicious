module FileReader
import demo::common::Crawl;
import IO;
import ValueIO;
import List;
import Map;
import String;

public map[str, str] filterCharacters = (" " : "", "\t" : "", "\n" : "", "}" : "", "{" : "");

// Filters everything between quotation marks out of a line.
public str filterNestedLines(str line){
	while(/<before:.*>.\".*\"<after:.*>/:=line) {		
			line = before+" "+after;
		}
	return line;
}

public str filterNestedComments(str line){
	while(/<before:.*>.\/\*.*\*\/<after:.*>/:=line) {		
			line = before+" "+after;
		}
	return line;
}

// Get all java files from a project location.
public list[loc] findJavaFiles(loc l) {
	return crawl(l, ".java");
}

public map[str,str] brackets = ("{":"", "}":"");

public map[str,int] countLines(loc l) {

	map[str,int] results = (
						"lines" 		: 0,
						"comments" 		: 0,
						"emptylines" 	: 0, 
						"brackets" 		: 0
						);
						
	int linesOfCom = 0;
	
	for (line <- readFileLines(l)) {
		<results, linesOfCom> = addFilteredLines(line, results, linesOfCom);
	}
		
	return results;
}

public tuple[map[str,int], int] addFilteredLines(str line, map[str, int] results, int linesOfCom) {
	
	// Remove any comment indicators nested in strings.
	filteredLine = trim(filterNestedLines(filterNestedComments(line)));
	results["lines"] += 1;
	
	if(startsWith(filteredLine,"//") || (startsWith(filteredLine,"/*") && endsWith(filteredLine,"*/"))){
		// We have  a single comment line
		results["comments"] += 1;						
	} else if (contains(filteredLine,"/*") && linesOfCom == 0){
		// We enter a mulitline comment.
		linesOfCom = 1;
		
		if (startsWith(trim(line), "/*")) {
			results["comments"] += 1;
		} else if (startsWith(trim(line), "}") || startsWith(trim(line), "{")){
			results["brackets"] += 1;
		}		
	} else if (linesOfCom > 0) {
		
		if (endsWith(trim(line),"*/")){
			// A mulitline comment ends here.
			linesOfCom = 0;			
			results["comments"] += 1;
		}
		else if (contains(line,"*/")){
			// A mulitline comment ends somewhere in this line.
			linesOfCom = 0;
			lineSplit = split("*/", trim(line));
			
			if (size(lineSplit) > 1) {
				if (lineSplit[1] == "}" || lineSplit[1] == "{") {
					results["brackets"] += 1;
				} else if (startsWith(trim(lineSplit[1]), "//")) {
					results["comments"] += 1;
				}
			}				
		} else {
			results["comments"] += 1;
		}
	} else if (startsWith(trim(line), "{")) {
		lineSplit = split("{", trim(line));
		if (size(lineSplit) == 0) {
			results["brackets"] += 1;
		} else if (startsWith(trim(lineSplit[1]), "//")) {
			results["brackets"] += 1;
		}	
	} else if (startsWith(trim(line), "}")){
		lineSplit = split("}", trim(line));
		if (size(lineSplit) == 0) {
			results["brackets"] += 1;
		} else if (startsWith(trim(lineSplit[1]), "//")) {
			results["brackets"] += 1;
		}
	}else if (trim(line) == "") {
		results["emptylines"] += 1;
	} 
	return <results, linesOfCom>;
}