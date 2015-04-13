// LABEL.MSS CONTENTS:
// - Ocean & Marine Labels
// - Place Names
//     - Countries
//     - States
//     - Cities
//     - Towns
//     - Villages
//     - Suburbs
//     - Neighbourhoods & Hamlets
// - Water Labels 
// - Road Labels
// - House numbers

// Name field to use. Language options:
// name (local), name_en, name_fr, name_es, name_de
@name: '[name]';

// set up font sets for various weights and styles
@sans_lt:           "Open Sans Regular","Arial Unicode MS Regular";
@sans_lt_italic:    "Open Sans Italic","Arial Unicode MS Regular";
@sans:              "Open Sans Semibold","Arial Unicode MS Regular";
@sans_bold:         "Open Sans Bold","Arial Unicode MS Regular";
@sans_italic:       "Open Sans Semibold Italic","Arial Unicode MS Regular";
@sans_bold_italic:  "Open Sans Bold Italic","Arial Unicode MS Regular";

// We set up a default halo color for places so you can edit them all
// at once or override each individually:
@place_halo:        fadeout(#fff,80);
@country_text:      @land * 0.2;
@country_halo:      @place_halo;
@state_text:        #666;
@state_halo:        @place_halo;
@city_text:         #4a4032;
@city_halo:         @place_halo;
@town_text:         lighten(#4a4032,10);
@town_halo:         @place_halo;
@poi_text:          @poi_text;  
@road_text:         #4a4032;
@road_halo:         #fff;
@other_text:        lighten(#4a4032,20);
@other_halo:        @place_halo;
@locality_text:     #aaa;
@locality_halo:     @land;
// Also used for other small places: hamlets, suburbs, localities:
@village_text:      #888;
@village_halo:      @place_halo;
@transport_text:    #445;


// =====================================================================
// OCEAN & MARINE LABELS
// =====================================================================

#marine_label {
  text-name: @name;
  text-face-name: @sans_lt_italic;
  text-fill: mix(@water_dark,@water,25);
  text-wrap-width: 80;
  text-wrap-before: true;
  [placement='point'] {
    text-placement: point;
  }
  [placement='line'] {
    text-placement: line;
    text-avoid-edges: true;
  }
  [labelrank=1] {
    [zoom=3] {
      text-size: 20;
      text-character-spacing: 8;
      text-line-spacing: 16;
    }
    [zoom=4] {
      text-size: 25;
      text-character-spacing: 16;
      text-line-spacing: 24;
    }
    [zoom=5] {
      text-size: 30;
      text-character-spacing: 20;
      text-line-spacing: 32;
    }
  }
  [labelrank=2] {
    [zoom=3] {
      text-size: 13;
      text-character-spacing: 1;
      text-line-spacing: 6;
    }
    [zoom=4] {
      text-size: 14;
      text-character-spacing: 2;
      text-line-spacing: 8;
    }
    [zoom=5] {
      text-size: 20;
      text-character-spacing: 4;
      text-line-spacing: 8;
    }
    [zoom=6] {
      text-size: 24;
      text-character-spacing: 5;
      text-line-spacing: 10;
    }
  }
  [labelrank=3] {
    [zoom=3] {
      text-size: 12;
      text-character-spacing: 2;
      text-line-spacing: 3;
    }
    [zoom=4] {
      text-size: 13;
      text-character-spacing: 3;
      text-line-spacing: 8;
    }
    [zoom=5] {
      text-size: 15;
      text-character-spacing: 4;
      text-line-spacing: 8;
    }
    [zoom=6] {
      text-size: 18;
      text-character-spacing: 5;
      text-line-spacing: 10;
    }
  }
  [labelrank=4][zoom=4],
  [labelrank=5][zoom=5],
  [labelrank=6][zoom=6] {
    text-size: 12;
    text-character-spacing: 2;
    text-line-spacing: 6;
  }
  [labelrank=4][zoom=5],
  [labelrank=5][zoom=6],
  [labelrank=6][zoom=7] {
    text-size: 14;
    text-character-spacing: 3;
    text-line-spacing: 8;
  }
  [labelrank=4][zoom=6],
  [labelrank=5][zoom=7] {
    text-size: 16;
    text-character-spacing: 4;
    text-line-spacing: 1;
  }
}


// =====================================================================
// PLACE NAMES
// =====================================================================

// Countries ___________________________________________________________

#country_label_line {
  line-color: #fff;
  line-opacity: 0.8;
  line-width: 0.8;
  line-dasharray: 5,2;
}

#country_label[zoom<=10] {
  text-name: @name;
  text-face-name: @sans_bold;
  text-placement: point;
  [zoom=2] { text-opacity:.75; }
  text-size: 10;
  text-fill: @country_text;
  text-halo-fill: @country_halo;
  text-halo-radius: 1;
  text-halo-rasterizer: fast;
  text-wrap-width: 30;
  text-min-distance: 2;
  [scalerank=1] {
    [zoom=2]  { text-size: 12; text-wrap-width: 60; }
    [zoom=3]  { text-size: 13; text-wrap-width: 60; }
    [zoom=4]  { text-size: 14; text-wrap-width: 90; }
    [zoom=5]  { text-size: 20; text-wrap-width: 120; }
    [zoom>=6] { text-size: 20; text-wrap-width: 120; }
  }
  [scalerank=2] {
    [zoom=3]  { text-size: 12; }
    [zoom=4]  { text-size: 13; }
    [zoom=5]  { text-size: 17; }
    [zoom>=6] { text-size: 20; }
  }
  [scalerank=3] {
    [zoom=4]  { text-size: 11; }
    [zoom=5]  { text-size: 15; }
    [zoom=6]  { text-size: 17; }
    [zoom=7]  { text-size: 18; text-wrap-width: 60; }
    [zoom>=8] { text-size: 20; text-wrap-width: 120; }
  }
  [scalerank=4] {
    [zoom=5] { text-size: 13; }
    [zoom=6] { text-size: 15; text-wrap-width: 60  }
    [zoom=7] { text-size: 16; text-wrap-width: 90; }
    [zoom=8] { text-size: 18; text-wrap-width: 120; }
    [zoom>=9] { text-size: 20; text-wrap-width: 120; }
  }
  [scalerank=5] {
    [zoom=5] { text-size: 12; }
    [zoom=6] { text-size: 13; }
    [zoom=7] { text-size: 14; text-wrap-width: 60; }
    [zoom=8] { text-size: 16; text-wrap-width: 90; }
    [zoom>=9] { text-size: 18; text-wrap-width: 120; }
  }
  [scalerank>=6] {
    [zoom=6] { text-size: 11; }
    [zoom=7] { text-size: 12; }
    [zoom=8] { text-size: 14; }
    [zoom>=9] { text-size: 16; }
  }
}


