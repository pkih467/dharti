import React from 'react';
import './sidebar.css';
import states from '../data/regions_states.json'; // small local index for quick state jump

export default function Sidebar({activeIndicator, setActiveIndicator}){
  return (
    <aside className="left-sidebar">
      <div className="search-top">
        <input placeholder="Search district or village (shrid/name)..." />
        <select>
          <option value="">Jump to state...</option>
          {states.map(s=> <option key={s.state_code} value={s.state_code}>{s.name}</option>)}
        </select>
      </div>

      <div className="accordion">
        {/* Render 11 domain categories here; expand/collapse each. Example item: */}
        <div className="accordion-section">
          <button className="accordion-toggle">1. Consumption, Wealth & Macro-Economy</button>
          <div className="accordion-panel">
            <button onClick={()=> setActiveIndicator({domain:'economy', indicator:'rwi', year:2024})}>Relative Wealth Index</button>
            <button onClick={()=> setActiveIndicator({domain:'economy', indicator:'mpi', year:2024})}>MPI</button>
            <button onClick={()=> setActiveIndicator({domain:'economy', indicator:'per_capita_consumption', year:2024})}>Per Capita Consumption</button>
          </div>
        </div>

        {/* Repeat for other domains... */}
      </div>
    </aside>
  );
}
