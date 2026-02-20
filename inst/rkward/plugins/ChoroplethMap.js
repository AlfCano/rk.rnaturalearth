// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!

function preview(){
	preprocess(true);
	calculate(true);
	printout(true);
}

function preprocess(is_preview){
	// add requirements etc. here
	if(is_preview) {
		echo("if(!base::require(rnaturalearth)){stop(" + i18n("Preview not available, because package rnaturalearth is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(rnaturalearth)\n");
	}	if(is_preview) {
		echo("if(!base::require(sf)){stop(" + i18n("Preview not available, because package sf is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(sf)\n");
	}	if(is_preview) {
		echo("if(!base::require(ggplot2)){stop(" + i18n("Preview not available, because package ggplot2 is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(ggplot2)\n");
	}	if(is_preview) {
		echo("if(!base::require(dplyr)){stop(" + i18n("Preview not available, because package dplyr is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(dplyr)\n");
	}	if(is_preview) {
		echo("if(!base::require(viridis)){stop(" + i18n("Preview not available, because package viridis is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(viridis)\n");
	}	if(is_preview) {
		echo("if(!base::require(ggspatial)){stop(" + i18n("Preview not available, because package ggspatial is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(ggspatial)\n");
	}
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
  
    var df = getValue("inp_data"); var region_col = getCol("inp_region_col"); var val_col = getCol("inp_value_col");
    var country = getValue("drp_country"); var custom = getValue("inp_custom_country");
    if (custom && custom !== "") { country = custom; }
    var pal = getValue("drp_palette"); var tit = getValue("map_title"); var cap = getValue("map_caption");
    
    // Element values
    var show_lbl = getValue("chk_labels");
    var lbl_size = getValue("lbl_size");
    var lbl_ovr = (getValue("chk_overlap") == "1") ? "TRUE" : "FALSE";
    
    var show_north = getValue("chk_north");
    var north_pos = getValue("north_pos");
    var north_sty = getValue("north_style");
    
    var show_scale = getValue("chk_scale");
    var scale_pos = getValue("scale_pos");

    echo("user_data <- " + df + "\n");
    echo("map_sf <- rnaturalearth::ne_states(country = \"" + country + "\", returnclass = \"sf\")\n");
    echo("if(nrow(map_sf) == 0) stop(\"Could not find map data for country: " + country + ". Check spelling (must be in English).\")\n");
    echo("plot_data <- map_sf %>% dplyr::left_join(user_data, by = c(\"name\" = \"" + region_col + "\"))\n");

    echo("p <- ggplot2::ggplot(plot_data) +\n");
    echo("  ggplot2::geom_sf(ggplot2::aes(fill = .data[[\"" + val_col + "\"]]), color = \"white\", size = 0.2) +\n");
    echo("  ggplot2::scale_fill_viridis_c(option = \"" + pal + "\", na.value = \"gray90\", name = \"" + val_col + "\") +\n");
    echo("  ggplot2::theme_void() + ggplot2::theme(legend.position = \"right\")\n");
    
    // Add Labels
    if (show_lbl == "1") {
        echo("p <- p + ggplot2::geom_sf_text(ggplot2::aes(label = name), size = " + lbl_size + ", check_overlap = !" + lbl_ovr + ")\n");
    }
    
    // Add North Arrow - FIXED FUNCTION NAMES
    if (show_north == "1") {
        var style_code = "ggspatial::north_arrow_fancy_orienteering()";
        if (north_sty == "minimal") style_code = "ggspatial::north_arrow_minimal()";
        if (north_sty == "default") style_code = "ggspatial::north_arrow_orienteering()";
        
        echo("p <- p + ggspatial::annotation_north_arrow(location = \"" + north_pos + "\", which_north = \"true\", style = " + style_code + ")\n");
    }
    
    // Add Scale Bar
    if (show_scale == "1") {
        echo("p <- p + ggspatial::annotation_scale(location = \"" + scale_pos + "\", width_hint = 0.5)\n");
    }

    if (tit) echo("p <- p + ggplot2::labs(title = \"" + tit + "\")\n");
    if (cap) echo("p <- p + ggplot2::labs(caption = \"" + cap + "\")\n");
  
}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("Choropleth Map results")).print();	
	}
    if (is_preview) { echo("print(p)\n"); } else {
        echo("rk.graph.on()\n"); echo("print(p)\n"); echo("rk.graph.off()\n");
        echo("my_choropleth <- p\n");
    }
  
	if(!is_preview) {
		//// save result object
		// read in saveobject variables
		var saveMapObj = getValue("save_map_obj");
		var saveMapObjActive = getValue("save_map_obj.active");
		var saveMapObjParent = getValue("save_map_obj.parent");
		// assign object to chosen environment
		if(saveMapObjActive) {
			echo(".GlobalEnv$" + saveMapObj + " <- my_choropleth\n");
		}	
	}

}

