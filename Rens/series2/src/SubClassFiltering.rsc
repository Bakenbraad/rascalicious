module SubClassFiltering

import Node;
import List;
import String;
import IO;
import Clone2;

alias subTreeMap 	= map[node, list[loc]];
alias cloneClass 	= tuple[node, list[loc]];
alias filePair 		= tuple[loc, loc];

/*
	The following functions take the initial output of mapping nodes to their locations.
	For each list of locations we get every pair of that list of locations and map them 
	to the two files they appear in.
	This way we get all the cloneclasses that occur in a pair of files.
	
	We need all pairs of 2 because if there is a transitive relation between 3 clone locations
	(a,b) & (b,c) -> (a,c), it is not necessarily the case for any superclass a pair may belong to.
	
	We then filter for each file pair the cloneclasses such that there is no 
	clone class that has a superclass, meaning it is contained inside another cloneclass.
	
	Finally, we reconstruct the original cloneclasses by mapping the original node back to all the locations
	and removing any duplicates from the list. Duplicates can be added by the fact that we look at all 
	possible pairs of locations.
*/
public subTreeMap filterSubClones(list[cloneClass] cloneClasses) {

	cloneClassesPerFilePair = createCloneClassesPerFilePair(cloneClasses);
	subTreeMap filteredNodes = ();
	
	for (fp <- cloneClassesPerFilePair) {
		allCloneClassesInFilePair = cloneClassesPerFilePair[fp];
		for (cC <- allCloneClassesInFilePair) {
			if (!isSubLocOfAny(cC, allCloneClassesInFilePair)) {
				locs = cC[1];
				if (cC[0] in filteredNodes) {
					filteredNodes[(cC[0])] += locs[0];
				} else {
					filteredNodes[(cC[0])] = [locs[0]];
				}
				filteredNodes[cC[0]] += locs[1];
			}
		}
	}
	
	return filteredNodes;
}

public bool isSubLocOfAny(cloneClass cC, list[cloneClass] allCloneClassesInFilePair) {
	
	cClocs = cC[1];
	cCOneLoc = cClocs[0];
	cCTwoLoc = cClocs[1];
	
	for (superCC <- allCloneClassesInFilePair) {
		if (cC != superCC) {
			
			superCCLocs = superCC[1];
			superCCOneLoc = superCCLocs[0];
			superCCTwoLoc = superCCLocs[1];
			
			if (isSubLocOf(cCOneLoc, superCCOneLoc) && isSubLocOf(cCTwoLoc, superCCTwoLoc)) {
				return true;
			}
		}
	}
	return false;
}

public bool isSubLocOf(loc l, loc superloc) {
	if (l.offset >= superloc.offset && l.offset + l.length <= superloc.offset + superloc.length) {
		return true;
	}
	return false;
}

public map[filePair, list[cloneClass]] createCloneClassesPerFilePair(list[cloneClass] cloneClasses) {
	
	map[filePair, list[cloneClass]] cloneClassPerFile = ();
	for (cC <- cloneClasses) {
		cloneLocs = cC[1];
		locCombinations = getLocCombinations(cloneLocs);
		cloneClassPerFile = insertCloneClassPerFile(locCombinations, cC, cloneClassPerFile);		
	}
	return cloneClassPerFile;
}

public map[filePair, list[cloneClass]] insertCloneClassPerFile(lrel[loc,loc] locCombinations, cloneClass cC, map[filePair, list[cloneClass]] cloneClassPerFile) {

	for (lc <- locCombinations) {
	
		loc1 = toLocation(lc[0].uri);
		loc2 = toLocation(lc[1].uri);
		
		if (<loc1, loc2> in cloneClassPerFile) {
			cloneClassPerFile[<loc1, loc2>] += <cC[0], [lc[0],lc[1]]>;
		} else if (<loc2, loc1> in cloneClassPerFile) {
			cloneClassPerFile[<loc2, loc1>] += <cC[0], [lc[1],lc[0]]>;
		} else {
			cloneClassPerFile[<loc1, loc2>] = [<cC[0], [lc[0],lc[1]]>];
		}
	}
	return cloneClassPerFile;
}

public list[tuple[loc, loc]] getLocCombinations(list[loc] locs) {
	
	res = [];
	
	locSize = size(locs);
	n = 1;
	
	if (locSize >= 2) {
		for (l <- locs) {
			for (i <- [n..locSize]) {
				res += <l, locs[i]>;
			}
			n += 1;
		}
	}
	return res;
}