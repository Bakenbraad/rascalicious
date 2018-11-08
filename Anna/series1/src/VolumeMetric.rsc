module VolumeMetric

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import List;
import String;
import demo::common::Crawl;

public loc carProject = |project://test_project//src//test_project/Cars.java|;

public map[str,int] countProjectLines(list[loc] allLocations){
	map[str,int] values = ();
	values["lines"] 		= 0;
	values["comments"]		= 0;
	values["emptylines"]	= 0;
	for(location <- allLocations){
		linesPerlocation = countLines(location);
		values["lines"]+= linesPerlocation["lines"];
		values["comments"]+= linesPerlocation["comments"];
		values["emptylines"]+= linesPerlocation["emptylines"];
	}
	return values;
}

public map[str,int] countLines(loc carProjectLoc) {

	map[str,int] results = ();
	
	results["lines"] 		= 0;
	results["comments"]		= 0;
	results["emptylines"]	= 0;
	int linesOfCom 			= 0;			
	
	
		for (line <- readFileLines(carProjectLoc)) {
		
			results["lines"] += 1;
			
			// checks for one line comments
			if(startsWith(trim(line),"//") || contains(line,"//") || (startsWith(trim(line),"/*") && endsWith(trim(line),"*/"))){
				results["comments"] += 1;
			}
			// checks for comments of more than one line
			else if (startsWith(trim(line),"/*") || linesOfCom>0){
				linesOfCom += 1;
				if (endsWith(trim(line),"*/")){
					results["comments"] += linesOfCom;
					linesOfCom = 0;
				}
			}
			// checks for empty lines
			else if(trim(line) == ""){
				results["emptylines"]+=1;
			}
		 }
		
	return results;
}