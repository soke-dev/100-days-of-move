// src/App.js
import React, { useState } from 'react';
import {
  AptosConnectButton,
  useAptosWallet,
  addressEllipsis,
} from '@razorlabs/wallet-kit';
import '@razorlabs/wallet-kit/style.css';
import './index.css'; // Your custom CSS

/* 
  1) Sub-component responsible only for 
     - connect button
     - wallet status
     - account address display
*/
function WalletConnectUI() {
  const wallet = useAptosWallet();

  return (
    <div className="card">
      {/* Styled connect button */}
      <AptosConnectButton className="custom-connect-button" />

      <p>
        <strong>Wallet status:</strong> {wallet.status}
      </p>

      {/* If connected, show the address */}
      {wallet.account && (
        <p>
          <strong>Account:</strong> {addressEllipsis(wallet.account.address)}
        </p>
      )}
    </div>
  );
}

/*
  2) Main App component
     - imports the sub-component (WalletConnectUI)
     - handles the signMessage logic
*/
function App() {
  const wallet = useAptosWallet();
  const [signature, setSignature] = useState(null);

  async function signMessage() {
    if (!wallet.connected) {
      alert('Please connect your wallet first!');
      return;
    }

    try {
      const res = await wallet.signMessage({
        message: 'GMOVE',
        nonce: '1234', // Nonce can be any string or number
      });

      console.log('Signed message result:', res);
      setSignature(res.signature);
      alert('Message signed successfully!');
    } catch (error) {
      console.error('Signing message failed:', error);
      alert('Failed to sign message. Check console for details.');
    }
  }

  return (
    <div className="app-container">
      <h1 className="app-title">Movement DApp — Sign a Message</h1>

      {/* 3) Render the sub-component for wallet connection */}
      <WalletConnectUI />

      {/* 4) Show the "Sign Message" card only if wallet is connected */}
      {wallet.status === 'connected' && (
        <div className="card">
          <h2>Sign the Message "GMOVE"</h2>
          <button onClick={signMessage} className="primary-button">
            Sign Message
          </button>
          {signature && (
            <div style={{ marginTop: '1rem' }}>
              <strong>Signature:</strong>
              <p>{signature}</p>
            </div>
          )}
        </div>
      )}
    </div>
  );
}

export default App;
