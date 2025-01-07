// src/index.js
import React from 'react';
import { createRoot } from 'react-dom/client';
import { AptosWalletProvider } from '@razorlabs/wallet-kit';
import App from './App';

const networks = [
  {
    name: 'Movement Porto Testnet',
    chainId: '177',
    rpcUrl: 'https://aptos.testnet.porto.movementlabs.xyz/v1',
  },
  {
    name: '',
    chainId: '',
    rpcUrl: '',
  },
];

const container = document.getElementById('root');
const root = createRoot(container);

root.render(
  <AptosWalletProvider
    networks={networks}
    defaultNetwork="testnet"
  >
    <App />
  </AptosWalletProvider>
);
