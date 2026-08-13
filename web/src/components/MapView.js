import React, {useEffect, useRef} from 'react';
import maplibregl from 'maplibre-gl';
import 'maplibre-gl/dist/maplibre-gl.css';
import axios from 'axios';

const TILEJSON_URL = 'http://localhost:8080/data/india_admins.json'; // adjust to tileserver endpoint

export default function MapView({activeIndicator, selectedRegion, setSelectedRegion}){
  const mapContainer = useRef();
  const mapRef = useRef();

  useEffect(()=>{
    if(mapRef.current) return; // init once
    const map = new maplibregl.Map({
      container: mapContainer.current,
      style: { version: 8, sources: {}, layers: [] }, // we'll add source programmatically
      center: [78.0, 22.0],
      zoom: 4
    });
    mapRef.current = map;

    // Add vector tile source (tileserver-gl TileJSON)
    map.on('load', async () => {
      const tilejson = await axios.get(TILEJSON_URL).then(r=>r.data);
      map.addSource('india_admins', {
        type: 'vector',
        tiles: tilejson.tiles, // e.g. ["http://localhost:8080/data/india_admins/{z}/{x}/{y}.pbf"]
        maxzoom: tilejson.maxzoom || 12
      });

      // Choropleth fill layer (data-driven color via property 'value_q')
      map.addLayer({
        id: 'regions-fill',
        type: 'fill',
        source: 'india_admins',
        'source-layer': 'layer0', // tippecanoe default; adjust as needed
        paint: {
          'fill-color': ['get', 'fill_color'], // precomputed color attribute, or set expression
          'fill-opacity': 0.8
        }
      });

      // Border line (drawn on top)
      map.addLayer({
        id: 'regions-line',
        type: 'line',
        source: 'india_admins',
        'source-layer': 'layer0',
        paint: {
          'line-color': '#ffffff',
          'line-width': 0.5
        }
      });

      // Highlight line for selected region
      map.addLayer({
        id: 'regions-highlight',
        type: 'line',
        source: 'india_admins',
        'source-layer': 'layer0',
        paint: {
          'line-color': '#000000',
          'line-width': 2
        },
        filter: ['==', 'shrid', ''] // empty filter initially
      });

      // click handler
      map.on('click', 'regions-fill', (e) => {
        const props = e.features[0].properties;
        const shrid = props.shrid;
        setSelectedRegion({
          shrid,
          name: props.name,
          indicator_value: props.active_val
        });

        // set highlight filter
        map.setFilter('regions-highlight', ['==', ['get', 'shrid'], shrid]);
        // drop pin: you can add a marker to map at centroid coordinates
      });

      // cursor
      map.on('mouseenter', 'regions-fill', () => map.getCanvas().style.cursor = 'pointer');
      map.on('mouseleave', 'regions-fill', () => map.getCanvas().style.cursor = '');
    });

    return () => map.remove();
  }, [setSelectedRegion]);

  // activeIndicator change: fetch precomputed legend and update styling (not heavy)
  useEffect(()=>{
    if(!mapRef.current) return;
    // fetch precomputed legend/bins from server (indicator_legend table export)
    // then update fill-color expression or rely on 'fill_color' attribute in vector tiles
  }, [activeIndicator]);

  return <div ref={mapContainer} className="map-container" />;
}
