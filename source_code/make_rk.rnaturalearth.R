local({
  # =========================================================================================
  # 1. Package Definition and Metadata
  # =========================================================================================
  require(rkwarddev)
  rkwarddev.required("0.08-1")

  plugin_name <- "rk.rnaturalearth"
  plugin_ver <- "0.1.4" # FROZEN VERSION (UI Layout adjustments)

  package_about <- rk.XML.about(
    name = plugin_name,
    author = person(
      given = "Alfonso",
      family = "Cano",
      email = "alfonso.cano@correo.buap.mx",
      role = c("aut", "cre")
    ),
    about = list(
      desc = "An RKWard wrapper for 'rnaturalearth'. Features a modular workflow: Download -> Process -> Plot (Continuous & Categorical).",
      version = plugin_ver,
      date = format(Sys.Date(), "%Y-%m-%d"),
      url = "https://github.com/AlfCano/rk.rnaturalearth",
      license = "GPL (>= 3)"
    )
  )

  # =========================================================================================
  # 2. Shared Helpers
  # =========================================================================================
  js_helpers <- '
    function getCol(id) {
        var raw = getValue(id);
        if (!raw) return "NULL";
        if (raw.indexOf("[[") > -1) {
            var match = raw.match(/\\[\\[\\"(.*?)\\"\\]\\]/);
            return match ? match[1] : raw;
        }
        return raw.split("$").pop();
    }
  '

  country_options <- list(
      "Mexico" = list(val = "Mexico", chk = TRUE),
      "United States" = list(val = "United States of America"),
      "Canada" = list(val = "Canada"),
      "Brazil" = list(val = "Brazil"),
      "Argentina" = list(val = "Argentina"),
      "Colombia" = list(val = "Colombia"),
      "Chile" = list(val = "Chile"),
      "Peru" = list(val = "Peru"),
      "Spain" = list(val = "Spain"),
      "France" = list(val = "France"),
      "Germany" = list(val = "Germany"),
      "Italy" = list(val = "Italy"),
      "United Kingdom" = list(val = "United Kingdom")
  )

  # =========================================================================================
  # 3. MAIN PLUGIN: DOWNLOADER
  # =========================================================================================

  down_country <- rk.XML.dropdown(label = "Select Country", id.name = "down_country", options = country_options)
  down_custom <- rk.XML.input(label = "Or type Country name", id.name = "down_custom", required = FALSE)
  down_save <- rk.XML.saveobj(label = "Save Map Object As", initial = "map_sf", id.name = "save_map_obj", chk = TRUE)

  dialog_downloader <- rk.XML.dialog(label = "Download Map Object", child = rk.XML.col(
      rk.XML.text("Downloads administrative boundaries (states/provinces) from Natural Earth and saves them as an 'sf' object."),
      down_country, down_custom, rk.XML.stretch(), down_save
  ))

  js_calc_down <- '
    var country = getValue("down_country");
    var custom = getValue("down_custom");
    if (custom && custom !== "") { country = custom; }
    echo("map_sf <- rnaturalearth::ne_states(country = \\"" + country + "\\", returnclass = \\"sf\\")\\n");
    echo("if(nrow(map_sf) == 0) stop(\\"Could not find map data for country: " + country + ". Check spelling.\\")\\n");
  '
  js_print_down <- 'echo("rk.header(\\"Map Download Successful\\")\\n");'

  # =========================================================================================
  # SHARED PLOT UI ELEMENTS
  # =========================================================================================

  # --- Appearance Tab Elements ---
  drp_palette <- rk.XML.dropdown(label = "Color Palette", id.name = "drp_palette", options = list("Viridis (Default)"=list(val="D",chk=TRUE),"Magma"=list(val="A"),"Inferno"=list(val="B"),"Plasma"=list(val="C"),"Cividis"=list(val="E")))

  drp_border_col <- rk.XML.dropdown(label = "Polygon Border Color", id.name = "drp_border_col", options = list(
      "White"=list(val="white", chk=TRUE), "Black"=list(val="black"),
      "Dark Gray"=list(val="gray40"), "Light Gray"=list(val="gray80"), "None"=list(val="NA")
  ))

  inp_title <- rk.XML.input(label = "Map Title", id.name = "map_title")
  inp_caption <- rk.XML.input(label = "Caption", id.name = "map_caption")

  inp_leg_title <- rk.XML.input(label = "Legend Title (Leave empty for variable name)", id.name = "leg_title")
  drp_leg_pos <- rk.XML.dropdown(label = "Legend Position", id.name = "leg_pos", options = list(
      "Right"=list(val="right", chk=TRUE), "Left"=list(val="left"), "Top"=list(val="top"), "Bottom"=list(val="bottom"), "None"=list(val="none")
  ))
  frame_legend <- rk.XML.frame(label = "Legend Settings", inp_leg_title, drp_leg_pos)

  # --- Map Elements Tab Elements ---

  # LABELS & GGREPEL (Refactored Layout)
  chk_labels <- rk.XML.cbox(label = "Show Region Labels", value = "1", id.name = "chk_labels")
  chk_lbl_overlap <- rk.XML.cbox(label = "Allow Overlap (Standard only)", value = "1", chk = FALSE, id.name = "chk_overlap")
  chk_use_repel <- rk.XML.cbox(label = "Use ggrepel (Smart Positioning)", value = "1", chk = FALSE, id.name = "chk_repel")

  inp_lbl_size <- rk.XML.spinbox(label = "Label Size", min = 1, max = 10, initial = 3, id.name = "lbl_size")
  inp_max_ov <- rk.XML.spinbox(label = "Max Overlaps (ggrepel)", min = 0, max = 9999, initial = 15, id.name = "max_overlaps")

  # Layout: Two columns to save vertical space and reduce width
  frame_labels <- rk.XML.frame(label="Text Labels",
      rk.XML.row(
          rk.XML.col(chk_labels, chk_lbl_overlap, chk_use_repel),
          rk.XML.col(inp_lbl_size, inp_max_ov)
      )
  )

  drp_grid_mode <- rk.XML.dropdown(label = "Map Style / Grid", id.name = "drp_grid_mode", options = list(
      "Clean (Void)" = list(val = "void", chk = TRUE),
      "Lat/Lon Graticules (Degrees)" = list(val = "graticule"),
      "Lat/Lon Graticules (Dotted, No Labels)" = list(val = "graticule_clean")
  ))

  # NORTH ARROW (Refactored Layout)
  chk_north <- rk.XML.cbox(label = "North Arrow", value = "1", id.name = "chk_north")
  drp_north_pos <- rk.XML.dropdown(label = "Position", id.name = "north_pos", options = list("Top Right"=list(val="tr",chk=TRUE), "Top Left"=list(val="tl"), "Bottom Right"=list(val="br"), "Bottom Left"=list(val="bl")))
  drp_north_style <- rk.XML.dropdown(label = "Style", id.name = "north_style", options = list("Default"=list(val="default"), "Fancy"=list(val="fancy",chk=TRUE), "Minimal"=list(val="minimal")))

  # Layout: Checkbox on top, dropdowns below
  frame_north <- rk.XML.frame(label="North Arrow",
      rk.XML.col(
          chk_north,
          rk.XML.row(drp_north_pos, drp_north_style)
      )
  )

  # SCALE BAR
  chk_scale <- rk.XML.cbox(label = "Scale Bar", value = "1", id.name = "chk_scale")
  drp_scale_pos <- rk.XML.dropdown(label = "Position", id.name = "scale_pos", options = list("Bottom Left"=list(val="bl",chk=TRUE), "Bottom Right"=list(val="br"), "Top Left"=list(val="tl"), "Top Right"=list(val="tr")))

  # Layout: Checkbox on top (Consistent with North Arrow)
  frame_scale <- rk.XML.frame(label="Scale Bar",
      rk.XML.col(
          chk_scale,
          drp_scale_pos
      )
  )

  save_plot <- rk.XML.saveobj(label = "Save Plot Object", initial = "p", id.name = "save_plot_obj", chk = TRUE)
  preview_map <- rk.XML.preview(mode = "plot")
  export_frame <- rk.XML.frame(label = "Graphics Export Settings",
      rk.XML.dropdown(label = "Device type", id.name = "device_type", options = list("PNG" = list(val = "PNG", chk = TRUE), "SVG" = list(val = "SVG"))),
      rk.XML.row(rk.XML.spinbox(label = "Width (px)", id.name = "dev_width", min = 100, max = 4000, initial = 1200), rk.XML.spinbox(label = "Height (px)", id.name = "dev_height", min = 100, max = 4000, initial = 1000)),
      rk.XML.col(rk.XML.spinbox(label = "Resolution (ppi)", id.name = "dev_res", min = 50, max = 600, initial = 150), rk.XML.dropdown(label = "Background", id.name = "dev_bg", options = list("Transparent" = list(val = "transparent", chk = TRUE), "White" = list(val = "white"))))
  )
  output_tab_content <- rk.XML.col(export_frame, save_plot, preview_map)

  # =========================================================================================
  # 4. COMPONENT: PLOT CONTINUOUS MAP
  # =========================================================================================

  var_sel_cont <- rk.XML.varselector(id.name = "v_sel_cont")
  inp_map_cont <- rk.XML.varslot(label = "Map Object (sf)", source = "v_sel_cont", required = TRUE, id.name = "inp_map_obj", classes = "sf")
  inp_map_id_cont <- rk.XML.varslot(label = "Map Id Column (e.g. name, NAME_1)", source = "v_sel_cont", required = TRUE, id.name = "inp_map_id")
  inp_data_cont <- rk.XML.varslot(label = "Data Frame", source = "v_sel_cont", classes = "data.frame", required = TRUE, id.name = "inp_data")
  inp_reg_cont <- rk.XML.varslot(label = "Region Name Column (Data)", source = "v_sel_cont", required = TRUE, id.name = "inp_region_col")
  inp_val_cont <- rk.XML.varslot(label = "Value Column (Numeric)", source = "v_sel_cont", required = TRUE, id.name = "inp_value_col")
  drp_pal_cont <- rk.XML.dropdown(label = "Continuous Palette", id.name = "drp_palette", options = list("Viridis (Default)"=list(val="D",chk=TRUE),"Magma"=list(val="A"),"Inferno"=list(val="B"),"Plasma"=list(val="C"),"Cividis"=list(val="E")))

  dialog_plotter_cont <- rk.XML.dialog(label = "Plot Continuous Map", child = rk.XML.row(var_sel_cont, rk.XML.col(rk.XML.tabbook(tabs = list(
            "Data Input" = rk.XML.col(inp_map_cont, inp_map_id_cont, rk.XML.stretch(), inp_data_cont, inp_reg_cont, inp_val_cont),
            "Appearance" = rk.XML.col(drp_pal_cont, drp_border_col, frame_legend, inp_title, inp_caption),
            "Map Elements" = rk.XML.col(drp_grid_mode, frame_labels, frame_north, frame_scale),
            "Output & Export" = output_tab_content)))))

  js_calc_plotter_cont <- paste0(js_helpers, '
    var map_obj = getValue("inp_map_obj");
    var map_id = getCol("inp_map_id");
    var df = getValue("inp_data"); var region_col = getCol("inp_region_col"); var val_col = getCol("inp_value_col");
    var pal = getValue("drp_palette"); var border_col = getValue("drp_border_col");
    var tit = getValue("map_title"); var cap = getValue("map_caption");
    var leg_title = getValue("leg_title"); var leg_pos = getValue("leg_pos");

    var grid_mode = getValue("drp_grid_mode");
    var show_lbl = getValue("chk_labels"); var lbl_size = getValue("lbl_size"); var lbl_ovr = (getValue("chk_overlap") == "1") ? "TRUE" : "FALSE";
    var use_repel = getValue("chk_repel"); var max_ov = getValue("max_overlaps");

    var show_north = getValue("chk_north"); var north_pos = getValue("north_pos"); var north_sty = getValue("north_style");
    var show_scale = getValue("chk_scale"); var scale_pos = getValue("scale_pos");

    if (leg_title == "") { leg_title = val_col; }

    echo("user_data <- " + df + "\\n");
    echo("plot_data <- " + map_obj + " %>% dplyr::left_join(user_data, by = c(\\"" + map_id + "\\" = \\"" + region_col + "\\"))\\n");

    echo("p <- ggplot2::ggplot(plot_data) +\\n");
    echo("  ggplot2::geom_sf(ggplot2::aes(fill = .data[[\\"" + val_col + "\\"]]), color = \\"" + border_col + "\\", size = 0.2) +\\n");
    echo("  ggplot2::scale_fill_viridis_c(option = \\"" + pal + "\\", na.value = \\"gray90\\", name = \\"" + leg_title + "\\")\\n");

    if (grid_mode == "void") {
        echo("p <- p + ggplot2::theme_void()\\n");
    } else if (grid_mode == "graticule") {
        echo("p <- p + ggplot2::theme_light() + ggplot2::coord_sf(datum = sf::st_crs(4326))\\n");
    } else {
        echo("p <- p + ggplot2::theme_void() + ggplot2::coord_sf(datum = sf::st_crs(4326)) + ggplot2::theme(panel.grid.major = ggplot2::element_line(color = \\"gray80\\", linetype = \\"dotted\\"))\\n");
    }

    echo("p <- p + ggplot2::theme(legend.position = \\"" + leg_pos + "\\")\\n");

    if (show_lbl == "1") {
        if (use_repel == "1") {
             echo("p <- p + ggrepel::geom_text_repel(ggplot2::aes(label = .data[[\\"" + map_id + "\\"]], geometry = geometry), stat = \\"sf_coordinates\\", size = " + lbl_size + ", min.segment.length = 0, box.padding = 0.5, max.overlaps = " + max_ov + ")\\n");
        } else {
             echo("p <- p + ggplot2::geom_sf_text(ggplot2::aes(label = .data[[\\"" + map_id + "\\"]]), size = " + lbl_size + ", check_overlap = !" + lbl_ovr + ")\\n");
        }
    }

    if (show_north == "1") {
        var style_code = "ggspatial::north_arrow_fancy_orienteering()";
        if (north_sty == "minimal") style_code = "ggspatial::north_arrow_minimal()";
        if (north_sty == "default") style_code = "ggspatial::north_arrow_orienteering()";
        echo("p <- p + ggspatial::annotation_north_arrow(location = \\"" + north_pos + "\\", which_north = \\"true\\", style = " + style_code + ")\\n");
    }

    if (show_scale == "1") { echo("p <- p + ggspatial::annotation_scale(location = \\"" + scale_pos + "\\", width_hint = 0.5)\\n"); }
    if (tit) echo("p <- p + ggplot2::labs(title = \\"" + tit + "\\")\\n");
    if (cap) echo("p <- p + ggplot2::labs(caption = \\"" + cap + "\\")\\n");
  ')

  js_print_plotter <- '
    if (is_preview) { echo("print(p)\\n"); } else {
        var dev_type = getValue("device_type"); var w = getValue("dev_width"); var h = getValue("dev_height"); var res = getValue("dev_res"); var bg = getValue("dev_bg");
        echo("rk.graph.on(device.type=\\"" + dev_type + "\\", width=" + w + ", height=" + h + ", res=" + res + ", bg=\\"" + bg + "\\")\\n");
        echo("print(p)\\n"); echo("rk.graph.off()\\n");
    }
  '

  comp_plotter_cont <- rk.plugin.component("Plot Continuous Map", xml = list(dialog = dialog_plotter_cont), js = list(require=c("sf", "ggplot2", "dplyr", "viridis", "ggspatial", "ggrepel"), calculate=js_calc_plotter_cont, printout=js_print_plotter), hierarchy = list("plots", "Maps"))

  # =========================================================================================
  # 5. COMPONENT: PLOT CATEGORICAL MAP
  # =========================================================================================

  var_sel_cat <- rk.XML.varselector(id.name = "v_sel_cat")
  inp_map_cat <- rk.XML.varslot(label = "Map Object (sf)", source = "v_sel_cat", required = TRUE, id.name = "inp_map_obj", classes = "sf")
  inp_map_id_cat <- rk.XML.varslot(label = "Map Id Column (e.g. name, NAME_1)", source = "v_sel_cat", required = TRUE, id.name = "inp_map_id")
  inp_data_cat <- rk.XML.varslot(label = "Data Frame", source = "v_sel_cat", classes = "data.frame", required = TRUE, id.name = "inp_data")
  inp_reg_cat <- rk.XML.varslot(label = "Region Name Column (Data)", source = "v_sel_cat", required = TRUE, id.name = "inp_region_col")
  inp_val_cat <- rk.XML.varslot(label = "Grouping Variable (Categorical)", source = "v_sel_cat", required = TRUE, id.name = "inp_value_col")

  drp_pal_cat <- rk.XML.dropdown(label = "Categorical Palette", id.name = "drp_cat_palette", options = list(
      "Manual Colors" = list(val = "manual"),
      "Brewer: Set1" = list(val = "Set1"), "Brewer: Set2" = list(val = "Set2"), "Brewer: Set3" = list(val = "Set3", chk=TRUE),
      "Brewer: Pastel1" = list(val = "Pastel1"), "Brewer: Pastel2" = list(val = "Pastel2"),
      "Brewer: Dark2" = list(val = "Dark2"), "Brewer: Paired" = list(val = "Paired"), "Brewer: Accent" = list(val = "Accent")
  ))
  inp_manual_cols <- rk.XML.input(label = "Manual Colors (comma separated, e.g. 'red', '#00FF00')", id.name = "inp_manual_colors", required = FALSE)

  dialog_plotter_cat <- rk.XML.dialog(label = "Plot Categorical Map", child = rk.XML.row(var_sel_cat, rk.XML.col(rk.XML.tabbook(tabs = list(
            "Data Input" = rk.XML.col(inp_map_cat, inp_map_id_cat, rk.XML.stretch(), inp_data_cat, inp_reg_cat, inp_val_cat),
            "Appearance" = rk.XML.col(drp_pal_cat, inp_manual_cols, drp_border_col, frame_legend, inp_title, inp_caption),
            "Map Elements" = rk.XML.col(drp_grid_mode, frame_labels, frame_north, frame_scale),
            "Output & Export" = output_tab_content)))))

  js_calc_plotter_cat <- paste0(js_helpers, '
    var map_obj = getValue("inp_map_obj");
    var map_id = getCol("inp_map_id");
    var df = getValue("inp_data"); var region_col = getCol("inp_region_col"); var val_col = getCol("inp_value_col");
    var pal = getValue("drp_cat_palette"); var man_cols = getValue("inp_manual_colors");
    var border_col = getValue("drp_border_col");
    var tit = getValue("map_title"); var cap = getValue("map_caption");
    var leg_title = getValue("leg_title"); var leg_pos = getValue("leg_pos");

    var grid_mode = getValue("drp_grid_mode");
    var show_lbl = getValue("chk_labels"); var lbl_size = getValue("lbl_size"); var lbl_ovr = (getValue("chk_overlap") == "1") ? "TRUE" : "FALSE";
    var use_repel = getValue("chk_repel"); var max_ov = getValue("max_overlaps");

    var show_north = getValue("chk_north"); var north_pos = getValue("north_pos"); var north_sty = getValue("north_style");
    var show_scale = getValue("chk_scale"); var scale_pos = getValue("scale_pos");

    if (leg_title == "") { leg_title = val_col; }

    echo("user_data <- " + df + "\\n");
    echo("plot_data <- " + map_obj + " %>% dplyr::left_join(user_data, by = c(\\"" + map_id + "\\" = \\"" + region_col + "\\"))\\n");
    echo("plot_data[[\\"" + val_col + "\\"]] <- as.factor(plot_data[[\\"" + val_col + "\\"]])\\n");

    echo("p <- ggplot2::ggplot(plot_data) +\\n");
    echo("  ggplot2::geom_sf(ggplot2::aes(fill = .data[[\\"" + val_col + "\\"]]), color = \\"" + border_col + "\\", size = 0.2) +\\n");

    if (pal == "manual") {
        echo("  ggplot2::scale_fill_manual(values = c(" + man_cols + "), na.value = \\"gray90\\", name = \\"" + leg_title + "\\")\\n");
    } else {
        echo("  ggplot2::scale_fill_brewer(palette = \\"" + pal + "\\", na.value = \\"gray90\\", name = \\"" + leg_title + "\\")\\n");
    }

    if (grid_mode == "void") {
        echo("p <- p + ggplot2::theme_void()\\n");
    } else if (grid_mode == "graticule") {
        echo("p <- p + ggplot2::theme_light() + ggplot2::coord_sf(datum = sf::st_crs(4326))\\n");
    } else {
        echo("p <- p + ggplot2::theme_void() + ggplot2::coord_sf(datum = sf::st_crs(4326)) + ggplot2::theme(panel.grid.major = ggplot2::element_line(color = \\"gray80\\", linetype = \\"dotted\\"))\\n");
    }

    echo("p <- p + ggplot2::theme(legend.position = \\"" + leg_pos + "\\")\\n");

    if (show_lbl == "1") {
        if (use_repel == "1") {
             echo("p <- p + ggrepel::geom_text_repel(ggplot2::aes(label = .data[[\\"" + map_id + "\\"]], geometry = geometry), stat = \\"sf_coordinates\\", size = " + lbl_size + ", min.segment.length = 0, box.padding = 0.5, max.overlaps = " + max_ov + ")\\n");
        } else {
             echo("p <- p + ggplot2::geom_sf_text(ggplot2::aes(label = .data[[\\"" + map_id + "\\"]]), size = " + lbl_size + ", check_overlap = !" + lbl_ovr + ")\\n");
        }
    }

    if (show_north == "1") {
        var style_code = "ggspatial::north_arrow_fancy_orienteering()";
        if (north_sty == "minimal") style_code = "ggspatial::north_arrow_minimal()";
        if (north_sty == "default") style_code = "ggspatial::north_arrow_orienteering()";
        echo("p <- p + ggspatial::annotation_north_arrow(location = \\"" + north_pos + "\\", which_north = \\"true\\", style = " + style_code + ")\\n");
    }

    if (show_scale == "1") { echo("p <- p + ggspatial::annotation_scale(location = \\"" + scale_pos + "\\", width_hint = 0.5)\\n"); }
    if (tit) echo("p <- p + ggplot2::labs(title = \\"" + tit + "\\")\\n");
    if (cap) echo("p <- p + ggplot2::labs(caption = \\"" + cap + "\\")\\n");
  ')

  comp_plotter_cat <- rk.plugin.component("Plot Categorical Map", xml = list(dialog = dialog_plotter_cat), js = list(require=c("sf", "ggplot2", "dplyr", "ggspatial", "RColorBrewer", "ggrepel"), calculate=js_calc_plotter_cat, printout=js_print_plotter), hierarchy = list("plots", "Maps"))

  # =========================================================================================
  # 6. COMPONENT: Get Map Region Names
  # =========================================================================================
  var_sel_names <- rk.XML.varselector(id.name = "v_sel_names")
  inp_map_obj_names <- rk.XML.varslot(label = "Map Object (sf)", source = "v_sel_names", required = TRUE, id.name = "inp_map_obj", classes = "sf")
  save_names <- rk.XML.saveobj(label = "Save Names As", initial = "map_names_ref", id.name = "save_names_obj", chk = TRUE)
  dialog_names <- rk.XML.dialog(label = "Get Map Region Names", child = rk.XML.row(var_sel_names, rk.XML.col(rk.XML.text("Extracts official names."), inp_map_obj_names, rk.XML.stretch(), save_names)))
  js_calc_names <- '
    var map_obj = getValue("inp_map_obj");
    echo("names_df <- " + map_obj + " %>% sf::st_drop_geometry() %>% dplyr::select(any_of(c(\\"name\\", \\"iso_3166_2\\", \\"postal\\", \\"type\\", \\"gn_name\\")))\\n");
    echo("map_names_ref <- names_df\\n");
  '
  js_print_names <- 'echo("rk.header(\\"Map Region Names Extracted\\")\\n");'
  comp_names <- rk.plugin.component("Get Map Names", xml = list(dialog = dialog_names), js = list(require=c("sf", "dplyr"), calculate=js_calc_names, printout=js_print_names), hierarchy = list("plots", "Maps"))

  # =========================================================================================
  # 7. COMPONENT: Recode Map Regions
  # =========================================================================================
  var_sel_rec <- rk.XML.varselector(id.name = "v_sel_rec")
  inp_map_obj_rec <- rk.XML.varslot(label = "Map Object (sf)", source = "v_sel_rec", required = TRUE, id.name = "inp_map_obj", classes = "sf")
  inp_dict_df <- rk.XML.varslot(label = "Dictionary Data Frame", source = "v_sel_rec", classes = "data.frame", required = TRUE, id.name = "inp_dict_df")
  inp_col_old <- rk.XML.varslot(label = "Old Name Column", source = "v_sel_rec", required = TRUE, id.name = "inp_col_old")
  inp_col_new <- rk.XML.varslot(label = "New Name Column", source = "v_sel_rec", required = TRUE, id.name = "inp_col_new")
  save_mod_map <- rk.XML.saveobj(label = "Save Modified Map As", initial = "modified_map", id.name = "save_mod_map", chk = TRUE)
  dialog_recode <- rk.XML.dialog(label = "Recode Map Regions", child = rk.XML.row(var_sel_rec, rk.XML.col(rk.XML.text("Update map names."), rk.XML.frame(label="Inputs", inp_map_obj_rec, inp_dict_df), rk.XML.frame(label="Correspondence", inp_col_old, inp_col_new), rk.XML.stretch(), save_mod_map)))
  js_calc_recode <- paste0(js_helpers, '
    var map_obj = getValue("inp_map_obj"); var dict_df = getValue("inp_dict_df"); var col_old = getCol("inp_col_old"); var col_new = getCol("inp_col_new");
    echo("modified_map <- " + map_obj + "\\n"); echo("dictionary <- " + dict_df + "\\n");
    echo("if(\\"name\\" %in% names(modified_map)) { target_col <- \\"name\\" } else if(\\"NAME_1\\" %in% names(modified_map)) { target_col <- \\"NAME_1\\" } else { target_col <- \\"NAME_2\\" }\\n");
    echo("indices <- match(modified_map[[target_col]], dictionary[[\\"" + col_old + "\\"]])\\n");
    echo("valid_matches <- !is.na(indices)\\n");
    echo("modified_map[[target_col]][valid_matches] <- as.character(dictionary[[\\"" + col_new + "\\"]][indices[valid_matches]])\\n");
  ')
  js_print_recode <- 'echo("rk.header(\\"Map Object Recoded\\")\\n");'
  comp_recode <- rk.plugin.component("Recode Map Regions", xml = list(dialog = dialog_recode), js = list(require=c("sf", "dplyr"), calculate=js_calc_recode, printout=js_print_recode), hierarchy = list("plots", "Maps"))

  # =========================================================================================
  # 8. COMPONENT: Transform Map Projection
  # =========================================================================================
  var_sel_trans <- rk.XML.varselector(id.name = "v_sel_trans")
  inp_map_obj_trans <- rk.XML.varslot(label = "Map Object (sf)", source = "v_sel_trans", required = TRUE, id.name = "inp_map_obj", classes = "sf")
  drp_crs <- rk.XML.dropdown(label = "Target Projection (CRS)", id.name = "drp_crs", options = list("Google/Web Mercator (3857)" = list(val = "3857", chk = TRUE), "Mexico ITRF2008 / LCC (6362)" = list(val = "6362"), "WGS 84 (4326) - Unprojected" = list(val = "4326"), "Robinson (World)" = list(val = "ESRI:54030"), "US National Atlas (2163)" = list(val = "2163")))
  inp_custom_crs <- rk.XML.input(label = "Or custom EPSG Code (e.g. 6362)", id.name = "inp_custom_crs", required = FALSE)
  save_trans_map <- rk.XML.saveobj(label = "Save Transformed Map As", initial = "map_projected", id.name = "save_trans_map", chk = TRUE)
  dialog_trans <- rk.XML.dialog(label = "Transform Map Projection", child = rk.XML.row(var_sel_trans, rk.XML.col(rk.XML.text("Projects the map to a specific Coordinate Reference System (CRS)."), inp_map_obj_trans, rk.XML.frame(label = "Projection Settings", drp_crs, inp_custom_crs), rk.XML.stretch(), save_trans_map)))
  js_calc_trans <- '
    var map_obj = getValue("inp_map_obj"); var crs = getValue("drp_crs"); var custom = getValue("inp_custom_crs");
    if (custom && custom !== "") { crs = custom; }
    var crs_val = (isNaN(crs)) ? "\\"" + crs + "\\"" : crs;
    echo("map_projected <- sf::st_transform(" + map_obj + ", crs = " + crs_val + ")\\n");
  '
  js_print_trans <- 'echo("rk.header(\\"Map Transformation Successful\\")\\n");'
  comp_transform <- rk.plugin.component("Transform Map Projection", xml = list(dialog = dialog_trans), js = list(require=c("sf"), calculate=js_calc_trans, printout=js_print_trans), hierarchy = list("plots", "Maps"))

  # =========================================================================================
  # 9. Assembly
  # =========================================================================================

  rk.plugin.skeleton(
    about = package_about,
    path = ".",
    xml = list(dialog = dialog_downloader),
    js = list(
        require = c("rnaturalearth", "sf"),
        calculate = js_calc_down,
        printout = js_print_down
    ),
    components = list(comp_plotter_cont, comp_plotter_cat, comp_names, comp_recode, comp_transform),
    pluginmap = list(
        name = "Download Map Object",
        hierarchy = list("plots", "Maps")
    ),
    create = c("pmap", "xml", "js", "desc", "rkh"),
    load = TRUE, overwrite = TRUE, show = FALSE
  )

  cat("\nPlugin 'rk.rnaturalearth' (v0.1.4) generated successfully.\n")
})
