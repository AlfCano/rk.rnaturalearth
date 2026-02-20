// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(rnaturalearth)\n");	echo("require(sf)\n");	echo("require(dplyr)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    var country = getValue("drp_country_ext");
    var custom = getValue("inp_custom_ext");
    if (custom && custom !== "") { country = custom; }
    
    echo("map_sf <- rnaturalearth::ne_states(country = \"" + country + "\", returnclass = \"sf\")\n");
    echo("if(nrow(map_sf) == 0) stop(\"Could not find map data for country: " + country + ".\")\n");
    echo("names_df <- map_sf %>% sf::st_drop_geometry() %>% dplyr::select(any_of(c(\"name\", \"iso_3166_2\", \"postal\", \"type\", \"gn_name\")))\n");
    
    echo("map_names_ref <- names_df\n");
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Get Map Names results")).print();

    echo("rk.header(\"Map Region Names Extracted\")\n");
    echo("rk.print(\"Object saved as: " + getValue("save_names_obj") + "\")\n");
    echo("rk.print(head(map_names_ref, 20))\n");
  
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