// States ______________________________________________________________

#state_label[zoom>=4][zoom<=10] {
  text-name: @name;
  text-face-name: @sans_lt;
  text-placement: point;
  text-fill: @state_text;
  text-halo-fill: fadeout(@land,80);
  text-halo-radius: 2;
  text-halo-rasterizer: fast;
  text-min-distance: 1;
  text-size: 10;
  [zoom>=5][zoom<=6] {
    [area>10000] { text-size: 12; }
    [area>50000] { text-size: 14; }
    text-wrap-width: 40;
  }
  [zoom>=7][zoom<=8] {
    text-size: 14;
    [area>50000] { text-size: 16; text-character-spacing: 1; }
    [area>100000] { text-size: 18; text-character-spacing: 3; }
    text-wrap-width: 60;
  }
  [zoom>=9][zoom<=10] {
    text-halo-radius: 2;
    text-size: 16;
    text-character-spacing: 2;
    [area>50000] { text-size: 18; text-character-spacing: 2; }
    text-wrap-width: 100;
  }
}

// Cities ______________________________________________________________

// City labels with dots for low zoom levels.
#place_label::citydots[type='city'][zoom>=4][zoom<=7][localrank<=3] {
  // explicitly defining all the `ldir` values we're going
  // to use shaves a bit off the final project.xml size
  [ldir='N'],[ldir='S'],[ldir='E'],[ldir='W'],
  [ldir='NE'],[ldir='SE'],[ldir='SW'],[ldir='NW'] {
    shield-file: url("img/dot-small.png");
    shield-unlock-image: true;
    shield-name: @name;
    shield-face-name: @sans;
    shield-placement: point;
    shield-fill: @city_text;
    shield-halo-fill: @city_halo;
    shield-halo-radius: 2;
    shield-halo-rasterizer: fast;
    shield-min-distance: 2;
    shield-size: 11;
    [scalerank>=0][scalerank<=1] {
      [zoom=5] { shield-size: 13; }
      [zoom>=6] { shield-size: 14; }
    }
    [scalerank>=2][scalerank<=3] {
      [zoom=5] { shield-size: 11; }
      [zoom=6] { shield-size: 12; }
      [zoom=7] { shield-size: 13; }
    }
    [scalerank>=4][scalerank<=5] {
      [zoom=6] { shield-size: 11; }
      [zoom=7] { shield-size: 12; }
    }
    [ldir='E'] { shield-text-dx: 4; }
    [ldir='W'] { shield-text-dx: -4; }
    [ldir='N'] { shield-text-dy: -4; }
    [ldir='S'] { shield-text-dy: 4; }
    [ldir='NE'] { shield-text-dx: 3; shield-text-dy: -3; }
    [ldir='SE'] { shield-text-dx: 3; shield-text-dy: 3; }
    [ldir='SW'] { shield-text-dx: -3; shield-text-dy: 3; }
    [ldir='NW'] { shield-text-dx: -3; shield-text-dy: -3; }
  }
}

