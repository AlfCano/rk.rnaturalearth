// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(sf)\n");	echo("require(dplyr)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    function getCol(id) {
        var raw = getValue(id);
        if (!raw) return "NULL";
        if (raw.indexOf("[[") > -1) {
            var match = raw.match(/\[\[\"(.*?)\"\]\]/);
            return match ? match[1] : raw;
        }
        return raw.split("$").pop();
    }
  
    var map_obj = getValue("inp_map_obj"); var dict_df = getValue("inp_dict_df"); var col_old = getCol("inp_col_old"); var col_new = getCol("inp_col_new");
    echo("modified_map <- " + map_obj + "\n"); echo("dictionary <- " + dict_df + "\n");
    echo("if(\"name\" %in% names(modified_map)) { target_col <- \"name\" } else if(\"NAME_1\" %in% names(modified_map)) { target_col <- \"NAME_1\" } else { target_col <- \"NAME_2\" }\n");
    echo("indices <- match(modified_map[[target_col]], dictionary[[\"" + col_old + "\"]])\n");
    echo("valid_matches <- !is.na(indices)\n");
    echo("modified_map[[target_col]][valid_matches] <- as.character(dictionary[[\"" + col_new + "\"]][indices[valid_matches]])\n");
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Recode Map Regions results")).print();
echo("rk.header(\"Map Object Recoded\")\n");
	//// save result object
	// read in saveobject variables
	var saveModMap = getValue("save_mod_map");
	var saveModMapActive = getValue("save_mod_map.active");
	var saveModMapParent = getValue("save_mod_map.parent");
	// assign object to chosen environment
	if(saveModMapActive) {
		echo(".GlobalEnv$" + saveModMap + " <- modified_map\n");
	}

}

