import '@testing-library/jest-dom';

// Mock fetch globally
global.fetch = jest.fn();

// Mock CSRF token
Object.defineProperty(document, 'querySelector', {
  writable: true,
  value: jest.fn((selector) => {
    if (selector === '[name="csrf-token"]') {
      return { content: 'mock-csrf-token' };
    }
    return null;
  }),
});
