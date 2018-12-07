module VolumeDetection

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import List;
import String;
import demo::common::Crawl;
import FileReader;
import CloneDetection;


public map[str,int] countProjectLines(loc projectLoc){

	allLocs = findJavaFiles(projectLoc);

map[str,int] values = (
					"lines" 		: 0,
					"comments" 		: 0,
					"emptylines" 	: 0, 
					"brackets" 		: 0
					);
	
	for(l <- allLocs){
	
		linesPerlocation = countLines(l);
		
		values["lines"]			+= linesPerlocation["lines"];
		values["comments"]		+= linesPerlocation["comments"];
		values["emptylines"]	+= linesPerlocation["emptylines"];
		values["brackets"]		+= linesPerlocation["brackets"];
	}
	
	return values;
}