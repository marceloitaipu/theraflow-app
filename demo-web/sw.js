// TheraFlow Service Worker
// IMPORTANTE: Altere CACHE_VERSION a cada atualização para forçar refresh
const CACHE_VERSION = '2026-01-13-v5';
const CACHE_NAME = 'theraflow-' + CACHE_VERSION;
const urlsToCache = [
  './',
  './index.html',
  './app.html',
  './agenda.html',
  './clientes.html',
  './financeiro.html',
  './perfil.html',
  './onboarding.html',
  './atualizar.html',
  './styles/common.css',
  './js/data.js',
  './js/ui.js',
  './js/components.js',
  './assets/logo.svg',
  './assets/logo-horizontal.svg',
  './assets/icons/icon.svg'
];

// Instalação do Service Worker
self.addEventListener('install', event => {
  // Força o novo SW a assumir imediatamente
  self.skipWaiting();
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('TheraFlow: Cache atualizado para ' + CACHE_VERSION);
        return cache.addAll(urlsToCache);
      })
  );
});

// Fetch - Network first, fallback to cache
self.addEventListener('fetch', event => {
  event.respondWith(
    fetch(event.request)
      .then(response => {
        // Se conseguiu da rede, atualiza o cache
        if (response.ok) {
          const responseClone = response.clone();
          caches.open(CACHE_NAME).then(cache => {
            cache.put(event.request, responseClone);
          });
        }
        return response;
      })
      .catch(() => {
        // Se falhou (offline), tenta do cache
        return caches.match(event.request);
      })
  );
});

// Ativação - Limpar caches antigos e assumir controle
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheName !== CACHE_NAME) {
            console.log('TheraFlow: Removendo cache antigo', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    }).then(() => {
      // Força o SW a controlar todas as páginas imediatamente
      return self.clients.claim();
    })
  );
});
