module Visualisation

import JSONFormatter;
import CloneDetection;
import CloneStats;
import String;
import IO;

alias cloneClass = tuple[node, list[loc]];

public void addVisualisationToProject(loc projectLoc) {

	cloneClasses1 	= findCloneClasses(projectLoc, 1);
	cloneClasses2 	= findCloneClasses(projectLoc, 2);
	
	cloneType1Perc 	= getClonePercentage(cloneClasses1, projectLoc);	
	cloneType2Perc 	= getClonePercentage(cloneClasses2, projectLoc);
	
	<clonesPerFile1, originalFileNames1> = createFileRelations(cloneClasses1, projectLoc);
	<clonesPerFile2, originalFileNames2> = createFileRelations(cloneClasses2, projectLoc);
	
	jsonToFile(clonesPerFileToJSON(clonesPerFile1, originalFileNames1),"fileRelations_1");
	jsonToFile(clonesPerFileToJSON(clonesPerFile2, originalFileNames2),"fileRelations_2");	
	
	jsonToFile("[{\"percentage\" :<cloneType1Perc>}]","cloning_1");
	jsonToFile("[{\"percentage\" :<cloneType2Perc>}]","cloning_2");

	createFileNameToNodesJSON(cloneClasses1, projectLoc, 1);
	createNodeToLocsJSON(cloneClasses1, projectLoc, 1);

	createFileNameToNodesJSON(cloneClasses2, projectLoc, 2);
	createNodeToLocsJSON(cloneClasses2, projectLoc, 2);
	
	mkDirectory(projectLoc + "visualisation");
	copyDirectory(|project://series2/visualisation/|, projectLoc + "visualisation");
	
	return;
}
