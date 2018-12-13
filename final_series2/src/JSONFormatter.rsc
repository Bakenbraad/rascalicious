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

alias cloneClass = tuple[node, list[loc]];

public void createCloneClassJSON(list[cloneClass] cloneClasses, int cloneType){
	
	jsonString = "{\"<cloneType>\": ["; 
	first = true;
	cloneCount = 0;
	
	for (cC <- cloneClasses) {
	
		stringifiedLocs = locListToString(locsToJSONUris(cC[1]));
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

public tuple[map[str, list[str]], map[str,str]] createFileRelations(list[cloneClass] cloneClasses, int cloneType, loc projectLoc) {
	
	map[str, list[str]] clonesPerFile = ();
	map[str, str] originalFileNames = ();
	
	for (cC <- cloneClasses) {
		cCLocs = cC[1];
		for (i <- [0.. size(cCLocs)]) {
			fileName = filterToDataFormat(cCLocs[i].uri, projectLoc);
			originalFileNames[fileName] = cCLocs[i].uri;
			if (fileName in clonesPerFile) {
				clonesPerFile[fileName] += locsToJSONUris(cCLocs - cCLocs[i], projectLoc);
			} else {
				clonesPerFile[fileName] = locsToJSONUris(cCLocs - cCLocs[i], projectLoc);				
			}
			clonesPerFile[fileName] = dup(clonesPerFile[fileName]);
		}		
	}
	return <clonesPerFile, originalFileNames>;
}

public str clonesPerFileToJSON(map[str, list[str]] clonesPerFile, map[str, str] originalFileNames) {

	outputString = "[{";
	for (file <- clonesPerFile) {
		outputString += "\"link\" : \"<originalFileNames[file]>\",\"name\" : \"<file>\", \"imports\" : ";
		outputString += locListToString(clonesPerFile[file]);
		outputString += "},{";
	}
	return outputString[..-2] + "]";	
}

public list[str] locsToJSONUris(list[loc] locList, loc projectLoc) {

	outputList = [];
	
	for (l <- locList) {
		outputList += filterToDataFormat(l.uri, projectLoc);
	}
	
	return outputList;
}

public str filterToDataFormat(str l, loc projectLoc) {
	splitString = split(".", l[10..]);
	ln = "";
	for (s <- splitString[..-1]) {
		ln += s;
	}
	return escape(ln, ("/":"."));	
}

public str locListToString(list[str] locs) {

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
	str outputLoc = projectLoc.uri + "/data_cat<cloneType>.json";
	writeFile(toLocation(outputLoc), JSON);
	return;
}