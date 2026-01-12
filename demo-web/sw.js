// TheraFlow Service Worker
const CACHE_NAME = 'theraflow-v1';
const urlsToCache = [
  './',
  './index.html',
  './app.html',
  './agenda.html',
  './clientes.html',
  './financeiro.html',
  './perfil.html',
  './onboarding.html',
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
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('TheraFlow: Cache aberto');
        return cache.addAll(urlsToCache);
      })
  );
});

// Fetch - Servir do cache ou rede
self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request)
      .then(response => {
        // Retorna do cache se disponível
        if (response) {
          return response;
        }
        // Caso contrário, busca da rede
        return fetch(event.request);
      }
    )
  );
});

// Ativação - Limpar caches antigos
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
    })
  );
});
