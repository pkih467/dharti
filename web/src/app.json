import React, {useState} from 'react';
import MapView from './components/MapView';
import Sidebar from './components/Sidebar';
import './styles.css';

function App(){
  const [activeIndicator, setActiveIndicator] = useState({domain:'demographics', indicator:'per_capita_consumption', year:2024});
  const [selectedRegion, setSelectedRegion] = useState(null);

  return (
    <div className="app-root">
      <Sidebar activeIndicator={activeIndicator} setActiveIndicator={setActiveIndicator} />
      <MapView activeIndicator={activeIndicator} selectedRegion={selectedRegion} setSelectedRegion={setSelectedRegion} />
    </div>
  );
}

export default App;
