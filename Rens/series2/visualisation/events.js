
function mouse(e) {
		return [e.pageX - radius, e.pageY - radius];
	}
	
function mouseclick(d) {

    var source = d.data.filename,
        targets = d.data.locs,
        selected = d.selected;
        
    
    if (selectedNode != d) {
        if (Object.keys(selectedNode).length !== 0) {				
            selectedNode.selected = false;
            mouseout(selectedNode);
        }			
        selectedNode = d;
    }
    var selectedClones = [];
    if (selected) {			
        d.selected = false;
        mouseout(d);
    } else {
        d.selected = true;
        mouseover(d);		
        selectedClones = getFileCloneClasses(d);
    }

    document.getElementById('cloneList').innerHTML = "";
    document.getElementById('cloneList').appendChild(makeCloneCollapsible(selectedClones));
    setCollapsibleListeners();
    
    return;
}

function mouseover(d) {
		var source = d.data.filename,
			targets = d.data.locs;
			
		targets.forEach(function(t) { 
			if (selectedNode.data === undefined || selectedNode.data.filename !== t) {
				updatePath(source, t, "#B10DC9", "1", "1.5", "black"); 
			}			
			updatePath(t, source, "#B10DC9", "1", "1.5", "green");
		});
			
	}
	
function mouseout(d) {
            
    var source = d.data.filename,
        targets = d.data.locs;
        selected = d.selected,
        keepTextRed = [];
        
    if (!selected) {
        // Check if the current link of node being turned off is not a link of the selected node, they can only be turned off if we are deselecting the selected node.
        targets.forEach(function(t) { 
            if(selectedNode.data !== undefined) {
                if(selectedNode == d || !(selectedNode.data.locs.indexOf(source) !== -1 && selectedNode.data.filename === t )) {
                    updatePath(source, t, "blue", "0.5", "0.5", getTextColor(d));
                    updatePath(t, source, "blue", "0.5", "0.5", getTextColor(d));
                }
            } else {
                updatePath(source, t, "blue", "0.5", "0.5", getTextColor(d));
                updatePath(t, source, "blue", "0.5", "0.5", getTextColor(d));
            }
        });
    }		
}

function buttonChangeCat(){
    var newCat 	= "",
        url		= urlParams[0];
    switch (cloneCat){
        case "1" : newCat = "2"; break;
        case "2" : newCat = "1"; break;
    }
    url = url +"?file="+project+"&cat="+newCat;
    window.location.href = url;

}

function buttonChangeFile(){
    var newProj = "",
        url		= urlParams[0];
    switch (project){
        case "small" : newProj 	= "big"; break;
        case "big" 	 : newProj 	= "small"; break;
    }
    url = url +"?file="+newProj+"&cat="+cloneCat;
    window.location.href = url;

}