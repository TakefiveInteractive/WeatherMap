// =====================================================================
// POINTS OF INTEREST ICONS & LABELS
// =====================================================================

// Airports and rail stations are styled separately from other POIs
// because we use different fields to set their icon images.

#poi_label[type!='Aerodrome'][type!='Rail Station'][type!='hole'] {
  ::icon {
    [zoom<14],
    [zoom>=14][scalerank=1][localrank<=1],
    [zoom>=15][scalerank<=2][localrank<=1],
    [zoom>=16][scalerank<=3][localrank<=1],
    [zoom>=17][localrank<=4],
    [zoom>=18][localrank<=16],
    [zoom>=19] {
      [maki!=null] {
        marker-file: url("img/maki/[maki]-12.svg");
      }
      [maki=null] {
        // small dot for POIs with no Maki icon defined
        marker-width: 4;
        marker-fill: rgba(0,0,0,0);
        marker-line-width: 1.2;
        marker-line-color: #666;
      }
    }
  }
  [zoom<14],
  [zoom>=14][scalerank=1][localrank<=1],
  [zoom>=15][scalerank<=2][localrank<=1],
  [zoom>=16][scalerank<=3][localrank<=1],
  [zoom>=17][localrank<=4],
  [zoom>=18][localrank<=16],
  [zoom>=19] {
    text-name: @name;
    text-face-name: @sans;
    text-fill: #555;
    text-halo-fill: @land;
    text-halo-radius: 1;
    text-halo-rasterizer: fast;
    text-dy: 12;
    text-line-spacing: -4;
    text-wrap-width: 80;
    text-wrap-before: true;
    [scalerank=1] {
      [zoom>=15] { text-size: 11; text-wrap-width: 100; }
      [zoom>=16] { text-size: 12; text-wrap-width: 120; }
      [zoom>=17] { text-size: 14; text-wrap-width: 130; }
    }
    [scalerank=2] {
      [zoom>=16] { text-size: 11; text-wrap-width: 100; }
      [zoom>=17] { text-size: 12; text-wrap-width: 120; }
    }
    [scalerank>=3] {
      [zoom>=17] { text-size: 11; text-wrap-width: 100; }
      [zoom>=19] { text-size: 12; text-wrap-width: 120; }
    }
  }
}

// Rail Stations _______________________________________________________

#poi_label[type='Rail Station'][network!=null][scalerank=1][zoom>=14],
#poi_label[type='Rail Station'][network!=null][scalerank=2][zoom>=15],
#poi_label[type='Rail Station'][network!=null][scalerank=3][zoom>=16] {
  marker-file: url("img/rail/[network]-12.svg");
  marker-height: 12;
  marker-allow-overlap: false;
  [zoom=16] {
    marker-file: url("img/rail/[network]-18.svg");
    marker-height: 18;
  }
  [zoom>16] {
    marker-file: url("img/rail/[network]-12.svg");
    marker-height:24;
  }
  [zoom>15] {
    text-name: @name;
    text-face-name: @sans;
    text-fill: #888;
    text-halo-fill: #fff;
    text-halo-radius: 1.5;
    text-halo-rasterizer: fast;
    text-size: 11;
    text-wrap-width: 80;
    text-placement-type: simple;
    text-dx: 11; text-dy: 11;
    text-placements: "S,N,E,W";
    [zoom>=17] {
      text-size: 12;
      text-halo-radius: 2;
      text-dx: 15; text-dy: 15;
    }
  }
}

// Airports ____________________________________________________________

#poi_label[type='Aerodrome'][zoom>=10] {
  marker-file: url("img/maki/[maki]-12.svg");
  text-name: "''";
  text-size: 10;
  text-fill: #888;
  text-halo-fill: #fff;
  text-halo-radius: 1;
  text-halo-rasterizer: fast;
  text-face-name: @sans;
  text-line-spacing: -2;
  text-dy: 8;
  [zoom>=11][zoom<=13][scalerank=1],
  [zoom>=12][zoom<=13][scalerank=2] {
    text-name: [ref];
  }
  [zoom>=14] {
    text-name: @name;
    text-wrap-before: true;
  }
  [zoom>=11][scalerank=1],
  [zoom>=12][scalerank=2],
  [zoom>=14] {
    marker-file: url("img/maki/[maki]-18.svg");
    text-size: 10;
    text-dy: 12;
    text-wrap-width: 80;
  }
  [zoom>=13][scalerank=1],
  [zoom>=14][scalerank=2],
  [zoom>=15] {
    marker-file: url("img/maki/[maki]-24.svg");
    text-size: 12;
    text-dy: 15;
    text-wrap-width: 100;
  }
  [zoom>=14][scalerank=1],
  [zoom>=15][scalerank=2],
  [zoom>=16] {
    marker-file: url("img/maki/[maki]-24.svg");
    text-size: 14;
    text-dy: 19;
    text-wrap-width: 120;
  }
}

// Golf holes __________________________________________________________

#poi_label[type='hole'][zoom>=16] {
  text-avoid-edges: false;
  text-name: @name;
  text-character-spacing: 0.25;
  text-placement: point;
  text-face-name: @sans;
  text-fill: darken(#cdb,50);
  text-size: 10;
  text-halo-fill: @road_halo;
  text-halo-radius: 1.5;
  text-halo-rasterizer: fast;
  [zoom>=17] { text-size: 12; }
  [zoom>=18] { text-size: 14; }
}

/**/