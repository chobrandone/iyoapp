import '@testing-library/jest-dom/vitest';
import { configure } from '@testing-library/react';

// Screens are lazy-loaded chunks; the first import of each takes a moment.
configure({ asyncUtilTimeout: 5000 });

// jsdom has no WebGL, so the map never loads in tests; it shows its placeholder instead.
vi.mock('maplibre-gl', () => {
  throw new Error('no WebGL in tests');
});
vi.mock('maplibre-gl/dist/maplibre-gl.css', () => ({}));
