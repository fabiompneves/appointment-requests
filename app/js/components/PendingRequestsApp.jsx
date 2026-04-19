import React, { useState, useEffect } from 'react';

const PendingRequestsApp = ({ nutritionistId }) => {
  const [loading, setLoading] = useState(true);
  const [nutritionist, setNutritionist] = useState(null);
  const [requests, setRequests] = useState([]);
  const [error, setError] = useState(null);
  const [actionLoading, setActionLoading] = useState({});

  useEffect(() => {
    fetchPendingRequests();
  }, [nutritionistId]);

  const fetchPendingRequests = async () => {
    try {
      setLoading(true);
      const response = await fetch(`/api/v1/nutritionists/${nutritionistId}/pending_requests`);
      const data = await response.json();
      
      if (data.success) {
        setError(null);
        setNutritionist(data.nutritionist);
        setRequests(data.requests);
      } else {
        setError(data.error || 'Failed to load requests');
      }
    } catch (err) {
      setError('Failed to connect to server');
    } finally {
      setLoading(false);
    }
  };

  const handleAccept = async (requestId) => {
    if (!confirm('Tem certeza que deseja aceitar este pedido?')) return;
    
    setActionLoading(prev => ({ ...prev, [requestId]: 'accepting' }));
    
    try {
      const response = await fetch(`/api/v1/appointment_requests/${requestId}/accept`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        }
      });
      
      const data = await response.json();
      
      if (data.success) {
        await fetchPendingRequests();
        alert('Pedido aceite com sucesso! Pedidos sobrepostos foram rejeitados automaticamente.');
      } else {
        alert(`Erro: ${data.errors?.join(', ') || 'Failed to accept request'}`);
      }
    } catch (err) {
      alert('Erro ao aceitar pedido');
    } finally {
      setActionLoading(prev => ({ ...prev, [requestId]: null }));
    }
  };

  const handleReject = async (requestId) => {
    if (!confirm('Tem certeza que deseja rejeitar este pedido?')) return;
    
    setActionLoading(prev => ({ ...prev, [requestId]: 'rejecting' }));
    
    try {
      const response = await fetch(`/api/v1/appointment_requests/${requestId}/reject`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        }
      });
      
      const data = await response.json();
      
      if (data.success) {
        await fetchPendingRequests();
        alert('Pedido rejeitado');
      } else {
        alert(`Erro: ${data.errors?.join(', ') || 'Failed to reject request'}`);
      }
    } catch (err) {
      alert('Erro ao rejeitar pedido');
    } finally {
      setActionLoading(prev => ({ ...prev, [requestId]: null }));
    }
  };

  const formatDate = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('pt-PT', { 
      day: '2-digit', 
      month: 'long', 
      year: 'numeric' 
    });
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">A carregar pedidos...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="bg-white rounded-lg shadow-md p-8 max-w-md">
          <svg className="mx-auto h-12 w-12 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
          </svg>
          <h3 className="mt-4 text-lg font-medium text-gray-900 text-center">Erro</h3>
          <p className="mt-2 text-gray-500 text-center">{error}</p>
          <button 
            onClick={fetchPendingRequests}
            className="mt-4 w-full px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
          >
            Tentar Novamente
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Pedidos Pendentes</h1>
              {nutritionist && (
                <p className="mt-2 text-gray-600">
                  {nutritionist.name} • {nutritionist.location}
                </p>
              )}
            </div>
            <a 
              href="/"
              className="px-4 py-2 text-blue-600 hover:text-blue-800 font-medium"
            >
              ← Voltar à pesquisa
            </a>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {requests.length === 0 ? (
          <div className="bg-white rounded-lg shadow-md p-12 text-center">
            <svg className="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
            </svg>
            <h3 className="mt-4 text-lg font-medium text-gray-900">Sem pedidos pendentes</h3>
            <p className="mt-2 text-gray-500">Não tem pedidos de consulta aguardando aprovação</p>
          </div>
        ) : (
          <div className="space-y-4">
            <p className="text-gray-600">
              {requests.length} {requests.length === 1 ? 'pedido pendente' : 'pedidos pendentes'}
            </p>
            
            {requests.map((request) => {
              const isProcessing = actionLoading[request.id];
              
              return (
                <div key={request.id} className="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition">
                  <div className="p-6">
                    <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                      {/* Request Info */}
                      <div className="flex-1">
                        <div className="flex items-start gap-4">
                          <div className="flex-shrink-0">
                            <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center">
                              <svg className="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                              </svg>
                            </div>
                          </div>
                          
                          <div className="flex-1">
                            <h3 className="text-lg font-semibold text-gray-900">{request.guest_name}</h3>
                            <p className="text-sm text-gray-600">{request.guest_email}</p>
                            
                            <div className="mt-3 space-y-2">
                              <div className="flex items-center text-sm text-gray-700">
                                <svg className="w-5 h-5 mr-2 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                                </svg>
                                <strong className="mr-2">Serviço:</strong>
                                {request.service.name}
                                <span className="ml-2 text-blue-600 font-semibold">
                                  €{request.service.price.toFixed(2)}
                                </span>
                              </div>
                              
                              <div className="flex items-center text-sm text-gray-700">
                                <svg className="w-5 h-5 mr-2 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                                </svg>
                                <strong className="mr-2">Data:</strong>
                                {formatDate(request.desired_date)}
                              </div>
                              
                              <div className="flex items-center text-sm text-gray-700">
                                <svg className="w-5 h-5 mr-2 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
                                </svg>
                                <strong className="mr-2">Hora:</strong>
                                {request.desired_time}
                              </div>
                            </div>
                          </div>
                        </div>
                      </div>
                      
                      {/* Actions */}
                      <div className="flex flex-col gap-2 md:flex-row md:items-center">
                        <button
                          onClick={() => handleAccept(request.id)}
                          disabled={isProcessing}
                          className={`px-6 py-2 bg-green-600 text-white font-medium rounded-lg hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2 transition ${isProcessing ? 'opacity-50 cursor-not-allowed' : ''}`}
                        >
                          {isProcessing === 'accepting' ? 'A aceitar...' : 'Aceitar'}
                        </button>
                        
                        <button
                          onClick={() => handleReject(request.id)}
                          disabled={isProcessing}
                          className={`px-6 py-2 bg-red-600 text-white font-medium rounded-lg hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2 transition ${isProcessing ? 'opacity-50 cursor-not-allowed' : ''}`}
                        >
                          {isProcessing === 'rejecting' ? 'A rejeitar...' : 'Rejeitar'}
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
};

export default PendingRequestsApp;
