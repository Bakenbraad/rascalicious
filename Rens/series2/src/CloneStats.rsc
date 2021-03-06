module CloneStats

import VolumeDetection;
import FileReader;
import CloneDetection;

import IO;
import String;
import List;
import util::Math;

alias cloneClass 	= tuple[node, list[loc]];

public int getSmallestCloneClass(list[cloneClass] cloneClasses) {

	smallestCloneClassOccurrance = 10000;
	
	for (cC <- cloneClasses) {
		locs = cC[1];
		funLines = calcFunctionalLines(countLines(locs[0]));
		if (funLines < smallestCloneClassOccurrance) {
			smallestCloneClassOccurrance = funLines;
		}
	}
	if(smallestCloneClassOccurrance == 10000) {
		return -1;
	} else {
		return smallestCloneClassOccurrance;
	}
}

public int getCloneClassCount(list[cloneClass] cloneClasses) { return size(cloneClasses);}

public int getBiggestCloneClassLOC(list[cloneClass] cloneClasses) { 
	
	largestCloneOccurrance = 0;
	if(size(cloneClasses) == 0) {
		return -1;
	}
	for (cC <- cloneClasses) {
		locs = cC[1];
		funLines = calcFunctionalLines(countLines(locs[0]));
		if (funLines > largestCloneOccurrance) {
			largestCloneOccurrance = funLines;
		}
	}
	return largestCloneOccurrance;
}

public int getBiggestCloneClass(list[cloneClass] cloneClasses) { 
	
	largestCloneOccurrance = 0;
	for (cC <- cloneClasses) {
		if (size(cC[1]) > largestCloneOccurrance) {
			largestCloneOccurrance = cC[1];
		}
	}
	return largestCloneOccurrance;
}

public tuple[real, int, int] getFileClonePercentage(loc file, list[cloneClass] cloneClasses) {

	totalFunctionalLines 	= calcFunctionalLines(countLines(toLocation(file.uri)));
	clonedLinesPerFile = 0;
	
	for (cC <- cloneClasses) {
		for (l <- cC[1]) {
			if (l.uri == file.uri) {
				clonedLinesPerFile += calcFunctionalLines(countLines(l));
			}
		}
	}
	
	return <(toReal(clonedLinesPerFile) / toReal(totalFunctionalLines) * 100), clonedLinesPerFile, totalFunctionalLines>;
}

public real getClonePercentage(list[cloneClass] cloneClasses, loc projectLoc) {
	
	clonedLines 			= 0;
	totalFunctionalLines 	= calcFunctionalLines(countProjectLines(projectLoc));
	
	for (cC <- cloneClasses) {
		locList = cC[1];
		for (l <- locList) {		
			clonedLines += calcFunctionalLines(countLines(l));
		}		
	}	

	return toReal(clonedLines) / toReal(totalFunctionalLines) * 100;
}

public int calcFunctionalLines(map[str,int] totalLines) {
	return totalLines["lines"] - (totalLines["comments"] + totalLines["emptylines"] + totalLines["brackets"]);
}