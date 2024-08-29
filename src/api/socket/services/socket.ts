import { Core } from "@strapi/strapi";

export default ({ strapi }: { strapi: Core.Strapi }) => ({
  initialize() {
    strapi.eventHub.on('socket.ready', async () => {
      const io = (strapi as any).io;
      if (!io) {
        strapi.log.error("Socket.IO is not initialized");
        return;
      }

      io.on("connection", (socket: any) => {
        strapi.log.info(`New client connected with id ${socket.id}`);

        socket.on("disconnect", () => {
          strapi.log.info(`Client disconnected with id ${socket.id}`);
        });
      });

      strapi.log.info("Socket service initialized successfully");
    });
  },

  emit(event: string, data: any) {
    const io = (strapi as any).io;
    if (io) {
      io.emit(event, data);
    } else {
      strapi.log.warn("Attempted to emit event before Socket.IO was ready");
    }
  },
});