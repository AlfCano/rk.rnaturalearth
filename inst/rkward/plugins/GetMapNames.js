// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(sf)\n");	echo("require(dplyr)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    var map_obj = getValue("inp_map_obj");
    echo("names_df <- " + map_obj + " %>% sf::st_drop_geometry() %>% dplyr::select(any_of(c(\"name\", \"iso_3166_2\", \"postal\", \"type\", \"gn_name\")))\n");
    echo("map_names_ref <- names_df\n");
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Get Map Names results")).print();
echo("rk.header(\"Map Region Names Extracted\")\n");
	//// save result object
	// read in saveobject variables
	var saveNamesObj = getValue("save_names_obj");
	var saveNamesObjActive = getValue("save_names_obj.active");
	var saveNamesObjParent = getValue("save_names_obj.parent");
	// assign object to chosen environment
	if(saveNamesObjActive) {
		echo(".GlobalEnv$" + saveNamesObj + " <- map_names_ref\n");
	}

}

