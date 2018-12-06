module JSONFormatter

import Clone2;
import IO;
import List;
import String;
import Node;

/* 
	The following functions take a list of cloneclasses (pairs of a node and its locations)
	and write them in json format to a file inside the project.
*/

alias cloneClass 	= tuple[node, list[loc]];

public void createCloneClassJSON(list[cloneClass] cloneClasses){
	
	jsonString = "{\"<projectLoc>\": ["; 
	first = true;
	for (cC <- cloneClasses) {
	
		stringifiedLocs = locListToString(cC[1]);
		cCName = toString(cC[0]);
		
		if (first) {
			jsonString += "{\"<cCName>\":<stringifiedLocs>}";
			first = false;
		} else {
			jsonString += ",{\"<cCName>\":<stringifiedLocs>}";
		}
	} 
	jsonString += "] }";
	return jsonToFile(jsonString); ;
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

public void jsonToFile(str JSON) {
	str outputLoc = projectLoc.uri + "/clones.json";
	writeFile(toLocation(outputLoc), JSON);
	return;
}