// For medium to high zoom levels we do away with the dot
// and center place labels on their point location.
#place_label[type='city'][zoom>=8][zoom<=15][localrank<=3] {
  text-name: @name;
  text-face-name: @sans;
  text-placement: point;
  text-fill: @city_text;
  text-halo-fill: @city_halo;
  text-halo-radius: 2;
  text-halo-rasterizer: fast;
  text-wrap-width: 40;
  text-min-distance: 5;
  text-line-spacing: -4;
  [zoom>=12] { text-halo-radius: 3; }
  // We keep the scalerank filters the same for each zoom level.
  // This is slightly inefficient-looking CartoCSS, but it saves
  // some space in the project.xml
  [zoom=8] {
    text-size: 13;
    text-wrap-width: 60;
    [scalerank>=0][scalerank<=1] { text-size: 18; }
    [scalerank>=2][scalerank<=3] { text-size: 16; }
    [scalerank>=4][scalerank<=5] { text-size: 15; }
    [scalerank>=6] { text-size: 13; }
  }
  [zoom=9] {
    text-size: 14;
    text-wrap-width: 60;
    [scalerank>=0][scalerank<=1] { text-size: 19; }
    [scalerank>=2][scalerank<=3] { text-size: 17; }
    [scalerank>=4][scalerank<=5] { text-size: 16; }
    [scalerank>=6] { text-size: 14; }
  }
  [zoom=10] {
    text-size: 15;
    text-wrap-width: 70;
    [scalerank>=0][scalerank<=1] { text-size: 20; }
    [scalerank>=2][scalerank<=3] { text-size: 19; }
    [scalerank>=4][scalerank<=5] { text-size: 17; }
    [scalerank>=6] { text-size: 15; }
  }
  [zoom=11] {
    text-size: 16;
    text-wrap-width: 80;
    [scalerank>=0][scalerank<=1] { text-size: 20; }
    [scalerank>=2][scalerank<=3] { text-size: 19; }
    [scalerank>=4][scalerank<=5] { text-size: 17; }
    [scalerank>=6] { text-size: 16; }
  }
  [zoom=12] {
    text-size: 17;
    text-wrap-width: 100;
    [scalerank>=0][scalerank<=1] { text-size: 20; }
    [scalerank>=2][scalerank<=3] { text-size: 19; }
    [scalerank>=4][scalerank<=5] { text-size: 18; }
    [scalerank>=6] { text-size: 17; }
  }
  [zoom=13] {
    text-size: 18;
    text-wrap-width: 200;
    [scalerank>=0][scalerank<=1] { text-size: 20; }
    [scalerank>=2][scalerank<=3] { text-size: 19; }
    [scalerank>=4][scalerank<=5] { text-size: 19; }
    [scalerank>=6] { text-size: 17; }
  }
  [zoom=14] {
    text-fill: lighten(@city_text,10);
    text-size: 19;
    text-wrap-width: 300;
    [scalerank>=0][scalerank<=1] { text-size: 20; }
    [scalerank>=2][scalerank<=3] { text-size: 20; }
    [scalerank>=4][scalerank<=5] { text-size: 19; }
    [scalerank>=6] { text-size: 18; }
  }
  [zoom=15] {
    text-fill: lighten(@city_text,10);
    text-size: 20;
    text-wrap-width: 400;
    [scalerank>=0][scalerank<=1] { text-size: 20; }
    [scalerank>=2][scalerank<=3] { text-size: 20; }
    [scalerank>=4][scalerank<=5] { text-size: 20; }
    [scalerank>=6] { text-size: 19; }
  }
}

// Towns _______________________________________________________________

