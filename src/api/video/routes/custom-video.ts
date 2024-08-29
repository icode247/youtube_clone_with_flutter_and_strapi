export default {
    routes: [
      {
        method: 'PUT',
        path: '/videos/:id/like',
        handler: 'api::video.video.like',
        config: {
          policies: [],
          middlewares: [],
        },
      },
      {
        method: 'PUT',
        path: '/videos/:id/increment-view',
        handler: 'api::video.video.incrementView',
        config: {
          policies: [],
          middlewares: [],
        },
      },
      {
        method: 'PUT',
        path: '/videos/:id/subscribe',
        handler: 'api::video.video.subscribe',
        config: {
          policies: [],
          middlewares: [],
        },
      },
    ],
  };
  