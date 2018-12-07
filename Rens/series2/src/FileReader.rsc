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
	int linesOfCom 			= 0;
	int counter 			= 0;			
	for (line <- readFileLines(l)) {
		<results, linesOfCom, counter> = addFilteredLines(line, results, linesOfCom, counter);
	}
		
	return results;
}

public tuple[map[str,int], int, int] addFilteredLines(str line, map[str, int] results, int linesOfCom, int counter) {
	
	line = filterNestedLines(line);
	results["lines"] += 1;
	
	// Checks for one line comments
	if(startsWith(trim(line),"//") || contains(line,"//") || (startsWith(trim(line),"/*") && endsWith(trim(line),"*/"))){
		results["comments"] += 1;
	}
	// Checks for comments of more than one line
	else if (startsWith(trim(line),"/*") || linesOfCom > 0 || contains(trim(line),"/*")){
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
	// Checks for empty lines
	else if(trim(line) == ""){
		results["emptylines"]+=1;
	}
	else if(escape(trim(line), brackets)==""){
		results["brackets"]+=1;
	}
	
	return <results, linesOfCom, counter>;
}