#place_label[type='town'][zoom>=8][zoom<=17] {
  text-name: @name;
  text-face-name: @sans_lt;
  text-placement: point;
  text-fill: @town_text;
  text-halo-fill: @town_halo;
  text-halo-radius: 2;
  text-halo-rasterizer: fast;
  text-wrap-width: 60;
  text-wrap-before: true;
  text-line-spacing: -4;
  text-min-distance: 15;
  [zoom>=13] { text-min-distance: 4; }
  text-size: 12;
  [zoom>=11] { text-size: 14; text-min-distance: 18; }
  [zoom>=12] { text-size: 15; text-wrap-width: 80; }
  [zoom>=13] { text-size: 16; text-wrap-width: 120; }
  [zoom>=14] { text-size: 18; text-wrap-width: 160; text-halo-radius: 3; }
  [zoom>=15] { text-size: 20; text-wrap-width: 200; }
  [zoom>=16] { text-size: 22; text-wrap-width: 240; }
}

// Villages ____________________________________________________________

#place_label[type='village'][zoom>=10][zoom<=17] {
  text-name: @name;
  text-face-name: @sans;
  text-placement: point;
  text-fill: @town_text;
  text-size: 11;
  text-halo-fill: @town_halo;
  text-halo-radius: 2;
  text-halo-rasterizer: fast;
  text-wrap-width: 60;
  text-wrap-before: true;
  text-min-distance: 40;
  text-line-spacing: -4;
  [zoom>=12] { text-size: 12; }
  [zoom>=13] { text-wrap-width: 80; }
  [zoom>=14] { text-size: 14; text-wrap-width: 100; }
  [zoom>=15] { text-size: 16; text-wrap-width: 120; }
  [zoom>=16] { text-size: 18; text-wrap-width: 160; }
  [zoom=17] { text-size: 20; text-wrap-width: 200; }
}

// Suburbs _____________________________________________________________

#place_label[type='suburb'][zoom>=12][zoom<=17] {
  text-name: @name;
  text-face-name: @sans_lt;
  text-placement: point;
  text-fill: @other_text;
  text-size: 11;
  text-halo-fill: @other_halo;
  text-halo-radius: 1.5;
  text-halo-rasterizer: fast;
  text-wrap-width: 60;
  text-wrap-before: true;
  text-min-distance: 4;
  text-line-spacing: -2;
  [zoom=12] { text-min-distance: 30; }
  [zoom>=13] { text-size: 12; text-min-distance: 20; }
  [zoom>=14] { text-size: 13; text-wrap-width: 80; }
  [zoom>=15] { text-size: 14; text-wrap-width: 120; }
  [zoom>=16] { text-size: 16; text-wrap-width: 160; }
  [zoom>=17] { text-size: 20; text-wrap-width: 200; }
}

// Neighbourhoods & Hamlets ____________________________________________

#place_label[zoom>=13][zoom<=18] {
  [type='hamlet'],
  [type='neighbourhood'] {
    text-name: @name;
    text-face-name: @sans_lt;
    text-placement: point;
    text-fill: @other_text;
    text-size: 11;
    text-halo-fill: @other_halo;
    text-halo-radius: 1.5;
    text-halo-rasterizer: fast;
    text-wrap-width: 60;
    text-wrap-before: true;
    text-min-distance: 4;
    text-line-spacing: -2;
    [zoom>=14] { text-size: 12; text-wrap-width: 80; }
    [zoom>=16] { text-size: 14; text-wrap-width: 100; }
    [zoom>=17] { text-size: 16; text-wrap-width: 130; }
    [zoom>=18] { text-size: 18; text-wrap-width: 160; }
  }
}


// =====================================================================
// WATER LABELS
// =====================================================================

#water_label {
  [zoom<=15][area>200000],
  [zoom=16][area>50000],
  [zoom=17][area>10000],
  [zoom>=18][area>0]{
    text-name: @name;
    text-halo-radius: 2;
    text-halo-rasterizer: fast;
    text-size: 11;
    text-wrap-width: 50;
    text-wrap-before: true;
    text-halo-fill: fadeout(#fff,80);
    text-line-spacing: -2;
    text-face-name: @sans_italic;
    text-fill: @water_dark;
  }
  [zoom>=14][area>3200000],
  [zoom>=15][area>800000],
  [zoom>=16][area>200000],
  [zoom>=17][area>50000],
  [zoom>=18][area>10000] {
    text-size: 12;
    text-wrap-width: 75;
  }
  [zoom>=15][area>3200000],
  [zoom>=16][area>800000],
  [zoom>=17][area>200000],
  [zoom>=18][area>50000] {
    text-size: 14;
    text-wrap-width: 100;
  }
  [zoom>=16][area>3200000],
  [zoom>=17][area>800000],
  [zoom>=18][area>200000] {
    text-size: 16;
    text-wrap-width: 125;
  }
  [zoom>=17][area>3200000],
  [zoom>=18][area>800000] {
    text-size: 18;
    text-wrap-width: 150;
  }
}

