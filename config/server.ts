export default ({ env }) => ({
  host: env('HOST', '0.0.0.0'),
  port: env.int('PORT', 1347),
  app: {
    keys: env.array('APP_KEYS'),
  },
  cors: {
    origin: ['*'],
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS', 'HEAD'],
    headers: ['Content-Type', 'Authorization', 'Origin', 'Accept'],
    keepHeaderOnError: true,
  },
  // io: {
  //   enabled: true,
  //   sockets: {
  //     cors: {
  //       origin: "*",
  //     },
  //   },
  // },
});
