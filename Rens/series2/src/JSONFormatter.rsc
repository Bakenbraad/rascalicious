module JSONFormatter

import CloneDetection;
import FileReader;
import CloneStats;
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

public map[str, tuple[real, int, int]] getFileNameToStats(list[cloneClass] cloneClasses, loc projectLoc) {

	map[str, tuple[real, int, int]] fileNameToStats = ();
	
	for (cC <- cloneClasses) {
		for (cloneLoc <- cC[1]) {
			fileName = filterToDataFormat(cloneLoc.uri, projectLoc);
			if (!(fileName in fileNameToStats)) {
				fileNameToStats[fileName] = getFileClonePercentage(cloneLoc, cloneClasses);
			}
		}	
	}	
	return fileNameToStats;
}

public void createFileNameToNodesJSON(list[cloneClass] cloneClasses, loc projectLoc, int cloneType) {

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
	
	fileStats = getFileNameToStats(cloneClasses, projectLoc);
	
	for (fn <- fileNameToNodes) {		
		
		if (first) {
			JSONMap += "{\"filename\" : \"<fn>\", \"nodes\" : <locListToString(fileNameToNodes[fn])>, \"cloneinfo\" : [\"<fileStats[fn][0]>\",\"<fileStats[fn][1]>\",\"<fileStats[fn][2]>\"]}";
			first = false;
		} else {
			JSONMap += ", {\"filename\" : \"<fn>\", \"nodes\" : <locListToString(fileNameToNodes[fn])>, \"cloneinfo\" : [\"<fileStats[fn][0]>\",\"<fileStats[fn][1]>\",\"<fileStats[fn][2]>\"]}";
		}
	} 
	JSONMap += "] }";
	jsonToFile(JSONMap, "fileNameToNodes_<cloneType>");
}


public str formatJSONMap(list[cloneClass] cloneClasses, str mapName, loc projectLoc) {

	JSONMap = "{\"<mapName>\": [";
	
	first = true;
	
	for (cC <- cloneClasses) {	
	
		locs = cC[1];
		stringifiedLocs = locsToURLs(locs, projectLoc);		
		
		if (first) {
			JSONMap += "{\"node\" : \"<escape(toString(cC[0]),invalidJSON)>\",\"locs\" :<stringifiedLocs>, \"nodesize\": \"<calcFunctionalLines(countLines(locs[0]))>\"}";
			first = false;
		} else {
			JSONMap += ", {\"node\" : \"<escape(toString(cC[0]),invalidJSON)>\",\"locs\" : <stringifiedLocs>, \"nodesize\": \"<calcFunctionalLines(countLines(locs[0]))>\"}";
		}
	} 
	JSONMap += "] }";
	return JSONMap;
}

public void createNodeToLocsJSON(list[cloneClass] cloneClasses, loc projectLoc, int cloneType){
	
	nodeToLocsJSON = formatJSONMap(cloneClasses, "nodeToLocsJSON", projectLoc);
	jsonToFile(nodeToLocsJSON, "nodeToLocs_<cloneType>");
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

public list[str] locsToURLs(list[loc] locList, loc projectLoc) {

	outputList = [];
	
	for (l <- locList) {
		outputList += l.uri[(size(projectLoc.uri))..] + "|<l.begin.line>,<l.begin.column>|<l.end.line>,<l.end.column>";
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
	str outputLoc = projectLoc.uri + "/visualisation/<outputName>.json";
	writeFile(toLocation(outputLoc), JSON);
	return;
}