#waterway_label[type='river'][zoom>=12],
#waterway_label[type='canal'][zoom>=14],
#waterway_label[type='stream'][zoom>=16] {
  text-avoid-edges: true;
  text-name: @name;
  text-face-name: @sans_italic;
  text-fill: @water_dark;
  text-halo-fill: fadeout(#fff,80%);
  text-halo-radius: 1.5;
  text-halo-rasterizer: fast;
  text-placement: line;
  text-min-distance: 400;
  text-size: 10;
  text-character-spacing: 0.25;
  text-dy: -7;
  [type='river'][zoom=14],
  [type='canal'][zoom=16],
  [type='stream'][zoom>=18] {
    text-size: 10;
  }
  [type='river'][zoom=15],
  [type='canal'][zoom>=17] {
    text-size: 11;
  }
  [type='river'][zoom>=16],
  [type='canal'][zoom>=18] {
    text-size: 12;
    text-spacing: 300;
  }
}


// =====================================================================
// ROAD LABELS
// =====================================================================

// highway shield
#road_label[class='motorway'][zoom>=8][reflen>=1][reflen<=6],
#road_label[class='main'][zoom>=8][reflen>=1][reflen<=6] {
  shield-name: "[ref]";
  shield-file: url("img/shield/motorway_sm_[reflen].png");
  shield-size: 9;
  shield-face-name: @sans_bold;
  shield-fill: #fff;
  shield-spacing: 300;
  shield-avoid-edges: true;
  shield-min-padding: 10;
  shield-min-distance: 40;
  [zoom>=12] { shield-min-distance: 80; }
  [zoom>=15] {
    shield-spacing: 400;
    shield-size: 11;
    shield-file: url("img/shield/motorway_sm_[reflen].png");
  }
}

// regular labels
#road_label['mapnik::geometry_type'=2] {
  // The z14 filter is *not* redundant to logic in SQL queries. Because z14
  // includes all data for z14+ via overzooming, the streets included in a
  // z14 vector tile include more features than ideal for optimal performance.
  [class='motorway'][zoom>=12],
  [class='main'][zoom>=12],
  [class='street'][zoom<=14][len>2500],
  [class='street'][zoom>=15],
  [class='street_limited'] {
    text-avoid-edges: true;
    text-name: @name;
    text-placement: line;
    text-face-name: @sans_lt;
    text-fill: @road_text;
    text-size: 11;
    text-halo-fill: fadeout(@land,85);
    text-halo-radius: 2;
    text-halo-rasterizer: fast;
    text-min-distance: 200; // only for labels w/ the same name
    [zoom>=14] { text-size: 12; }
    [zoom>=16] { text-size: 14; }
    [zoom>=18] { text-size: 16; }
    [class='motorway'],
    [class='main'] {
      [zoom>=14] { text-size: 12; }
      [zoom>=16] { text-size: 14; }
      [zoom>=17] { text-size: 16; }
      [zoom>=18] { text-size: 18; }
    }
  }
}

// less prominent labels for service + paths
#road_label[zoom>=14]['mapnik::geometry_type'=2]
[class!='motorway']
[class!='main']
[class!='street']
[class!='street_limited'] {
  text-avoid-edges: true;
  text-name: @name;
  text-placement: line;
  text-face-name: @sans;
  text-fill: #666;
  text-size: 10;
  text-halo-fill: fadeout(@land,60);
  text-halo-radius: 2;
  text-halo-rasterizer: fast;
  text-min-distance: 200; // only for labels with the same name
  [zoom>=16] { text-size: 12; }
  [zoom>=18] { text-size: 14; }
  [class='aerialway'] { text-fill: #765; }
  [type='piste'] { text-fill: lighten(#558,20); }
  [type='piste'][zoom>=15] { text-fill: lighten(#558,10); }
  [type='piste'][zoom>=18] { text-fill: #558; }
}


// =====================================================================
// HOUSE NUMBERS
// =====================================================================

#housenum_label[zoom>=18] {
  text-name: [house_num];
  text-face-name: @sans_italic;
  text-fill: @land * 0.8;
  text-size: 9;
}

/**/