module CloneStats

import VolumeDetection;
import FileReader;
import CloneDetection;
import IO;
import util::Math;

alias cloneClass 	= tuple[node, list[loc]];

public real getClonePercentage(list[cloneClass] cloneClasses) {
	
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