// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(rnaturalearth)\n");	echo("require(sf)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    var country = getValue("down_country");
    var custom = getValue("down_custom");
    if (custom && custom !== "") { country = custom; }
    echo("map_sf <- rnaturalearth::ne_states(country = \"" + country + "\", returnclass = \"sf\")\n");
    echo("if(nrow(map_sf) == 0) stop(\"Could not find map data for country: " + country + ". Check spelling.\")\n");
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Download Country Map Object results")).print();
echo("rk.header(\"Map Download Successful\")\n");
	//// save result object
	// read in saveobject variables
	var saveMapObj = getValue("save_map_obj");
	var saveMapObjActive = getValue("save_map_obj.active");
	var saveMapObjParent = getValue("save_map_obj.parent");
	// assign object to chosen environment
	if(saveMapObjActive) {
		echo(".GlobalEnv$" + saveMapObj + " <- map_sf\n");
	}

}

