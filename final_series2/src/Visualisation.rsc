module Visualisation

import JSONFormatter;
import CloneDetection;
import String;
import IO;

alias cloneClass = tuple[node, list[loc]];

public void addVisualisationToProject(loc projectLoc) {

	cloneClasses1 = findCloneClasses(projectLoc, 1);
	cloneClasses2 = findCloneClasses(projectLoc, 2);
	
	<clonesPerFile1, originalFileNames1> = createFileRelations(cloneClasses1, projectLoc);
	<clonesPerFile2, originalFileNames2> = createFileRelations(cloneClasses2, projectLoc);
	
	jsonToFile(clonesPerFileToJSON(clonesPerFile1, originalFileNames1),"fileRelations_cat1");
	jsonToFile(clonesPerFileToJSON(clonesPerFile2, originalFileNames2),"fileRelations_cat2");	
	createFileNameToNodesJSON(cloneClasses1, projectLoc);
	createNodeToLocsJSON(cloneClasses1, projectLoc);

	visualisationHTML = readFile(|project://series2/visualisation/visualisation.html|);
	writeFile(toLocation(projectLoc.uri + "/visualisation.html"), visualisationHTML);
	return;
}
