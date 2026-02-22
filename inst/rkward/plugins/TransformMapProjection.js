// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(sf)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    var map_obj = getValue("inp_map_obj"); var crs = getValue("drp_crs"); var custom = getValue("inp_custom_crs");
    if (custom && custom !== "") { crs = custom; }
    var crs_val = (isNaN(crs)) ? "\"" + crs + "\"" : crs;
    echo("map_projected <- sf::st_transform(" + map_obj + ", crs = " + crs_val + ")\n");
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Transform Map Projection results")).print();
echo("rk.header(\"Map Transformation Successful\")\n");
	//// save result object
	// read in saveobject variables
	var saveTransMap = getValue("save_trans_map");
	var saveTransMapActive = getValue("save_trans_map.active");
	var saveTransMapParent = getValue("save_trans_map.parent");
	// assign object to chosen environment
	if(saveTransMapActive) {
		echo(".GlobalEnv$" + saveTransMap + " <- map_projected\n");
	}

}

