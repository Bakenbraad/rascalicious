module Visualisation

import JSONFormatter;
import CloneDetection;
import String;
import IO;

alias cloneClass = tuple[node, list[loc]];

public void addVisualisationToProject(loc projectLoc) {

	clonesCat1 = findCloneClasses(projectLoc, 1);
	clonesCat2 = findCloneClasses(projectLoc, 2);
	
	<clonesPerFile1, originalFileNames1> = createFileRelations(clonesCat1, 1, projectLoc);
	<clonesPerFile2, originalFileNames2> = createFileRelations(clonesCat2, 2, projectLoc);
	
	jsonToFile(clonesPerFileToJSON(clonesPerFile1, originalFileNames1),1);
	jsonToFile(clonesPerFileToJSON(clonesPerFile2, originalFileNames2),2);	

	visualisationHTML = readFile(|project://series2/visualisation/visualisation.html|);
	writeFile(toLocation(projectLoc.uri + "/visualisation.html"), visualisationHTML);
	return;
}
