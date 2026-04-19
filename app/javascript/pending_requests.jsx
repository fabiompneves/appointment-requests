import React from 'react';
import { createRoot } from 'react-dom/client';
import PendingRequestsApp from '../js/components/PendingRequestsApp.jsx';

document.addEventListener('DOMContentLoaded', () => {
  const rootElement = document.getElementById('pending-requests-root');
  
  if (rootElement) {
    const nutritionistId = rootElement.dataset.nutritionistId;
    const root = createRoot(rootElement);
    root.render(<PendingRequestsApp nutritionistId={nutritionistId} />);
  }
});
