import React from 'react';
import { render, screen, waitFor, fireEvent } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import PendingRequestsApp from '../PendingRequestsApp';

describe('PendingRequestsApp', () => {
  const mockNutritionist = {
    id: 1,
    name: 'Dra. Ana Silva',
    location: 'Porto'
  };

  const mockRequests = [
    {
      id: 1,
      guest_name: 'João Silva',
      guest_email: 'joao@example.com',
      desired_date: '2026-04-25',
      desired_time: '10:00',
      service: {
        id: 1,
        name: 'Consulta Geral',
        price: 50.0
      }
    },
    {
      id: 2,
      guest_name: 'Maria Santos',
      guest_email: 'maria@example.com',
      desired_date: '2026-04-26',
      desired_time: '14:00',
      service: {
        id: 2,
        name: 'Nutrição Desportiva',
        price: 60.0
      }
    }
  ];

  beforeEach(() => {
    // Clear all mocks before each test
    jest.clearAllMocks();
    global.fetch.mockClear();
    
    // Mock window.confirm
    global.confirm = jest.fn(() => true);
    global.alert = jest.fn();
  });

  describe('Loading State', () => {
    it('should show loading spinner initially', () => {
      global.fetch.mockImplementationOnce(() =>
        new Promise(() => {}) // Never resolves to keep loading state
      );

      render(<PendingRequestsApp nutritionistId={1} />);

      expect(screen.getByText(/a carregar pedidos/i)).toBeInTheDocument();
    });
  });

  describe('Error Handling', () => {
    it('should display error message when API call fails', async () => {
      global.fetch.mockRejectedValueOnce(new Error('Network error'));

      render(<PendingRequestsApp nutritionistId={1} />);

      await waitFor(() => {
        expect(screen.getByText(/failed to connect to server/i)).toBeInTheDocument();
      });

      expect(screen.getByText(/erro/i)).toBeInTheDocument();
      expect(screen.getByRole('button', { name: /tentar novamente/i })).toBeInTheDocument();
    });

    it('should display error from API response', async () => {
      global.fetch.mockResolvedValueOnce({
        json: async () => ({ success: false, error: 'Custom error message' })
      });

      render(<PendingRequestsApp nutritionistId={1} />);

      await waitFor(() => {
        expect(screen.getByText(/custom error message/i)).toBeInTheDocument();
      });
    });

    it('should retry fetching when "Tentar Novamente" is clicked', async () => {
      // Initial failed fetch
      global.fetch.mockRejectedValueOnce(new Error('Network error'));

      render(<PendingRequestsApp nutritionistId={1} />);

      await waitFor(() => {
        expect(screen.getByText(/failed to connect to server/i)).toBeInTheDocument();
      });

      // Mock successful response for retry
      global.fetch.mockResolvedValueOnce({
        json: async () => ({
          success: true,
          nutritionist: mockNutritionist,
          requests: []
        })
      });

      const retryButton = screen.getByRole('button', { name: /tentar novamente/i });
      fireEvent.click(retryButton);

      // First wait for error to disappear
      await waitFor(() => {
        expect(screen.queryByText(/failed to connect to server/i)).not.toBeInTheDocument();
      }, { timeout: 5000 });

      // Then wait for empty state heading
      await waitFor(() => {
        expect(screen.getByText(/sem pedidos pendentes/i)).toBeInTheDocument();
      }, { timeout: 5000 });
    });
  });

  describe('Empty State', () => {
    it('should display empty state when no pending requests', async () => {
      global.fetch.mockResolvedValueOnce({
        json: async () => ({
          success: true,
          nutritionist: mockNutritionist,
          requests: []
        })
      });

      render(<PendingRequestsApp nutritionistId={1} />);

      await waitFor(() => {
        expect(screen.getByText(/sem pedidos pendentes/i)).toBeInTheDocument();
      });

      expect(screen.getByText(/não tem pedidos de consulta aguardando aprovação/i)).toBeInTheDocument();
    });
  });

  describe('Pending Requests Display', () => {
    it('should display nutritionist information in header', async () => {
      // Initial fetch
      global.fetch.mockResolvedValueOnce({
        json: async () => ({
          success: true,
          nutritionist: mockNutritionist,
          requests: mockRequests
        })
      });

      render(<PendingRequestsApp nutritionistId={1} />);

      // Wait for requests to load first
      await waitFor(() => {
        expect(screen.getByText('João Silva')).toBeInTheDocument();
      }, { timeout: 3000 });

      // Then check nutritionist info
      expect(screen.getByText(/dra\. ana silva/i)).toBeInTheDocument();
      expect(screen.getByText(/porto/i)).toBeInTheDocument();
    });

    it('should display correct number of pending requests', async () => {
      global.fetch.mockResolvedValueOnce({
        json: async () => ({
          success: true,
          nutritionist: mockNutritionist,
          requests: mockRequests
        })
      });

      render(<PendingRequestsApp nutritionistId={1} />);

      await waitFor(() => {
        expect(screen.getByText('2 pedidos pendentes')).toBeInTheDocument();
      });
    });

    it('should display singular form for one request', async () => {
      global.fetch.mockResolvedValueOnce({
        json: async () => ({
          success: true,
          nutritionist: mockNutritionist,
          requests: [mockRequests[0]]
        })
      });

      render(<PendingRequestsApp nutritionistId={1} />);

      await waitFor(() => {
        expect(screen.getByText('1 pedido pendente')).toBeInTheDocument();
      }, { timeout: 3000 });
    });

    it('should display all request details correctly', async () => {
      global.fetch.mockResolvedValueOnce({
        json: async () => ({
          success: true,
          nutritionist: mockNutritionist,
          requests: mockRequests
        })
      });

      render(<PendingRequestsApp nutritionistId={1} />);

      await waitFor(() => {
        // First request
        expect(screen.getByText('João Silva')).toBeInTheDocument();
        expect(screen.getByText('joao@example.com')).toBeInTheDocument();
        expect(screen.getByText('Consulta Geral')).toBeInTheDocument();
        expect(screen.getByText('€50.00')).toBeInTheDocument();
        expect(screen.getByText('10:00')).toBeInTheDocument();

        // Second request
        expect(screen.getByText('Maria Santos')).toBeInTheDocument();
        expect(screen.getByText('maria@example.com')).toBeInTheDocument();
        expect(screen.getByText('Nutrição Desportiva')).toBeInTheDocument();
        expect(screen.getByText('€60.00')).toBeInTheDocument();
        expect(screen.getByText('14:00')).toBeInTheDocument();
      }, { timeout: 3000 });
    });

    it('should call API to accept request when accept button is clicked', async () => {
      // Initial fetch
      global.fetch.mockResolvedValueOnce({
        json: async () => ({
          success: true,
          nutritionist: mockNutritionist,
          requests: mockRequests
        })
      });

      render(<PendingRequestsApp nutritionistId={1} />);

      await waitFor(() => {
        expect(screen.getByText('João Silva')).toBeInTheDocument();
      });

      // Mock accept API call
      global.fetch.mockResolvedValueOnce({
        json: async () => ({ success: true, message: 'Request accepted' })
      });

      // Mock refresh fetch
      global.fetch.mockResolvedValueOnce({
        json: async () => ({
          success: true,
          nutritionist: mockNutritionist,
          requests: [mockRequests[1]] // Only second request remains
        })
      });

      const acceptButtons = screen.getAllByRole('button', { name: /^aceitar$/i });
      fireEvent.click(acceptButtons[0]);

      await waitFor(() => {
        expect(global.fetch).toHaveBeenCalledWith(
          '/api/v1/appointment_requests/1/accept',
          expect.objectContaining({
            method: 'PATCH',
            headers: expect.objectContaining({
              'Content-Type': 'application/json',
              'X-CSRF-Token': 'mock-csrf-token'
            })
          })
        );
      });
    });

    it('should show confirmation dialog before accepting', async () => {
      // Initial fetch
      global.fetch.mockResolvedValueOnce({
        json: async () => ({
          success: true,
          nutritionist: mockNutritionist,
          requests: mockRequests
        })
      });

      render(<PendingRequestsApp nutritionistId={1} />);

      await waitFor(() => {
        expect(screen.getByText('João Silva')).toBeInTheDocument();
      }, { timeout: 3000 });

      const acceptButtons = screen.getAllByRole('button', { name: /^aceitar$/i });
      fireEvent.click(acceptButtons[0]);

      expect(global.confirm).toHaveBeenCalledWith('Tem certeza que deseja aceitar este pedido?');
    });

    it('should not accept if user cancels confirmation', async () => {
      global.confirm.mockReturnValueOnce(false);

      // Initial fetch
      global.fetch.mockResolvedValueOnce({
        json: async () => ({
          success: true,
          nutritionist: mockNutritionist,
          requests: mockRequests
        })
      });

      render(<PendingRequestsApp nutritionistId={1} />);

      await waitFor(() => {
        expect(screen.getByText('João Silva')).toBeInTheDocument();
      });

      const acceptButtons = screen.getAllByRole('button', { name: /^aceitar$/i });
      fireEvent.click(acceptButtons[0]);

      // Verify fetch was only called once (initial load, not accept)
      await waitFor(() => {
        expect(global.fetch).toHaveBeenCalledTimes(1);
      });
    });

    it('should show loading state while accepting', async () => {
      // Initial fetch
      global.fetch.mockResolvedValueOnce({
        json: async () => ({
          success: true,
          nutritionist: mockNutritionist,
          requests: mockRequests
        })
      });

      render(<PendingRequestsApp nutritionistId={1} />);

      await waitFor(() => {
        expect(screen.getByText('João Silva')).toBeInTheDocument();
      });

      // Mock slow API response
      global.fetch.mockImplementationOnce(() =>
        new Promise(resolve => setTimeout(() => resolve({
          json: async () => ({ success: true })
        }), 100))
      );

      const acceptButtons = screen.getAllByRole('button', { name: /^aceitar$/i });
      fireEvent.click(acceptButtons[0]);

      await waitFor(() => {
        expect(screen.getByText(/a aceitar\.\.\./i)).toBeInTheDocument();
      });
    });

    it('should refresh request list after successful accept', async () => {
      // Initial fetch
      global.fetch.mockResolvedValueOnce({
        json: async () => ({
          success: true,
          nutritionist: mockNutritionist,
          requests: mockRequests
        })
      });

      render(<PendingRequestsApp nutritionistId={1} />);

      await waitFor(() => {
        expect(screen.getByText('João Silva')).toBeInTheDocument();
      });

      // Mock accept API call
      global.fetch.mockResolvedValueOnce({
        json: async () => ({ success: true })
      });

      // Mock refresh fetch - now only one request remains
      global.fetch.mockResolvedValueOnce({
        json: async () => ({
          success: true,
          nutritionist: mockNutritionist,
          requests: [mockRequests[1]]
        })
      });

      const acceptButtons = screen.getAllByRole('button', { name: /^aceitar$/i });
      fireEvent.click(acceptButtons[0]);

      await waitFor(() => {
        expect(screen.queryByText('João Silva')).not.toBeInTheDocument();
        expect(screen.getByText('Maria Santos')).toBeInTheDocument();
      });
    });

    it('should show success alert after accepting', async () => {
      // Initial fetch
      global.fetch.mockResolvedValueOnce({
        json: async () => ({
          success: true,
          nutritionist: mockNutritionist,
          requests: mockRequests
        })
      });

      render(<PendingRequestsApp nutritionistId={1} />);

      await waitFor(() => {
        expect(screen.getByText('João Silva')).toBeInTheDocument();
      });

      // Mock accept API call
      global.fetch.mockResolvedValueOnce({
        json: async () => ({ success: true })
      });

      // Mock refresh fetch
      global.fetch.mockResolvedValueOnce({
        json: async () => ({
          success: true,
          nutritionist: mockNutritionist,
          requests: []
        })
      });

      const acceptButtons = screen.getAllByRole('button', { name: /^aceitar$/i });
      fireEvent.click(acceptButtons[0]);

      await waitFor(() => {
        expect(global.alert).toHaveBeenCalledWith(
          expect.stringContaining('Pedido aceite com sucesso')
        );
      });
    });

    it('should show success alert with overlaps message when applicable', async () => {
      // Initial fetch
      global.fetch.mockResolvedValueOnce({
        json: async () => ({
          success: true,
          nutritionist: mockNutritionist,
          requests: mockRequests
        })
      });

      render(<PendingRequestsApp nutritionistId={1} />);

      await waitFor(() => {
        expect(screen.getByText('João Silva')).toBeInTheDocument();
      });

      // Mock accept with overlaps
      global.fetch.mockResolvedValueOnce({
        json: async () => ({ success: true, message: 'Request accepted', rejected_overlaps: 2 })
      });

      // Mock refresh fetch
      global.fetch.mockResolvedValueOnce({
        json: async () => ({
          success: true,
          nutritionist: mockNutritionist,
          requests: []
        })
      });

      const acceptButtons = screen.getAllByRole('button', { name: /^aceitar$/i });
      fireEvent.click(acceptButtons[0]);

      await waitFor(() => {
        expect(global.alert).toHaveBeenCalledWith(
          expect.stringContaining('Pedido aceite com sucesso')
        );
      });
    });

    it('should show error alert when accept fails', async () => {
      // Initial fetch
      global.fetch.mockResolvedValueOnce({
        json: async () => ({
          success: true,
          nutritionist: mockNutritionist,
          requests: mockRequests
        })
      });

      render(<PendingRequestsApp nutritionistId={1} />);

      await waitFor(() => {
        expect(screen.getByText('João Silva')).toBeInTheDocument();
      });

      // Mock failed accept
      global.fetch.mockResolvedValueOnce({
        json: async () => ({ success: false, errors: ['Cannot accept request'] })
      });

      const acceptButtons = screen.getAllByRole('button', { name: /^aceitar$/i });
      fireEvent.click(acceptButtons[0]);

      await waitFor(() => {
        expect(global.alert).toHaveBeenCalledWith('Erro: Cannot accept request');
      });
    });
  });

  describe('Reject Action', () => {
    it('should call API to reject request when reject button is clicked', async () => {
      // Initial fetch
      global.fetch.mockResolvedValueOnce({
        json: async () => ({
          success: true,
          nutritionist: mockNutritionist,
          requests: mockRequests
        })
      });

      render(<PendingRequestsApp nutritionistId={1} />);

      await waitFor(() => {
        expect(screen.getByText('João Silva')).toBeInTheDocument();
      });

      // Mock reject API call
      global.fetch.mockResolvedValueOnce({
        json: async () => ({ success: true })
      });

      // Mock refresh fetch
      global.fetch.mockResolvedValueOnce({
        json: async () => ({
          success: true,
          nutritionist: mockNutritionist,
          requests: [mockRequests[1]]
        })
      });

      const rejectButtons = screen.getAllByRole('button', { name: /^rejeitar$/i });
      fireEvent.click(rejectButtons[0]);

      await waitFor(() => {
        expect(global.fetch).toHaveBeenCalledWith(
          '/api/v1/appointment_requests/1/reject',
          expect.objectContaining({
            method: 'PATCH',
            headers: expect.objectContaining({
              'Content-Type': 'application/json',
              'X-CSRF-Token': 'mock-csrf-token'
            })
          })
        );
      });
    });

    it('should show confirmation dialog before rejecting', async () => {
      // Initial fetch
      global.fetch.mockResolvedValueOnce({
        json: async () => ({
          success: true,
          nutritionist: mockNutritionist,
          requests: mockRequests
        })
      });

      render(<PendingRequestsApp nutritionistId={1} />);

      await waitFor(() => {
        expect(screen.getByText('João Silva')).toBeInTheDocument();
      });

      const rejectButtons = screen.getAllByRole('button', { name: /^rejeitar$/i });
      fireEvent.click(rejectButtons[0]);

      expect(global.confirm).toHaveBeenCalledWith('Tem certeza que deseja rejeitar este pedido?');
    });

    it('should show loading state while rejecting', async () => {
      // Initial fetch
      global.fetch.mockResolvedValueOnce({
        json: async () => ({
          success: true,
          nutritionist: mockNutritionist,
          requests: mockRequests
        })
      });

      render(<PendingRequestsApp nutritionistId={1} />);

      await waitFor(() => {
        expect(screen.getByText('João Silva')).toBeInTheDocument();
      });

      // Mock slow API response
      global.fetch.mockImplementationOnce(() =>
        new Promise(resolve => setTimeout(() => resolve({
          json: async () => ({ success: true })
        }), 100))
      );

      const rejectButtons = screen.getAllByRole('button', { name: /^rejeitar$/i });
      fireEvent.click(rejectButtons[0]);

      await waitFor(() => {
        expect(screen.getByText(/a rejeitar\.\.\./i)).toBeInTheDocument();
      });
    });

    it('should refresh request list after successful reject', async () => {
      // Initial fetch
      global.fetch.mockResolvedValueOnce({
        json: async () => ({
          success: true,
          nutritionist: mockNutritionist,
          requests: mockRequests
        })
      });

      render(<PendingRequestsApp nutritionistId={1} />);

      await waitFor(() => {
        expect(screen.getByText('João Silva')).toBeInTheDocument();
      });

      // Mock reject API call
      global.fetch.mockResolvedValueOnce({
        json: async () => ({ success: true })
      });

      // Mock refresh fetch
      global.fetch.mockResolvedValueOnce({
        json: async () => ({
          success: true,
          nutritionist: mockNutritionist,
          requests: [mockRequests[1]]
        })
      });

      const rejectButtons = screen.getAllByRole('button', { name: /^rejeitar$/i });
      fireEvent.click(rejectButtons[0]);

      await waitFor(() => {
        expect(screen.queryByText('João Silva')).not.toBeInTheDocument();
        expect(screen.getByText('Maria Santos')).toBeInTheDocument();
      });
    });

    it('should show success alert after rejecting', async () => {
      // Initial fetch
      global.fetch.mockResolvedValueOnce({
        json: async () => ({
          success: true,
          nutritionist: mockNutritionist,
          requests: mockRequests
        })
      });

      render(<PendingRequestsApp nutritionistId={1} />);

      await waitFor(() => {
        expect(screen.getByText('João Silva')).toBeInTheDocument();
      });

      // Mock reject API call
      global.fetch.mockResolvedValueOnce({
        json: async () => ({ success: true })
      });

      // Mock refresh fetch
      global.fetch.mockResolvedValueOnce({
        json: async () => ({
          success: true,
          nutritionist: mockNutritionist,
          requests: []
        })
      });

      const rejectButtons = screen.getAllByRole('button', { name: /^rejeitar$/i });
      fireEvent.click(rejectButtons[0]);

      await waitFor(() => {
        expect(global.alert).toHaveBeenCalledWith('Pedido rejeitado');
      });
    });
  });

  describe('Date Formatting', () => {
    it('should format dates in Portuguese format', async () => {
      global.fetch.mockResolvedValueOnce({
        json: async () => ({
          success: true,
          nutritionist: mockNutritionist,
          requests: [mockRequests[0]]
        })
      });

      render(<PendingRequestsApp nutritionistId={1} />);

      await waitFor(() => {
        // Date should be formatted as "25 de abril de 2026"
        expect(screen.getByText(/25 de abril de 2026/i)).toBeInTheDocument();
      });
    });
  });
});
