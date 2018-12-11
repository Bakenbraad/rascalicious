module JSONFormatter

import CloneDetection;
import IO;
import List;
import String;
import Node;

/* 
	The following functions take a list of cloneclasses (pairs of a node and its locations)
	and write them in json format to a file inside the project.
*/

alias cloneClass 	= tuple[node, list[loc]];

public void createCloneClassJSON(list[cloneClass] cloneClasses, int cloneType){
	
	jsonString = "{\"<cloneType>\": ["; 
	first = true;
	cloneCount = 0;
	
	for (cC <- cloneClasses) {
	
		stringifiedLocs = locListToString(cC[1]);
		cloneCount += 1;
		cCName = "clone<cloneCount>";
		
		if (first) {
			jsonString += "{\"<cCName>\":<stringifiedLocs>}";
			first = false;
		} else {
			jsonString += ",{\"<cCName>\":<stringifiedLocs>}";
		}
	} 
	jsonString += "] }";
	return jsonToFile(jsonString, cloneType); ;
}

public str locListToString(list[loc] locs) {

	stringifiedLocs = "[";
	first = true;
	for (l <- locs) {
		if (first) {
			stringifiedLocs += "\"<l>\"";
			first = false;
		} else {
			stringifiedLocs += ",\"<l>\"";
		}
	}
	stringifiedLocs += "]";
	return stringifiedLocs;
}

public void jsonToFile(str JSON, int cloneType) {
	str outputLoc = projectLoc.uri + "/clones_cat<cloneType>.json";
	writeFile(toLocation(outputLoc), JSON);
	return;
}