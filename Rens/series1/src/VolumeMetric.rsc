module VolumeMetric

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import List;
import String;
import demo::common::Crawl;
import FileReader;


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


public tuple[map[str, int], int,str] showLines(loc projectloc){
	map[str,int] projectVolumeValues = countProjectLines(findJavaFiles(projectloc));
	str rank = "";
	int codeLines = projectVolumeValues["lines"]-(projectVolumeValues["comments"] + projectVolumeValues["emptylines"]+projectVolumeValues["brackets"]);
	if(codeLines<=66000){
		rank = "++";
	}
	else if(codeLines<=246000){
		rank = "+";
	}
	else if(codeLines<=665000){
		rank = "o";
	}
	else if(codeLines<=1310000){
		rank = "-";
	}
	else rank = "--";
		
	return <projectVolumeValues, codeLines,rank>;
}