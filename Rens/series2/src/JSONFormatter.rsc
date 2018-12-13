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

map[str, str] invalidJSON = ("\\": " ", "\"" : "\'");

public void createFileNameToNodesJSON(list[cloneClass] cloneClasses, loc projectLoc) {

	map[str, list[str]] fileNameToNodes = (); 
	for (cC <- cloneClasses) {
		for (cloneLoc <- cC[1]) {
			fileName = filterToDataFormat(cloneLoc.uri, projectLoc);
			if(fileName in fileNameToNodes) {
				fileNameToNodes[fileName] += escape(toString(cC[0]),invalidJSON);
			} else {
				fileNameToNodes[fileName] = [escape(toString(cC[0]),invalidJSON)];
			}
		}	
	}	
	JSONMap = "{\"fileNameToNodes\": [";
	
	first = true;
	
	for (fn <- fileNameToNodes) {		
		if (first) {
			JSONMap += "{\"<fn>\":<locListToString(fileNameToNodes[fn])>}";
			first = false;
		} else {
			JSONMap += ",{\"<fn>\":<locListToString(fileNameToNodes[fn])>}";
		}
	} 
	JSONMap += "] }";
	jsonToFile(JSONMap, "fileNameToNodes");
}


public str formatJSONMap(list[cloneClass] cloneClasses, str mapName, loc projectLoc) {

	JSONMap = "{\"<mapName>\": [";
	
	first = true;
	
	for (cC <- cloneClasses) {	
	
		stringifiedLocs = locListToString(locsToJSONUris(cC[1], projectLoc));
		
		if (first) {
			JSONMap += "{\"<escape(toString(cC[0]),invalidJSON)>\":<stringifiedLocs>}";
			first = false;
		} else {
			JSONMap += ",{\"<escape(toString(cC[0]),invalidJSON)>\":<stringifiedLocs>}";
		}
	} 
	JSONMap += "] }";
	return JSONMap;
}

public void createNodeToLocsJSON(list[cloneClass] cloneClasses, loc projectLoc){
	
	nodeToLocsJSON = formatJSONMap(cloneClasses, "nodeToLocsJSON", projectLoc);
	jsonToFile(nodeToLocsJSON, "nodeToLocs");
}

public tuple[map[str, list[str]], map[str,str]] createFileRelations(list[cloneClass] cloneClasses, loc projectLoc) {
	
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
		outputString += "\"filename\" : \"<file>\", \"locs\" : ";
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

public void jsonToFile(str JSON, str outputName) {
	str outputLoc = projectLoc.uri + "/<outputName>.json";
	writeFile(toLocation(outputLoc), JSON);
	return;
}