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
    if (!confirm('Are you sure you want to accept this request?')) return;
    
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
        alert('Request accepted successfully! Overlapping requests were automatically rejected.');
      } else {
        alert(`Error: ${data.errors?.join(', ') || 'Failed to accept request'}`);
      }
    } catch (err) {
      alert('Error accepting request');
    } finally {
      setActionLoading(prev => ({ ...prev, [requestId]: null }));
    }
  };

  const handleReject = async (requestId) => {
    if (!confirm('Are you sure you want to reject this request?')) return;
    
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
        alert('Request rejected');
      } else {
        alert(`Error: ${data.errors?.join(', ') || 'Failed to reject request'}`);
      }
    } catch (err) {
      alert('Error rejecting request');
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
      <div className="min-h-screen bg-gray-100 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-emerald-500 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading requests...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gray-100 flex items-center justify-center">
        <div className="bg-white rounded-lg shadow-sm p-8 max-w-md">
          <svg className="mx-auto h-12 w-12 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
          </svg>
          <h3 className="mt-4 text-lg font-medium text-gray-900 text-center">Error</h3>
          <p className="mt-2 text-gray-500 text-center">{error}</p>
          <button 
            onClick={fetchPendingRequests}
            className="mt-4 w-full px-4 py-2 bg-gradient-to-r from-emerald-400 to-teal-500 text-white rounded-lg hover:from-emerald-500 hover:to-teal-600"
          >
            Try Again
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-100">
      <div className="bg-white border-b border-gray-200">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-2xl font-bold text-gray-900">Pending Requests</h1>
              <p className="mt-1 text-sm text-gray-500">Accept or reject new pending requests</p>
            </div>
            <div className="flex items-center gap-3">
              <a 
                href="/"
                className="p-2 text-gray-400 hover:text-gray-600 transition"
                title="Back to search"
              >
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 19l-7-7 7-7"/>
                </svg>
              </a>
              <button 
                onClick={fetchPendingRequests}
                className="p-2 text-gray-400 hover:text-gray-600 transition"
                title="Refresh"
              >
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
                </svg>
              </button>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {requests.length === 0 ? (
          <div className="bg-white rounded-lg shadow-sm p-12 text-center">
            <svg className="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
            </svg>
            <h3 className="mt-4 text-lg font-medium text-gray-900">No pending requests</h3>
            <p className="mt-2 text-gray-500">You have no appointment requests awaiting approval</p>
          </div>
        ) : (
          <div className="space-y-3">
            {requests.map((request) => {
              const isProcessing = actionLoading[request.id];
              
              return (
                <div key={request.id} className="bg-white rounded-lg shadow-sm hover:shadow-md transition">
                  <div className="p-5">
                    <div className="flex items-center gap-4">
                      <div className="flex-shrink-0">
                        <div className="w-14 h-14 bg-gradient-to-br from-emerald-400 to-teal-500 rounded-full flex items-center justify-center shadow-sm">
                          <span className="text-white font-bold text-lg">
                            {request.guest_name.charAt(0).toUpperCase()}
                          </span>
                        </div>
                      </div>
                      
                      <div className="flex-1 min-w-0">
                        <h3 className="text-base font-semibold text-gray-900">{request.guest_name}</h3>
                        <p className="text-sm text-gray-500">{request.service.name}</p>
                        
                        <div className="mt-2 flex items-center gap-4 text-sm text-gray-600">
                          <div className="flex items-center gap-1.5">
                            <svg className="w-4 h-4 text-emerald-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                            </svg>
                            <span>{formatDate(request.desired_date)}</span>
                          </div>
                          
                          <div className="flex items-center gap-1.5">
                            <svg className="w-4 h-4 text-emerald-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
                            </svg>
                            <span>{request.desired_time}</span>
                          </div>
                        </div>
                      </div>
                      
                      <div className="flex-shrink-0 flex items-center gap-2">
                        <button
                          onClick={() => handleAccept(request.id)}
                          disabled={isProcessing}
                          className={`px-5 py-2 bg-gradient-to-r from-emerald-400 to-teal-500 text-white font-medium rounded-lg hover:from-emerald-500 hover:to-teal-600 transition shadow-sm text-sm ${isProcessing ? 'opacity-50 cursor-not-allowed' : ''}`}
                        >
                          {isProcessing === 'accepting' ? 'Accepting...' : 'Accept'}
                        </button>
                        
                        <button
                          onClick={() => handleReject(request.id)}
                          disabled={isProcessing}
                          className={`p-2 text-gray-400 hover:text-red-600 transition ${isProcessing ? 'opacity-50 cursor-not-allowed' : ''}`}
                          title="Reject"
                        >
                          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12"/>
                          </svg>
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
