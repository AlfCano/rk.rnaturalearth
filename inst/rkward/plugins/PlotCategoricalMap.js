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
		echo("if(!base::require(ggspatial)){stop(" + i18n("Preview not available, because package ggspatial is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(ggspatial)\n");
	}	if(is_preview) {
		echo("if(!base::require(RColorBrewer)){stop(" + i18n("Preview not available, because package RColorBrewer is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(RColorBrewer)\n");
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
  
    var map_obj = getValue("inp_map_obj");
    var df = getValue("inp_data"); var region_col = getCol("inp_region_col"); var val_col = getCol("inp_value_col");
    var pal = getValue("drp_cat_palette"); var man_cols = getValue("inp_manual_colors");
    var border_col = getValue("drp_border_col");
    var tit = getValue("map_title"); var cap = getValue("map_caption");
    var leg_title = getValue("leg_title"); var leg_pos = getValue("leg_pos");
    
    var grid_mode = getValue("drp_grid_mode");
    var show_lbl = getValue("chk_labels"); var lbl_size = getValue("lbl_size"); var lbl_ovr = (getValue("chk_overlap") == "1") ? "TRUE" : "FALSE";
    var show_north = getValue("chk_north"); var north_pos = getValue("north_pos"); var north_sty = getValue("north_style");
    var show_scale = getValue("chk_scale"); var scale_pos = getValue("scale_pos");

    if (leg_title == "") { leg_title = val_col; }

    echo("user_data <- " + df + "\n");
    echo("plot_data <- " + map_obj + " %>% dplyr::left_join(user_data, by = c(\"name\" = \"" + region_col + "\"))\n");
    // Ensure categorical is factor
    echo("plot_data[[\"" + val_col + "\"]] <- as.factor(plot_data[[\"" + val_col + "\"]])\n");

    echo("p <- ggplot2::ggplot(plot_data) +\n");
    echo("  ggplot2::geom_sf(ggplot2::aes(fill = .data[[\"" + val_col + "\"]]), color = \"" + border_col + "\", size = 0.2) +\n");
    
    if (pal == "manual") {
        echo("  ggplot2::scale_fill_manual(values = c(" + man_cols + "), na.value = \"gray90\", name = \"" + leg_title + "\")\n");
    } else {
        echo("  ggplot2::scale_fill_brewer(palette = \"" + pal + "\", na.value = \"gray90\", name = \"" + leg_title + "\")\n");
    }
    
    // Grid Logic
    if (grid_mode == "void") {
        echo("p <- p + ggplot2::theme_void()\n");
    } else if (grid_mode == "graticule") {
        echo("p <- p + ggplot2::theme_light() + ggplot2::coord_sf(datum = sf::st_crs(4326))\n");
    } else {
        // Dotted, No Labels
        echo("p <- p + ggplot2::theme_void() + ggplot2::coord_sf(datum = sf::st_crs(4326)) + ggplot2::theme(panel.grid.major = ggplot2::element_line(color = \"gray80\", linetype = \"dotted\"))\n");
    }
    
    echo("p <- p + ggplot2::theme(legend.position = \"" + leg_pos + "\")\n");
    
    if (show_lbl == "1") { echo("p <- p + ggplot2::geom_sf_text(ggplot2::aes(label = name), size = " + lbl_size + ", check_overlap = !" + lbl_ovr + ")\n"); }
    
    if (show_north == "1") {
        var style_code = "ggspatial::north_arrow_fancy_orienteering()";
        if (north_sty == "minimal") style_code = "ggspatial::north_arrow_minimal()";
        if (north_sty == "default") style_code = "ggspatial::north_arrow_orienteering()";
        echo("p <- p + ggspatial::annotation_north_arrow(location = \"" + north_pos + "\", which_north = \"true\", style = " + style_code + ")\n");
    }
    
    if (show_scale == "1") { echo("p <- p + ggspatial::annotation_scale(location = \"" + scale_pos + "\", width_hint = 0.5)\n"); }
    if (tit) echo("p <- p + ggplot2::labs(title = \"" + tit + "\")\n");
    if (cap) echo("p <- p + ggplot2::labs(caption = \"" + cap + "\")\n");
  
}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("Plot Categorical Map results")).print();	
	}
    if (is_preview) { echo("print(p)\n"); } else {
        var dev_type = getValue("device_type"); var w = getValue("dev_width"); var h = getValue("dev_height"); var res = getValue("dev_res"); var bg = getValue("dev_bg");
        echo("rk.graph.on(device.type=\"" + dev_type + "\", width=" + w + ", height=" + h + ", res=" + res + ", bg=\"" + bg + "\")\n");
        echo("print(p)\n"); echo("rk.graph.off()\n");
    }
  
	if(!is_preview) {
		//// save result object
		// read in saveobject variables
		var savePlotObj = getValue("save_plot_obj");
		var savePlotObjActive = getValue("save_plot_obj.active");
		var savePlotObjParent = getValue("save_plot_obj.parent");
		// assign object to chosen environment
		if(savePlotObjActive) {
			echo(".GlobalEnv$" + savePlotObj + " <- p\n");
		}	
	}

}

