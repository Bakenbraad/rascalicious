module VolumeMetric

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import List;
import String;
import demo::common::Crawl;


// public loc carProject = |project://test_project//src//test_project/Cars.java|;
public loc projectloc 	= |project://smallsql0.21_src|;
public loc projectloc1 	= |project://test_project|;

public map[str,int] countProjectLines(list[loc] allLocations){
	map[str,int] values = ();
	values["lines"] 		= 0;
	values["comments"]		= 0;
	values["emptylines"]	= 0;
	values["brackets"]		= 0;
	for(location <- allLocations){
		linesPerlocation = countLines(location);
		values["lines"]+= linesPerlocation["lines"];
		values["comments"]+= linesPerlocation["comments"];
		values["emptylines"]+= linesPerlocation["emptylines"];
		values["brackets"]+= linesPerlocation["brackets"];
	}
	
	return values;
}

public str filterLines(str line){
	while(/<before:.*>.+\".+\"<after:.*>/:=line){
		
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
			line = filterLines(line);
			results["lines"] += 1;
			
			// checks for one line comments
			if(startsWith(trim(line),"//") || contains(line,"//") || (startsWith(trim(line),"/*") && endsWith(trim(line),"*/"))){
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